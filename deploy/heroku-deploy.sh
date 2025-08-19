#!/bin/bash

# Heroku Deployment Script for ExamCoach

echo "🚀 Deploying ExamCoach to Heroku..."

# Check if Heroku CLI is installed
if ! command -v heroku &> /dev/null; then
    echo "❌ Heroku CLI is not installed. Please install it first."
    echo "Visit: https://devcenter.heroku.com/articles/heroku-cli"
    exit 1
fi

# Configuration
APP_NAME="examcoach-backend"
REGION="us"

# Create Heroku app if it doesn't exist
echo "📱 Creating Heroku app..."
heroku create $APP_NAME --region $REGION || echo "App already exists"

# Add PostgreSQL addon
echo "🗄️ Adding PostgreSQL database..."
heroku addons:create heroku-postgresql:mini --app $APP_NAME || echo "PostgreSQL already added"

# Add Redis addon
echo "💾 Adding Redis cache..."
heroku addons:create heroku-redis:mini --app $APP_NAME || echo "Redis already added"

# Set buildpacks
echo "📦 Setting buildpacks..."
heroku buildpacks:set heroku/nodejs --app $APP_NAME

# Set environment variables
echo "🔐 Setting environment variables..."
heroku config:set \
  NODE_ENV=production \
  JWT_SECRET=$(openssl rand -hex 32) \
  SESSION_SECRET=$(openssl rand -hex 32) \
  ADMIN_USER=admin_prod_2024 \
  ADMIN_PASS=$(openssl rand -base64 20) \
  CORS_ORIGINS="https://$APP_NAME.herokuapp.com" \
  RATE_LIMIT_WINDOW_MS=900000 \
  RATE_LIMIT_MAX_REQUESTS=100 \
  ANDROID_PACKAGE_NAME=com.examcoachng.app \
  BCRYPT_ROUNDS=12 \
  COOKIE_SECURE=true \
  --app $APP_NAME

# Create Procfile
echo "📝 Creating Procfile..."
cat > Procfile << EOF
web: cd server && npm start
release: cd server && npm run migrate
EOF

# Deploy
echo "🚀 Deploying to Heroku..."
git add .
git commit -m "Deploy to Heroku"
git push heroku main

# Run migrations
echo "🗄️ Running database migrations..."
heroku run "cd server && npm run migrate" --app $APP_NAME

# Scale dynos
echo "⚡ Scaling dynos..."
heroku ps:scale web=1 --app $APP_NAME

# Open app
echo "✅ Deployment complete!"
echo "🌐 Opening app..."
heroku open --app $APP_NAME

echo "📊 View logs with: heroku logs --tail --app $APP_NAME"
