const progressRepository = require('../repositories/progressRepository');

class PlayerProgressService {
  async getPlayerProgress(userId) {
    const data = await progressRepository.findByUserId(userId);
    return data;
  }

  async syncPlayerProgress(userId, syncPayload) {
    await progressRepository.upsertFullSync(userId, syncPayload);
    return this.getPlayerProgress(userId);
  }
}

module.exports = new PlayerProgressService();
