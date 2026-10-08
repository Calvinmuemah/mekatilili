const analyticsService = require('../services/analyticsService');
const userRepository = require('../repositories/userRepository');
const { success } = require('../utils/response');

class AnalyticsController {
  async recordEvent(req, res, next) {
    try {
      const { eventType, chapterId, questId, metadata } = req.body;
      const userId = req.user ? req.user.id : null;
      const event = await analyticsService.recordEvent({
        userId,
        eventType,
        chapterId,
        questId,
        metadata,
      });
      return success(res, event, 201);
    } catch (err) {
      next(err);
    }
  }

  async getDashboardAnalytics(req, res, next) {
    try {
      const metrics = await analyticsService.getDashboardMetrics();
      return success(res, metrics);
    } catch (err) {
      next(err);
    }
  }
}

class UserController {
  async listPlayers(req, res, next) {
    try {
      const limit = parseInt(req.query.limit, 10) || 50;
      const offset = parseInt(req.query.offset, 10) || 0;
      const result = await userRepository.listUsers({ limit, offset });
      return success(res, result);
    } catch (err) {
      next(err);
    }
  }
}

module.exports = {
  analyticsController: new AnalyticsController(),
  userController: new UserController(),
};
