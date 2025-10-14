// Entry point: sets up Express, middleware, and routes
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

const connectDB = require('./config/db');

const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/user');

const app = express();
const PORT = process.env.PORT || 5000;

// Connect to DB
connectDB();

// Middleware
app.use(cors()); // allow cross-origin requests (configure origin in production)
app.use(bodyParser.json());

// Routes
app.use('/api/auth', authRoutes);   // /api/auth/register, /api/auth/login
app.use('/api/user', userRoutes);   // protected user endpoints

// Health check
app.get('/', (req, res) => res.send({ status: 'ok', msg: 'FitQuest API running' }));

app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
