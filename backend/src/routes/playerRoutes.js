const express = require('express');
const playerProgressController = require('../controllers/playerProgressController');
const { authenticateUser } = require('../middleware/authMiddleware');

const router = express.Router();

router.use(authenticateUser);

router.get('/progress', (req, res, next) => playerProgressController.getProgress(req, res, next));
router.post('/sync', (req, res, next) => playerProgressController.syncProgress(req, res, next));
router.put('/progress', (req, res, next) => playerProgressController.syncProgress(req, res, next));

module.exports = router;
