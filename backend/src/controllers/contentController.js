const contentService = require('../services/contentService');
const { success, error } = require('../utils/response');

class ContentController {
  // Public Bundle
  async getBundle(req, res, next) {
    try {
      const bundle = await contentService.getPublishedContentBundle();
      return success(res, bundle);
    } catch (err) {
      next(err);
    }
  }

  // Chapters
  async getChapters(req, res, next) {
    try {
      const status = req.query.status || null;
      const chapters = await contentService.getChapters({ status });
      return success(res, chapters);
    } catch (err) {
      next(err);
    }
  }

  async getChapterById(req, res, next) {
    try {
      const chapter = await contentService.getChapterById(req.params.id);
      return success(res, chapter);
    } catch (err) {
      if (err.statusCode) return error(res, err.message, err.code, err.statusCode);
      next(err);
    }
  }

  async createChapter(req, res, next) {
    try {
      const chapter = await contentService.createChapter(req.body);
      return success(res, chapter, 201);
    } catch (err) {
      next(err);
    }
  }

  async updateChapter(req, res, next) {
    try {
      const chapter = await contentService.updateChapter(req.params.id, req.body);
      return success(res, chapter);
    } catch (err) {
      if (err.statusCode) return error(res, err.message, err.code, err.statusCode);
      next(err);
    }
  }

  async setChapterStatus(req, res, next) {
    try {
      const { status: newStatus } = req.body;
      const chapter = await contentService.setChapterStatus(req.params.id, newStatus);
      return success(res, chapter);
    } catch (err) {
      if (err.statusCode) return error(res, err.message, err.code, err.statusCode);
      next(err);
    }
  }

  async deleteChapter(req, res, next) {
    try {
      const result = await contentService.deleteChapter(req.params.id);
      return success(res, result);
    } catch (err) {
      if (err.statusCode) return error(res, err.message, err.code, err.statusCode);
      next(err);
    }
  }

  // Quests
  async getQuests(req, res, next) {
    try {
      const { chapterId, status } = req.query;
      const quests = await contentService.getQuests({ chapterId, status });
      return success(res, quests);
    } catch (err) {
      next(err);
    }
  }

  async getQuestById(req, res, next) {
    try {
      const quest = await contentService.getQuestById(req.params.id);
      return success(res, quest);
    } catch (err) {
      if (err.statusCode) return error(res, err.message, err.code, err.statusCode);
      next(err);
    }
  }

  async createQuest(req, res, next) {
    try {
      const quest = await contentService.createQuest(req.body);
      return success(res, quest, 201);
    } catch (err) {
      next(err);
    }
  }

  async updateQuest(req, res, next) {
    try {
      const quest = await contentService.updateQuest(req.params.id, req.body);
      return success(res, quest);
    } catch (err) {
      if (err.statusCode) return error(res, err.message, err.code, err.statusCode);
      next(err);
    }
  }

  async deleteQuest(req, res, next) {
    try {
      const result = await contentService.deleteQuest(req.params.id);
      return success(res, result);
    } catch (err) {
      if (err.statusCode) return error(res, err.message, err.code, err.statusCode);
      next(err);
    }
  }

  // NPCs
  async getNPCs(req, res, next) {
    try {
      const { chapterId } = req.query;
      const npcs = await contentService.getNPCs({ chapterId });
      return success(res, npcs);
    } catch (err) {
      next(err);
    }
  }

  async getNPCById(req, res, next) {
    try {
      const npc = await contentService.getNPCById(req.params.id);
      return success(res, npc);
    } catch (err) {
      if (err.statusCode) return error(res, err.message, err.code, err.statusCode);
      next(err);
    }
  }

  async createNPC(req, res, next) {
    try {
      const npc = await contentService.createNPC(req.body);
      return success(res, npc, 201);
    } catch (err) {
      next(err);
    }
  }

  async updateNPC(req, res, next) {
    try {
      const npc = await contentService.updateNPC(req.params.id, req.body);
      return success(res, npc);
    } catch (err) {
      if (err.statusCode) return error(res, err.message, err.code, err.statusCode);
      next(err);
    }
  }

  async deleteNPC(req, res, next) {
    try {
      const result = await contentService.deleteNPC(req.params.id);
      return success(res, result);
    } catch (err) {
      if (err.statusCode) return error(res, err.message, err.code, err.statusCode);
      next(err);
    }
  }

  // Dialogues
  async getDialogues(req, res, next) {
    try {
      const { npcId, chapterId, status } = req.query;
      const dialogues = await contentService.getDialogues({ npcId, chapterId, status });
      return success(res, dialogues);
    } catch (err) {
      next(err);
    }
  }

