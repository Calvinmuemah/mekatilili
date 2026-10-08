const playerProgressService = require('../services/playerProgressService');
const { success, error } = require('../utils/response');

class PlayerProgressController {
  async getProgress(req, res, next) {
    try {
      const data = await playerProgressService.getPlayerProgress(req.user.id);
      return success(res, data);
    } catch (err) {
      next(err);
    }
  }

  async syncProgress(req, res, next) {
    try {
      const updated = await playerProgressService.syncPlayerProgress(req.user.id, req.body);
      return success(res, updated);
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new PlayerProgressController();
