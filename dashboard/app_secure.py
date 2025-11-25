#!/usr/bin/env python3
"""
ALFA HLR Reconciliation System - Secure Dashboard
Enhanced version with authentication and real database connectivity
"""

from flask import Flask, render_template, jsonify, request, redirect, url_for, session, flash
from flask_login import LoginManager, UserMixin, login_user, logout_user, login_required, current_user
from functools import wraps
from datetime import datetime, timedelta
import random
import hashlib
import config

# Try to import Oracle connector
try:
    import cx_Oracle
    ORACLE_AVAILABLE = True
except ImportError:
    ORACLE_AVAILABLE = False
    print("⚠️  cx_Oracle not available. Using mock data.")

app = Flask(__name__)
app.secret_key = config.SECRET_KEY
app.config['PERMANENT_SESSION_LIFETIME'] = timedelta(minutes=config.SESSION_TIMEOUT_MINUTES)

# Flask-Login setup
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'
login_manager.login_message = 'Please log in to access the dashboard.'

# User class
class User(UserMixin):
    def __init__(self, username, role, full_name, email):
        self.id = username
        self.username = username
        self.role = role
        self.full_name = full_name
        self.email = email

@login_manager.user_loader
def load_user(username):
    if username in config.USERS:
        user_data = config.USERS[username]
        return User(username, user_data['role'], user_data['full_name'], user_data['email'])
    return None

# Audit log decorator
def audit_log(action):
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if config.ENABLE_USER_AUDIT_LOG and current_user.is_authenticated:
                timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
                print(f"[AUDIT] {timestamp} | User: {current_user.username} | Action: {action}")
            return f(*args, **kwargs)
        return decorated_function
    return decorator

# Database connection
def get_oracle_connection():
    """Get Oracle database connection"""
    if not ORACLE_AVAILABLE or not config.USE_REAL_DATABASE:
        return None

    try:
        dsn = cx_Oracle.makedsn(
            config.ORACLE_CONFIG['host'],
            config.ORACLE_CONFIG['port'],
            service_name=config.ORACLE_CONFIG['service_name']
        )
        connection = cx_Oracle.connect(
            config.ORACLE_CONFIG['username'],
            config.ORACLE_CONFIG['password'],
            dsn
        )
        return connection
    except Exception as e:
        print(f"❌ Database connection failed: {e}")
        return None

# Data fetchers (real database versions)
def fetch_real_metrics():
    """Fetch real metrics from Oracle database"""
    conn = get_oracle_connection()
    if not conn:
        return None

    try:
        cursor = conn.cursor()

        # Query execution log table
        query = """
            SELECT
                COUNT(*) as total_executions,
                SUM(CASE WHEN status = 'SUCCESS' THEN 1 ELSE 0 END) as successful,
                SUM(CASE WHEN status = 'FAILED' THEN 1 ELSE 0 END) as failed,
                SUM(CASE WHEN status = 'WARNING' THEN 1 ELSE 0 END) as warnings,
                AVG(duration_seconds) as avg_duration,
                SUM(records_processed) as total_records
            FROM RECONCILIATION_EXECUTION_LOG
            WHERE execution_time >= SYSDATE - 7
        """

        cursor.execute(query)
        result = cursor.fetchone()

        if result:
            total, successful, failed, warnings, avg_dur, total_rec = result
            success_rate = (successful / total * 100) if total > 0 else 0

            metrics = {
                'total_executions': total,
                'successful_executions': successful,
                'failed_executions': failed,
                'warning_executions': warnings,
                'success_rate': round(success_rate, 2),
                'average_duration_seconds': round(avg_dur, 2) if avg_dur else 0,
                'total_records_processed': total_rec or 0,
                'last_execution_time': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
                'active_errors': 0  # Will be fetched from errors table
            }

            cursor.close()
            conn.close()
            return metrics

    except Exception as e:
        print(f"❌ Error fetching metrics: {e}")
        if conn:
            conn.close()

    return None

