# ExamCoach Deployment Guide

## 🚀 Quick Start Deployment Options

### Option 1: Heroku (Easiest - Free Tier Available)
**Best for**: Quick deployment, automatic SSL, easy scaling

```bash
# Make deployment script executable
chmod +x deploy/heroku-deploy.sh

# Run deployment
./deploy/heroku-deploy.sh
```

**Cost**: Free tier available, ~$7-50/month for production

### Option 2: DigitalOcean App Platform (Recommended)
**Best for**: Better performance, predictable pricing, automatic scaling

```bash
# Install DigitalOcean CLI
brew install doctl  # macOS
# or
snap install doctl  # Linux

# Authenticate
doctl auth init

# Deploy
chmod +x deploy/digitalocean-deploy.sh
./deploy/digitalocean-deploy.sh
```

**Cost**: ~$12-40/month

### Option 3: AWS Elastic Beanstalk (Enterprise)
**Best for**: Large scale, enterprise features, global reach

```bash
# Install AWS and EB CLI
pip install awscli awsebcli

# Configure AWS
aws configure

# Deploy
chmod +x deploy/aws-deploy.sh
./deploy/aws-deploy.sh
```

**Cost**: ~$20-100/month

### Option 4: Docker (Self-Hosted)
**Best for**: Full control, on-premise deployment

```bash
# Build and run with Docker Compose
docker-compose -f docker-compose.production.yml up -d

# Or deploy to any Docker host
docker build -t examcoach .
docker run -d -p 3000:3000 --env-file production.env examcoach
```

---

## 📋 Pre-Deployment Checklist

### 1. Environment Variables
Update `production.env` with real values:
- [ ] Generate strong JWT_SECRET: `openssl rand -hex 32`
- [ ] Generate strong SESSION_SECRET: `openssl rand -hex 32`  
- [ ] Set secure ADMIN_PASS: `openssl rand -base64 20`
- [ ] Update DATABASE_URL with production database
- [ ] Set CORS_ORIGINS to your domain
- [ ] Configure email settings (SMTP)

### 2. Database Setup
```bash
# Run migrations on production database
psql $DATABASE_URL < server/migrations/run-all-migrations.sql

# Seed initial data (optional)
cd server && npm run db:seed
```

### 3. Google Play Configuration
- [ ] Create service account in Google Cloud Console
- [ ] Download service account JSON key
- [ ] Upload to secure location on server
- [ ] Update GOOGLE_SERVICE_ACCOUNT_KEY_PATH

### 4. Domain & SSL
- [ ] Register domain (e.g., examcoachng.com)
- [ ] Configure DNS to point to your server
- [ ] Set up SSL certificate (automatic on most platforms)

---

## 🔧 Manual Deployment Steps

### Step 1: Prepare Server
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Install PostgreSQL
sudo apt install -y postgresql postgresql-contrib

# Install Redis
sudo apt install -y redis-server

# Install PM2 for process management
sudo npm install -g pm2
```

### Step 2: Clone Repository
```bash
git clone https://github.com/mitchell1972/examCoachNG.git
cd examCoachNG
```

### Step 3: Setup Backend
```bash
cd server
npm install
npm run build

# Copy production environment
cp ../production.env .env

# Run migrations
psql $DATABASE_URL < migrations/run-all-migrations.sql
```

### Step 4: Start Services
```bash
# Start with PM2
pm2 start dist/app.js --name examcoach
pm2 save
pm2 startup

# Or use systemd service
sudo nano /etc/systemd/system/examcoach.service
```

### Step 5: Setup Nginx (Optional)
```bash
sudo apt install -y nginx

# Configure reverse proxy
sudo nano /etc/nginx/sites-available/examcoach
```

```nginx
server {
    listen 80;
    server_name examcoachng.com www.examcoachng.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/examcoach /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Setup SSL with Let's Encrypt
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d examcoachng.com -d www.examcoachng.com
```

---

## 📱 Mobile App Deployment

### Android (Google Play Store)
```bash
cd app
flutter build appbundle --release

# Upload app/build/app/outputs/bundle/release/app-release.aab to Play Console
```

### iOS (App Store)
```bash
cd app
flutter build ios --release

# Open in Xcode and archive for App Store
open ios/Runner.xcworkspace
```

---

## 🔍 Post-Deployment Verification

### 1. Health Check
```bash
curl https://your-domain.com/health
```

### 2. Test Authentication
```bash
# Register user
curl -X POST https://your-domain.com/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test123!","fullName":"Test User"}'

# Login
curl -X POST https://your-domain.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test123!"}'
```

### 3. Monitor Logs
```bash
# Heroku
heroku logs --tail

# DigitalOcean
doctl apps logs <app-id>

# PM2
pm2 logs examcoach

# Docker
docker logs examcoach-backend
```

---

## 🚨 Troubleshooting

### Database Connection Issues
```bash
# Test connection
psql $DATABASE_URL -c "SELECT 1"

# Check firewall
sudo ufw status
```

### Port Already in Use
```bash
# Find process using port 3000
lsof -i :3000

# Kill process
kill -9 <PID>
```

### SSL Certificate Issues
```bash
# Renew certificate
sudo certbot renew

# Test SSL
curl -I https://your-domain.com
```

---

## 📊 Monitoring & Maintenance

### Setup Monitoring
- [ ] Configure Sentry for error tracking
- [ ] Set up uptime monitoring (UptimeRobot, Pingdom)
- [ ] Enable application metrics (New Relic, DataDog)
- [ ] Configure log aggregation (LogDNA, Papertrail)

### Regular Maintenance
- [ ] Weekly: Check logs for errors
- [ ] Monthly: Update dependencies
- [ ] Quarterly: Security audit
- [ ] Yearly: SSL certificate renewal

---

## 🆘 Support

If you encounter issues:
1. Check logs for error messages
2. Verify environment variables are set correctly
3. Ensure database migrations ran successfully
4. Check network/firewall settings
5. Contact support with error details

---

**Ready to deploy!** Choose your platform above and follow the steps. The application is production-ready and configured for secure deployment.