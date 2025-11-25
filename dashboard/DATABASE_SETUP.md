# Database Setup Guide for HLR Dashboard

This guide explains how to connect the dashboard to your real Oracle database.

## Prerequisites

- Oracle Database 11g or higher
- Oracle Instant Client installed
- Database credentials with SELECT permissions

## Step 1: Install Oracle Instant Client

### Linux
```bash
# Download Oracle Instant Client from oracle.com
wget https://download.oracle.com/otn_software/linux/instantclient/...

# Extract
unzip instantclient-basic-linux.x64-*.zip
cd instantclient_*

# Set environment variables
export LD_LIBRARY_PATH=/path/to/instantclient_XX_X:$LD_LIBRARY_PATH
export ORACLE_HOME=/path/to/instantclient_XX_X
```

### Verify Installation
```python
import cx_Oracle
print(cx_Oracle.version)
```

## Step 2: Create Database Tables

The dashboard needs these tables to function with real data:

### Execution Log Table
```sql
CREATE TABLE RECONCILIATION_EXECUTION_LOG (
    execution_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    procedure_name VARCHAR2(100) NOT NULL,
    execution_time TIMESTAMP DEFAULT SYSTIMESTAMP,
    status VARCHAR2(20) CHECK (status IN ('SUCCESS', 'FAILED', 'WARNING')),
    duration_seconds NUMBER,
    records_processed NUMBER,
    records_inserted NUMBER,
    records_updated NUMBER,
    records_deleted NUMBER,
    integration_log_id VARCHAR2(50),
    error_message VARCHAR2(4000),
    created_date TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE INDEX idx_exec_log_time ON RECONCILIATION_EXECUTION_LOG(execution_time);
CREATE INDEX idx_exec_log_proc ON RECONCILIATION_EXECUTION_LOG(procedure_name);
CREATE INDEX idx_exec_log_status ON RECONCILIATION_EXECUTION_LOG(status);
```

### Error Log Table
```sql
CREATE TABLE RECONCILIATION_ERRORS (
    error_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    procedure_name VARCHAR2(100) NOT NULL,
    error_code VARCHAR2(20),
    error_type VARCHAR2(50),
    error_message VARCHAR2(4000),
    error_stack VARCHAR2(4000),
    error_backtrace VARCHAR2(4000),
    error_timestamp TIMESTAMP DEFAULT SYSTIMESTAMP,
    integration_log_id VARCHAR2(50),
    context_info VARCHAR2(4000),
    resolved_flag CHAR(1) DEFAULT 'N' CHECK (resolved_flag IN ('Y', 'N')),
    resolved_timestamp TIMESTAMP,
    resolved_by VARCHAR2(100),
    severity VARCHAR2(20) CHECK (severity IN ('CRITICAL', 'HIGH', 'MEDIUM', 'LOW'))
);

CREATE INDEX idx_err_timestamp ON RECONCILIATION_ERRORS(error_timestamp);
CREATE INDEX idx_err_procedure ON RECONCILIATION_ERRORS(procedure_name);
CREATE INDEX idx_err_resolved ON RECONCILIATION_ERRORS(resolved_flag);
CREATE INDEX idx_err_severity ON RECONCILIATION_ERRORS(severity);
```

### Procedure Performance Summary View
```sql
CREATE OR REPLACE VIEW V_PROCEDURE_PERFORMANCE AS
SELECT
    procedure_name,
    COUNT(*) as total_runs,
    SUM(CASE WHEN status = 'SUCCESS' THEN 1 ELSE 0 END) as successful_runs,
    SUM(CASE WHEN status = 'FAILED' THEN 1 ELSE 0 END) as failed_runs,
    ROUND((SUM(CASE WHEN status = 'SUCCESS' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) as success_rate,
    ROUND(AVG(duration_seconds), 2) as avg_duration_seconds,
    MAX(execution_time) as last_run_time
FROM RECONCILIATION_EXECUTION_LOG
WHERE execution_time >= SYSDATE - 30  -- Last 30 days
GROUP BY procedure_name
ORDER BY procedure_name;
```

## Step 3: Update Existing Procedures to Log Data

Add logging to your existing HLR reconciliation procedures:

