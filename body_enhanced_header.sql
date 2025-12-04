CREATE OR REPLACE PACKAGE BODY RECONCILIATION_INTERFACES IS

-- =============================================================================================
-- PACKAGE-LEVEL CONSTANTS FOR RECONCILIATION
-- Added: 2025-12-04 - Wave 1 Enhancement (E9)
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

-- Default values
c_DEFAULT_ZERO           CONSTANT NUMBER := 0;

-- Package-level variables for logging
g_current_run_id VARCHAR2(50);
g_step_start_time TIMESTAMP;

-- =============================================================================================
-- LOGGING PROCEDURES
-- Added: 2025-12-04 - Wave 1 Enhancement (E7)
-- =============================================================================================

PROCEDURE log_step_start(p_step_name IN VARCHAR2) IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  g_step_start_time := SYSTIMESTAMP;

  INSERT INTO RECON_EXECUTION_LOG (
    run_id, procedure_name, step_name, step_status, start_time
  ) VALUES (
    g_current_run_id, 'P1_MAIN_SYS_INTERFACES', p_step_name, 'STARTED', g_step_start_time
  );
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    -- Silent fail - logging should not break main process
    NULL;
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
    AND step_status = 'STARTED'
    AND ROWNUM = 1;

  IF SQL%ROWCOUNT = 0 THEN
    -- If no matching STARTED record, insert directly as COMPLETED
    INSERT INTO RECON_EXECUTION_LOG (
      run_id, procedure_name, step_name, step_status, start_time, end_time, elapsed_seconds, row_count
    ) VALUES (
      g_current_run_id, 'P1_MAIN_SYS_INTERFACES', p_step_name, p_status, SYSTIMESTAMP, SYSTIMESTAMP, 0, p_row_count
    );
  END IF;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
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
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END log_error;

-- =============================================================================================
-- FUNCTION: NORMALIZE_MSISDN
-- Added: 2025-12-04 - Wave 1 Enhancement (E1)
-- Purpose: Normalize MSISDN by removing country code and adding leading zero
-- Input: Raw NUM_APPEL from HLR/billing system (format: country code + number)
-- Output: Normalized MSISDN (format: 0XXXXXXX or XXXXXXXX)
-- Logic: Removes first 3 digits (country code 961), adds '0' prefix for certain patterns
-- =============================================================================================
FUNCTION NORMALIZE_MSISDN(p_num_appel VARCHAR2) RETURN VARCHAR2 IS
  v_normalized VARCHAR2(20);
  v_first_digit CHAR(1);
BEGIN
  IF p_num_appel IS NULL THEN
    RETURN NULL;
  END IF;

  -- Remove country code (first 3 digits, position 1-3), keep from position 4 onwards
  v_normalized := SUBSTR(p_num_appel, 4);

  -- Get first digit of the remaining number
  v_first_digit := SUBSTR(v_normalized, 1, 1);

  -- Add leading '0' for mobile numbers starting with 1 or 3
  -- Numbers starting with 7 or 8 are returned as-is
  IF v_first_digit IN ('1', '3') THEN
    v_normalized := '0' || v_normalized;
  END IF;

  RETURN v_normalized;

EXCEPTION
  WHEN OTHERS THEN
    -- Log error and return NULL on any exception
    log_error('NORMALIZE_MSISDN', 'Error normalizing: ' || p_num_appel || ' - ' || SQLERRM);
    RETURN NULL;
END NORMALIZE_MSISDN;

-- =============================================================================================
-- Helper function to build MSISDN normalization SQL for inline use in queries
-- =============================================================================================
FUNCTION GET_MSISDN_NORMALIZE_SQL(p_column_name VARCHAR2) RETURN VARCHAR2 IS
BEGIN
  RETURN 'DECODE(SUBSTR(SUBSTR(' || p_column_name || ', 4), 1, 1), ' ||
         '8, SUBSTR(' || p_column_name || ', 4), ' ||
         '7, SUBSTR(' || p_column_name || ', 4), ' ||
         '3, ''0'' || SUBSTR(' || p_column_name || ', 4), ' ||
         '1, ''0'' || SUBSTR(' || p_column_name || ', 4))';
END GET_MSISDN_NORMALIZE_SQL;

