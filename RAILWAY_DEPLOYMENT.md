# Railway Deployment Step-by-Step Guide

## Prerequisites
- GitHub account with your code pushed
- Railway account (sign up at https://railway.app)

## Step 1: Create GitHub Repository

1. Go to https://github.com/new
2. Create a new repository named `examcoach`
3. **DO NOT** initialize with README or .gitignore
4. After creating, add the remote to your local repo:

```bash
git remote add origin https://github.com/YOUR_USERNAME/examcoach.git
git push -u origin main
```

## Step 2: Deploy Backend to Railway

### A. Sign up/Login to Railway
1. Go to https://railway.app
2. Sign in with GitHub (recommended)

### B. Create New Project
1. Click **"New Project"** button
2. Select **"Deploy from GitHub repo"**
3. Authorize Railway to access your GitHub
4. Search and select your `examcoach` repository

### C. Configure the Backend Service
1. Railway will detect the Node.js app
2. Click on the service card that appears
3. Go to **Settings** tab
4. Under **Service**, set:
   - **Root Directory**: `/server`
   - **Build Command**: `npm install && npm run build`
   - **Start Command**: `npm start`

### D. Add PostgreSQL Database
1. In your Railway project, click **"+ New"**
2. Select **"Database"**
3. Choose **"PostgreSQL"**
4. Railway will automatically provision a PostgreSQL database

### E. Connect Database to Backend
1. Click on your backend service
2. Go to **Variables** tab
3. Click **"Add Variable Reference"**
4. Select `DATABASE_URL` from the PostgreSQL service
5. Add these additional variables:
   ```
   NODE_ENV=production
   PORT=3000
   CORS_ORIGINS=https://your-frontend-domain.vercel.app
   ```

### F. Run Database Setup
1. After the backend deploys, go to the backend service
2. Click on **"Settings"** → **"Deploy"**
3. Add a temporary deploy override:
   - **Start Command**: `npm run setup-db && npm start`
4. Deploy once to create tables
5. Remove the override after tables are created

### G. Get Your Backend URL
1. Go to your backend service
2. Click **Settings** → **Networking**
3. Click **"Generate Domain"**
4. Your backend will be available at: `https://your-app.up.railway.app`

## Step 3: Deploy Frontend to Vercel

### A. Update Frontend API URLs
Before deploying, update all HTML files to use your Railway backend URL:

```bash
node update-api-url.js https://your-backend.up.railway.app
```

### B. Deploy to Vercel
1. Go to https://vercel.com
2. Sign in with GitHub
3. Click **"Add New Project"**
4. Import your `examcoach` repository
5. Configure:
   - **Framework Preset**: Other
   - **Root Directory**: `.` (leave as is)
   - **Build Command**: (leave empty)
   - **Output Directory**: `.` (leave as is)
6. Click **Deploy**

### C. Access Your Web App
Your web app will be available at:
- Main app: `https://your-app.vercel.app/phone_app.html`
- Admin: `https://your-app.vercel.app/admin_dashboard.html`
- Test suite: `https://your-app.vercel.app/test_suite.html`

## Step 4: Update Environment Variables

### On Railway (Backend):
```
DATABASE_URL=(automatically set by Railway)
NODE_ENV=production
PORT=3000
CORS_ORIGINS=https://your-frontend.vercel.app
```

### Update CORS in Backend:
Make sure your backend allows your Vercel domain in CORS settings.

## Step 5: Test Your Deployment

1. Visit your frontend URL
2. Check that it shows "Connected to Backend Database"
3. Try selecting a subject and starting a practice session
4. Verify questions load from the database

## Troubleshooting

### Backend Issues:
- Check Railway logs: Click on service → **Observability** → **Logs**
- Verify DATABASE_URL is set correctly
- Ensure build completes successfully

### Frontend Issues:
- Check browser console for errors
- Verify API_BASE URL is correct in HTML files
- Check CORS settings on backend

### Database Issues:
- Ensure tables are created (run setup script)
- Check PostgreSQL logs in Railway
- Verify connection string format

## Monitoring

### Railway Dashboard:
- View metrics, logs, and deployments
- Set up alerts for errors
- Monitor database usage

### Useful Commands:

Check backend health:
```bash
curl https://your-backend.up.railway.app/health
```

Check subjects endpoint:
```bash
curl https://your-backend.up.railway.app/api/questions/subjects
```

## Cost Considerations

### Railway:
- Free tier: $5 credit/month
- Includes 500 hours of compute
- PostgreSQL included

### Vercel:
- Free tier generous for static sites
- Unlimited bandwidth for personal projects

## Next Steps

1. Set up custom domain (optional)
2. Add SSL certificates (automatic on Railway/Vercel)
3. Set up monitoring (e.g., UptimeRobot)
4. Configure backup strategy for database
5. Set up CI/CD with GitHub Actions

---

## Quick Deploy Checklist

- [ ] Code pushed to GitHub
- [ ] Railway account created
- [ ] Backend deployed on Railway
- [ ] PostgreSQL database connected
- [ ] Database tables created
- [ ] Frontend API URLs updated
- [ ] Frontend deployed on Vercel
- [ ] CORS configured correctly
- [ ] App tested and working