```sql
-- Example: Add to P1_MAIN_SYS_INTERFACES
CREATE OR REPLACE PROCEDURE P1_MAIN_SYS_INTERFACES(
    INTEGRATION_LOG_ID IN VARCHAR2 DEFAULT '0',
    RESULT OUT VARCHAR2,
    P_ENT_TYPE IN NUMBER DEFAULT 4,
    P_ENT_CODE IN NUMBER DEFAULT 1
) IS
    v_start_time TIMESTAMP;
    v_end_time TIMESTAMP;
    v_duration NUMBER;
    v_records_processed NUMBER := 0;
    v_records_inserted NUMBER := 0;
    v_records_updated NUMBER := 0;
    v_records_deleted NUMBER := 0;
BEGIN
    v_start_time := SYSTIMESTAMP;

    -- Your existing reconciliation logic here
    -- ...

    -- Log successful execution
    v_end_time := SYSTIMESTAMP;
    v_duration := EXTRACT(SECOND FROM (v_end_time - v_start_time));

    INSERT INTO RECONCILIATION_EXECUTION_LOG (
        procedure_name, execution_time, status,
        duration_seconds, records_processed, records_inserted,
        records_updated, records_deleted, integration_log_id
    ) VALUES (
        'P1_MAIN_SYS_INTERFACES', v_end_time, 'SUCCESS',
        v_duration, v_records_processed, v_records_inserted,
        v_records_updated, v_records_deleted, INTEGRATION_LOG_ID
    );
    COMMIT;

    RESULT := 'SUCCESS';

EXCEPTION
    WHEN OTHERS THEN
        -- Log error
        INSERT INTO RECONCILIATION_ERRORS (
            procedure_name, error_code, error_message,
            error_stack, error_backtrace, integration_log_id,
            severity, context_info
        ) VALUES (
            'P1_MAIN_SYS_INTERFACES', SQLCODE, SQLERRM,
            DBMS_UTILITY.FORMAT_ERROR_STACK,
            DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
            INTEGRATION_LOG_ID, 'CRITICAL',
            'Step: ' || CURSTEP
        );
        COMMIT;

        -- Also log as failed execution
        INSERT INTO RECONCILIATION_EXECUTION_LOG (
            procedure_name, execution_time, status,
            duration_seconds, integration_log_id, error_message
        ) VALUES (
            'P1_MAIN_SYS_INTERFACES', SYSTIMESTAMP, 'FAILED',
            0, INTEGRATION_LOG_ID, SQLERRM
        );
        COMMIT;

        RESULT := 'FAILED';
        RAISE;
END;
```

## Step 4: Configure Dashboard Connection

Edit `/home/user/hlr/dashboard/config.py`:

```python
# Oracle Database Configuration
ORACLE_CONFIG = {
    'host': 'your-oracle-host.com',      # Or IP: 192.168.1.100
    'port': 1521,                         # Default Oracle port
    'service_name': 'ORCL',               # Your service name or SID
    'username': 'fafif',                  # Your schema username
    'password': 'your_password',          # ⚠️ Use env variable in production
}

# Enable real database connection
USE_REAL_DATABASE = True
```

### Using Environment Variables (Recommended)
```python
import os

ORACLE_CONFIG = {
    'host': os.getenv('ORACLE_HOST', 'localhost'),
    'port': int(os.getenv('ORACLE_PORT', 1521)),
    'service_name': os.getenv('ORACLE_SERVICE', 'ORCL'),
    'username': os.getenv('ORACLE_USER', 'fafif'),
    'password': os.getenv('ORACLE_PASSWORD'),
}
```

Then set environment variables:
```bash
export ORACLE_HOST="your-host.com"
export ORACLE_PORT="1521"
export ORACLE_SERVICE="ORCL"
export ORACLE_USER="fafif"
export ORACLE_PASSWORD="your_password"
```

## Step 5: Test Database Connection

Create a test script:

```python
# test_db_connection.py
import cx_Oracle
import config

try:
    dsn = cx_Oracle.makedsn(
        config.ORACLE_CONFIG['host'],
        config.ORACLE_CONFIG['port'],
        service_name=config.ORACLE_CONFIG['service_name']
    )

    connection = cx_Oracle.connect(
        config.ORACLE_CONFIG['username'],
        config.ORACLE_CONFIG['password'],
        dsn
    )

    print("✅ Database connection successful!")

    cursor = connection.cursor()
    cursor.execute("SELECT COUNT(*) FROM RECONCILIATION_EXECUTION_LOG")
    result = cursor.fetchone()
    print(f"📊 Total execution logs: {result[0]}")

    cursor.close()
    connection.close()

except cx_Oracle.DatabaseError as e:
    error, = e.args
    print(f"❌ Database connection failed:")
    print(f"   Error Code: {error.code}")
    print(f"   Error Message: {error.message}")
```

