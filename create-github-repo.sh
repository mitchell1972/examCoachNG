#!/bin/bash

# This script helps create a GitHub repository and push the code

echo "📦 Creating GitHub Repository for ExamCoach"
echo "==========================================="
echo ""
echo "Please follow these steps:"
echo ""
echo "1. Go to https://github.com/new"
echo "2. Create a new repository with:"
echo "   - Repository name: examcoach"
echo "   - Description: JAMB exam practice application with backend API"
echo "   - Set as Public or Private (your choice)"
echo "   - DO NOT initialize with README, .gitignore, or license"
echo ""
echo "3. After creating, GitHub will show you commands. Come back here."
echo ""
read -p "Press Enter when you've created the repository on GitHub..."

echo ""
echo "Enter your GitHub username:"
read GITHUB_USERNAME

echo ""
echo "Setting up remote and pushing code..."

# Add remote origin
git remote add origin https://github.com/$GITHUB_USERNAME/examcoach.git

# Push to GitHub
git branch -M main
git push -u origin main

echo ""
echo "✅ Code pushed to GitHub successfully!"
echo ""
echo "Your repository is at: https://github.com/$GITHUB_USERNAME/examcoach"
