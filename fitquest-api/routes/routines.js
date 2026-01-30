const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');

const Routine = require('../models/Routine');

// GET /api/routines - get all routines for logged in user
router.get('/', auth, async (req, res) => {
  try {
    const routines = await Routine.find({ owner: req.user.id }).select('-__v');
    res.json({ routines });
  } catch (err) {
    console.error('Get routines error:', err);
    res.status(500).json({ msg: 'Server error' });
  }
});

// POST /api/routines - create a new routine
// Body: { name, description?, exercises: [...] }
router.post('/', auth, async (req, res) => {
  try {
    const { name, description, exercises } = req.body;
    if (!name) return res.status(400).json({ msg: 'Name is required' });

    const newRoutine = new Routine({
      owner: req.user.id,
      name,
      description: description || '',
      exercises: Array.isArray(exercises) ? exercises : [],
    });

    await newRoutine.save();
    res.status(201).json({ msg: 'Routine created', routine: newRoutine });
  } catch (err) {
    console.error('Create routine error:', err);
    res.status(500).json({ msg: 'Server error' });
  }
});

// GET /api/routines/:id - get a single routine (must belong to user)
router.get('/:id', auth, async (req, res) => {
  try {
    const routine = await Routine.findById(req.params.id).select('-__v');
    if (!routine) return res.status(404).json({ msg: 'Routine not found' });
    if (String(routine.owner) !== req.user.id) return res.status(403).json({ msg: 'Forbidden' });
    res.json({ routine });
  } catch (err) {
    console.error('Get routine by id error:', err);
    res.status(500).json({ msg: 'Server error' });
  }
});

// PUT /api/routines/:id - update a routine
router.put('/:id', auth, async (req, res) => {
  try {
    const routine = await Routine.findById(req.params.id);
    if (!routine) return res.status(404).json({ msg: 'Routine not found' });
    if (String(routine.owner) !== req.user.id) return res.status(403).json({ msg: 'Forbidden' });

    const { name, description, exercises } = req.body;
    if (name !== undefined) routine.name = name;
    if (description !== undefined) routine.description = description;
    if (exercises !== undefined) routine.exercises = Array.isArray(exercises) ? exercises : routine.exercises;
    routine.updatedAt = Date.now();
    await routine.save();
    res.json({ msg: 'Routine updated', routine });
  } catch (err) {
    console.error('Update routine error:', err);
    res.status(500).json({ msg: 'Server error' });
  }
});

// DELETE /api/routines/:id
router.delete('/:id', auth, async (req, res) => {
  try {
    const routine = await Routine.findById(req.params.id);
    if (!routine) return res.status(404).json({ msg: 'Routine not found' });
    if (String(routine.owner) !== req.user.id) return res.status(403).json({ msg: 'Forbidden' });
    await routine.remove();
    res.json({ msg: 'Routine deleted' });
  } catch (err) {
    console.error('Delete routine error:', err);
    res.status(500).json({ msg: 'Server error' });
  }
});

module.exports = router;
