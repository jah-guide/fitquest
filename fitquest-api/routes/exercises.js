const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const Exercise = require('../models/Exercise');

// GET /api/exercises - all exercises created/synced by the current user
router.get('/', auth, async (req, res) => {
  try {
    const exercises = await Exercise.find({ owner: req.user.id })
      .sort({ createdAt: -1 })
      .select('-__v');
    return res.json({ exercises });
  } catch (err) {
    console.error('Get exercises error:', err);
    return res.status(500).json({ msg: 'Server error' });
  }
});

// POST /api/exercises - create one exercise for sync
router.post('/', auth, async (req, res) => {
  try {
    const { name, category, description, imageUrl } = req.body;

    if (!name || !category) {
      return res.status(400).json({ msg: 'name and category are required' });
    }

    const exercise = new Exercise({
      owner: req.user.id,
      name: String(name).trim(),
      category: String(category).trim(),
      description: description ? String(description).trim() : '',
      imageUrl: imageUrl ? String(imageUrl).trim() : '',
      updatedAt: Date.now(),
    });

    await exercise.save();
    return res.status(201).json({ msg: 'Exercise synced', exercise });
  } catch (err) {
    console.error('Create exercise error:', err);
    return res.status(500).json({ msg: 'Server error' });
  }
});

module.exports = router;
