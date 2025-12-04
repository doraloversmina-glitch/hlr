"""
Excel Comparator Web Application
A Flask-based web interface for comparing Excel files.
"""

from flask import Flask, render_template, request, jsonify, send_file
import os
from werkzeug.utils import secure_filename
from excel_comparator import ExcelComparator
import pandas as pd
from datetime import datetime
import uuid

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = 'uploads'
app.config['OUTPUT_FOLDER'] = 'outputs'
app.config['MAX_CONTENT_LENGTH'] = 50 * 1024 * 1024  # 50MB max file size
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'excel-comparator-secret-key-2024')

# Ensure upload and output directories exist
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
os.makedirs(app.config['OUTPUT_FOLDER'], exist_ok=True)

ALLOWED_EXTENSIONS = {'xlsx', 'xls'}


def allowed_file(filename):
    """Check if file has an allowed extension."""
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


@app.route('/')
def index():
    """Render the main page."""
    return render_template('index.html')


@app.route('/compare', methods=['POST'])
def compare():
    """Handle file comparison request."""
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

        # Save uploaded files
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

        # Clean up uploaded files after comparison
        try:
            os.remove(filepath1)
            os.remove(filepath2)
        except:
            pass

        return jsonify(response_data)

    except Exception as e:
        return jsonify({'error': f'An error occurred: {str(e)}'}), 500


@app.route('/download/<filename>')
def download(filename):
    """Download the generated differences file."""
    try:
        file_path = os.path.join(app.config['OUTPUT_FOLDER'], secure_filename(filename))
        if os.path.exists(file_path):
            return send_file(file_path, as_attachment=True, download_name='differences.xlsx')
        else:
            return jsonify({'error': 'File not found'}), 404
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/health')
def health():
    """Health check endpoint."""
    return jsonify({'status': 'healthy', 'timestamp': datetime.now().isoformat()})


if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    debug = os.environ.get('FLASK_ENV') != 'production'
    app.run(debug=debug, host='0.0.0.0', port=port)
