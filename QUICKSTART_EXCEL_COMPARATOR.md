# Excel Comparator - Quick Start Guide

## 🚀 Get Started in 3 Steps

### 1. Install Dependencies

```bash
pip install -r requirements.txt
```

### 2. Choose Your Interface

#### Option A: Command Line (Quick & Simple)

```bash
# Basic comparison
python compare_excel.py file1.xlsx file2.xlsx

# With key column for alignment
python compare_excel.py file1.xlsx file2.xlsx --key ID
```

#### Option B: Web Interface (Beautiful UI/UX)

```bash
# Start the server
python app.py

# Open browser to http://localhost:5000
```

### 3. Get Your Results

- **CLI**: Results printed to terminal + `differences.xlsx` generated
- **Web**: Interactive results + downloadable Excel report

---

## 📝 Example Usage

### Test with Sample Files

Create sample files:
```bash
python create_test_files.py
```

Run comparison:
```bash
python compare_excel.py test_file1.xlsx test_file2.xlsx --key ID
```

Output:
```
============================================================
EXCEL FILE COMPARISON REPORT
============================================================

📊 STRUCTURE COMPARISON:
------------------------------------------------------------
✓ Rows: 5 (both files)
✓ Columns: 5 (both files)
✓ Column names and order match

📝 DATA COMPARISON:
------------------------------------------------------------
✗ Found 4 rows with differences
```

---

## 🌐 Web Interface Features

- **Drag & Drop**: Simply drag Excel files onto the upload zones
- **Real-time Results**: Instant comparison results with beautiful visualization
- **Download Report**: Full Excel report with color-coded differences
- **Responsive Design**: Works on desktop, tablet, and mobile
- **Sample Preview**: See first 10 differences instantly

---

## 🔧 Advanced Usage

### Key Column Alignment

When comparing files where rows might be in different order:

```bash
python compare_excel.py customers_old.xlsx customers_new.xlsx --key CustomerID
```

This will:
1. Sort both files by CustomerID
2. Align rows based on the key
3. Compare matched rows

### Custom Output Location

```bash
python compare_excel.py file1.xlsx file2.xlsx --output ./reports/my_report.xlsx
```

### Use in Your Python Scripts

```python
from excel_comparator import compare_excel_files

results = compare_excel_files(
    'file1.xlsx',
    'file2.xlsx',
    key_column='ID',
    output_file='report.xlsx'
)

if results['identical']:
    print("Files match!")
else:
    print(f"Found {results['difference_count']} differences")
```

---

## 📊 Output Report Contents

The generated Excel file contains:

1. **Summary Sheet**
   - Overall comparison statistics
   - Identical status
   - Row/column counts

2. **Column Comparison** (if applicable)
   - Columns in each file
   - Missing columns highlighted

3. **Differences Sheet**
   - All rows with differences
   - Side-by-side comparison
   - Color-coded cells

---

## 🎯 Common Use Cases

### 1. Data Migration Validation
```bash
python compare_excel.py before_migration.xlsx after_migration.xlsx --key RecordID
```

### 2. Report Version Comparison
```bash
python compare_excel.py report_v1.xlsx report_v2.xlsx
```

### 3. Quality Assurance
```bash
python compare_excel.py expected_output.xlsx actual_output.xlsx --key TestID
```

### 4. Batch Comparison (Script)
```python
files_to_compare = [
    ('old/sales.xlsx', 'new/sales.xlsx'),
    ('old/inventory.xlsx', 'new/inventory.xlsx'),
]

for old, new in files_to_compare:
    results = compare_excel_files(old, new, key_column='ID')
    if not results['identical']:
        print(f"⚠️ Differences found in {old}")
```

---

## 🚀 Deploy Web App to Production

### Using Gunicorn (Recommended)

```bash
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

### Using Docker

```bash
docker build -t excel-comparator .
docker run -p 5000:5000 excel-comparator
```

### Environment Variables

```bash
export FLASK_ENV=production
export FLASK_SECRET_KEY=your-secret-key
python app.py
```

---

## 💡 Tips & Tricks

1. **Large Files**: The tool handles 100,000+ rows efficiently
2. **Memory**: Uses pandas for memory-efficient processing
3. **Speed**: Vectorized operations for fast comparison
4. **Accuracy**: Handles NaN values and data types correctly
5. **Sorting**: Always use a key column for unordered data

---

## 🆘 Troubleshooting

**Problem**: "ModuleNotFoundError: No module named 'pandas'"
```bash
pip install -r requirements.txt
```

**Problem**: "File not found"
```bash
# Use absolute paths
python compare_excel.py /full/path/to/file1.xlsx /full/path/to/file2.xlsx
```

**Problem**: Web app won't start
```bash
# Check if port 5000 is available
lsof -i :5000

# Use different port
export FLASK_RUN_PORT=8000
python app.py
```

---

## 📚 Need More Help?

- See [README_EXCEL_COMPARATOR.md](README_EXCEL_COMPARATOR.md) for full documentation
- Check code comments for implementation details
- Run `python compare_excel.py --help` for CLI options

---

**Happy Comparing! 📊✨**
