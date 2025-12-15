# P1_MAIN_SYS_INTERFACES_TE - Enhancement Documentation

## Overview
This document describes the enhancements made to the P1_MAIN_SYS_INTERFACES procedure. The enhanced version (suffix: _TE) includes activity tracing, configuration management, and improved maintainability.

---

## Files Created

### 1. P1_CONFIG_TABLES_TE.sql
**Purpose**: Configuration tables to eliminate hardcoded values

**Tables Created**:
- `P1_APN_CONFIG_TE` - APN configurations
- `P1_SDP_ROUTING_CONFIG_TE` - SDP routing rules based on MSISDN ranges
- `P1_HLR_CONFIG_TE` - HLR identification based on IMSI prefixes
- `P1_PRODUCT_CONFIG_TE` - Product types and rate plans for MISP filtering
- `P1_SYSTEM_CONFIG_TE` - General system parameters
- `P1_ACTIVITY_TRACE_TE` - Activity trace logging table

**Views Created**:
- `V_P1_ACTIVE_CONFIG_TE` - Unified view of all active configurations

### 2. P1_CONFIG_HELPER_PKG_TE.sql
**Purpose**: Helper package for dynamic SQL generation from configuration

**Functions**:
- `GET_ACTIVE_APN_IDS()` - Returns active APN IDs
- `GENERATE_APN_COLUMNS(p_hlr_suffix)` - Generates APN column definitions
- `GENERATE_SDP_CASE(p_msisdn_column)` - Generates SDP routing logic
- `GENERATE_HLR_DECODE(p_imsi_column)` - Generates HLR identification logic
- `GENERATE_MISP_FILTER()` - Generates MISP filtering conditions
- `GENERATE_COMPANION_CASE(p_hlr_suffix)` - Generates companion product logic
- `GET_SYS_CONFIG(p_config_key)` - Retrieves system configuration
- `IS_TRACE_ENABLED()` - Checks if tracing is enabled

### 3. P1_MAIN_SYS_INTERFACES_TE.sql
**Purpose**: Enhanced main procedure with activity tracing

**Key Features**:
- All created objects have "_TE" suffix
- Comprehensive activity trace logging
- Performance metrics tracking
- Enhanced error handling
- Row count tracking for each operation

---

## Major Enhancements

### 1. Activity Tracing System
All operations are logged to `P1_ACTIVITY_TRACE_TE` table with:
- Session ID
- Step number and name
- Start/end timestamps
- Duration in seconds
- Rows affected
- Status (SUCCESS/FAILED/ERROR)
- Error messages

**Example Query to View Trace**:
```sql
SELECT
    STEP_NUMBER,
    STEP_NAME,
    STEP_STATUS,
    DURATION_SECONDS,
    ROWS_AFFECTED,
    START_TIME,
    END_TIME
FROM P1_ACTIVITY_TRACE_TE
WHERE SESSION_ID = 'your_session_id'
ORDER BY STEP_NUMBER;
```

### 2. Configuration-Driven Approach

#### Before (Hardcoded):
```sql
max( decode( APN_ID, '20', APN_ID, null ) ) AS WLL_APN1,
max( decode( APN_ID, '15', APN_ID, null ) ) AS ALFA_APN1,
-- ... many more hardcoded values
```

#### After (Configuration-Based):
```sql
-- APN configurations stored in P1_APN_CONFIG_TE
-- Dynamic SQL generated from configuration
-- Easy to add/modify/disable APNs without code changes
```

### 3. Tables Created with _TE Suffix

