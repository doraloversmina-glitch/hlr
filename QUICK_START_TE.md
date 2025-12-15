# P1_MAIN_SYS_INTERFACES_TE - Quick Start Guide

## What Was Done?

The P1_MAIN_SYS_INTERFACES procedure has been enhanced with:

✅ **All objects now have "_TE" suffix** (tables, indexes, procedures)
✅ **Activity tracing** - Every step logged with timing and row counts
✅ **Configuration tables** - No more hardcoded values
✅ **Enhanced error handling** - Detailed error messages and automatic rollback
✅ **Performance tracking** - Duration and row counts for each operation

---

## Quick Installation (3 Steps)

```bash
# Run from SQL*Plus or SQL Developer
sqlplus username/password@database

# Execute the installation script
@INSTALL_P1_TE.sql
```

That's it! The script will:
1. Create configuration tables
2. Create helper package
3. Verify everything is working

---

## Files Overview

| File | Purpose |
|------|---------|
| `P1_CONFIG_TABLES_TE.sql` | Configuration tables (APN, SDP, HLR, Products) |
| `P1_CONFIG_HELPER_PKG_TE.sql` | Helper package for dynamic SQL |
| `P1_MAIN_SYS_INTERFACES_TE.sql` | Enhanced main procedure |
| `INSTALL_P1_TE.sql` | One-click installation script |
| `P1_ENHANCEMENT_README_TE.md` | Complete documentation |
| `QUICK_START_TE.md` | This file |

---

## Configuration Tables

### 1. APN Configuration (`P1_APN_CONFIG_TE`)
Manages APN definitions instead of hardcoding them.

**Example**: Add a new APN
```sql
INSERT INTO P1_APN_CONFIG_TE (APN_ID, APN_NAME, APN_DESCRIPTION, COMPANION_PRODUCT, PRIORITY_ORDER)
VALUES ('99', 'NEW_APN', 'New Service', 'New Product', 14);
```

### 2. SDP Routing (`P1_SDP_ROUTING_CONFIG_TE`)
Defines which SDP to use based on MSISDN ranges.

**Example**: Add a new SDP route
```sql
INSERT INTO P1_SDP_ROUTING_CONFIG_TE (MSISDN_RANGE_START, MSISDN_RANGE_END, SDP_NAME, PRIORITY_ORDER)
VALUES (82000000, 82999999, 'SDP07', 16);
```

### 3. HLR Configuration (`P1_HLR_CONFIG_TE`)
Maps IMSI prefixes to HLR numbers.

**Example**: View HLR mappings
```sql
SELECT IMSI_PREFIX, HLR_NUMBER, HLR_NAME FROM P1_HLR_CONFIG_TE WHERE ACTIVE_FLAG = 'Y';
```

### 4. Product Configuration (`P1_PRODUCT_CONFIG_TE`)
Defines MISP products and rate plans.

**Example**: Add a new rate plan
```sql
INSERT INTO P1_PRODUCT_CONFIG_TE (PRODUCT_TYPE_NAME, RATE_PLAN, CATEGORY, DESCRIPTION)
VALUES ('Mobile Broadband Prepaid', 60, 'MISP', 'New MISP Plan');
```

---

## Activity Tracing

Every execution is tracked in `P1_ACTIVITY_TRACE_TE`.

### View Last Execution
```sql
SELECT
    STEP_NUMBER,
    STEP_NAME,
    STEP_STATUS,
    DURATION_SECONDS,
    ROWS_AFFECTED,
    TO_CHAR(START_TIME, 'HH24:MI:SS') as TIME
FROM P1_ACTIVITY_TRACE_TE
WHERE SESSION_ID = USERENV('SESSIONID')
ORDER BY STEP_NUMBER;
```

### Find Errors
```sql
SELECT
    STEP_NAME,
    ERROR_MESSAGE,
    START_TIME
FROM P1_ACTIVITY_TRACE_TE
WHERE STEP_STATUS = 'FAILED'
ORDER BY START_TIME DESC;
```

### Performance Summary
```sql
SELECT
    COUNT(*) as TOTAL_STEPS,
    SUM(DURATION_SECONDS) as TOTAL_TIME_SEC,
    MIN(START_TIME) as STARTED,
    MAX(END_TIME) as COMPLETED
FROM P1_ACTIVITY_TRACE_TE
WHERE SESSION_ID = 'your_session_id';
```

---

## Running the Procedure

```sql
DECLARE
    v_result VARCHAR2(1000);
BEGIN
    P1_MAIN_SYS_INTERFACES_TE(
        INTEGRATION_LOG_ID => 'RUN_001',
        RESULT => v_result,
        P_ENT_TYPE => 4,
        P_ENT_CODE => 1
    );

    DBMS_OUTPUT.PUT_LINE('Result: ' || v_result);
END;
/
```

---

## Tables Created (All with _TE Suffix)

The procedure creates 24 tables:

**HLR Data**:
- `HLR1_APN_DATA_TE`, `HLR1_PARAM_TE`, `MERGE_HLR1_APN_TE`
- `HLR2_APN_DATA_TE`, `HLR2_PARAM_TE`, `MERGE_HLR2_APN_TE`
- `MERGE_HLR1_HLR2_TE`, `CLEAN_HLRS_MERGED_TE`

