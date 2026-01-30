const mongoose = require('mongoose');

const RoutineExerciseSchema = new mongoose.Schema({
  name: { type: String, required: true },
  description: { type: String, default: '' },
  reps: { type: Number, default: 0 },
  sets: { type: Number, default: 0 },
  durationSeconds: { type: Number, default: 0 },
  restSeconds: { type: Number, default: 0 },
});

const RoutineSchema = new mongoose.Schema({
  owner: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  name: { type: String, required: true },
  description: { type: String, default: '' },
  exercises: { type: [RoutineExerciseSchema], default: [] },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Routine', RoutineSchema);
