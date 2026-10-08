const express = require('express');
const { analyticsController } = require('../controllers/analyticsController');
const { authenticateAdmin } = require('../middleware/authMiddleware');
const { validateRequest } = require('../middleware/validationMiddleware');
const { eventValidator } = require('../validators/contentValidators');

const router = express.Router();

// Public / Player event ingestion
router.post('/event', eventValidator, validateRequest, (req, res, next) => analyticsController.recordEvent(req, res, next));

// Admin dashboard metrics
router.get('/dashboard', authenticateAdmin, (req, res, next) => analyticsController.getDashboardAnalytics(req, res, next));

module.exports = router;
