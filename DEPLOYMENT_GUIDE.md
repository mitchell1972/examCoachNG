# ExamCoach Deployment Guide

## Backend Deployment to Railway

### Prerequisites
1. Create a Railway account at https://railway.app
2. Install Railway CLI (optional): `npm install -g @railway/cli`

### Step 1: Prepare the Backend

The backend is already configured for deployment with:
- `railway.json` configuration file
- Environment variables support
- Production-ready CORS settings
- PostgreSQL database support

### Step 2: Deploy to Railway

#### Option A: Using Railway Dashboard (Recommended)

1. Go to https://railway.app and sign in
2. Click "New Project"
3. Select "Deploy from GitHub repo"
4. Connect your GitHub account and select your repository
5. Railway will automatically detect the Node.js app in the `/server` directory
6. Click "Add Service" → "Database" → "PostgreSQL" to add a database
7. Railway will automatically set the `DATABASE_URL` environment variable

#### Option B: Using Railway CLI

```bash
cd server
railway login
railway init
railway add postgresql
railway up
```

### Step 3: Configure Environment Variables

In Railway dashboard, go to your project → Variables, and add:

```env
NODE_ENV=production
PORT=3000
JWT_SECRET=<generate-a-secure-random-string>
CORS_ORIGINS=https://your-frontend-domain.vercel.app,https://your-other-domain.com
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

Railway automatically provides:
- `DATABASE_URL` (from PostgreSQL service)
- `PORT` (Railway assigns this)

### Step 4: Run Database Migrations

After deployment, run the database setup:

1. In Railway dashboard, go to your backend service
2. Click on "Settings" → "Deploy" → "Run Command"
3. Run: `npx tsx scripts/setup-database.ts`
4. Then run: `npx tsx scripts/seed-questions.ts`

Or using Railway CLI:
```bash
railway run npx tsx scripts/setup-database.ts
railway run npx tsx scripts/seed-questions.ts
```

### Step 5: Get Your Backend URL

Your backend will be available at:
```
https://your-app-name.railway.app
```

Test it by visiting:
- Health check: `https://your-app-name.railway.app/health`
- API endpoint: `https://your-app-name.railway.app/api/questions/subjects`

---

## Web App Deployment to Vercel

### Step 1: Prepare the Web App

1. Update all API URLs in your HTML files to point to your Railway backend:

```javascript
// In phone_app.html and other HTML files, update:
const API_BASE = 'https://your-app-name.railway.app';
```

### Step 2: Create Vercel Configuration

Create `vercel.json` in the root directory:

```json
{
  "buildCommand": "echo 'No build required'",
  "outputDirectory": ".",
  "framework": null,
  "rewrites": [
    { "source": "/(.*)", "destination": "/$1" }
  ],
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "X-Content-Type-Options",
          "value": "nosniff"
        },
        {
          "key": "X-Frame-Options",
          "value": "DENY"
        },
        {
          "key": "X-XSS-Protection",
          "value": "1; mode=block"
        }
      ]
    }
  ]
}
```

### Step 3: Deploy to Vercel

#### Option A: Using Vercel Dashboard

1. Go to https://vercel.com and sign in
2. Click "Add New Project"
3. Import your Git repository
4. Configure:
   - Framework Preset: Other
   - Root Directory: ./
   - Build Command: (leave empty)
   - Output Directory: ./
5. Click "Deploy"

#### Option B: Using Vercel CLI

```bash
npm install -g vercel
vercel
```

### Step 4: Update CORS in Backend

Add your Vercel domain to the CORS_ORIGINS environment variable in Railway:

```env
CORS_ORIGINS=https://your-app.vercel.app
```

---

## Mobile App Deployment (Flutter)

### Prerequisites
- Fix compilation errors in `/app` directory
- Android SDK installed
- Flutter configured

### Build APK

```bash
cd app
flutter build apk --release \
  --dart-define=API_BASE_URL=https://your-app-name.railway.app \
  --dart-define=FLAVOR=prod
```

The APK will be available at:
```
app/build/app/outputs/flutter-apk/app-release.apk
```

---

## Post-Deployment Checklist

- [ ] Backend health check working
- [ ] Database connected and seeded
- [ ] CORS configured for frontend domains
- [ ] Frontend API URLs updated
- [ ] SSL certificates active (automatic on Railway/Vercel)
- [ ] Environment variables set correctly
- [ ] Rate limiting configured
- [ ] Error logging working

---

## Monitoring

### Railway
- View logs: Railway Dashboard → Your Service → Logs
- Monitor metrics: Railway Dashboard → Your Service → Metrics

### Vercel
- View logs: Vercel Dashboard → Your Project → Functions → Logs
- Analytics: Vercel Dashboard → Your Project → Analytics

---

## Troubleshooting

### Backend Issues
1. **Database connection fails**: Check DATABASE_URL in Railway variables
2. **CORS errors**: Add frontend domain to CORS_ORIGINS
3. **502 errors**: Check Railway logs for crash reports

### Frontend Issues
1. **API calls fail**: Verify API_BASE URL is correct
2. **CORS blocked**: Ensure backend CORS_ORIGINS includes your domain

---

## Support

For deployment issues:
- Railway: https://docs.railway.app
- Vercel: https://vercel.com/docs
- PostgreSQL: https://www.postgresql.org/docs/
