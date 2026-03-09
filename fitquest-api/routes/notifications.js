const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const User = require('../models/User');
const { getMessaging } = require('../config/firebaseAdmin');

// POST /api/notifications/send-user
// Body: { userId?, title, body, data? }
// If userId omitted, sends to current authenticated user.
// If userId is provided and differs from current user, require x-notify-key header matching NOTIFY_API_KEY.
router.post('/send-user', auth, async (req, res) => {
  try {
    const { userId, title, body, data } = req.body;

    if (!title || !body) {
      return res.status(400).json({ msg: 'title and body are required' });
    }

    const targetUserId = userId || req.user.id;

    if (targetUserId !== req.user.id) {
      const expectedKey = process.env.NOTIFY_API_KEY;
      const suppliedKey = req.header('x-notify-key');
      if (!expectedKey || suppliedKey !== expectedKey) {
        return res.status(403).json({ msg: 'Not allowed to notify other users' });
      }
    }

    const user = await User.findById(targetUserId).select('pushTokens');
    if (!user) return res.status(404).json({ msg: 'Target user not found' });

    const tokens = Array.isArray(user.pushTokens)
      ? user.pushTokens.filter((token) => typeof token === 'string' && token.length > 0)
      : [];

    if (!tokens.length) {
      return res.status(404).json({ msg: 'No registered push tokens for this user' });
    }

    const messaging = getMessaging();
    if (!messaging) {
      return res.status(503).json({
        msg: 'Firebase Admin not configured. Set FIREBASE_SERVICE_ACCOUNT_JSON or FIREBASE_SERVICE_ACCOUNT_PATH.',
      });
    }

    const sanitizedData = {};
    if (data && typeof data === 'object') {
      for (const [key, value] of Object.entries(data)) {
        sanitizedData[String(key)] = String(value);
      }
    }

    const result = await messaging.sendEachForMulticast({
      tokens,
      notification: { title, body },
      data: sanitizedData,
    });

    const invalidTokens = [];
    result.responses.forEach((response, index) => {
      if (!response.success) {
        const code = response.error?.code;
        if (
          code === 'messaging/registration-token-not-registered' ||
          code === 'messaging/invalid-registration-token'
        ) {
          invalidTokens.push(tokens[index]);
        }
      }
    });

    if (invalidTokens.length) {
      await User.findByIdAndUpdate(targetUserId, {
        $pull: { pushTokens: { $in: invalidTokens } },
      });
    }

    return res.json({
      msg: 'Notification send completed',
      successCount: result.successCount,
      failureCount: result.failureCount,
      invalidTokensRemoved: invalidTokens.length,
    });
  } catch (error) {
    console.error('Send notification error:', error);
    return res.status(500).json({ msg: 'Server error' });
  }
});

module.exports = router;
