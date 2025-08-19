// Test script to verify clean deployment
console.log('Testing clean deployment...');

// Check that essential files exist
const fs = require('fs');
const path = require('path');

const essentialFiles = [
  'apps/server/package.json',
  'apps/frontend/package.json',
  'packages/db/package.json',
  'railway.toml',
  'vercel.json'
];

console.log('Checking essential files...');
essentialFiles.forEach(file => {
  if (fs.existsSync(file)) {
    console.log(`✅ ${file} exists`);
  } else {
    console.log(`❌ ${file} missing`);
  }
});

console.log('\nClean deployment verification complete!');
