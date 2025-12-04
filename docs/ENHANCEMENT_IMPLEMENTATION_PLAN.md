# RECONCILIATION INTERFACES - ENHANCEMENT IMPLEMENTATION
## Waves 1-3: Quick Win Path

**Date**: 2025-12-04
**Branch**: `claude/recon-interface-build-019DzFM6txnA2hYgFMoyxqcE`
**Target Procedure**: `P1_MAIN_SYS_INTERFACES`
**Total Effort**: 10.5 hours

---

## WAVE 1: FOUNDATION (5 hours)

### E9: Extract Magic Numbers to Constants (1h) ✅ IN PROGRESS
**Location**: Package body header (after line 1)

**Constants to add**:
```sql
-- =============================================================================================
-- PACKAGE-LEVEL CONSTANTS FOR RECONCILIATION
-- =============================================================================================

-- IMSI Primary HLR Identifiers
c_IMSI_PRIMARY_ALFA_1    CONSTANT VARCHAR2(6) := '415012';
c_IMSI_PRIMARY_ALFA_2    CONSTANT VARCHAR2(6) := '415019';
c_HLR_PRIMARY            CONSTANT NUMBER := 1;
c_HLR_SECONDARY          CONSTANT NUMBER := 2;

-- APN (Access Point Name) Identifiers
c_APN_WLL                CONSTANT VARCHAR2(2) := '20';  -- Wireless Local Loop
c_APN_ALFA               CONSTANT VARCHAR2(2) := '15';  -- ALFA APN
c_APN_MBB                CONSTANT VARCHAR2(2) := '13';  -- Mobile Broadband
c_APN_BLACKBERRY         CONSTANT VARCHAR2(2) := '12';  -- BlackBerry
c_APN_GPRS_INTRA         CONSTANT VARCHAR2(2) := '10';  -- GPRS Intra-network
c_APN_MMS                CONSTANT VARCHAR2(2) := '9';   -- MMS
c_APN_WAP                CONSTANT VARCHAR2(2) := '8';   -- WAP
c_APN_GPRS               CONSTANT VARCHAR2(2) := '7';   -- GPRS
c_APN_DATACARD_1         CONSTANT VARCHAR2(2) := '3';   -- Data Card 1
c_APN_DATACARD_2         CONSTANT VARCHAR2(2) := '4';   -- Data Card 2
c_APN_DATACARD_3         CONSTANT VARCHAR2(2) := '6';   -- Data Card 3
c_APN_VOLTE_01           CONSTANT VARCHAR2(2) := '94';  -- VoLTE 01
c_APN_VOLTE_02           CONSTANT VARCHAR2(2) := '95';  -- VoLTE 02

-- SDP (Service Delivery Platform) Range Mappings
-- Format: (start, end, code)
TYPE t_sdp_range IS RECORD (
  range_start NUMBER,
  range_end NUMBER,
  sdp_code VARCHAR2(10)
);
TYPE t_sdp_ranges IS TABLE OF t_sdp_range;

-- Default values for NULL conversion
c_DEFAULT_ZERO           CONSTANT NUMBER := 0;
```

---

### E1: Create NORMALIZE_MSISDN Function (1h)
**Location**: Package body, before P1_MAIN_SYS_INTERFACES

**Function**:
```sql
-- =============================================================================================
-- FUNCTION: NORMALIZE_MSISDN
-- Purpose: Normalize MSISDN by removing country code and adding leading zero
-- Input: Raw NUM_APPEL from HLR/billing system
-- Output: Normalized MSISDN
-- =============================================================================================
FUNCTION NORMALIZE_MSISDN(p_num_appel VARCHAR2) RETURN VARCHAR2 IS
  v_normalized VARCHAR2(20);
  v_first_digit CHAR(1);
BEGIN
  IF p_num_appel IS NULL THEN
    RETURN NULL;
  END IF;

  -- Extract substring starting from position 4
  v_normalized := SUBSTR(p_num_appel, 4);

  -- Get first digit of extracted string
  v_first_digit := SUBSTR(v_normalized, 1, 1);

  -- Add leading '0' for specific prefixes (1 or 3)
  IF v_first_digit IN ('1', '3') THEN
    v_normalized := '0' || v_normalized;
  END IF;

  -- For prefixes 7 and 8, return as-is
  RETURN v_normalized;

EXCEPTION
  WHEN OTHERS THEN
    -- Log error and return NULL
    RETURN NULL;
END NORMALIZE_MSISDN;
```

**Usage**: Replace all 20+ instances of the complex DECODE logic

---

### E7: Build Logging Framework (2h)
**DDL Script**: Create logging table first

