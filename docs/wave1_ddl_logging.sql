-- =============================================================================================
-- WAVE 1: DDL FOR LOGGING INFRASTRUCTURE
-- Purpose: Create logging tables for reconciliation execution tracking
-- Date: 2025-12-04
-- =============================================================================================

-- Drop existing tables if they exist (for clean reinstall)
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE FAFIF.RECON_EXECUTION_LOG CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- =============================================================================================
-- RECONCILIATION EXECUTION LOG TABLE
-- Tracks each step of reconciliation procedure execution
-- =============================================================================================
CREATE TABLE FAFIF.RECON_EXECUTION_LOG (
  log_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  run_id VARCHAR2(50) NOT NULL,
  procedure_name VARCHAR2(100) NOT NULL,
  step_name VARCHAR2(200) NOT NULL,
  step_status VARCHAR2(20) NOT NULL, -- STARTED, COMPLETED, FAILED
  start_time TIMESTAMP NOT NULL,
  end_time TIMESTAMP,
  elapsed_seconds NUMBER,
  row_count NUMBER,
  error_message VARCHAR2(4000),
  created_date DATE DEFAULT SYSDATE NOT NULL,
  created_by VARCHAR2(30) DEFAULT USER NOT NULL
);

-- Create indexes for efficient querying
CREATE INDEX IX_RECON_LOG_RUN_ID ON FAFIF.RECON_EXECUTION_LOG(run_id);
CREATE INDEX IX_RECON_LOG_PROC ON FAFIF.RECON_EXECUTION_LOG(procedure_name);
CREATE INDEX IX_RECON_LOG_DATE ON FAFIF.RECON_EXECUTION_LOG(created_date);
CREATE INDEX IX_RECON_LOG_STATUS ON FAFIF.RECON_EXECUTION_LOG(step_status);

-- Add comments for documentation
COMMENT ON TABLE FAFIF.RECON_EXECUTION_LOG IS 'Tracks execution steps of reconciliation procedures for monitoring and debugging';
COMMENT ON COLUMN FAFIF.RECON_EXECUTION_LOG.run_id IS 'Unique identifier for each reconciliation run';
COMMENT ON COLUMN FAFIF.RECON_EXECUTION_LOG.step_name IS 'Name of the reconciliation step (e.g., Create SYS_MINSAT, Merge HLRs)';
COMMENT ON COLUMN FAFIF.RECON_EXECUTION_LOG.step_status IS 'Status: STARTED, COMPLETED, FAILED';
COMMENT ON COLUMN FAFIF.RECON_EXECUTION_LOG.elapsed_seconds IS 'Execution time in seconds for this step';
COMMENT ON COLUMN FAFIF.RECON_EXECUTION_LOG.row_count IS 'Number of rows processed/affected in this step';

-- Grant permissions (adjust as needed for your environment)
GRANT SELECT, INSERT, UPDATE ON FAFIF.RECON_EXECUTION_LOG TO PUBLIC;

-- =============================================================================================
-- VERIFICATION QUERY
-- =============================================================================================
-- Run this after installation to verify table creation:
-- SELECT table_name, column_name, data_type FROM user_tab_columns WHERE table_name = 'RECON_EXECUTION_LOG' ORDER BY column_id;

PROMPT 'Logging infrastructure created successfully';
PROMPT 'Table: FAFIF.RECON_EXECUTION_LOG';
PROMPT 'Indexes: 4 created';
