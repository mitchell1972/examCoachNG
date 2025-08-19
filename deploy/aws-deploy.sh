#!/bin/bash

# AWS Deployment Script for ExamCoach (using AWS Elastic Beanstalk)

echo "🚀 Deploying ExamCoach to AWS Elastic Beanstalk..."

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install it first."
    echo "Visit: https://aws.amazon.com/cli/"
    exit 1
fi

# Check if EB CLI is installed
if ! command -v eb &> /dev/null; then
    echo "❌ EB CLI is not installed. Installing..."
    pip install awsebcli
fi

# Configuration
APP_NAME="examcoach"
ENV_NAME="examcoach-prod"
REGION="us-east-1"
PLATFORM="node.js-20"

# Initialize Elastic Beanstalk
echo "📱 Initializing Elastic Beanstalk..."
eb init $APP_NAME --region $REGION --platform $PLATFORM

# Create environment if it doesn't exist
echo "🌍 Creating environment..."
eb create $ENV_NAME \
  --instance-type t3.small \
  --database \
  --database.engine postgres \
  --database.instance db.t3.micro \
  --database.username examcoach \
  --database.password $(openssl rand -base64 20) \
  || echo "Environment already exists"

# Set environment variables
echo "🔐 Setting environment variables..."
eb setenv \
  NODE_ENV=production \
  JWT_SECRET=$(openssl rand -hex 32) \
  SESSION_SECRET=$(openssl rand -hex 32) \
  ADMIN_USER=admin_prod_2024 \
  ADMIN_PASS=$(openssl rand -base64 20) \
  CORS_ORIGINS="https://$ENV_NAME.$REGION.elasticbeanstalk.com" \
  RATE_LIMIT_WINDOW_MS=900000 \
  RATE_LIMIT_MAX_REQUESTS=100 \
  ANDROID_PACKAGE_NAME=com.examcoachng.app \
  BCRYPT_ROUNDS=12 \
  COOKIE_SECURE=true

# Create .ebextensions for configuration
echo "📝 Creating EB configuration..."
mkdir -p .ebextensions

cat > .ebextensions/node-settings.config << EOF
option_settings:
  aws:elasticbeanstalk:container:nodejs:
    NodeCommand: "cd server && npm start"
    NodeVersion: 20.x
    GzipCompression: true
  aws:elasticbeanstalk:application:environment:
    NPM_CONFIG_PRODUCTION: true
EOF

cat > .ebextensions/migrations.config << EOF
container_commands:
  01_migrate:
    command: "cd server && npm run migrate"
    leader_only: true
EOF

# Deploy
echo "🚀 Deploying to AWS..."
eb deploy

# Set up auto-scaling
echo "⚡ Configuring auto-scaling..."
eb scale 2 --timeout 10

# Enable health monitoring
echo "📊 Enabling enhanced health monitoring..."
eb config set --namespace aws:elasticbeanstalk:healthreporting:system --option SystemType --value enhanced

# Open app
echo "✅ Deployment complete!"
echo "🌐 Opening app..."
eb open

echo "📊 View status with: eb status"
echo "📋 View logs with: eb logs"