  async getDialogueById(req, res, next) {
    try {
      const dialogue = await contentService.getDialogueById(req.params.id);
      return success(res, dialogue);
    } catch (err) {
      if (err.statusCode) return error(res, err.message, err.code, err.statusCode);
      next(err);
    }
  }

  async createDialogue(req, res, next) {
    try {
      const dialogue = await contentService.createDialogue(req.body);
      return success(res, dialogue, 201);
    } catch (err) {
      next(err);
    }
  }

  async updateDialogue(req, res, next) {
    try {
      const dialogue = await contentService.updateDialogue(req.params.id, req.body);
      return success(res, dialogue);
    } catch (err) {
      if (err.statusCode) return error(res, err.message, err.code, err.statusCode);
      next(err);
    }
  }

  async deleteDialogue(req, res, next) {
    try {
      const result = await contentService.deleteDialogue(req.params.id);
      return success(res, result);
    } catch (err) {
      if (err.statusCode) return error(res, err.message, err.code, err.statusCode);
      next(err);
    }
  }

  // Collectibles
  async getCollectibles(req, res, next) {
    try {
      const { status, chapterId } = req.query;
      const collectibles = await contentService.getCollectibles({ status, chapterId });
      return success(res, collectibles);
    } catch (err) {
      next(err);
    }
  }

  async getCollectibleById(req, res, next) {
    try {
      const item = await contentService.getCollectibleById(req.params.id);
      return success(res, item);
    } catch (err) {
      if (err.statusCode) return error(res, err.message, err.code, err.statusCode);
      next(err);
    }
  }

  async createCollectible(req, res, next) {
    try {
      const item = await contentService.createCollectible(req.body);
      return success(res, item, 201);
    } catch (err) {
      next(err);
    }
  }

  async updateCollectible(req, res, next) {
    try {
      const item = await contentService.updateCollectible(req.params.id, req.body);
      return success(res, item);
    } catch (err) {
      if (err.statusCode) return error(res, err.message, err.code, err.statusCode);
      next(err);
    }
  }

  async deleteCollectible(req, res, next) {
    try {
      const result = await contentService.deleteCollectible(req.params.id);
      return success(res, result);
    } catch (err) {
      if (err.statusCode) return error(res, err.message, err.code, err.statusCode);
      next(err);
    }
  }

  // Journal
  async getJournalEntries(req, res, next) {
    try {
      const { category, status } = req.query;
      const entries = await contentService.getJournalEntries({ category, status });
      return success(res, entries);
    } catch (err) {
      next(err);
    }
  }

  async createJournalEntry(req, res, next) {
    try {
      const entry = await contentService.createJournalEntry(req.body);
      return success(res, entry, 201);
    } catch (err) {
      next(err);
    }
  }

  async updateJournalEntry(req, res, next) {
    try {
      const entry = await contentService.updateJournalEntry(req.params.id, req.body);
      return success(res, entry);
    } catch (err) {
      if (err.statusCode) return error(res, err.message, err.code, err.statusCode);
      next(err);
    }
  }

  async deleteJournalEntry(req, res, next) {
    try {
      const result = await contentService.deleteJournalEntry(req.params.id);
      return success(res, result);
    } catch (err) {
      if (err.statusCode) return error(res, err.message, err.code, err.statusCode);
      next(err);
    }
  }

  // Historical References
  async getHistoricalReferences(req, res, next) {
    try {
      const { chapterId } = req.query;
      const references = await contentService.getHistoricalReferences({ chapterId });
      return success(res, references);
    } catch (err) {
      next(err);
    }
  }

  async createHistoricalReference(req, res, next) {
    try {
      const ref = await contentService.createHistoricalReference(req.body);
      return success(res, ref, 201);
    } catch (err) {
      next(err);
    }
  }

  async updateHistoricalReference(req, res, next) {
    try {
      const ref = await contentService.updateHistoricalReference(req.params.id, req.body);
      return success(res, ref);
    } catch (err) {
      if (err.statusCode) return error(res, err.message, err.code, err.statusCode);
      next(err);
    }
  }

  async deleteHistoricalReference(req, res, next) {
    try {
      const result = await contentService.deleteHistoricalReference(req.params.id);
      return success(res, result);
    } catch (err) {
      if (err.statusCode) return error(res, err.message, err.code, err.statusCode);
      next(err);
    }
  }
}

module.exports = new ContentController();