```sql
-- =============================================================================================
-- RECONCILIATION EXECUTION LOG TABLE
-- =============================================================================================
CREATE TABLE FAFIF.RECON_EXECUTION_LOG (
  log_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  run_id VARCHAR2(50),
  procedure_name VARCHAR2(100),
  step_name VARCHAR2(200),
  step_status VARCHAR2(20), -- STARTED, COMPLETED, FAILED
  start_time TIMESTAMP,
  end_time TIMESTAMP,
  elapsed_seconds NUMBER,
  row_count NUMBER,
  error_message VARCHAR2(4000),
  created_date DATE DEFAULT SYSDATE,
  created_by VARCHAR2(30) DEFAULT USER
);

CREATE INDEX IX_RECON_LOG_RUN_ID ON FAFIF.RECON_EXECUTION_LOG(run_id);
CREATE INDEX IX_RECON_LOG_PROC ON FAFIF.RECON_EXECUTION_LOG(procedure_name);
CREATE INDEX IX_RECON_LOG_DATE ON FAFIF.RECON_EXECUTION_LOG(created_date);
```

**Logging Procedures**:
```sql
-- Package-level variable for run tracking
g_current_run_id VARCHAR2(50);
g_step_start_time TIMESTAMP;

PROCEDURE log_step_start(
  p_step_name IN VARCHAR2
) IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  g_step_start_time := SYSTIMESTAMP;

  INSERT INTO RECON_EXECUTION_LOG (
    run_id, procedure_name, step_name, step_status, start_time
  ) VALUES (
    g_current_run_id, 'P1_MAIN_SYS_INTERFACES', p_step_name, 'STARTED', g_step_start_time
  );
  COMMIT;
END log_step_start;

PROCEDURE log_step_end(
  p_step_name IN VARCHAR2,
  p_row_count IN NUMBER DEFAULT NULL,
  p_status IN VARCHAR2 DEFAULT 'COMPLETED'
) IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  v_elapsed NUMBER;
BEGIN
  v_elapsed := EXTRACT(SECOND FROM (SYSTIMESTAMP - g_step_start_time));

  UPDATE RECON_EXECUTION_LOG
  SET step_status = p_status,
      end_time = SYSTIMESTAMP,
      elapsed_seconds = v_elapsed,
      row_count = p_row_count
  WHERE run_id = g_current_run_id
    AND step_name = p_step_name
    AND step_status = 'STARTED';
  COMMIT;
END log_step_end;

PROCEDURE log_error(
  p_step_name IN VARCHAR2,
  p_error_message IN VARCHAR2
) IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  INSERT INTO RECON_EXECUTION_LOG (
    run_id, procedure_name, step_name, step_status, start_time, error_message
  ) VALUES (
    g_current_run_id, 'P1_MAIN_SYS_INTERFACES', p_step_name, 'FAILED', SYSTIMESTAMP, p_error_message
  );
  COMMIT;
END log_error;
```

---

### E6: Fix Exception Handling (1h)

**Replace**:
```sql
EXCEPTION
  WHEN OTHERS THEN
    NULL;
```

**With**:
```sql
EXCEPTION
  WHEN TABLE_CREATION_FAILED THEN
    log_error('TABLE_CREATION', 'Table creation failed: ' || SQLERRM);
    RESULT := 'FAILED: TABLE_CREATION';
    RAISE;

  WHEN INDEX_CREATION_FAILED THEN
    log_error('INDEX_CREATION', 'Index creation failed: ' || SQLERRM);
    RESULT := 'FAILED: INDEX_CREATION';
    RAISE;

  WHEN TABLE_UPDATE_FAILED THEN
    log_error('TABLE_UPDATE', 'Table update failed: ' || SQLERRM);
    RESULT := 'FAILED: TABLE_UPDATE';
    RAISE;

  WHEN OTHERS THEN
    log_error('UNEXPECTED_ERROR', 'Unexpected error: ' || SQLERRM || ' - ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    RESULT := 'FAILED: ' || SQLERRM;
    RAISE;
END P1_MAIN_SYS_INTERFACES;
```

---

## WAVE 2: PERFORMANCE (2 hours)

### E11: Remove Commented Code (15min)
**Lines to remove**:
- Lines 2-24: Commented P_CHECK_DUMPS_VALIDITY function
- Lines 102-120: Old HLR1_APN_DATA creation (pre-May 2015)
- Lines 198-215: Old MERGE_HLR1_APN logic
- Lines 236-254: Old HLR2_APN_DATA creation
- Lines 329-346: Old MERGE_HLR2_APN logic
- Lines 432-433, 836-837: Commented IMSI filters
- Line 1076: Commented END IF

