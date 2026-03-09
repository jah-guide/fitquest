require('dotenv').config();
const jwt = require('jsonwebtoken');

// Create a test user token
const testUserId = '507f1f77bcf86cd799439011'; // dummy MongoDB ObjectId
const token = jwt.sign(
  { id: testUserId, email: 'test@example.com' },
  process.env.JWT_SECRET,
  { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
);

console.log('Test JWT Token:');
console.log(token);
