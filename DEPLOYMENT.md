# Excel Comparator - Deployment Guide

This guide covers multiple deployment options for the Excel File Comparator web application.

## 🚀 Quick Deploy Options

### Option 1: Render.com (Recommended - Free Tier Available)

1. **Sign up** at [render.com](https://render.com)

2. **Create New Web Service**
   - Click "New +" → "Web Service"
   - Connect your GitHub repository
   - Select the branch: `claude/excel-file-comparison-01J87X8Mm35v4U1bDMEGemfT`

3. **Configure Service**
   ```
   Name: excel-comparator
   Environment: Python 3
   Build Command: pip install -r requirements.txt
   Start Command: gunicorn -w 4 -b 0.0.0.0:$PORT app:app --timeout 120
   ```

4. **Environment Variables** (Optional)
   ```
   SECRET_KEY=your-random-secret-key
   FLASK_ENV=production
   ```

5. **Deploy** - Click "Create Web Service"

**Your app will be live at**: `https://excel-comparator.onrender.com`

---

### Option 2: Railway.app (Easy & Fast)

1. **Install Railway CLI** (optional)
   ```bash
   npm i -g @railway/cli
   ```

2. **Deploy via Web**
   - Go to [railway.app](https://railway.app)
   - Click "New Project" → "Deploy from GitHub repo"
   - Select your repository
   - Railway auto-detects the Procfile

3. **Deploy via CLI**
   ```bash
   railway login
   railway init
   railway up
   railway open
   ```

**Your app will be live at**: Railway provides a custom URL

---

### Option 3: Heroku

1. **Install Heroku CLI**
   ```bash
   curl https://cli-assets.heroku.com/install.sh | sh
   ```

2. **Deploy**
   ```bash
   heroku login
   heroku create excel-comparator-app
   git push heroku claude/excel-file-comparison-01J87X8Mm35v4U1bDMEGemfT:main
   heroku open
   ```

3. **Set Environment Variables**
   ```bash
   heroku config:set SECRET_KEY=your-secret-key
   heroku config:set FLASK_ENV=production
   ```

**Your app will be live at**: `https://excel-comparator-app.herokuapp.com`

---

### Option 4: Docker (Any Platform)

1. **Build Docker Image**
   ```bash
   docker build -t excel-comparator .
   ```

2. **Run Locally**
   ```bash
   docker run -p 5000:5000 excel-comparator
   ```

3. **Or Use Docker Compose**
   ```bash
   docker-compose up -d
   ```

4. **Deploy to Docker Hub**
   ```bash
   docker tag excel-comparator yourusername/excel-comparator
   docker push yourusername/excel-comparator
   ```

**Access at**: `http://localhost:5000`

---

### Option 5: AWS (EC2 or Elastic Beanstalk)

#### EC2 Deployment

1. **Launch EC2 Instance**
   - Ubuntu 22.04 LTS
   - t2.micro (free tier eligible)
   - Open port 5000 in security group

2. **SSH and Setup**
   ```bash
   ssh -i your-key.pem ubuntu@your-ec2-ip

   # Install dependencies
   sudo apt update
   sudo apt install python3-pip nginx

   # Clone repository
   git clone your-repo-url
   cd hlr

   # Install Python packages
   pip3 install -r requirements.txt

   # Run with Gunicorn
   gunicorn -w 4 -b 0.0.0.0:5000 app:app --daemon
   ```

3. **Configure Nginx** (optional, for port 80)
   ```bash
   sudo nano /etc/nginx/sites-available/excel-comparator
   ```

   Add:
   ```nginx
   server {
       listen 80;
       server_name your-domain.com;

       location / {
           proxy_pass http://127.0.0.1:5000;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
       }
   }
   ```

   Enable:
   ```bash
   sudo ln -s /etc/nginx/sites-available/excel-comparator /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl restart nginx
   ```

#### Elastic Beanstalk

```bash
# Install EB CLI
pip install awsebcli

# Initialize
eb init -p python-3.11 excel-comparator

# Create environment and deploy
eb create excel-comparator-env
eb open
```

---

### Option 6: Google Cloud Run (Serverless)

1. **Install Google Cloud SDK**
   ```bash
   curl https://sdk.cloud.google.com | bash
   ```

2. **Deploy**
   ```bash
   gcloud auth login
   gcloud config set project your-project-id

   # Build and deploy
   gcloud run deploy excel-comparator \
     --source . \
     --platform managed \
     --region us-central1 \
     --allow-unauthenticated
   ```

**Your app will be live at**: Google provides a URL

---

### Option 7: Azure Web App

1. **Install Azure CLI**
   ```bash
   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
   ```

2. **Deploy**
   ```bash
   az login
   az group create --name ExcelComparatorRG --location eastus
   az appservice plan create --name ExcelComparatorPlan --resource-group ExcelComparatorRG --sku B1 --is-linux
   az webapp create --resource-group ExcelComparatorRG --plan ExcelComparatorPlan --name excel-comparator-app --runtime "PYTHON:3.11"
   az webapp deployment source config-local-git --name excel-comparator-app --resource-group ExcelComparatorRG

   # Deploy
   git remote add azure <deployment-url>
   git push azure main
   ```

---

### Option 8: DigitalOcean App Platform

1. **Via Web Console**
   - Go to [DigitalOcean](https://www.digitalocean.com)
   - Click "Create" → "Apps"
   - Connect GitHub repository
   - Select branch
   - DigitalOcean auto-detects Python app

2. **Via CLI (doctl)**
   ```bash
   # Install doctl
   snap install doctl

   # Authenticate
   doctl auth init

   # Create app
   doctl apps create --spec .do/app.yaml
   ```

---

## 🔧 Environment Variables

Set these environment variables for production:

```bash
SECRET_KEY=your-super-secret-random-key-here
FLASK_ENV=production
PORT=5000  # Usually auto-set by platform
```

Generate a secure secret key:
```python
python -c "import secrets; print(secrets.token_hex(32))"
```

---

## 📊 Resource Requirements

**Minimum:**
- RAM: 512 MB
- CPU: 0.5 vCPU
- Storage: 1 GB

**Recommended:**
- RAM: 1 GB
- CPU: 1 vCPU
- Storage: 2 GB

**For Large Files (100k+ rows):**
- RAM: 2 GB+
- CPU: 2 vCPU
- Storage: 5 GB

---

## 🔒 Production Checklist

- [ ] Set strong `SECRET_KEY` environment variable
- [ ] Enable HTTPS/SSL (most platforms do this automatically)
- [ ] Set `FLASK_ENV=production`
- [ ] Configure proper file upload limits
- [ ] Set up monitoring and logging
- [ ] Configure automatic cleanup of old files
- [ ] Set up backup strategy for outputs
- [ ] Enable CORS if needed for API access
- [ ] Configure rate limiting (optional)
- [ ] Set up health check endpoints

---

## 🔍 Testing Deployment

Once deployed, test with:

1. **Health Check**
   ```bash
   curl https://your-app-url.com/health
   ```

2. **Upload Test**
   - Visit the app URL in browser
   - Upload two test Excel files
   - Verify comparison results
   - Download the report

3. **Load Test** (optional)
   ```bash
   # Install Apache Bench
   ab -n 100 -c 10 https://your-app-url.com/
   ```

---

## 📝 Monitoring

### Add Custom Logging

Add to `app.py`:
```python
import logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
```

### Platform-Specific Monitoring

- **Render**: Built-in metrics dashboard
- **Railway**: View logs with `railway logs`
- **Heroku**: `heroku logs --tail`
- **Docker**: `docker logs container-name`

---

## 🚨 Troubleshooting

**Problem**: App crashes on startup
```bash
# Check logs
# Render: View in dashboard
# Railway: railway logs
# Heroku: heroku logs --tail
```

**Problem**: File upload fails
- Check `MAX_CONTENT_LENGTH` in app.py
- Ensure uploads/ and outputs/ directories are writable
- Verify platform has enough storage

**Problem**: Timeout on large files
- Increase gunicorn timeout in Procfile
- Scale up to higher tier with more resources
- Optimize comparison algorithm

**Problem**: Memory errors
- Scale up to plan with more RAM
- Reduce number of gunicorn workers
- Implement file streaming for very large files

---

## 💰 Cost Comparison

| Platform | Free Tier | Paid (Basic) | Notes |
|----------|-----------|--------------|-------|
| Render | 750 hrs/month | $7/month | Sleeps after inactivity |
| Railway | $5 credit | $5/month | Pay as you go |
| Heroku | Eco: $5/month | $25/month | No free tier anymore |
| DigitalOcean | $200 credit | $5/month | 60-day trial |
| AWS EC2 | t2.micro free | $10+/month | 12 months free |
| Google Cloud | $300 credit | Varies | 90-day trial |
| Azure | $200 credit | Varies | 30-day trial |

---

## 🎯 Recommended Quick Start

**For beginners**: Use **Render.com** - Easiest setup, free tier available

**For speed**: Use **Railway.app** - Fastest deployment

**For control**: Use **Docker + DigitalOcean** - Most flexible

**For enterprise**: Use **AWS/Azure/GCP** - Most scalable

---

## 📚 Additional Resources

- [Flask Deployment](https://flask.palletsprojects.com/en/2.3.x/deploying/)
- [Gunicorn Documentation](https://docs.gunicorn.org/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [NGINX Configuration](https://nginx.org/en/docs/)

---

## ✅ Quick Deploy Commands

### Render.com (Web UI)
Just connect GitHub repo → Auto-deploys ✨

### Railway (CLI)
```bash
railway login && railway up
```

### Heroku (CLI)
```bash
heroku create && git push heroku main
```

### Docker (Local)
```bash
docker-compose up -d
```

---

**Need help? Check logs first, then consult platform-specific documentation.**