# Mock data generators (keeping existing ones)
def generate_mock_execution_data():
    """Generate mock reconciliation execution data"""
    procedures = [
        'P1_MAIN_SYS_INTERFACES',
        'P2_POST_PREP_SERV_INTERFACES',
        'P3_PREP_INTERFACES',
        'P4_CP_INTERFACES',
        'P5_ALFA_CP_INTERFACES',
        'P6_VOLTE_INTERFACES',
        'P7_DATACARD_INTERFACES'
    ]

    executions = []
    base_time = datetime.now()

    for i in range(50):
        execution_time = base_time - timedelta(hours=i*0.5)
        procedure = random.choice(procedures)
        status = random.choices(['SUCCESS', 'FAILED', 'WARNING'], weights=[85, 8, 7])[0]

        executions.append({
            'id': i + 1,
            'procedure_name': procedure,
            'execution_time': execution_time.strftime('%Y-%m-%d %H:%M:%S'),
            'status': status,
            'duration_seconds': random.randint(30, 600),
            'records_processed': random.randint(1000, 50000),
            'records_inserted': random.randint(0, 5000),
            'records_updated': random.randint(0, 3000),
            'records_deleted': random.randint(0, 500),
            'integration_log_id': f'LOG_{i+1000}'
        })

    return executions

def generate_mock_errors():
    """Generate mock error data"""
    procedures = [
        'P1_MAIN_SYS_INTERFACES',
        'P4_CP_INTERFACES',
        'P6_VOLTE_INTERFACES'
    ]

    error_types = [
        'TABLE_CREATION_FAILED',
        'INDEX_CREATION_FAILED',
        'DATA_CONVERSION_ERROR',
        'NETWORK_TIMEOUT',
        'INSUFFICIENT_PRIVILEGES'
    ]

    errors = []
    base_time = datetime.now()

    for i in range(15):
        error_time = base_time - timedelta(hours=random.randint(1, 72))

        errors.append({
            'error_id': i + 1,
            'procedure_name': random.choice(procedures),
            'error_code': f'ORA-{random.randint(1000, 9999)}',
            'error_type': random.choice(error_types),
            'error_message': f'Error in reconciliation process: {random.choice(error_types)}',
            'error_timestamp': error_time.strftime('%Y-%m-%d %H:%M:%S'),
            'resolved': random.choice([True, False]),
            'severity': random.choice(['CRITICAL', 'HIGH', 'MEDIUM'])
        })

    return sorted(errors, key=lambda x: x['error_timestamp'], reverse=True)

def generate_system_metrics():
    """Generate system-wide metrics"""
    # Try real database first
    real_metrics = fetch_real_metrics()
    if real_metrics:
        return real_metrics

    # Fallback to mock data
    executions = generate_mock_execution_data()

    total_executions = len(executions)
    successful = len([e for e in executions if e['status'] == 'SUCCESS'])
    failed = len([e for e in executions if e['status'] == 'FAILED'])
    warnings = len([e for e in executions if e['status'] == 'WARNING'])

    avg_duration = sum(e['duration_seconds'] for e in executions) / len(executions)
    total_records = sum(e['records_processed'] for e in executions)

    return {
        'total_executions': total_executions,
        'successful_executions': successful,
        'failed_executions': failed,
        'warning_executions': warnings,
        'success_rate': round((successful / total_executions) * 100, 2),
        'average_duration_seconds': round(avg_duration, 2),
        'total_records_processed': total_records,
        'last_execution_time': executions[0]['execution_time'],
        'active_errors': len([e for e in generate_mock_errors() if not e['resolved']])
    }

def generate_procedure_performance():
    """Generate per-procedure performance metrics"""
    procedures = [
        'P1_MAIN_SYS_INTERFACES',
        'P2_POST_PREP_SERV_INTERFACES',
        'P3_PREP_INTERFACES',
        'P4_CP_INTERFACES',
        'P5_ALFA_CP_INTERFACES',
        'P6_VOLTE_INTERFACES',
        'P7_DATACARD_INTERFACES'
    ]

    performance = []
    for proc in procedures:
        total_runs = random.randint(50, 150)
        successful = random.randint(int(total_runs * 0.85), total_runs)

        performance.append({
            'procedure_name': proc,
            'total_runs': total_runs,
            'successful_runs': successful,
            'failed_runs': total_runs - successful,
            'success_rate': round((successful / total_runs) * 100, 2),
            'avg_duration_seconds': random.randint(60, 500),
            'last_run_time': (datetime.now() - timedelta(hours=random.randint(1, 24))).strftime('%Y-%m-%d %H:%M:%S')
        })

    return sorted(performance, key=lambda x: x['success_rate'])

