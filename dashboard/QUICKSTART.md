# HLR Dashboard - Quick Start Guide

## ✅ Oracle Instant Client Installed!

The Oracle database connector is now installed and ready to use.

**Location**: `/opt/oracle/instantclient_23_4`

---

## 🚀 To Start the Dashboard

### Option 1: Use the Start Script (Easiest)

```bash
/home/user/hlr/dashboard/start_dashboard.sh
```

This automatically:
- Sets up Oracle environment variables
- Starts the secure dashboard on port 8080

### Option 2: Manual Start

```bash
export LD_LIBRARY_PATH=/opt/oracle/instantclient_23_4:$LD_LIBRARY_PATH
cd /home/user/hlr/dashboard
python3 app_secure.py
```

---

## 🔌 To Connect to Your Oracle Database

### 1. Update Database Configuration

Edit `/home/user/hlr/dashboard/config.py`:

```python
ORACLE_CONFIG = {
    'host': 'your-oracle-server.com',  # Or IP: 192.168.1.100
    'port': 1521,                       # Default Oracle port
    'service_name': 'ORCL',             # Your Oracle service name
    'username': 'fafif',                # Your database username
    'password': 'your_password',        # Your database password
}

# Enable real database connection
USE_REAL_DATABASE = True
```

### 2. Test the Connection

```bash
export LD_LIBRARY_PATH=/opt/oracle/instantclient_23_4:$LD_LIBRARY_PATH
cd /home/user/hlr/dashboard
python3 test_db_connection.py
```

This will:
- ✅ Test database connectivity
- ✅ Check if reconciliation tables exist
- ✅ Display helpful error messages if connection fails

---

## 📋 What You Need From Your DBA

Ask your database administrator for:

1. **Hostname or IP**: `_________________`
2. **Port**: Usually `1521`
3. **Service Name**: `_________________`
4. **Username**: Usually `fafif` or your schema name
5. **Password**: `_________________`

---

## 🗄️ Create Database Tables (If Needed)

If the reconciliation tables don't exist yet, run this SQL as your DBA:

```sql
-- Execution Log Table
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

-- Error Log Table
CREATE TABLE RECONCILIATION_ERRORS (
    error_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    procedure_name VARCHAR2(100) NOT NULL,
    error_code VARCHAR2(20),
    error_message VARCHAR2(4000),
    error_timestamp TIMESTAMP DEFAULT SYSTIMESTAMP,
    integration_log_id VARCHAR2(50),
    resolved_flag CHAR(1) DEFAULT 'N',
    severity VARCHAR2(20)
);

CREATE INDEX idx_err_timestamp ON RECONCILIATION_ERRORS(error_timestamp);
```

See `DATABASE_SETUP.md` for complete SQL scripts.

---

## ✅ Verification Checklist

- [ ] Oracle Instant Client installed (`/opt/oracle/instantclient_23_4`)
- [ ] Database credentials obtained from DBA
- [ ] Updated `config.py` with database details
- [ ] Ran `test_db_connection.py` successfully
- [ ] Reconciliation tables created in database
- [ ] Set `USE_REAL_DATABASE = True` in config.py
- [ ] Dashboard showing real data from Oracle

---

## 🔧 Troubleshooting

### Error: "Cannot locate Oracle Client library"
```bash
# Set environment variable before running Python
export LD_LIBRARY_PATH=/opt/oracle/instantclient_23_4:$LD_LIBRARY_PATH
```

Or use the start script: `./start_dashboard.sh`

### Error: "TNS: could not resolve connect identifier"
- Check `service_name` in config.py
- Try using SID instead of service_name
- Verify with DBA

### Error: "ORA-01017: invalid username/password"
- Double-check credentials in config.py
- Make sure password doesn't have special characters that need escaping
- Check if account is locked: Contact DBA

### Error: "Connection timeout"
- Verify hostname/IP is correct
- Check if port 1521 is open (firewall)
- Test network connectivity: `ping your-oracle-server`

---

## 📞 Need Help?

1. Check detailed guide: `DATABASE_SETUP.md`
2. Run connection test: `python3 test_db_connection.py`
3. Check server logs when running dashboard

---

**Last Updated**: 2025-11-25
**Oracle Client Version**: 23.4.0
