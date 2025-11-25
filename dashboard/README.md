# HLR Reconciliation Dashboard

## 🎯 Overview

Professional, real-time monitoring dashboard for the HLR (Home Location Register) Reconciliation System. Built with Flask (Python) backend and modern HTML/CSS/JavaScript frontend.

## ✨ Features

### Real-Time Monitoring
- **Key Metrics Cards**: Total executions, success rate, active errors, average duration
- **Interactive Charts**:
  - 24-hour execution trends (line chart)
  - Procedure success rates (bar chart)
- **Live Data Tables**: Recent executions and errors
- **Auto-Refresh**: Updates every 30 seconds automatically

### User Interface
- 🎨 **Modern Design**: TailwindCSS-powered responsive UI
- 📊 **Beautiful Charts**: Chart.js for interactive visualizations
- 🔄 **Real-Time Updates**: Live data refresh without page reload
- 📱 **Mobile Responsive**: Works on desktop, tablet, and mobile
- 🎯 **Professional UX**: Clean, intuitive interface

## 🚀 Quick Start

### Prerequisites
- Python 3.11+ (✅ Already installed)
- Flask 3.0+ (✅ Already installed)

### Running the Dashboard

1. **Start the server**:
```bash
cd /home/user/hlr/dashboard
python3 app.py
```

2. **Access the dashboard**:
Open your browser and navigate to:
```
http://localhost:8080
```

3. **Stop the server**:
Press `CTRL+C` in the terminal

## 📊 API Endpoints

The dashboard exposes a RESTful API:

### Health Check
```
GET /api/health
```
Returns server health status

### System Metrics
```
GET /api/metrics
```
Returns overall system metrics:
- Total executions
- Success rate
- Failed executions
- Average duration
- Active errors

### Recent Executions
```
GET /api/executions?limit=20
```
Returns recent reconciliation executions

### Recent Errors
```
GET /api/errors?limit=10
```
Returns recent error logs

### Procedure Performance
```
GET /api/procedure-performance
```
Returns performance metrics by procedure

### Hourly Statistics
```
GET /api/hourly-stats
```
Returns 24-hour execution statistics for charts

## 🏗️ Architecture

```
dashboard/
├── app.py                      # Flask backend server
├── requirements.txt            # Python dependencies
├── templates/
│   └── dashboard.html         # Main dashboard UI
└── README.md                  # This file
```

### Technology Stack

**Backend**:
- Python 3.11
- Flask 3.0 (Web framework)

**Frontend**:
- HTML5 / CSS3
- TailwindCSS 3.x (Styling)
- Chart.js 4.x (Charts)
- Font Awesome 6.x (Icons)
- Vanilla JavaScript (No framework dependencies)

## 📈 Dashboard Components

### 1. Key Metrics Row
Four metric cards showing:
- Total Executions (last 50 runs)
- Success Rate percentage
- Active Errors count
- Average Duration per execution

### 2. Charts Section
- **Hourly Trends**: Line chart showing successful vs failed executions over 24 hours
- **Procedure Performance**: Bar chart showing success rates by procedure

### 3. Data Tables
- **Recent Executions**: Last 10 reconciliation runs with status and duration
- **Recent Errors**: Last 10 errors with severity and resolution status

### 4. Procedure Performance Table
Detailed table showing all procedures with:
- Total runs
- Success rate (with progress bar)
- Average duration
- Last run timestamp

## 🔧 Configuration

### Port Configuration
Default port: `8080`

To change the port, edit `app.py`:
```python
app.run(host='0.0.0.0', port=YOUR_PORT, debug=True)
```

### Mock Data
Currently using mock/sample data for demonstration.

To connect to real Oracle database:
1. Install `cx_Oracle`: `pip install cx_Oracle`
2. Replace mock data generators in `app.py` with database queries
3. Add database connection configuration

## 🎨 Customization

### Colors
The dashboard uses a blue color scheme. To change:
- Edit color classes in `templates/dashboard.html`
- Modify gradient backgrounds in metric cards

### Refresh Interval
Default: 30 seconds

To change auto-refresh interval:
```javascript
// In dashboard.html, find:
setInterval(() => {
    initDashboard();
}, 30000);  // Change 30000 to your desired milliseconds
```

## 🐛 Troubleshooting

### Server won't start
```bash
# Check if port 8080 is already in use
lsof -i :8080

# Kill existing process
kill -9 <PID>

# Restart server
python3 app.py
```

### Flask not found
```bash
pip3 install --break-system-packages Flask
```

### Can't access dashboard
- Ensure server is running (check terminal output)
- Try: `http://127.0.0.1:8080` or `http://localhost:8080`
- Check firewall settings

## 📝 Future Enhancements

### Planned Features
- [ ] Real Oracle database integration
- [ ] User authentication
- [ ] Export reports to PDF/Excel
- [ ] Email alerting system
- [ ] Configurable alert thresholds
- [ ] Historical data retention
- [ ] Dark mode theme
- [ ] WebSocket for real-time push updates
- [ ] Advanced filtering and search
- [ ] Custom dashboard widgets

### Database Integration
To connect to Oracle:

```python
import cx_Oracle

def get_db_connection():
    dsn = cx_Oracle.makedsn('host', 1521, service_name='service')
    connection = cx_Oracle.connect('user', 'password', dsn)
    return connection

def get_real_metrics():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT COUNT(*) as total,
               SUM(CASE WHEN status='SUCCESS' THEN 1 ELSE 0 END) as success
        FROM RECONCILIATION_EXECUTION_LOG
    """)
    result = cursor.fetchone()
    conn.close()
    return result
```

## 📞 Support

For issues or questions:
- Check the logs in terminal where server is running
- Review API responses: `curl http://localhost:8080/api/health`
- Check browser console for JavaScript errors (F12)

## 📄 License

Part of the HLR Reconciliation System project.

---

**Built with** ❤️ **using Flask + TailwindCSS + Chart.js**