All tables now have "_TE" suffix for clear identification:
- `SYS_MINSAT_TE`
- `HLR1_APN_DATA_TE`
- `HLR1_PARAM_TE`
- `MERGE_HLR1_APN_TE`
- `HLR2_APN_DATA_TE`
- `HLR2_PARAM_TE`
- `MERGE_HLR2_APN_TE`
- `REP_SV_MSISDN_IN_MISP_TE`
- `REP_SV_MSISDN_NOT_MISP_TE`
- `MERGE_SYS_SV_CS4_TE`
- `CLEAN_ALL_SYS_MERGED_TE`
- `MERGE_HLR1_HLR2_1_TE`
- `MERGE_HLR1_HLR2_2_TE`
- `MERGE_HLR1_HLR2_TE`
- `REP_HLRS_MIS_MSISDN_TE`
- `REP_HLRS_MIS_IMSI_TE`
- `CLEAN_HLRS_MERGED_TE`
- `MERGE_SYS_HLRS_TE`
- `REP_CLEAN_ALL_MERGED_TE`
- `REP_ADM_DMP_HLR1_TE`
- `REP_ADM_DMP_HLR2_TE`
- `UNION_APNS_TE`
- `REP_APN_SYS_ALL_TE`
- `list_null_cp_group_TE`

### 4. Enhanced Error Handling

Each operation wrapped with detailed error tracking:
- Step-level error capture
- Automatic rollback on failure
- Error message logging to trace table
- Procedure-level exception handling

---

## Configuration Management

### Adding a New APN
```sql
INSERT INTO P1_APN_CONFIG_TE (
    APN_ID,
    APN_NAME,
    APN_DESCRIPTION,
    COMPANION_PRODUCT,
    PRIORITY_ORDER,
    ACTIVE_FLAG
) VALUES (
    '99',
    'NEW_APN',
    'New APN Description',
    'New Service',
    14,
    'Y'
);
COMMIT;
```

### Adding a New SDP Route
```sql
INSERT INTO P1_SDP_ROUTING_CONFIG_TE (
    MSISDN_RANGE_START,
    MSISDN_RANGE_END,
    SDP_NAME,
    SDP_DESCRIPTION,
    PRIORITY_ORDER,
    ACTIVE_FLAG
) VALUES (
    82000000,
    82999999,
    'SDP07',
    'SDP07 Range 82xxxxxx',
    16,
    'Y'
);
COMMIT;
```

### Disabling a Configuration
```sql
-- Disable an APN without deleting
UPDATE P1_APN_CONFIG_TE
SET ACTIVE_FLAG = 'N'
WHERE APN_ID = '99';
COMMIT;
```

---

## Performance Tracking

The procedure tracks:
- Total tables created
- Total indexes created
- Total update operations
- Overall execution time
- Individual step timing

**Example Query**:
```sql
SELECT
    SESSION_ID,
    MIN(START_TIME) as PROC_START,
    MAX(END_TIME) as PROC_END,
    SUM(DURATION_SECONDS) as TOTAL_DURATION,
    COUNT(*) as TOTAL_STEPS,
    SUM(ROWS_AFFECTED) as TOTAL_ROWS
FROM P1_ACTIVITY_TRACE_TE
WHERE SESSION_ID = 'your_session_id'
GROUP BY SESSION_ID;
```

---

## Installation Instructions

### Step 1: Create Configuration Tables
```sql
@P1_CONFIG_TABLES_TE.sql
```

### Step 2: Create Helper Package
```sql
@P1_CONFIG_HELPER_PKG_TE.sql
```

### Step 3: Create Main Procedure
```sql
@P1_MAIN_SYS_INTERFACES_TE.sql
```

### Step 4: Verify Installation
```sql
-- Check configuration tables
SELECT * FROM V_P1_ACTIVE_CONFIG_TE;

-- Check helper package
DESC P1_CONFIG_HELPER_PKG_TE;

-- Verify procedure
SELECT OBJECT_NAME, OBJECT_TYPE, STATUS
FROM USER_OBJECTS
WHERE OBJECT_NAME LIKE 'P1%TE%';
```

---

## Execution Example

```sql
DECLARE
    v_result VARCHAR2(1000);
BEGIN
    P1_MAIN_SYS_INTERFACES_TE(
        INTEGRATION_LOG_ID => 'TEST_001',
        RESULT => v_result,
        P_ENT_TYPE => 4,
        P_ENT_CODE => 1
    );

    DBMS_OUTPUT.PUT_LINE('Result: ' || v_result);
END;
/
```

---

## Monitoring and Debugging

