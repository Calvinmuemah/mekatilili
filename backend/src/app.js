const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');

const healthRoutes = require('./routes/healthRoutes');
const authRoutes = require('./routes/authRoutes');
const adminAuthRoutes = require('./routes/adminAuthRoutes');
const contentRoutes = require('./routes/contentRoutes');
const adminContentRoutes = require('./routes/adminContentRoutes');
const playerRoutes = require('./routes/playerRoutes');
const analyticsRoutes = require('./routes/analyticsRoutes');

const { errorHandler } = require('./middleware/validationMiddleware');
const { error } = require('./utils/response');

const app = express();

// Security & Middlewares
app.use(helmet());
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  credentials: true,
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

if (process.env.NODE_ENV !== 'test') {
  app.use(morgan('dev'));
}

// API Routes (v1)
app.use('/api/v1', healthRoutes);
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/admin/auth', adminAuthRoutes);
app.use('/api/v1/content', contentRoutes);
app.use('/api/v1/admin/content', adminContentRoutes);
app.use('/api/v1/player', playerRoutes);
app.use('/api/v1/analytics', analyticsRoutes);

// 404 Handler
app.use((req, res) => {
  return error(res, `Route not found: ${req.method} ${req.originalUrl}`, 'NOT_FOUND', 404);
});

// Central Error Handler
app.use(errorHandler);

module.exports = app;
