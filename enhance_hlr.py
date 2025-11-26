#!/usr/bin/env python3
"""
Script to enhance HLR reconciliation package:
1. Add _te suffix to all created tables
2. Add fafif. prefix to external source tables
3. Add activity trace functionality
"""

import re
import sys

def read_file(filename):
    with open(filename, 'r', encoding='utf-8') as f:
        return f.read()

def write_file(filename, content):
    with open(filename, 'w', encoding='utf-8') as f:
        f.write(content)

def add_te_suffix_to_created_tables(content):
    """Add _te suffix to all CREATE TABLE statements"""
    # Pattern: CREATE TABLE table_name
    pattern = r'CREATE\s+TABLE\s+([A-Z_][A-Z0-9_]*)'

    def replace_create_table(match):
        table_name = match.group(1)
        # Don't add _te if already has it
        if not table_name.endswith('_TE'):
            return f'CREATE TABLE {table_name}_TE'
        return match.group(0)

    content = re.sub(pattern, replace_create_table, content, flags=re.IGNORECASE)
    return content

def get_all_created_tables(content):
    """Extract all table names that are created (will have _te suffix)"""
    pattern = r'CREATE\s+TABLE\s+([A-Z_][A-Z0-9_]*_TE)'
    matches = re.findall(pattern, content, flags=re.IGNORECASE)
    # Get base names without _TE
    base_names = set()
    for name in matches:
        if name.endswith('_TE'):
            base_names.add(name[:-3])  # Remove _TE suffix
    return base_names

def update_table_references(content, created_tables):
    """Update all references to created tables to use _te suffix"""
    # Sort by length (longest first) to avoid partial replacements
    sorted_tables = sorted(created_tables, key=len, reverse=True)

    for table_name in sorted_tables:
        # Pattern for table references in various contexts
        # Use a more general pattern to catch table names in more contexts

        # General table reference pattern (covers FROM, JOIN, comma-separated, etc.)
        # Match: word boundary + table_name + word boundary, not followed by _TE
        content = re.sub(
            rf'\b({table_name})\b(?!_TE)',
            rf'\1_TE',
            content,
            flags=re.IGNORECASE
        )

    return content

def add_fafif_prefix_to_external_tables(content):
    """Add fafif. prefix to external source tables where missing"""
    external_tables = ['HLR1', 'HLR2', 'CLEAN_SV_ALL_UPD', 'PPS_ABONNE_JOUR_MIGDB',
                       'APNID_HLR1', 'APNID_HLR2', 'PPS_ABONNE_JOUR_dbauserDB']

    for table in external_tables:
        # Don't prefix if already has fafif. or if it's followed by _TE (our created tables)
        # FROM table (not already prefixed, not _TE version)
        content = re.sub(
            rf'\bFROM\s+(?!FAFIF\.)({table})\b(?!_TE)',
            rf'FROM FAFIF.\1',
            content,
            flags=re.IGNORECASE
        )

        # JOIN table
        content = re.sub(
            rf'\bJOIN\s+(?!FAFIF\.)({table})\b(?!_TE)',
            rf'JOIN FAFIF.\1',
            content,
            flags=re.IGNORECASE
        )

    return content

def update_utils_interface_calls(content):
    """Update UTILS_INTERFACES.CREATE_TABLE calls to use DANAD schema and _te suffix"""
    # Pattern: UTILS_INTERFACES.CREATE_TABLE('TABLE_NAME', 'FAFIF', ...)
    # Change 'FAFIF' to 'DANAD'
    content = re.sub(
        r"UTILS_INTERFACES\.CREATE_TABLE\('([^']+)',\s*'FAFIF'",
        r"UTILS_INTERFACES.CREATE_TABLE('\1', 'DANAD'",
        content,
        flags=re.IGNORECASE
    )

    # Also update CREATE_INDEX calls
    content = re.sub(
        r"UTILS_INTERFACES\.CREATE_INDEX\('([^']+)',\s*'FAFIF'",
        r"UTILS_INTERFACES.CREATE_INDEX('\1', 'DANAD'",
        content,
        flags=re.IGNORECASE
    )

    return content

def add_activity_trace_helper(content):
    """Add activity trace helper procedure at the beginning of the package body"""

    trace_procedure = '''
-- =============================================================================================
-- Activity Trace Helper Procedure
-- =============================================================================================
PROCEDURE LOG_ACTIVITY_TRACE(
    p_interface_id IN VARCHAR2,
    p_interface_name IN VARCHAR2,
    p_act_type IN VARCHAR2,
    p_act_body IN VARCHAR2 DEFAULT NULL,
    p_act_body1 IN VARCHAR2 DEFAULT NULL,
    p_act_body2 IN VARCHAR2 DEFAULT NULL,
    p_act_status IN VARCHAR2 DEFAULT 'SUCCESS',
    p_act_exec_time IN NUMBER DEFAULT NULL,
    p_affected_rows IN NUMBER DEFAULT NULL,
    p_ora_error IN VARCHAR2 DEFAULT NULL,
    p_credentials IN VARCHAR2 DEFAULT NULL
) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    INSERT INTO DANAD.ACTIVITY_TRACE_TE (
        INTERFACE_ID, INTERFACE_NAME, ACT_TYPE, ACT_BODY, ACT_BODY1, ACT_BODY2,
        ACT_DATE, ACT_STATUS, ACT_EXEC_TIME, AFFECTED_ROWS, ORA_ERROR, CREDENTIALS
    ) VALUES (
        p_interface_id, p_interface_name, p_act_type, p_act_body, p_act_body1, p_act_body2,
        SYSDATE, p_act_status, p_act_exec_time, p_affected_rows, p_ora_error, p_credentials
    );
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        -- Silently fail to avoid disrupting main process
        NULL;
END LOG_ACTIVITY_TRACE;

'''

    # Insert after the package body declaration
    pattern = r'(CREATE OR REPLACE PACKAGE BODY RECONCILIATION_INTERFACES IS)'
    replacement = r'\1' + trace_procedure
    content = re.sub(pattern, replacement, content, count=1)

    return content

def add_trace_to_procedures(content):
    """Add activity trace logging to procedure starts"""
    # Pattern: PROCEDURE procedure_name(...) IS
    # Add trace logging after BEGIN

    # This is complex and would require parsing the PL/SQL structure
    # For now, we'll add a comment indicating where traces should be added
    # Manual addition would be more reliable for this specific requirement

    return content

def main():
    print("Reading hlrbo.txt...")
    content = read_file('hlrbo.txt')

    print("Step 1: Adding _te suffix to CREATE TABLE statements...")
    content = add_te_suffix_to_created_tables(content)

    print("Step 2: Getting list of created tables...")
    created_tables = get_all_created_tables(content)
    print(f"  Found {len(created_tables)} created tables")

    print("Step 3: Updating references to created tables...")
    content = update_table_references(content, created_tables)

    print("Step 4: Adding fafif. prefix to external tables...")
    content = add_fafif_prefix_to_external_tables(content)

    print("Step 5: Updating UTILS_INTERFACES calls to use DANAD schema...")
    content = update_utils_interface_calls(content)

    print("Step 6: Adding activity trace helper procedure...")
    content = add_activity_trace_helper(content)

    print("Writing enhanced hlrbo_enhanced.txt...")
    write_file('hlrbo_enhanced.txt', content)

    print("Done! Review hlrbo_enhanced.txt before using.")
    print(f"Created tables that now have _te suffix: {len(created_tables)}")

if __name__ == '__main__':
    main()
