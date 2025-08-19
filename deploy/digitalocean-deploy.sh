#!/bin/bash

# DigitalOcean App Platform Deployment Script for ExamCoach

echo "🚀 Deploying ExamCoach to DigitalOcean App Platform..."

# Check if doctl is installed
if ! command -v doctl &> /dev/null; then
    echo "❌ DigitalOcean CLI (doctl) is not installed."
    echo "Install with: brew install doctl"
    echo "Visit: https://docs.digitalocean.com/reference/doctl/how-to/install/"
    exit 1
fi

# Configuration
APP_NAME="examcoach"
REGION="nyc"

# Create app spec file
echo "📝 Creating app specification..."
cat > app.yaml << EOF
name: examcoach
region: ${REGION}
services:
- name: backend
  github:
    repo: mitchell1972/examCoachNG
    branch: main
    deploy_on_push: true
  build_command: cd server && npm install && npm run build
  run_command: cd server && npm start
  environment_slug: node-js
  instance_size_slug: basic-xxs
  instance_count: 1
  http_port: 3000
  health_check:
    http_path: /health
    initial_delay_seconds: 10
    period_seconds: 10
    timeout_seconds: 5
    success_threshold: 1
    failure_threshold: 3
  envs:
  - key: NODE_ENV
    value: production
  - key: JWT_SECRET
    value: \${JWT_SECRET}
    type: SECRET
  - key: SESSION_SECRET
    value: \${SESSION_SECRET}
    type: SECRET
  - key: ADMIN_USER
    value: admin_prod_2024
  - key: ADMIN_PASS
    value: \${ADMIN_PASS}
    type: SECRET
  - key: DATABASE_URL
    value: \${db.DATABASE_URL}
    scope: RUN_TIME
  - key: REDIS_URL
    value: \${redis.DATABASE_URL}
    scope: RUN_TIME
  - key: CORS_ORIGINS
    value: https://examcoach.ondigitalocean.app
  - key: ANDROID_PACKAGE_NAME
    value: com.examcoachng.app

databases:
- name: db
  engine: PG
  version: "15"
  size: db-s-1vcpu-1gb
  num_nodes: 1

- name: redis
  engine: REDIS
  version: "7"
  size: db-s-1vcpu-1gb
  num_nodes: 1
EOF

# Create the app
echo "📱 Creating DigitalOcean app..."
doctl apps create --spec app.yaml

# Get app ID
APP_ID=$(doctl apps list --format ID --no-header | head -1)

# Set secrets
echo "🔐 Setting secret environment variables..."
doctl apps update $APP_ID --spec app.yaml \
  --env JWT_SECRET=$(openssl rand -hex 32) \
  --env SESSION_SECRET=$(openssl rand -hex 32) \
  --env ADMIN_PASS=$(openssl rand -base64 20)

# Deploy
echo "🚀 Triggering deployment..."
doctl apps create-deployment $APP_ID

# Wait for deployment
echo "⏳ Waiting for deployment to complete..."
sleep 30

# Get app URL
APP_URL=$(doctl apps get $APP_ID --format LiveURL --no-header)

echo "✅ Deployment complete!"
echo "🌐 App URL: $APP_URL"
echo ""
echo "📊 View logs with: doctl apps logs $APP_ID"
echo "📋 View app details with: doctl apps get $APP_ID"

# Open app in browser
if [[ "$OSTYPE" == "darwin"* ]]; then
    open $APP_URL
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    xdg-open $APP_URL
fi