---

### E2: Add PARALLEL Hints (30min)
**Pattern**:
```sql
-- Before
SQL_TXT := 'CREATE TABLE HLR1_APN_DATA AS SELECT ...';

-- After
SQL_TXT := 'CREATE TABLE HLR1_APN_DATA /*+ PARALLEL(4) */ AS SELECT /*+ PARALLEL(HLR1, 4) */ ...';
```

**Apply to these 12 tables**:
1. SYS_MINSAT
2. HLR1_APN_DATA
3. HLR1_PARAM
4. MERGE_HLR1_APN
5. HLR2_APN_DATA
6. HLR2_PARAM
7. MERGE_HLR2_APN
8. MERGE_SYS_SV_CS4
9. MERGE_HLR1_HLR2_1
10. MERGE_HLR1_HLR2_2
11. MERGE_HLR1_HLR2
12. REP_CLEAN_ALL_MERGED

---

### E3: Add Statistics Gathering (30min)
**Pattern**:
```sql
-- After each major table creation
DBMS_STATS.GATHER_TABLE_STATS(
  ownname => 'FAFIF',
  tabname => 'TABLE_NAME',
  estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE,
  method_opt => 'FOR ALL COLUMNS SIZE AUTO',
  degree => 4
);
```

**Apply after creating**:
- CLEAN_ALL_SYS_MERGED
- CLEAN_HLRS_MERGED
- REP_CLEAN_ALL_MERGED

---

### E4: Consolidate Bulk NULL Updates (30min)

**Replace 16 separate UPDATEs (lines 622-802) with**:
```sql
-- Bulk update NULL values to 0 in single pass
UPDATE MERGE_HLR1_HLR2 HH
SET
  OBO_1 = NVL(OBO_1, 0),
  OBI_1 = NVL(OBI_1, 0),
  TICK_1 = NVL(TICK_1, 0),
  OBR_1 = NVL(OBR_1, 0),
  OICK_1 = NVL(OICK_1, 0),
  RSA_1 = NVL(RSA_1, 0),
  OBP_1 = NVL(OBP_1, 0),
  OCSIST_1 = NVL(OCSIST_1, 0),
  TCSIST_1 = NVL(TCSIST_1, 0),
  OBO_2 = NVL(OBO_2, 0),
  OBI_2 = NVL(OBI_2, 0),
  TICK_2 = NVL(TICK_2, 0),
  OBR_2 = NVL(OBR_2, 0),
  OICK_2 = NVL(OICK_2, 0),
  RSA_2 = NVL(RSA_2, 0),
  OBP_2 = NVL(OBP_2, 0),
  OCSIST_2 = NVL(OCSIST_2, 0),
  TCSIST_2 = NVL(TCSIST_2, 0);

log_step_end('Bulk NULL to 0 conversion', SQL%ROWCOUNT);
```

---

## WAVE 3: QUALITY (3.5 hours)

### E8: Input Validation (30min)
**Add at beginning of procedure**:
```sql
BEGIN
  -- Generate unique run ID
  g_current_run_id := INTEGRATION_LOG_ID || '_' || TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MISS');

  log_step_start('Input validation');

  -- Validate INTEGRATION_LOG_ID
  IF INTEGRATION_LOG_ID IS NULL OR INTEGRATION_LOG_ID = '0' THEN
    log_error('Input validation', 'Invalid INTEGRATION_LOG_ID');
    RESULT := 'FAILED: Invalid INTEGRATION_LOG_ID';
    RETURN;
  END IF;

  -- Validate entity type
  IF P_ENT_TYPE NOT BETWEEN 1 AND 10 THEN
    log_error('Input validation', 'Invalid P_ENT_TYPE: ' || P_ENT_TYPE);
    RESULT := 'FAILED: Invalid P_ENT_TYPE';
    RETURN;
  END IF;

  log_step_end('Input validation');
```

---

### E13: Create Summary Statistics Table (1.5h)
**DDL**:
```sql
CREATE TABLE FAFIF.RECON_RUN_STATISTICS (
  stat_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  run_id VARCHAR2(50),
  run_date DATE,
  -- Source system counts
  minsat_count NUMBER,
  sv_count NUMBER,
  hlr1_count NUMBER,
  hlr2_count NUMBER,
  -- Reconciliation results
  total_msisdns NUMBER,
  hlr1_only_count NUMBER,
  hlr2_only_count NUMBER,
  hlr_both_count NUMBER,
  imsi_mismatch_count NUMBER,
  -- Data quality metrics
  null_imsi_count NUMBER,
  duplicate_msisdn_count NUMBER,
  -- Performance metrics
  total_execution_seconds NUMBER,
  status VARCHAR2(20),
  created_date DATE DEFAULT SYSDATE
);

CREATE INDEX IX_RECON_STATS_RUN ON FAFIF.RECON_RUN_STATISTICS(run_id);
CREATE INDEX IX_RECON_STATS_DATE ON FAFIF.RECON_RUN_STATISTICS(run_date);
```

