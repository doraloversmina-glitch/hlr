#!/usr/bin/env python3
"""
Excel Comparison CLI Tool
Compare two Excel files and generate a detailed difference report.

Usage:
    python compare_excel.py file1.xlsx file2.xlsx [--key COLUMN] [--output OUTPUT.xlsx]
"""

import argparse
import sys
from pathlib import Path
from excel_comparator import compare_excel_files


def main():
    """Main CLI entry point."""
    parser = argparse.ArgumentParser(
        description='Compare two Excel files and generate a difference report',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python compare_excel.py file1.xlsx file2.xlsx
  python compare_excel.py file1.xlsx file2.xlsx --key MSISDN
  python compare_excel.py file1.xlsx file2.xlsx --key ID --output my_diff.xlsx
        """
    )

    parser.add_argument('file1', type=str, help='Path to first Excel file')
    parser.add_argument('file2', type=str, help='Path to second Excel file')
    parser.add_argument('--key', '-k', type=str, default=None,
                        help='Column name to use as key for row alignment and sorting')
    parser.add_argument('--output', '-o', type=str, default='differences.xlsx',
                        help='Output file path for differences report (default: differences.xlsx)')

    args = parser.parse_args()

    # Validate input files exist
    file1_path = Path(args.file1)
    file2_path = Path(args.file2)

    if not file1_path.exists():
        print(f"Error: File not found: {args.file1}", file=sys.stderr)
        sys.exit(1)

    if not file2_path.exists():
        print(f"Error: File not found: {args.file2}", file=sys.stderr)
        sys.exit(1)

    print(f"\nComparing Excel files:")
    print(f"  File 1: {args.file1}")
    print(f"  File 2: {args.file2}")
    if args.key:
        print(f"  Key column: {args.key}")
    print(f"  Output: {args.output}")

    # Perform comparison
    results = compare_excel_files(
        file1=args.file1,
        file2=args.file2,
        key_column=args.key,
        output_file=args.output
    )

    # Exit with appropriate code
    if 'error' in results:
        sys.exit(1)
    elif results.get('identical', False):
        sys.exit(0)
    else:
        sys.exit(2)  # Files differ


if __name__ == '__main__':
    main()
