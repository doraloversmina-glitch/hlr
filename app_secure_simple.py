"""
Secure Excel Comparator Web Application (Simplified)
A Flask-based web interface with security features for comparing Excel files.
Uses only built-in Python libraries for maximum compatibility.
"""

from flask import Flask, render_template, request, jsonify, send_file, session, redirect, url_for
import os
from werkzeug.utils import secure_filename
from excel_comparator import ExcelComparator
import pandas as pd
from datetime import datetime, timedelta
import uuid
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
import secrets
import hashlib
import time

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = 'uploads'
app.config['OUTPUT_FOLDER'] = 'outputs'
app.config['MAX_CONTENT_LENGTH'] = 50 * 1024 * 1024  # 50MB max file size
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', secrets.token_hex(32))
app.config['PERMANENT_SESSION_LIFETIME'] = timedelta(hours=1)  # 1 hour session

# Ensure upload and output directories exist
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
os.makedirs(app.config['OUTPUT_FOLDER'], exist_ok=True)

# Security: Rate limiting
limiter = Limiter(
    app=app,
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"],
    storage_uri="memory://"
)

# Security: Password (change this!)
APP_PASSWORD_HASH = os.environ.get('APP_PASSWORD_HASH',
                                   hashlib.sha256('SecurePass123!'.encode()).hexdigest())

ALLOWED_EXTENSIONS = {'xlsx', 'xls'}


def allowed_file(filename):
    """Check if file has an allowed extension."""
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


def require_auth(f):
    """Decorator to require authentication."""
    def decorated_function(*args, **kwargs):
        if not session.get('authenticated'):
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    decorated_function.__name__ = f.__name__
    return decorated_function


def secure_delete_file(filepath):
    """Securely delete a file by overwriting before deletion."""
    try:
        if os.path.exists(filepath):
            # Overwrite with random data (3 passes for extra security)
            file_size = os.path.getsize(filepath)
            for _ in range(3):
                with open(filepath, 'wb') as f:
                    f.write(os.urandom(file_size))
                    f.flush()
                    os.fsync(f.fileno())
            os.remove(filepath)
    except Exception:
        pass


@app.route('/login', methods=['GET', 'POST'])
@limiter.limit("10 per minute")
def login():
    """Handle login."""
    if request.method == 'POST':
        password = request.form.get('password', '')
        password_hash = hashlib.sha256(password.encode()).hexdigest()

        if password_hash == APP_PASSWORD_HASH:
            session['authenticated'] = True
            session['login_time'] = datetime.now().isoformat()
            session.permanent = True
            return redirect(url_for('index'))
        else:
            # Add small delay to prevent brute force
            time.sleep(1)
            return render_template('login.html', error='Invalid password')

    return render_template('login.html')


@app.route('/logout')
def logout():
    """Handle logout."""
    session.clear()
    return redirect(url_for('login'))


@app.route('/')
@require_auth
def index():
    """Render the main page."""
    return render_template('index.html')


