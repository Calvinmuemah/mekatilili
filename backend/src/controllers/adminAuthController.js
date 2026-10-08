const adminAuthService = require('../services/adminAuthService');
const { success, error } = require('../utils/response');

class AdminAuthController {
  async login(req, res, next) {
    try {
      const { email, password } = req.body;
      const result = await adminAuthService.login({ email, password });
      return success(res, result);
    } catch (err) {
      if (err.statusCode) {
        return error(res, err.message, err.code, err.statusCode);
      }
      next(err);
    }
  }

  async me(req, res) {
    return success(res, { admin: req.admin });
  }
}

module.exports = new AdminAuthController();
