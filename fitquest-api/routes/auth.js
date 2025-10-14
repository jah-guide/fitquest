// Routes: /api/auth/register and /api/auth/login
const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const User = require('../models/User');

// Helper: create JWT token
function createToken(user) {
  return jwt.sign(
    { id: user._id.toString(), email: user.email },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  );
}

// POST /api/auth/register
// Body: { email, password, displayName? }
router.post('/register', async (req, res) => {
  try {
    const { email, password, displayName } = req.body;
    if (!email || !password) return res.status(400).json({ msg: 'Email and password required' });

    const existing = await User.findOne({ email: email.toLowerCase() });
    if (existing) return res.status(400).json({ msg: 'User with this email already exists' });

    const saltRounds = parseInt(process.env.BCRYPT_SALT_ROUNDS || '10', 10);
    const passwordHash = await bcrypt.hash(password, saltRounds);

    const newUser = new User({
      email: email.toLowerCase(),
      passwordHash,
      displayName: displayName || ''
    });

    await newUser.save();

    const token = createToken(newUser);

    return res.status(201).json({
      msg: 'User created',
      token,
      user: { id: newUser._id, email: newUser.email, displayName: newUser.displayName }
    });
  } catch (err) {
    console.error('Register error', err);
    return res.status(500).json({ msg: 'Server error' });
  }
});

// POST /api/auth/login
// Body: { email, password }
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) return res.status(400).json({ msg: 'Email and password required' });

    const user = await User.findOne({ email: email.toLowerCase() });
    if (!user) return res.status(400).json({ msg: 'Invalid credentials' });

    const match = await bcrypt.compare(password, user.passwordHash);
    if (!match) return res.status(400).json({ msg: 'Invalid credentials' });

    const token = createToken(user);

    return res.json({
      msg: 'Login successful',
      token,
      user: { id: user._id, email: user.email, displayName: user.displayName }
    });
  } catch (err) {
    console.error('Login error', err);
    return res.status(500).json({ msg: 'Server error' });
  }
});

module.exports = router;