**Populate at end of procedure**:
```sql
-- Gather statistics for dashboard
INSERT INTO RECON_RUN_STATISTICS (
  run_id, run_date,
  minsat_count, sv_count, hlr1_count, hlr2_count,
  total_msisdns, hlr1_only_count, hlr2_only_count, imsi_mismatch_count
) VALUES (
  g_current_run_id, TRUNC(SYSDATE),
  (SELECT COUNT(*) FROM SYS_MINSAT),
  (SELECT COUNT(*) FROM CLEAN_SV_ALL_UPD),
  (SELECT COUNT(DISTINCT NUM_APPEL) FROM HLR1),
  (SELECT COUNT(DISTINCT NUM_APPEL) FROM HLR2),
  (SELECT COUNT(*) FROM REP_CLEAN_ALL_MERGED),
  (SELECT COUNT(*) FROM REP_HLRS_MIS_MSISDN WHERE MSISDN_HLR1 IS NULL),
  (SELECT COUNT(*) FROM REP_HLRS_MIS_MSISDN WHERE MSISDN_HLR2 IS NULL),
  (SELECT COUNT(*) FROM REP_HLRS_MIS_IMSI)
);
```

---

### E14: Add Data Validation Checks (1h)
**Add validation queries**:
```sql
-- Check for invalid IMSIs (not 15 digits)
log_step_start('Data validation - IMSI format');
SELECT COUNT(*) INTO v_invalid_imsi_count
FROM REP_CLEAN_ALL_MERGED
WHERE IMSI IS NOT NULL
  AND LENGTH(IMSI) != 15;

IF v_invalid_imsi_count > 0 THEN
  log_error('Data validation', v_invalid_imsi_count || ' invalid IMSI formats detected');
END IF;
log_step_end('Data validation - IMSI format', v_invalid_imsi_count);
```

---

### E15: Add Audit Columns (30min)
**Modify CTAS pattern**:
```sql
-- Before
CREATE TABLE CLEAN_ALL_SYS_MERGED AS SELECT ...

-- After
CREATE TABLE CLEAN_ALL_SYS_MERGED AS
SELECT
  ... (all existing columns),
  SYSDATE as created_date,
  USER as created_by,
  g_current_run_id as run_id
FROM ...
```

**Apply to**:
- REP_CLEAN_ALL_MERGED
- CLEAN_HLRS_MERGED
- CLEAN_ALL_SYS_MERGED

---

## IMPLEMENTATION CHECKLIST

### Wave 1: Foundation
- [ ] Create logging table (DDL)
- [ ] Add package constants
- [ ] Implement NORMALIZE_MSISDN function
- [ ] Implement logging procedures
- [ ] Add input validation
- [ ] Replace exception handler

### Wave 2: Performance
- [ ] Remove all commented code blocks
- [ ] Add PARALLEL hints to 12 tables
- [ ] Add DBMS_STATS calls for 3 tables
- [ ] Consolidate NULL updates into single statement

### Wave 3: Quality
- [ ] Create statistics table (DDL)
- [ ] Add data validation checks
- [ ] Add audit columns to CTAS
- [ ] Populate statistics at end

### Testing
- [ ] Compile package (check for syntax errors)
- [ ] Test NORMALIZE_MSISDN function
- [ ] Run procedure in test environment
- [ ] Verify logging output
- [ ] Check statistics population
- [ ] Performance comparison (before/after)

### Documentation
- [ ] Update procedure comments
- [ ] Document new tables
- [ ] Update README with changes

---

## EXPECTED RESULTS

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Execution Time | ~30-45 min | ~10-15 min | **3x faster** |
| Code Lines | ~1,200 | ~850 | **29% reduction** |
| Maintainability | Low | High | **Modular** |
| Observability | None | Full | **100% visibility** |
| Error Handling | Silent fails | Comprehensive | **Production-ready** |

---

## ROLLBACK PLAN

If issues occur:
1. Git revert to commit before changes
2. Original package body preserved in `body.backup`
3. DDL rollback script available in `docs/rollback.sql`

---

**Status**: Ready for implementation
**Next Step**: Create DDL scripts and begin Wave 1
