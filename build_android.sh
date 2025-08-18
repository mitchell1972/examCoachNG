#!/bin/bash

echo "🚀 Building ExamCoach Android App..."

# Navigate to app directory
cd app

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# For local testing (replace with your deployed backend URL later)
LOCAL_BACKEND="http://10.0.2.2:3000"  # Android emulator localhost
# PRODUCTION_BACKEND="https://your-deployed-backend.com"

echo "🔨 Building debug APK for local testing..."
flutter build apk --debug \
  --dart-define=API_BASE_URL=$LOCAL_BACKEND \
  --dart-define=FLAVOR=dev

echo "✅ Build complete!"
echo "📱 APK location: app/build/app/outputs/flutter-apk/app-debug.apk"
echo ""
echo "To install on connected device/emulator:"
echo "  flutter install"
echo ""
echo "To build release APK (for production):"
echo "  flutter build apk --release --dart-define=API_BASE_URL=<YOUR_BACKEND_URL>"