### View Current Execution Progress
```sql
SELECT
    STEP_NUMBER,
    STEP_NAME,
    STEP_STATUS,
    TO_CHAR(START_TIME, 'HH24:MI:SS') as START_TIME,
    DURATION_SECONDS,
    ROWS_AFFECTED
FROM P1_ACTIVITY_TRACE_TE
WHERE SESSION_ID = USERENV('SESSIONID')
ORDER BY STEP_NUMBER DESC
FETCH FIRST 10 ROWS ONLY;
```

### Find Failed Steps
```sql
SELECT
    SESSION_ID,
    STEP_NUMBER,
    STEP_NAME,
    ERROR_MESSAGE,
    START_TIME
FROM P1_ACTIVITY_TRACE_TE
WHERE STEP_STATUS = 'FAILED'
ORDER BY START_TIME DESC;
```

### Performance Analysis
```sql
SELECT
    STEP_NAME,
    AVG(DURATION_SECONDS) as AVG_DURATION,
    MAX(DURATION_SECONDS) as MAX_DURATION,
    MIN(DURATION_SECONDS) as MIN_DURATION,
    COUNT(*) as EXECUTION_COUNT
FROM P1_ACTIVITY_TRACE_TE
WHERE STEP_STATUS = 'SUCCESS'
GROUP BY STEP_NAME
ORDER BY AVG_DURATION DESC;
```

---

## Cleanup and Maintenance

### Clean Old Trace Records
```sql
DELETE FROM P1_ACTIVITY_TRACE_TE
WHERE CREATED_DATE < SYSDATE - 90; -- Keep last 90 days
COMMIT;
```

### Drop All _TE Objects
```sql
BEGIN
    FOR rec IN (SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME LIKE '%\_TE' ESCAPE '\') LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || rec.TABLE_NAME || ' CASCADE CONSTRAINTS';
    END LOOP;

    EXECUTE IMMEDIATE 'DROP PACKAGE P1_CONFIG_HELPER_PKG_TE';
    EXECUTE IMMEDIATE 'DROP VIEW V_P1_ACTIVE_CONFIG_TE';
END;
/
```

---

## Benefits Summary

### 1. **Maintainability**
- No more hardcoded values scattered throughout code
- Configuration changes don't require code deployment
- Centralized configuration management

### 2. **Observability**
- Complete audit trail of all operations
- Performance metrics for each step
- Easy debugging of failures

### 3. **Flexibility**
- Easy to add new APNs, SDP routes, or product configurations
- Can disable configurations without code changes
- Support for dynamic business rules

### 4. **Reliability**
- Enhanced error handling
- Automatic rollback on failures
- Detailed error messages for troubleshooting

### 5. **Performance Tracking**
- Duration tracking for each operation
- Row count tracking
- Identification of bottlenecks

---

## Configuration Reference

### P1_APN_CONFIG_TE
Stores APN (Access Point Name) configurations.

**Columns**:
- `APN_ID` - APN identifier (PK)
- `APN_NAME` - Column name in tables
- `APN_DESCRIPTION` - Description
- `COMPANION_PRODUCT` - Product name for reporting
- `PRIORITY_ORDER` - Processing order
- `ACTIVE_FLAG` - Y/N

### P1_SDP_ROUTING_CONFIG_TE
Stores SDP routing rules based on MSISDN ranges.

**Columns**:
- `RANGE_ID` - Auto-generated ID (PK)
- `MSISDN_RANGE_START` - Start of MSISDN range
- `MSISDN_RANGE_END` - End of MSISDN range
- `SDP_NAME` - SDP identifier
- `SDP_DESCRIPTION` - Description
- `PRIORITY_ORDER` - Evaluation order
- `ACTIVE_FLAG` - Y/N

### P1_HLR_CONFIG_TE
Stores HLR identification rules based on IMSI prefix.

**Columns**:
- `IMSI_PREFIX` - IMSI prefix (PK)
- `HLR_NUMBER` - HLR number (1, 2, or 0 for excluded)
- `HLR_NAME` - HLR name
- `HLR_DESCRIPTION` - Description
- `ACTIVE_FLAG` - Y/N

### P1_PRODUCT_CONFIG_TE
Stores product type and rate plan configurations.