@app.route('/compare', methods=['POST'])
@require_auth
@limiter.limit("10 per hour")
def compare():
    """Handle file comparison request."""
    filepath1 = None
    filepath2 = None
    output_path = None

    try:
        # Check if files were uploaded
        if 'file1' not in request.files or 'file2' not in request.files:
            return jsonify({'error': 'Both files are required'}), 400

        file1 = request.files['file1']
        file2 = request.files['file2']

        # Check if files have names
        if file1.filename == '' or file2.filename == '':
            return jsonify({'error': 'Both files must be selected'}), 400

        # Validate file types
        if not (allowed_file(file1.filename) and allowed_file(file2.filename)):
            return jsonify({'error': 'Only .xlsx and .xls files are allowed'}), 400

        # Get optional key column
        key_column = request.form.get('key_column', '').strip()
        key_column = key_column if key_column else None

        # Generate unique session ID
        session_id = str(uuid.uuid4())

        # Save uploaded files with secure names
        filename1 = secure_filename(f"{session_id}_file1_{file1.filename}")
        filename2 = secure_filename(f"{session_id}_file2_{file2.filename}")

        filepath1 = os.path.join(app.config['UPLOAD_FOLDER'], filename1)
        filepath2 = os.path.join(app.config['UPLOAD_FOLDER'], filename2)

        file1.save(filepath1)
        file2.save(filepath2)

        # Perform comparison
        comparator = ExcelComparator(filepath1, filepath2, key_column)
        results = comparator.compare()

        if 'error' in results:
            return jsonify({'error': results['error']}), 500

        # Generate output file
        output_filename = f"{session_id}_differences.xlsx"
        output_path = os.path.join(app.config['OUTPUT_FOLDER'], output_filename)
        comparator.generate_report(output_path)

        # Prepare response data
        response_data = {
            'session_id': session_id,
            'identical': results['identical'],
            'structure': {
                'rows_file1': results['structure']['rows_file1'],
                'rows_file2': results['structure']['rows_file2'],
                'rows_match': results['structure']['rows_match'],
                'cols_file1': results['structure']['cols_file1'],
                'cols_file2': results['structure']['cols_file2'],
                'cols_match': results['structure']['cols_match'],
                'column_names_match': results['structure']['column_names_match'],
                'columns_file1': results['structure']['columns_file1'],
                'columns_file2': results['structure']['columns_file2'],
                'missing_in_file1': results['structure']['missing_in_file1'],
                'missing_in_file2': results['structure']['missing_in_file2'],
            },
            'difference_count': results['difference_count'],
            'output_file': output_filename,
        }

        # Add sample differences for preview (first 10 rows)
        if not results['differences_df'].empty:
            sample_df = results['differences_df'].head(10)
            response_data['sample_differences'] = sample_df.to_dict(orient='records')
        else:
            response_data['sample_differences'] = []

        # Securely delete uploaded files immediately
        secure_delete_file(filepath1)
        secure_delete_file(filepath2)

        return jsonify(response_data)

    except Exception as e:
        # Clean up on error
        for f in [filepath1, filepath2, output_path]:
            if f:
                secure_delete_file(f)
        return jsonify({'error': f'An error occurred: {str(e)}'}), 500


@app.route('/download/<filename>')
@require_auth
@limiter.limit("20 per hour")
def download(filename):
    """Download the generated differences file."""
    try:
        file_path = os.path.join(app.config['OUTPUT_FOLDER'], secure_filename(filename))
        if os.path.exists(file_path):
            response = send_file(file_path, as_attachment=True, download_name='differences.xlsx')

            # Delete file after sending
            @response.call_on_close
            def cleanup():
                secure_delete_file(file_path)

            return response
        else:
            return jsonify({'error': 'File not found'}), 404
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/health')
def health():
    """Health check endpoint."""
    return jsonify({'status': 'healthy', 'timestamp': datetime.now().isoformat()})


@app.before_request
def cleanup_old_files():
    """Clean up old files periodically."""
    try:
        now = time.time()
        for folder in [app.config['UPLOAD_FOLDER'], app.config['OUTPUT_FOLDER']]:
            if not os.path.exists(folder):
                continue
            for filename in os.listdir(folder):
                filepath = os.path.join(folder, filename)
                # Delete files older than 1 hour
                if os.path.isfile(filepath) and (now - os.path.getmtime(filepath)) > 3600:
                    secure_delete_file(filepath)
    except Exception:
        pass


@app.after_request
def add_security_headers(response):
    """Add security headers to all responses."""
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['X-Frame-Options'] = 'DENY'
    response.headers['X-XSS-Protection'] = '1; mode=block'
    response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains'
    return response


if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    debug = os.environ.get('FLASK_ENV') != 'production'

    # Print password information for setup
    if not os.environ.get('APP_PASSWORD_HASH'):
        print("\n" + "="*60)
        print("🔒 SECURITY NOTICE")
        print("="*60)
        print("Default password: SecurePass123!")
        print("\nChange password by setting APP_PASSWORD_HASH environment variable")
        print("\nGenerate hash with:")
        print("  python -c \"import hashlib; print(hashlib.sha256('YourPassword'.encode()).hexdigest())\"")
        print("="*60 + "\n")

    app.run(debug=debug, host='0.0.0.0', port=port)
