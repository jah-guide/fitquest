// Entry point: sets up Express, middleware, and routes
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

const connectDB = require('./config/db');

const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/user');
const workoutsRoutes = require('./routes/workouts');
const routinesRoutes = require('./routes/routines');
const notificationsRoutes = require('./routes/notifications');

const app = express();
const PORT = process.env.PORT || 5000;

const isTest = process.env.NODE_ENV === 'test';

// Connect to DB (skip in test mode)
if (!isTest) {
	connectDB();
}

// Middleware
app.use(cors()); // allow cross-origin requests (configure origin in production)
app.use(bodyParser.json({ limit: '15mb' }));
app.use(bodyParser.urlencoded({ limit: '15mb', extended: true }));

// Routes
app.use('/api/auth', authRoutes);   // /api/auth/register, /api/auth/login
app.use('/api/user', userRoutes);   // protected user endpoints
app.use('/api/workouts', workoutsRoutes); // public workouts
app.use('/api/routines', routinesRoutes); // user routines (protected)
app.use('/api/notifications', notificationsRoutes); // push send endpoints (protected)

// Global error handler to avoid HTML responses on API failures
app.use((err, req, res, next) => {
	if (err?.type === 'entity.too.large') {
		return res.status(413).json({ msg: 'Uploaded image is too large' });
	}

	if (err instanceof SyntaxError && 'body' in err) {
		return res.status(400).json({ msg: 'Invalid JSON payload' });
	}

	return next(err);
});

// Health check
app.get('/', (req, res) => res.send({ status: 'ok', msg: 'FitQuest API running' }));

if (!isTest) {
	app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
}

module.exports = app;
