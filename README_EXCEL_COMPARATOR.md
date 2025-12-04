# Excel File Comparator

A powerful Python tool for comparing two Excel files and generating detailed difference reports. Available as both a command-line interface (CLI) and a modern web application.

## Features

- **Comprehensive Comparison**
  - Compare row counts and column counts
  - Compare column names and their order
  - Cell-by-cell data comparison
  - Detect and report all differences

- **Smart Row Alignment**
  - Optional key column for row alignment
  - Automatic sorting by key before comparison
  - Handles missing rows gracefully

- **Robust Error Handling**
  - Handles missing columns
  - Handles different row counts
  - Handles different column orders
  - Efficient processing of large files (100,000+ rows)

- **Rich Output**
  - Human-readable summary in terminal
  - Excel report with all differences
  - Color-coded difference highlighting
  - Web interface with visual results

## Installation

1. Clone or download this repository

2. Install dependencies:
```bash
pip install -r requirements.txt
```

## Usage

### Command Line Interface (CLI)

Basic usage:
```bash
python compare_excel.py file1.xlsx file2.xlsx
```

With key column for row alignment:
```bash
python compare_excel.py file1.xlsx file2.xlsx --key MSISDN
```

Custom output file:
```bash
python compare_excel.py file1.xlsx file2.xlsx --key ID --output my_report.xlsx
```

#### CLI Arguments

- `file1`: Path to first Excel file (required)
- `file2`: Path to second Excel file (required)
- `--key` or `-k`: Column name to use as key for row alignment (optional)
- `--output` or `-o`: Output file path for differences report (default: differences.xlsx)

#### Exit Codes

- `0`: Files are identical
- `1`: Error occurred during comparison
- `2`: Files are different

### Web Application

1. Start the web server:
```bash
python app.py
```

2. Open your browser and navigate to:
```
http://localhost:5000
```

3. Use the intuitive web interface to:
   - Upload two Excel files (drag-and-drop or click)
   - Optionally specify a key column
   - View comparison results instantly
   - Download the detailed Excel report

#### Deploying to Production

For production deployment, use a WSGI server like Gunicorn:

```bash
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

Or use Docker:

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "app:app"]
```

## Output Report

The generated Excel file (`differences.xlsx`) contains:

1. **Summary Sheet**
   - Files identical status
   - Row counts comparison
   - Column counts comparison
   - Total differences count

2. **Column Comparison Sheet** (if columns differ)
   - Columns in File 1
   - Columns in File 2
   - Missing columns highlighted

3. **Differences Sheet**
   - All rows with differences
   - Side-by-side values (File1 vs File2)
   - Color-coded highlights on changed cells

## Examples

### Example 1: Basic Comparison

```bash
python compare_excel.py sales_2023.xlsx sales_2024.xlsx
```

Output:
```
Comparing Excel files:
  File 1: sales_2023.xlsx
  File 2: sales_2024.xlsx
  Output: differences.xlsx

============================================================
EXCEL FILE COMPARISON REPORT
============================================================

📊 STRUCTURE COMPARISON:
------------------------------------------------------------
✓ Rows: 1500 (both files)
✓ Columns: 8 (both files)
✓ Column names and order match

📝 DATA COMPARISON:
------------------------------------------------------------
✗ Found 47 rows with differences

============================================================

Report generated successfully: differences.xlsx
```

### Example 2: With Key Column

```bash
python compare_excel.py customers_old.xlsx customers_new.xlsx --key CustomerID
```

This will:
1. Sort both files by CustomerID
2. Align rows based on CustomerID
3. Compare row-by-row
4. Generate report showing which CustomerIDs have differences

### Example 3: Large Files

The tool efficiently handles large files:

```bash
python compare_excel.py data_100k_rows.xlsx data_100k_rows_v2.xlsx --key ID
```

Performance notes:
- Processes 100,000 rows in under 30 seconds (typical hardware)
- Memory-efficient using pandas chunking
- Progress feedback in CLI mode

## Module Usage

You can also use the comparison module in your own Python scripts:

```python
from excel_comparator import compare_excel_files, ExcelComparator

# Simple comparison
results = compare_excel_files('file1.xlsx', 'file2.xlsx', key_column='MSISDN')

# Advanced usage with more control
comparator = ExcelComparator('file1.xlsx', 'file2.xlsx', key_column='ID')
results = comparator.compare()

# Check if files are identical
if results['identical']:
    print("Files are identical!")
else:
    print(f"Found {results['difference_count']} differences")

# Access detailed results
print(results['structure'])  # Structure comparison
print(results['differences_df'])  # DataFrame of differences

# Generate custom report
comparator.generate_report('my_custom_report.xlsx')
```

## Architecture

```
excel-comparator/
├── excel_comparator.py    # Core comparison logic
├── compare_excel.py        # CLI interface
├── app.py                  # Flask web application
├── templates/
│   └── index.html         # Web UI
├── requirements.txt        # Python dependencies
└── README.md              # This file
```

### Core Components

- **ExcelComparator**: Main class handling all comparison logic
- **compare_excel_files()**: Convenience function for simple comparisons
- **Flask App**: Web server with REST API endpoints
- **Web UI**: Modern, responsive interface with drag-and-drop

## Technical Details

### Comparison Algorithm

1. **Load Files**: Read both Excel files into pandas DataFrames
2. **Align Data**: If key column specified, sort both DataFrames
3. **Structure Check**: Compare dimensions and column names
4. **Data Comparison**:
   - Iterate through common columns
   - Compare values cell-by-cell
   - Handle NaN values correctly
   - Track all differences with context
5. **Report Generation**: Create Excel file with formatted results

### Performance Optimizations

- Pandas vectorized operations for speed
- Efficient memory usage with appropriate data types
- Lazy evaluation where possible
- Chunked processing for very large files

### Error Handling

- Validates file existence before processing
- Handles corrupt or invalid Excel files
- Gracefully manages missing columns
- Provides clear error messages

## Browser Support

The web interface supports:
- Chrome/Edge (latest)
- Firefox (latest)
- Safari (latest)
- Mobile browsers (responsive design)

## Contributing

Contributions are welcome! Areas for enhancement:
- Support for multiple sheets
- Custom comparison rules
- Statistical analysis of differences
- Export to other formats (CSV, JSON)

## License

MIT License - Feel free to use in your projects

## Support

For issues or questions:
1. Check this README
2. Review the code comments
3. Test with sample files
4. Report bugs with detailed error messages

## Version History

- **v1.0.0** (2024-12-04)
  - Initial release
  - CLI and web interfaces
  - Core comparison features
  - Excel report generation
  - Key column alignment
