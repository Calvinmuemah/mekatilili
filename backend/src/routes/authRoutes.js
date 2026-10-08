const express = require('express');
const authController = require('../controllers/authController');
const { authenticateUser } = require('../middleware/authMiddleware');
const { validateRequest } = require('../middleware/validationMiddleware');
const { registerValidator, loginValidator } = require('../validators/authValidators');

const router = express.Router();

router.post('/register', registerValidator, validateRequest, (req, res, next) => authController.register(req, res, next));
router.post('/login', loginValidator, validateRequest, (req, res, next) => authController.login(req, res, next));
router.post('/logout', authenticateUser, (req, res, next) => authController.logout(req, res, next));
router.get('/me', authenticateUser, (req, res, next) => authController.me(req, res, next));

module.exports = router;
