const express = require('express');
const adminAuthController = require('../controllers/adminAuthController');
const { authenticateAdmin } = require('../middleware/authMiddleware');
const { validateRequest } = require('../middleware/validationMiddleware');
const { adminLoginValidator } = require('../validators/authValidators');

const router = express.Router();

router.post('/login', adminLoginValidator, validateRequest, (req, res, next) => adminAuthController.login(req, res, next));
router.get('/me', authenticateAdmin, (req, res, next) => adminAuthController.me(req, res, next));

module.exports = router;
