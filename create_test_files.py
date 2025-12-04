"""
Create sample Excel files for testing the comparator
"""
import pandas as pd
import numpy as np

# Create first test file
data1 = {
    'ID': [1, 2, 3, 4, 5],
    'Name': ['Alice', 'Bob', 'Charlie', 'David', 'Eve'],
    'Age': [25, 30, 35, 40, 45],
    'City': ['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix'],
    'Salary': [50000, 60000, 70000, 80000, 90000]
}
df1 = pd.DataFrame(data1)
df1.to_excel('test_file1.xlsx', index=False)
print("✓ Created test_file1.xlsx")

# Create second test file with some differences
data2 = {
    'ID': [1, 2, 3, 4, 5],
    'Name': ['Alice', 'Bob', 'Charlie', 'David', 'Eve'],
    'Age': [25, 31, 35, 40, 46],  # Changed Bob's and Eve's age
    'City': ['New York', 'Los Angeles', 'Chicago', 'Dallas', 'Phoenix'],  # Changed Houston to Dallas
    'Salary': [50000, 60000, 75000, 80000, 90000]  # Changed Charlie's salary
}
df2 = pd.DataFrame(data2)
df2.to_excel('test_file2.xlsx', index=False)
print("✓ Created test_file2.xlsx")

# Create identical files for testing
df1.to_excel('test_file3.xlsx', index=False)
df1.to_excel('test_file4.xlsx', index=False)
print("✓ Created test_file3.xlsx (identical to file1)")
print("✓ Created test_file4.xlsx (identical to file1)")

print("\nTest files created successfully!")
print("\nExpected differences between file1 and file2:")
print("  - Bob's age: 30 → 31")
print("  - Charlie's salary: 70000 → 75000")
print("  - David's city: Houston → Dallas")
print("  - Eve's age: 45 → 46")
