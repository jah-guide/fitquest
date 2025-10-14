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
  passwordHash: {
    type: String,
    required: true
  },
  displayName: {
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
