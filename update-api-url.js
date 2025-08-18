#!/usr/bin/env node

/**
 * Script to update API URLs in HTML files for production deployment
 * Usage: node update-api-url.js https://your-backend.railway.app
 */

const fs = require('fs');
const path = require('path');

const newApiUrl = process.argv[2];

if (!newApiUrl) {
  console.error('Please provide the new API URL as an argument');
  console.error('Usage: node update-api-url.js https://your-backend.railway.app');
  process.exit(1);
}

// List of HTML files to update
const htmlFiles = [
  'phone_app.html',
  'index.html',
  'test_suite.html',
  'admin_dashboard.html',
  'jamb_api_test.html',
  'simple_test.html',
  'debug_connection.html',
  'jamb_test.html'
];

// Pattern to match API_BASE declarations
const patterns = [
  // Pattern 1: const API_BASE = 'http://localhost:3000';
  /const\s+API_BASE\s*=\s*['"]http:\/\/localhost:3000['"]/g,
  // Pattern 2: const API_BASE = window.location.origin...
  /const\s+API_BASE\s*=\s*window\.location\.origin\.includes\('replit'\)[^;]+;/g,
  // Pattern 3: API_BASE = 'http://localhost:3000'
  /API_BASE\s*=\s*['"]http:\/\/localhost:3000['"]/g
];

console.log(`Updating API URLs to: ${newApiUrl}`);
console.log('-----------------------------------');

htmlFiles.forEach(file => {
  const filePath = path.join(__dirname, file);
  
  if (!fs.existsSync(filePath)) {
    console.log(`⚠️  ${file} - File not found, skipping`);
    return;
  }
  
  let content = fs.readFileSync(filePath, 'utf8');
  let updated = false;
  
  patterns.forEach(pattern => {
    if (pattern.test(content)) {
      content = content.replace(pattern, `const API_BASE = '${newApiUrl}'`);
      updated = true;
    }
  });
  
  if (updated) {
    fs.writeFileSync(filePath, content);
    console.log(`✅ ${file} - Updated successfully`);
  } else {
    console.log(`ℹ️  ${file} - No changes needed`);
  }
});

console.log('-----------------------------------');
console.log('✨ API URL update complete!');
console.log('');
console.log('Next steps:');
console.log('1. Test your changes locally');
console.log('2. Commit and push to your repository');
console.log('3. Deploy to Vercel or your hosting platform');