Run test:
```bash
cd /home/user/hlr/dashboard
python3 test_db_connection.py
```

## Step 6: Grant Permissions

Ensure your database user has necessary permissions:

```sql
-- As DBA user
GRANT SELECT ON RECONCILIATION_EXECUTION_LOG TO fafif;
GRANT SELECT ON RECONCILIATION_ERRORS TO fafif;
GRANT SELECT ON V_PROCEDURE_PERFORMANCE TO fafif;
GRANT INSERT ON RECONCILIATION_EXECUTION_LOG TO fafif;
GRANT INSERT ON RECONCILIATION_ERRORS TO fafif;
GRANT UPDATE ON RECONCILIATION_ERRORS TO fafif;  -- For marking errors as resolved
```

## Step 7: Populate Historical Data (Optional)

If you want to populate historical data for testing:

```sql
-- Generate sample execution logs
BEGIN
    FOR i IN 1..100 LOOP
        INSERT INTO RECONCILIATION_EXECUTION_LOG (
            procedure_name, execution_time, status,
            duration_seconds, records_processed, records_inserted
        ) VALUES (
            'P' || MOD(i, 7) || '_TEST_PROCEDURE',
            SYSTIMESTAMP - (i/24),  -- Last 4 days
            CASE WHEN MOD(i, 10) = 0 THEN 'FAILED'
                 WHEN MOD(i, 10) = 1 THEN 'WARNING'
                 ELSE 'SUCCESS' END,
            DBMS_RANDOM.VALUE(60, 600),
            DBMS_RANDOM.VALUE(1000, 50000),
            DBMS_RANDOM.VALUE(0, 5000)
        );
    END LOOP;
    COMMIT;
END;
/
```

## Troubleshooting

### Error: "DPY-6000: cannot connect to database"
- Check if Oracle Instant Client is installed
- Verify ORACLE_HOME and LD_LIBRARY_PATH are set
- Ensure host/port are correct

### Error: "ORA-12541: TNS:no listener"
- Database listener is not running
- Check port number (default 1521)
- Test with: `telnet your-host 1521`

### Error: "ORA-12514: TNS:listener does not currently know of service"
- Service name is incorrect
- Check with: `lsnrctl status` on database server

### Error: "ORA-01017: invalid username/password"
- Verify credentials
- Check if account is locked: `SELECT username, account_status FROM dba_users;`

### Performance Issues
- Add indexes on frequently queried columns
- Use partition tables for large datasets
- Consider materialized views for complex queries

## Production Best Practices

1. **Use Connection Pooling**
```python
import cx_Oracle

# Create connection pool
pool = cx_Oracle.SessionPool(
    user=config.ORACLE_CONFIG['username'],
    password=config.ORACLE_CONFIG['password'],
    dsn=dsn,
    min=2,
    max=10,
    increment=1
)

# Acquire connection from pool
connection = pool.acquire()
```

2. **Use Database Wallet** (for credentials)
```sql
-- Create wallet
BEGIN
    DBMS_CREDENTIAL.CREATE_CREDENTIAL(
        credential_name => 'HLR_DASHBOARD_CRED',
        username => 'fafif',
        password => 'your_password'
    );
END;
/
```

3. **Set up Read-Only User** (for dashboard)
```sql
CREATE USER hlr_dashboard IDENTIFIED BY dashboard_password;
GRANT CONNECT TO hlr_dashboard;
GRANT SELECT ON RECONCILIATION_EXECUTION_LOG TO hlr_dashboard;
GRANT SELECT ON RECONCILIATION_ERRORS TO hlr_dashboard;
GRANT SELECT ON V_PROCEDURE_PERFORMANCE TO hlr_dashboard;
```

4. **Enable Audit Logging**
```sql
AUDIT SELECT ON RECONCILIATION_EXECUTION_LOG BY ACCESS;
AUDIT SELECT ON RECONCILIATION_ERRORS BY ACCESS;
```

## Support

For issues or questions:
- Check Oracle documentation: https://docs.oracle.com/
- cx_Oracle documentation: https://cx-oracle.readthedocs.io/
- Review dashboard logs: Check console output when running app_secure.py

---

**Last Updated**: 2025-11-25
**Dashboard Version**: 2.0.0
