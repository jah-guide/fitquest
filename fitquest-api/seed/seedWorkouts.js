const mongoose = require('mongoose');
require('dotenv').config();

const Workout = require('../models/Workout');

const sampleWorkouts = [
  {
    title: 'Full Body Beginner',
    description: 'A gentle full-body routine for beginners',
    exercises: [
      { name: 'Bodyweight Squat', reps: 12, sets: 3, restSeconds: 60 },
      { name: 'Incline Push-up', reps: 10, sets: 3, restSeconds: 60 },
      { name: 'Plank', durationSeconds: 45, sets: 3, restSeconds: 45 },
    ],
  },
  {
    title: 'Upper Body Strength',
    description: 'Push/pull focused upper body routine',
    exercises: [
      { name: 'Push-up', reps: 8, sets: 4, restSeconds: 90 },
      { name: 'Bent-over Row', reps: 10, sets: 4, restSeconds: 90 },
      { name: 'Overhead Press', reps: 8, sets: 3, restSeconds: 90 },
    ],
  },
  {
    title: 'Cardio Blast',
    description: 'Short high-intensity cardio workout',
    exercises: [
      { name: 'Jumping Jacks', durationSeconds: 60, sets: 3, restSeconds: 30 },
      { name: 'Burpees', reps: 12, sets: 3, restSeconds: 45 },
      { name: 'Mountain Climbers', durationSeconds: 45, sets: 3, restSeconds: 30 },
    ],
  },
];

async function seed() {
  const mongoUri = process.env.MONGO_URI || 'mongodb://localhost:27017/fitquest';
  await mongoose.connect(mongoUri, { useNewUrlParser: true, useUnifiedTopology: true });
  console.log('Connected to MongoDB for seeding');

  for (const w of sampleWorkouts) {
    const exists = await Workout.findOne({ title: w.title });
    if (!exists) {
      const newW = new Workout({ ...w, system: true });
      await newW.save();
      console.log('Inserted', w.title);
    } else {
      console.log('Already exists', w.title);
    }
  }

  await mongoose.disconnect();
  console.log('Seeding complete');
}

seed().catch((e) => {
  console.error('Seeding error', e);
  process.exit(1);
});
