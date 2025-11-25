#!/usr/bin/env python3
"""
HLR Reconciliation System - Dashboard Backend
A Flask-based REST API providing real-time monitoring data
"""

from flask import Flask, render_template, jsonify, request
from datetime import datetime, timedelta
import random
import json

app = Flask(__name__)

# Mock data generators for HLR reconciliation metrics
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
        execution_time = base_time - timedelta(hours=i)
        procedure = random.choice(procedures)
        status = random.choices(['SUCCESS', 'FAILED', 'WARNING'], weights=[80, 10, 10])[0]

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
        total_runs = random.randint(20, 100)
        successful = random.randint(int(total_runs * 0.8), total_runs)

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
        hours.append({
            'hour': hour_time.strftime('%H:00'),
            'executions': random.randint(5, 30),
            'successful': random.randint(4, 25),
            'failed': random.randint(0, 5),
            'avg_duration': random.randint(120, 400)
        })

    return hours

# API Routes
@app.route('/')
def index():
    """Main dashboard page"""
    return render_template('dashboard.html')

@app.route('/api/metrics')
def get_metrics():
    """Get overall system metrics"""
    return jsonify(generate_system_metrics())

@app.route('/api/executions')
def get_executions():
    """Get recent reconciliation executions"""
    limit = request.args.get('limit', default=20, type=int)
    executions = generate_mock_execution_data()[:limit]
    return jsonify(executions)

@app.route('/api/errors')
def get_errors():
    """Get recent errors"""
    limit = request.args.get('limit', default=10, type=int)
    errors = generate_mock_errors()[:limit]
    return jsonify(errors)

@app.route('/api/procedure-performance')
def get_procedure_performance():
    """Get performance metrics by procedure"""
    return jsonify(generate_procedure_performance())

@app.route('/api/hourly-stats')
def get_hourly_stats():
    """Get hourly execution statistics"""
    return jsonify(generate_hourly_stats())

@app.route('/api/health')
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'version': '1.0.0'
    })

if __name__ == '__main__':
    print("=" * 60)
    print("🚀 HLR Reconciliation Dashboard Starting...")
    print("=" * 60)
    print("📊 Dashboard URL: http://localhost:8080")
    print("🔧 API Health: http://localhost:8080/api/health")
    print("=" * 60)
    print("✨ Ready! Open your browser and navigate to the URL above")
    print("=" * 60)

    app.run(host='0.0.0.0', port=8080, debug=True)
