const mongoose = require('mongoose');

const ExerciseSchema = new mongoose.Schema({
  name: { type: String, required: true },
  description: { type: String, default: '' },
  durationSeconds: { type: Number, default: 0 },
  reps: { type: Number, default: 0 },
  sets: { type: Number, default: 0 },
  restSeconds: { type: Number, default: 0 },
});

const WorkoutSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: { type: String, default: '' },
  exercises: { type: [ExerciseSchema], default: [] },
  createdAt: { type: Date, default: Date.now },
  // system flag so we can separate preloaded workouts from user-created routines
  system: { type: Boolean, default: true },
});

module.exports = mongoose.model('Workout', WorkoutSchema);
