// Protected endpoints to GET and UPDATE user profile/settings
const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const bcrypt = require('bcrypt');

const User = require('../models/User');

// GET /api/user/me  (returns user profile)
router.get('/me', auth, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-passwordHash -__v');
    if (!user) return res.status(404).json({ msg: 'User not found' });
    res.json({ user });
  } catch (err) {
    console.error('Get user error:', err);
    res.status(500).json({ msg: 'Server error' });
  }
});

// PUT /api/user/me  (update displayName, email, password)
// Body may include: displayName, email, password
router.put('/me', auth, async (req, res) => {
  try {
    const { displayName, email, password } = req.body;
    const updates = {};

    if (displayName !== undefined) updates.displayName = displayName;
    if (email !== undefined) updates.email = email.toLowerCase();

    if (password !== undefined) {
      const saltRounds = parseInt(process.env.BCRYPT_SALT_ROUNDS || '10', 10);
      const passwordHash = await bcrypt.hash(password, saltRounds);
      updates.passwordHash = passwordHash;
    }

    const user = await User.findByIdAndUpdate(req.user.id, updates, { new: true }).select('-passwordHash -__v');
    if (!user) return res.status(404).json({ msg: 'User not found' });

    res.json({ msg: 'User updated', user });
  } catch (err) {
    console.error('Update user error:', err);
    res.status(500).json({ msg: 'Server error' });
  }
});

module.exports = router;
