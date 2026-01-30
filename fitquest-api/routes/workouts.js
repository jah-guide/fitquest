const express = require('express');
const router = express.Router();

const Workout = require('../models/Workout');

// GET /api/workouts  - list preloaded/system workouts
router.get('/', async (req, res) => {
  try {
    const workouts = await Workout.find({ system: true }).select('-__v');
    res.json({ workouts });
  } catch (err) {
    console.error('Get workouts error:', err);
    res.status(500).json({ msg: 'Server error' });
  }
});

// GET /api/workouts/:id
router.get('/:id', async (req, res) => {
  try {
    const workout = await Workout.findById(req.params.id).select('-__v');
    if (!workout) return res.status(404).json({ msg: 'Workout not found' });
    res.json({ workout });
  } catch (err) {
    console.error('Get workout by id error:', err);
    res.status(500).json({ msg: 'Server error' });
  }
});

module.exports = router;
