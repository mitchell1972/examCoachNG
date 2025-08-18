#!/bin/bash

echo "🚀 Push to GitHub Script"
echo "========================"
echo ""
echo "This script will push your code to GitHub."
echo ""

# Check if remote exists
if git remote get-url origin &>/dev/null; then
    echo "Remote 'origin' already exists. Updating..."
    git remote remove origin
fi

echo "Enter your GitHub username:"
read GITHUB_USERNAME

echo ""
echo "Adding GitHub remote..."
git remote add origin https://github.com/$GITHUB_USERNAME/examcoach.git

echo "Pushing code to GitHub..."
git branch -M main
git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Success! Your code is now on GitHub!"
    echo ""
    echo "Repository URL: https://github.com/$GITHUB_USERNAME/examcoach"
    echo ""
    echo "Next steps:"
    echo "1. Go to https://railway.app"
    echo "2. Sign in with your GitHub account"
    echo "3. Create a new project from your examcoach repository"
else
    echo ""
    echo "❌ Push failed. Please make sure:"
    echo "1. You've created the repository on GitHub"
    echo "2. The repository name is 'examcoach'"
    echo "3. You have the correct username"
    echo ""
    echo "If you need to authenticate, GitHub may prompt you for credentials."
fi
