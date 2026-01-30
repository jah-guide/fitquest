// Routes: /api/auth/register and /api/auth/login
const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const axios = require('axios');

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

// POST /api/auth/social
// Body: { provider, idToken }
// Minimal implementation: verifies Google id_token via Google's tokeninfo endpoint.
// For Apple, decodes the identity token payload (note: full verification requires fetching Apple's public keys).
router.post('/social', async (req, res) => {
  try {
    const { provider, idToken } = req.body;
    if (!provider || !idToken) return res.status(400).json({ msg: 'provider and idToken required' });

    let email = null;
    let providerId = null;
    let displayName = '';

    if (provider === 'google') {
      // Verify token via Google's tokeninfo endpoint
      const resp = await axios.get(`https://oauth2.googleapis.com/tokeninfo?id_token=${idToken}`);
      if (resp.status !== 200) return res.status(400).json({ msg: 'Invalid Google token' });
      const data = resp.data;
      email = data.email?.toLowerCase();
      providerId = data.sub; // Google's subject identifier
      displayName = data.name || '';
    } else if (provider === 'apple') {
      // Minimal: decode JWT without verifying signature. For production, verify signature using Apple's public keys.
      const decoded = jwt.decode(idToken);
      if (!decoded) return res.status(400).json({ msg: 'Invalid Apple token' });
      email = decoded.email ? String(decoded.email).toLowerCase() : null;
      providerId = decoded.sub;
      displayName = '';
    } else {
      return res.status(400).json({ msg: 'Unsupported provider' });
    }

    if (!email || !providerId) return res.status(400).json({ msg: 'Unable to extract user info from token' });

    // Find existing user by providerId first
    let user = await User.findOne({ provider, providerId });

    if (!user) {
      // If not found by providerId, try by email
      user = await User.findOne({ email });
      if (user) {
        // Conflict: existing local/email account with password
        if (user.provider === 'local' && user.passwordHash) {
          return res.status(409).json({ msg: 'Account exists with different sign-in method', code: 'account_conflict' });
        }
        // Otherwise, attach provider info to existing record
        user.provider = provider;
        user.providerId = providerId;
        if (!user.displayName && displayName) user.displayName = displayName;
        await user.save();
      } else {
        // No user -> create new SSO user (no passwordHash)
        const newUser = new User({
          email,
          displayName: displayName || '',
          provider,
          providerId,
        });
        await newUser.save();
        user = newUser;
      }
    }

    // Create token and respond
    const token = createToken(user);
    return res.json({ msg: 'Social login successful', token, user: { id: user._id, email: user.email, displayName: user.displayName } });
  } catch (err) {
    console.error('Social login error', err?.response?.data || err);
    return res.status(500).json({ msg: 'Server error' });
  }
});

module.exports = router;
