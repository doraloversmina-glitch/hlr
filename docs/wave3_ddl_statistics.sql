-- =============================================================================================
-- WAVE 3: DDL FOR STATISTICS INFRASTRUCTURE
-- Purpose: Create summary statistics table for reconciliation dashboard
-- Date: 2025-12-04
-- =============================================================================================

-- Drop existing tables if they exist (for clean reinstall)
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE FAFIF.RECON_RUN_STATISTICS CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- =============================================================================================
-- RECONCILIATION RUN STATISTICS TABLE
-- Stores high-level metrics for each reconciliation run
-- =============================================================================================
CREATE TABLE FAFIF.RECON_RUN_STATISTICS (
  stat_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  run_id VARCHAR2(50) NOT NULL,
  run_date DATE NOT NULL,

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
  invalid_imsi_format_count NUMBER,

  -- Performance metrics
  total_execution_seconds NUMBER,
  status VARCHAR2(20),

  -- Audit fields
  created_date DATE DEFAULT SYSDATE NOT NULL,
  created_by VARCHAR2(30) DEFAULT USER NOT NULL,

  -- Constraints
  CONSTRAINT chk_status CHECK (status IN ('SUCCESS', 'FAILED', 'PARTIAL'))
);

-- Create indexes for efficient querying and dashboards
CREATE INDEX IX_RECON_STATS_RUN ON FAFIF.RECON_RUN_STATISTICS(run_id);
CREATE INDEX IX_RECON_STATS_DATE ON FAFIF.RECON_RUN_STATISTICS(run_date);
CREATE INDEX IX_RECON_STATS_STATUS ON FAFIF.RECON_RUN_STATISTICS(status);

-- Add comments for documentation
COMMENT ON TABLE FAFIF.RECON_RUN_STATISTICS IS 'Summary statistics for each reconciliation run - used for dashboards and trend analysis';
COMMENT ON COLUMN FAFIF.RECON_RUN_STATISTICS.run_id IS 'Unique identifier matching RECON_EXECUTION_LOG';
COMMENT ON COLUMN FAFIF.RECON_RUN_STATISTICS.minsat_count IS 'Total records in MINSAT/CS4 system';
COMMENT ON COLUMN FAFIF.RECON_RUN_STATISTICS.sv_count IS 'Total records in SV (Service Validation) system';
COMMENT ON COLUMN FAFIF.RECON_RUN_STATISTICS.hlr1_count IS 'Total MSISDNs in HLR1';
COMMENT ON COLUMN FAFIF.RECON_RUN_STATISTICS.hlr2_count IS 'Total MSISDNs in HLR2';
COMMENT ON COLUMN FAFIF.RECON_RUN_STATISTICS.hlr1_only_count IS 'MSISDNs found only in HLR1 (missing in HLR2)';
COMMENT ON COLUMN FAFIF.RECON_RUN_STATISTICS.hlr2_only_count IS 'MSISDNs found only in HLR2 (missing in HLR1)';
COMMENT ON COLUMN FAFIF.RECON_RUN_STATISTICS.imsi_mismatch_count IS 'MSISDNs with different IMSIs between HLR1 and HLR2';

-- Grant permissions (adjust as needed for your environment)
GRANT SELECT, INSERT, UPDATE ON FAFIF.RECON_RUN_STATISTICS TO PUBLIC;

-- =============================================================================================
-- SAMPLE DASHBOARD QUERIES
-- =============================================================================================

-- Daily reconciliation trend (last 30 days)
/*
SELECT
  run_date,
  total_msisdns,
  hlr1_only_count,
  hlr2_only_count,
  imsi_mismatch_count,
  ROUND(total_execution_seconds/60, 2) as execution_minutes
FROM FAFIF.RECON_RUN_STATISTICS
WHERE run_date >= SYSDATE - 30
ORDER BY run_date DESC;
*/

-- Data quality summary
/*
SELECT
  run_date,
  null_imsi_count,
  duplicate_msisdn_count,
  invalid_imsi_format_count,
  ROUND((null_imsi_count / total_msisdns) * 100, 2) as null_imsi_pct
FROM FAFIF.RECON_RUN_STATISTICS
WHERE run_date >= SYSDATE - 7
ORDER BY run_date DESC;
*/

PROMPT 'Statistics infrastructure created successfully';
PROMPT 'Table: FAFIF.RECON_RUN_STATISTICS';
PROMPT 'Indexes: 3 created';
PROMPT 'Sample queries available in comments';
