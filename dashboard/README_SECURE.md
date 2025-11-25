# ALFA HLR Reconciliation Dashboard - Secure Edition v2.0

## 🔐 Overview

Professional, secure web dashboard for monitoring ALFA's HLR (Home Location Register) Reconciliation System with:
- **User Authentication** - Login system with role-based access
- **Real Database Integration** - Connect to Oracle database for live data
- **ALFA Branding** - Customized theme and logo
- **Session Management** - Secure user sessions with timeout
- **Audit Logging** - Track all user actions

---

## ✨ New Features in v2.0

### Security
- ✅ **Login System**: Username/password authentication
- ✅ **Session Management**: Auto-logout after inactivity
- ✅ **Audit Logging**: All API calls logged with username
- ✅ **Role-Based Access**: Admin and Operator roles
- ✅ **Flash Messages**: User feedback for login/logout

### Database Integration
- ✅ **Oracle Connectivity**: Direct connection to your Oracle database
- ✅ **Real-Time Data**: Live metrics from `RECONCILIATION_EXECUTION_LOG`
- ✅ **Automatic Fallback**: Uses mock data if database unavailable
- ✅ **Connection Pooling Ready**: For production environments

### User Experience
- ✅ **Beautiful Login Page**: Animated gradient background
- ✅ **User Info Display**: Shows logged-in user with logout button
- ✅ **ALFA Branding**: Ready for your logo and custom colors
- ✅ **Responsive Design**: Works on all devices

---

## 🚀 Quick Start

### 1. Install Dependencies

```bash
cd /home/user/hlr/dashboard
pip3 install --break-system-packages Flask Flask-Login cx_Oracle
```

### 2. Configure Settings

Edit `config.py`:

```python
# Update with your credentials
USERS = {
    'admin': {
        'password': 'your_secure_password',  # Change this!
        'role': 'administrator',
        ...
    }
}

# Update Oracle connection
ORACLE_CONFIG = {
    'host': 'your-oracle-host',
    'port': 1521,
    'service_name': 'ORCL',
    'username': 'fafif',
    'password': 'your_db_password',
}

# Enable real database
USE_REAL_DATABASE = True  # Set to True when DB is ready
```

### 3. Add ALFA Logo

Place your ALFA logo file in:
```
/home/user/hlr/dashboard/static/images/alfa-logo.png
```

The login page and dashboard will automatically use it.

### 4. Run the Secure Dashboard

```bash
python3 app_secure.py
```

### 5. Access the Dashboard

**Option A: If you can access localhost**
```
http://localhost:8080
```

**Option B: For remote environments**
1. Download `standalone-dashboard.html`
2. Open in your browser

---

## 👥 Default Login Credentials

**⚠️ CHANGE THESE IN PRODUCTION!**

| Username | Password    | Role          |
|----------|-------------|---------------|
| admin    | admin123    | Administrator |
| operator | operator123 | Operator      |

---

## 📊 Features Overview

### Dashboard Pages

#### 1. Login Page (`/login`)
- Animated gradient background
- ALFA logo and branding
- Username/password fields
- "Remember me" option
- Demo credentials helper

#### 2. Main Dashboard (`/`)
- **Key Metrics**: Total executions, success rate, active errors, avg duration
- **Charts**: 24-hour trends, procedure performance bars
- **Data Tables**: Recent executions, error logs
- **Procedure Performance**: Detailed table with progress bars
- **User Info**: Display logged-in user with logout button

### API Endpoints

All endpoints require authentication:

| Endpoint | Description |
|----------|-------------|
| `/api/health` | System health check |
| `/api/metrics` | Overall system metrics |
| `/api/executions` | Recent execution logs |
| `/api/errors` | Recent error logs |
| `/api/procedure-performance` | Per-procedure metrics |
| `/api/hourly-stats` | 24-hour statistics |
| `/api/user-info` | Current user information |

---

## 🎨 ALFA Branding Customization

### Step 1: Add Your Logo

Place logo file at:
```
dashboard/static/images/alfa-logo.png
```

Supported formats: PNG, SVG, JPG

### Step 2: Update Colors

Edit `config.py`:

```python
# Branding
COMPANY_NAME = 'ALFA'
PRIMARY_COLOR = '#0066cc'    # Your primary blue
SECONDARY_COLOR = '#00a651'  # Your primary green
```

### Step 3: Update Templates

The templates use these colors automatically:
- Login page gradient: `PRIMARY_COLOR` → `SECONDARY_COLOR`
- Metric cards: Uses configured colors
- Buttons and accents: Primary color

### Step 4: Logo Replacement

In `templates/login.html`, find:
```html
<div class="logo-placeholder mx-auto mb-4">
    ALFA
</div>
```

Replace with:
```html
<img src="{{ url_for('static', filename='images/alfa-logo.png') }}"
     alt="ALFA Logo"
     class="mx-auto mb-4"
     style="max-width: 200px; height: auto;">
```

---

## 🗄️ Database Integration

### Quick Setup

1. **Create Tables**: See `DATABASE_SETUP.md` for SQL scripts

2. **Test Connection**:
```python
python3 test_db_connection.py
```

3. **Enable in Config**:
```python
USE_REAL_DATABASE = True
```

4. **Add Logging to Procedures**: Update your PL/SQL procedures to insert into `RECONCILIATION_EXECUTION_LOG`

### Data Flow

```
Your PL/SQL Procedures
        ↓
RECONCILIATION_EXECUTION_LOG (table)
RECONCILIATION_ERRORS (table)
        ↓
Dashboard API (app_secure.py)
        ↓
Frontend Charts & Tables
```

---

## 🔒 Security Features

### Authentication
- Session-based authentication using Flask-Login
- Password hashing recommended for production
- Auto-logout after 30 minutes of inactivity
- "Remember me" option available

