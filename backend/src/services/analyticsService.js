const analyticsRepository = require('../repositories/analyticsRepository');

class AnalyticsService {
  async recordEvent({ userId = null, eventType, chapterId = null, questId = null, metadata = {} }) {
    return analyticsRepository.recordEvent({
      userId,
      eventType,
      chapterId,
      questId,
      metadata,
    });
  }

  async getDashboardMetrics() {
    return analyticsRepository.getSummaryMetrics();
  }
}

module.exports = new AnalyticsService();
