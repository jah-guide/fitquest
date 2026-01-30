// Mongoose User model
const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true
  },
  // passwordHash is optional to allow SSO-only accounts
  passwordHash: {
    type: String,
  },
  displayName: {
    type: String,
    default: ''
  },
  // Social provider fields: 'local' (email/password), 'google', 'apple', etc.
  provider: {
    type: String,
    enum: ['local', 'google', 'apple'],
    default: 'local'
  },
  providerId: {
    type: String,
    default: ''
  },
  // Add other settings fields as needed later
  createdAt: {
    type: Date,
    default: Date.now
  },
  // optional: lastLogin, profilePictureUrl, preferences, etc.
});

module.exports = mongoose.model('User', UserSchema);
