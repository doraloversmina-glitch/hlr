# Dashboard Configuration
# Edit these settings for your environment

# Security Settings
SECRET_KEY = 'your-secret-key-change-this-in-production'
SESSION_TIMEOUT_MINUTES = 30

# User Credentials (In production, use database or LDAP)
USERS = {
    'admin': {
        'password': 'admin123',  # Change this!
        'role': 'administrator',
        'full_name': 'System Administrator',
        'email': 'admin@alfa.com'
    },
    'operator': {
        'password': 'operator123',  # Change this!
        'role': 'operator',
        'full_name': 'System Operator',
        'email': 'operator@alfa.com'
    }
}

# Oracle Database Configuration
# Update these with your actual Oracle connection details
ORACLE_CONFIG = {
    'host': 'UNKNOWN',  # ⚠️ UPDATE THIS - Ask your IT team for the database server IP/hostname
    'port': 1521,
    'service_name': 'RECON_GEOX',
    'username': 'danad',
    'password': 'danad#2025',
    # When you get the host, update it above and set USE_REAL_DATABASE = True below
}

# Dashboard Settings
DASHBOARD_TITLE = 'ALFA - HLR Reconciliation System'
REFRESH_INTERVAL_SECONDS = 30
MAX_RECORDS_DISPLAY = 50

# Branding
COMPANY_NAME = 'ALFA'
COMPANY_LOGO_PATH = '/static/images/alfa-logo.png'
PRIMARY_COLOR = '#ED1C24'  # ALFA red
SECONDARY_COLOR = '#C8102E'  # ALFA dark red

# Feature Flags
USE_REAL_DATABASE = False  # Set to True when database is configured
ENABLE_EMAIL_ALERTS = False
ENABLE_EXPORT_REPORTS = True
ENABLE_USER_AUDIT_LOG = True
