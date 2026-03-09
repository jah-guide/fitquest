// Protected endpoints to GET and UPDATE user profile/settings
const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const bcrypt = require('bcrypt');
const { getCloudinaryClient } = require('../config/cloudinary');

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

// PUT /api/user/me/push-token
// Body: { token }
router.put('/me/push-token', auth, async (req, res) => {
  try {
    const { token } = req.body;
    if (!token || typeof token !== 'string') {
      return res.status(400).json({ msg: 'Valid push token is required' });
    }

    const user = await User.findByIdAndUpdate(
      req.user.id,
      { $addToSet: { pushTokens: token } },
      { new: true }
    ).select('-passwordHash -__v');

    if (!user) return res.status(404).json({ msg: 'User not found' });

    res.json({ msg: 'Push token saved', user });
  } catch (err) {
    console.error('Save push token error:', err);
    res.status(500).json({ msg: 'Server error' });
  }
});

// DELETE /api/user/me/push-token
// Body: { token }
router.delete('/me/push-token', auth, async (req, res) => {
  try {
    const { token } = req.body;
    if (!token || typeof token !== 'string') {
      return res.status(400).json({ msg: 'Valid push token is required' });
    }

    const user = await User.findByIdAndUpdate(
      req.user.id,
      { $pull: { pushTokens: token } },
      { new: true }
    ).select('-passwordHash -__v');

    if (!user) return res.status(404).json({ msg: 'User not found' });

    res.json({ msg: 'Push token removed', user });
  } catch (err) {
    console.error('Remove push token error:', err);
    res.status(500).json({ msg: 'Server error' });
  }
});

// POST /api/user/me/avatar
// Body: { imageBase64 }
router.post('/me/avatar', auth, async (req, res) => {
  try {
    const { imageBase64 } = req.body;

    if (!imageBase64 || typeof imageBase64 !== 'string') {
      return res.status(400).json({ msg: 'imageBase64 is required' });
    }

    const cloudinary = getCloudinaryClient();
    if (!cloudinary) {
      return res.status(503).json({
        msg: 'Blob storage is not configured. Set CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET.',
      });
    }

    const normalized = imageBase64.includes('base64,')
      ? imageBase64
      : `data:image/jpeg;base64,${imageBase64}`;

    const uploadResult = await cloudinary.uploader.upload(normalized, {
      folder: 'fitquest/avatars',
      public_id: `user_${req.user.id}_${Date.now()}`,
      overwrite: true,
      resource_type: 'image',
    });

    const user = await User.findByIdAndUpdate(
      req.user.id,
      { profileImageUrl: uploadResult.secure_url },
      { new: true }
    ).select('-passwordHash -__v');

    if (!user) return res.status(404).json({ msg: 'User not found' });

    return res.json({
      msg: 'Profile image uploaded',
      profileImageUrl: uploadResult.secure_url,
      user,
    });
  } catch (err) {
    console.error('Avatar upload error:', err);
    return res.status(500).json({ msg: 'Server error' });
  }
});

module.exports = router;
