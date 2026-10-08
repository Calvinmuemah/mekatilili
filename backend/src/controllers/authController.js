const authService = require('../services/authService');
const { success, error } = require('../utils/response');

class AuthController {
  async register(req, res, next) {
    try {
      const { email, username, password, displayName } = req.body;
      const result = await authService.register({ email, username, password, displayName });
      return success(res, result, 201);
    } catch (err) {
      if (err.statusCode) {
        return error(res, err.message, err.code, err.statusCode);
      }
      next(err);
    }
  }

  async login(req, res, next) {
    try {
      const { emailOrUsername, password } = req.body;
      const result = await authService.login({ emailOrUsername, password });
      return success(res, result);
    } catch (err) {
      if (err.statusCode) {
        return error(res, err.message, err.code, err.statusCode);
      }
      next(err);
    }
  }

  async me(req, res) {
    return success(res, { user: req.user });
  }

  async logout(req, res) {
    return success(res, { message: 'Logged out successfully' });
  }
}

module.exports = new AuthController();