### Audit Logging
All actions are logged:
```
[AUDIT] 2025-11-25 10:30:15 | User: admin | Action: VIEW_DASHBOARD
[AUDIT] 2025-11-25 10:30:20 | User: admin | Action: API_METRICS
```

### Best Practices for Production

1. **Change Default Passwords**:
```python
# In config.py
USERS = {
    'admin': {
        'password': hashlib.sha256('strong_password'.encode()).hexdigest(),
        ...
    }
}
```

2. **Use Environment Variables**:
```bash
export SECRET_KEY="your-random-secret-key"
export DB_PASSWORD="your-db-password"
```

3. **Enable HTTPS**:
```python
# Use production WSGI server with SSL
gunicorn --certfile cert.pem --keyfile key.pem app_secure:app
```

4. **Database User with Minimal Permissions**:
```sql
-- Read-only user for dashboard
CREATE USER hlr_dashboard IDENTIFIED BY password;
GRANT SELECT ON RECONCILIATION_EXECUTION_LOG TO hlr_dashboard;
GRANT SELECT ON RECONCILIATION_ERRORS TO hlr_dashboard;
```

---

## 📱 Access Options

### Option 1: Flask Server (With Authentication)
```bash
python3 app_secure.py
# Access: http://localhost:8080
```

### Option 2: Standalone HTML (No Login)
```bash
# Open this file in browser:
standalone-dashboard.html
```

**When to use which:**
- **Secure server**: Production, multiple users, real data
- **Standalone**: Quick demo, offline viewing, single user

---

## 🛠️ Configuration Reference

### `config.py` Settings

```python
# Security
SECRET_KEY = 'change-this-in-production'
SESSION_TIMEOUT_MINUTES = 30

# Users (Add more users here)
USERS = {
    'username': {
        'password': 'password',
        'role': 'role_name',
        'full_name': 'Full Name',
        'email': 'email@alfa.com'
    }
}

# Database
ORACLE_CONFIG = {...}
USE_REAL_DATABASE = True/False

# Dashboard
DASHBOARD_TITLE = 'Title'
REFRESH_INTERVAL_SECONDS = 30

# Branding
COMPANY_NAME = 'ALFA'
PRIMARY_COLOR = '#0066cc'
SECONDARY_COLOR = '#00a651'

# Features
ENABLE_EMAIL_ALERTS = True/False
ENABLE_EXPORT_REPORTS = True/False
ENABLE_USER_AUDIT_LOG = True/False
```

---

## 🐛 Troubleshooting

### Login Page Not Accessible

**Symptom**: Can't access http://localhost:8080

**Solutions**:
1. Check if server is running: `ps aux | grep app_secure.py`
2. Try different URLs: `http://127.0.0.1:8080` or `http://21.0.0.2:8080`
3. Use standalone HTML version instead

### Can't Login

**Symptom**: "Invalid username or password"

**Solutions**:
1. Check credentials in `config.py` → `USERS` dictionary
2. Default: admin/admin123 or operator/operator123
3. Check console for error messages

### Database Connection Failed

**Symptom**: Dashboard shows mock data

**Solutions**:
1. Check `config.py` → `ORACLE_CONFIG` settings
2. Verify Oracle Instant Client is installed
3. Test connection: `python3 test_db_connection.py`
4. Check logs in console output

### Session Timeout

**Symptom**: Redirected to login after inactivity

**Solution**: This is normal. Adjust timeout in `config.py`:
```python
SESSION_TIMEOUT_MINUTES = 60  # Increase to 60 minutes
```

---

## 📈 Adding More Features

### Add New User Role
```python
# In config.py
USERS['viewer'] = {
    'password': 'viewer123',
    'role': 'viewer',
    'full_name': 'Read Only Viewer',
    'email': 'viewer@alfa.com'
}

# In app_secure.py, add role checking:
@app.route('/admin-only')
@login_required
def admin_only():
    if current_user.role != 'administrator':
        flash('Access denied', 'error')
        return redirect(url_for('index'))
    # Admin-only content
```

### Add Export Functionality
```python
@app.route('/export/csv')
@login_required
def export_csv():
    import csv
    from flask import Response

    executions = generate_mock_execution_data()

    def generate():
        data = StringIO()
        writer = csv.writer(data)
        writer.writerow(['Procedure', 'Time', 'Status', 'Duration', 'Records'])
        for exec in executions:
            writer.writerow([...])
            yield data.getvalue()
            data.truncate(0)
            data.seek(0)

    return Response(generate(), mimetype='text/csv',
                    headers={'Content-Disposition': 'attachment;filename=report.csv'})
```

---

## 📞 Support & Documentation

- **Database Setup**: See `DATABASE_SETUP.md`
- **Architecture**: See `../docs/ARCHITECTURE.md`
- **Code Analysis**: See `../docs/CODE_ANALYSIS.md`

---

## 🔄 Version History

### v2.0.0 (2025-11-25)
- ✅ Added user authentication system
- ✅ Implemented login/logout functionality
- ✅ Added Oracle database connectivity
- ✅ Added audit logging
- ✅ ALFA branding ready
- ✅ Created secure and standalone versions

### v1.0.0 (2025-11-25)
- Initial release with mock data
- Basic dashboard without authentication

---

## 📄 License

Part of the ALFA HLR Reconciliation System project.

**© 2025 ALFA - All Rights Reserved**

---

## 🎯 Next Steps

1. **Share ALFA logo** - Send your logo file
2. **Update credentials** - Change default passwords in `config.py`
3. **Configure database** - Update Oracle connection settings
4. **Test login** - Access dashboard and verify authentication
5. **Customize branding** - Adjust colors to match ALFA style

**Ready to go! 🚀**