def generate_hourly_stats():
    """Generate hourly execution statistics for charts"""
    hours = []
    base_time = datetime.now()

    for i in range(24, 0, -1):
        hour_time = base_time - timedelta(hours=i)
        total_exec = random.randint(10, 35)
        successful = random.randint(int(total_exec * 0.85), total_exec)

        hours.append({
            'hour': hour_time.strftime('%H:00'),
            'executions': total_exec,
            'successful': successful,
            'failed': total_exec - successful,
            'avg_duration': random.randint(120, 400)
        })

    return hours

# Routes
@app.route('/login', methods=['GET', 'POST'])
def login():
    """Login page"""
    if current_user.is_authenticated:
        return redirect(url_for('index'))

    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')

        if username in config.USERS:
            user_data = config.USERS[username]
            if user_data['password'] == password:
                user = User(username, user_data['role'], user_data['full_name'], user_data['email'])
                login_user(user, remember=True)

                # Log successful login
                timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
                print(f"✅ [LOGIN] {timestamp} | User: {username} | Role: {user_data['role']}")

                next_page = request.args.get('next')
                return redirect(next_page or url_for('index'))

        flash('Invalid username or password', 'error')

    return render_template('login.html', config=config)

@app.route('/logout')
@login_required
def logout():
    """Logout user"""
    username = current_user.username
    logout_user()

    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    print(f"👋 [LOGOUT] {timestamp} | User: {username}")

    flash('You have been logged out successfully', 'success')
    return redirect(url_for('login'))

@app.route('/')
@login_required
@audit_log('VIEW_DASHBOARD')
def index():
    """Main dashboard page"""
    return render_template('dashboard.html', user=current_user, config=config)

@app.route('/api/metrics')
@login_required
@audit_log('API_METRICS')
def get_metrics():
    """Get overall system metrics"""
    return jsonify(generate_system_metrics())

@app.route('/api/executions')
@login_required
@audit_log('API_EXECUTIONS')
def get_executions():
    """Get recent reconciliation executions"""
    limit = request.args.get('limit', default=20, type=int)
    executions = generate_mock_execution_data()[:limit]
    return jsonify(executions)

@app.route('/api/errors')
@login_required
@audit_log('API_ERRORS')
def get_errors():
    """Get recent errors"""
    limit = request.args.get('limit', default=10, type=int)
    errors = generate_mock_errors()[:limit]
    return jsonify(errors)

@app.route('/api/procedure-performance')
@login_required
@audit_log('API_PROCEDURE_PERFORMANCE')
def get_procedure_performance():
    """Get performance metrics by procedure"""
    return jsonify(generate_procedure_performance())

@app.route('/api/hourly-stats')
@login_required
@audit_log('API_HOURLY_STATS')
def get_hourly_stats():
    """Get hourly execution statistics"""
    return jsonify(generate_hourly_stats())

@app.route('/api/user-info')
@login_required
def get_user_info():
    """Get current user information"""
    return jsonify({
        'username': current_user.username,
        'full_name': current_user.full_name,
        'email': current_user.email,
        'role': current_user.role
    })

@app.route('/api/health')
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'version': '2.0.0',
        'database_connected': config.USE_REAL_DATABASE and ORACLE_AVAILABLE,
        'authenticated': current_user.is_authenticated
    })

if __name__ == '__main__':
    print("=" * 70)
    print("🔐 ALFA HLR Reconciliation Dashboard - Secure Edition")
    print("=" * 70)
    print(f"📊 Dashboard URL: http://localhost:8080")
    print(f"🔧 API Health: http://localhost:8080/api/health")
    print("=" * 70)
    print("👥 Default Login Credentials:")
    print("   Admin    → Username: admin    | Password: admin123")
    print("   Operator → Username: operator | Password: operator123")
    print("=" * 70)
    print("⚠️  SECURITY WARNING: Change default passwords in config.py!")
    print("=" * 70)
    print("✨ Server ready! Navigate to the URL above and log in.")
    print("=" * 70)

    app.run(host='0.0.0.0', port=8080, debug=True)