**Columns**:
- `CONFIG_ID` - Auto-generated ID (PK)
- `PRODUCT_TYPE_NAME` - Product type
- `RATE_PLAN` - Rate plan number
- `CATEGORY` - Category (e.g., MISP)
- `DESCRIPTION` - Description
- `ACTIVE_FLAG` - Y/N

### P1_SYSTEM_CONFIG_TE
Stores general system configuration parameters.

**Columns**:
- `CONFIG_KEY` - Configuration key (PK)
- `CONFIG_VALUE` - Configuration value
- `CONFIG_TYPE` - Data type hint
- `DESCRIPTION` - Description
- `ACTIVE_FLAG` - Y/N

### P1_ACTIVITY_TRACE_TE
Stores execution activity trace.

**Columns**:
- `TRACE_ID` - Auto-generated ID (PK)
- `SESSION_ID` - Database session ID
- `INTEGRATION_LOG_ID` - Integration log reference
- `STEP_NUMBER` - Sequential step number
- `STEP_NAME` - Step description
- `STEP_STATUS` - SUCCESS/FAILED/ERROR/RUNNING
- `START_TIME` - Step start timestamp
- `END_TIME` - Step end timestamp
- `DURATION_SECONDS` - Duration in seconds
- `ROWS_AFFECTED` - Number of rows affected
- `ERROR_MESSAGE` - Error details if failed
- `CREATED_DATE` - Record creation date

---

## Future Enhancements

1. **Email Notifications**: Send alerts on failures
2. **Performance Baselines**: Track and alert on performance degradation
3. **Data Quality Checks**: Add validation rules in configuration
4. **Parallel Execution**: Process independent steps in parallel
5. **Retry Logic**: Automatic retry for transient failures
6. **Archival Process**: Automated archival of old trace records
7. **Dashboard Integration**: Real-time monitoring dashboard
8. **Configuration Versioning**: Track configuration changes over time

---

## Support and Contact

For questions or issues:
1. Check the activity trace table for error details
2. Review the configuration tables for correctness
3. Verify all prerequisite tables exist (HLR1, HLR2, CLEAN_SV_ALL_UPD, etc.)
4. Check database permissions and tablespace availability

---

## Version History

- **R1.2_TE** (2025-12-15) - Enhanced version with:
  - Activity tracing
  - Configuration management
  - "_TE" suffix for all objects
  - Dynamic SQL generation
  - Performance tracking

- **R1.1** (2009-11-01) - Previous version with hardcoded values

---

## Appendix: Complete Object List

### Tables (27 total)
1. SYS_MINSAT_TE
2. HLR1_APN_DATA_TE
3. HLR1_PARAM_TE
4. MERGE_HLR1_APN_TE
5. HLR2_APN_DATA_TE
6. HLR2_PARAM_TE
7. MERGE_HLR2_APN_TE
8. REP_SV_MSISDN_IN_MISP_TE
9. REP_SV_MSISDN_NOT_MISP_TE
10. MERGE_SYS_SV_CS4_TE
11. CLEAN_ALL_SYS_MERGED_TE
12. MERGE_HLR1_HLR2_1_TE
13. MERGE_HLR1_HLR2_2_TE
14. MERGE_HLR1_HLR2_TE
15. REP_HLRS_MIS_MSISDN_TE
16. REP_HLRS_MIS_IMSI_TE
17. CLEAN_HLRS_MERGED_TE
18. MERGE_SYS_HLRS_TE
19. REP_CLEAN_ALL_MERGED_TE
20. REP_ADM_DMP_HLR1_TE
21. REP_ADM_DMP_HLR2_TE
22. UNION_APNS_TE
23. REP_APN_SYS_ALL_TE
24. list_null_cp_group_TE
25. P1_ACTIVITY_TRACE_TE
26. P1_APN_CONFIG_TE
27. P1_SDP_ROUTING_CONFIG_TE
28. P1_HLR_CONFIG_TE
29. P1_PRODUCT_CONFIG_TE
30. P1_SYSTEM_CONFIG_TE

### Views
1. V_P1_ACTIVE_CONFIG_TE

### Packages
1. P1_CONFIG_HELPER_PKG_TE

### Procedures
1. P1_MAIN_SYS_INTERFACES_TE

---

**END OF DOCUMENTATION**