**System Data**:
- `SYS_MINSAT_TE`
- `MERGE_SYS_SV_CS4_TE`, `CLEAN_ALL_SYS_MERGED_TE`
- `MERGE_SYS_HLRS_TE`

**Reports**:
- `REP_SV_MSISDN_IN_MISP_TE`, `REP_SV_MSISDN_NOT_MISP_TE`
- `REP_HLRS_MIS_MSISDN_TE`, `REP_HLRS_MIS_IMSI_TE`
- `REP_CLEAN_ALL_MERGED_TE`
- `REP_ADM_DMP_HLR1_TE`, `REP_ADM_DMP_HLR2_TE`
- `UNION_APNS_TE`, `REP_APN_SYS_ALL_TE`

---

## Common Tasks

### View All Active Configurations
```sql
SELECT * FROM V_P1_ACTIVE_CONFIG_TE ORDER BY CONFIG_TYPE, CONFIG_KEY;
```

### Disable a Configuration (Without Deleting)
```sql
UPDATE P1_APN_CONFIG_TE SET ACTIVE_FLAG = 'N' WHERE APN_ID = '99';
COMMIT;
```

### Clean Old Trace Records
```sql
DELETE FROM P1_ACTIVITY_TRACE_TE WHERE CREATED_DATE < SYSDATE - 90;
COMMIT;
```

### Check System Settings
```sql
SELECT CONFIG_KEY, CONFIG_VALUE FROM P1_SYSTEM_CONFIG_TE WHERE ACTIVE_FLAG = 'Y';
```

---

## Before/After Comparison

### Before (Hardcoded)
```sql
-- Hardcoded APN IDs
max( decode( APN_ID, '20', APN_ID, null ) ) AS WLL_APN1,
max( decode( APN_ID, '15', APN_ID, null ) ) AS ALFA_APN1,
-- ... 10+ more lines ...

-- Hardcoded SDP routing
when (to_number(M.MSISDN) between 71900000 and 71999999) then 'SDP05'
when (to_number(M.MSISDN) between 71800000 and 71899999) then 'SDP06'
-- ... 15+ more lines ...

-- No activity tracking
-- No error logging
-- No performance metrics
```

### After (Configuration-Based)
```sql
-- APNs from configuration table
P1_APN_CONFIG_TE

-- SDP routing from configuration table
P1_SDP_ROUTING_CONFIG_TE

-- Full activity tracking
P1_ACTIVITY_TRACE_TE

-- Automatic error handling
-- Performance metrics
-- Row counts
-- Duration tracking
```

---

## Benefits

1. **Easy Maintenance**: Change APN/SDP/Product configs without touching code
2. **Full Audit Trail**: See exactly what happened and when
3. **Performance Insights**: Know which steps take the longest
4. **Better Debugging**: Detailed error messages and step tracking
5. **Flexible**: Enable/disable features via configuration

---

## Troubleshooting

### Installation Failed?
```sql
-- Check for missing prerequisites
SELECT * FROM USER_TABLES WHERE TABLE_NAME IN ('HLR1', 'HLR2', 'CLEAN_SV_ALL_UPD');

-- Check for errors
SELECT * FROM USER_ERRORS WHERE NAME LIKE 'P1%TE%';
```

### Procedure Failed?
```sql
-- Check last error
SELECT STEP_NAME, ERROR_MESSAGE, START_TIME
FROM P1_ACTIVITY_TRACE_TE
WHERE STEP_STATUS = 'FAILED'
ORDER BY START_TIME DESC
FETCH FIRST 1 ROW ONLY;
```

### Performance Issues?
```sql
-- Find slowest steps
SELECT STEP_NAME, DURATION_SECONDS, ROWS_AFFECTED
FROM P1_ACTIVITY_TRACE_TE
WHERE SESSION_ID = 'your_session_id'
ORDER BY DURATION_SECONDS DESC;
```

---

## Next Steps

1. ✅ Install using `@INSTALL_P1_TE.sql`
2. ✅ Review configurations in `V_P1_ACTIVE_CONFIG_TE`
3. ✅ Deploy main procedure `P1_MAIN_SYS_INTERFACES_TE`
4. ✅ Test with sample data
5. ✅ Monitor using `P1_ACTIVITY_TRACE_TE`
6. ✅ Adjust configurations as needed

---

## Support

📖 **Full Documentation**: See `P1_ENHANCEMENT_README_TE.md`
🔧 **Configuration**: Edit tables in `P1_CONFIG_TABLES_TE.sql`
📊 **Monitoring**: Query `P1_ACTIVITY_TRACE_TE`
🎯 **Testing**: Use `INSTALL_P1_TE.sql` to verify

---

## Key Improvements Summary

| Feature | Before | After |
|---------|--------|-------|
| Hardcoded values | ✗ Yes, scattered everywhere | ✓ None, all in config tables |
| Activity tracking | ✗ No tracking | ✓ Complete audit trail |
| Error handling | ✗ Basic | ✓ Enhanced with details |
| Performance metrics | ✗ None | ✓ Duration + row counts |
| Maintainability | ✗ Requires code changes | ✓ Config-driven |
| Object naming | ✗ Mixed | ✓ All have _TE suffix |
| Documentation | ✗ Limited | ✓ Comprehensive |

---

**Ready to use! 🚀**
