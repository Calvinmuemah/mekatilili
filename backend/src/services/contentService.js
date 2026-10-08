const chapterRepository = require('../repositories/chapterRepository');
const questRepository = require('../repositories/questRepository');
const npcRepository = require('../repositories/npcRepository');
const dialogueRepository = require('../repositories/dialogueRepository');
const collectibleRepository = require('../repositories/collectibleRepository');
const journalRepository = require('../repositories/journalRepository');
const historyRepository = require('../repositories/historyRepository');

class ContentService {
  // --- CHAPTERS ---
  async getChapters({ status = null } = {}) {
    return chapterRepository.findAll({ status });
  }

  async getChapterById(id) {
    const chapter = await chapterRepository.findById(id);
    if (!chapter) {
      const err = new Error('Chapter not found');
      err.code = 'NOT_FOUND';
      err.statusCode = 404;
      throw err;
    }
    return chapter;
  }

  async createChapter(data) {
    return chapterRepository.create(data);
  }

  async updateChapter(id, data) {
    const existing = await this.getChapterById(id);
    const targetStatus = data.status || existing.status;
    if (targetStatus === 'PUBLISHED') {
      const title = data.title !== undefined ? data.title : existing.title;
      const chapterNumber = data.chapter_number !== undefined ? data.chapter_number : (data.chapterNumber !== undefined ? data.chapterNumber : existing.chapter_number);
      if (!title || !chapterNumber) {
        const err = new Error('Cannot publish chapter: title and chapter number are required');
        err.code = 'VALIDATION_ERROR';
        err.statusCode = 400;
        throw err;
      }
    }
    return chapterRepository.update(id, data);
  }

  async setChapterStatus(id, status) {
    const existing = await this.getChapterById(id);
    if (status === 'PUBLISHED') {
      if (!existing.title || !existing.chapter_number) {
        const err = new Error('Cannot publish chapter: title and chapter number are required');
        err.code = 'VALIDATION_ERROR';
        err.statusCode = 400;
        throw err;
      }
    }
    return chapterRepository.update(id, { status });
  }

  async deleteChapter(id) {
    await this.getChapterById(id);
    return chapterRepository.delete(id);
  }

  // --- QUESTS ---
  async getQuests({ chapterId = null, status = null } = {}) {
    const quests = await questRepository.findAll({ chapterId, status });
    const fullQuests = [];
    for (const q of quests) {
      const objectives = await questRepository.findObjectivesByQuestId(q.id);
      fullQuests.push({ ...q, objectives });
    }
    return fullQuests;
  }

  async getQuestById(id) {
    const quest = await questRepository.findById(id);
    if (!quest) {
      const err = new Error('Quest not found');
      err.code = 'NOT_FOUND';
      err.statusCode = 404;
      throw err;
    }
    const objectives = await questRepository.findObjectivesByQuestId(id);
    return { ...quest, objectives };
  }

  async createQuest(data) {
    const quest = await questRepository.create(data);
    if (Array.isArray(data.objectives)) {
      let order = 1;
      for (const obj of data.objectives) {
        await questRepository.createObjective({
          id: obj.id || `${quest.id}_obj_${order}`,
          questId: quest.id,
          title: obj.title || obj.description,
          description: obj.description,
          objectiveType: obj.objectiveType || 'CUSTOM',
          required: obj.required !== false,
          orderIndex: order,
        });
        order++;
      }
    }
    return this.getQuestById(quest.id);
  }

  async updateQuest(id, data) {
    await this.getQuestById(id);
    return questRepository.update(id, data);
  }

  async deleteQuest(id) {
    await this.getQuestById(id);
    return questRepository.delete(id);
  }

  // --- NPCS ---
  async getNPCs({ chapterId = null } = {}) {
    return npcRepository.findAll({ chapterId });
  }

  async getNPCById(id) {
    const npc = await npcRepository.findById(id);
    if (!npc) {
      const err = new Error('NPC not found');
      err.code = 'NOT_FOUND';
      err.statusCode = 404;
      throw err;
    }
    return npc;
  }

  async createNPC(data) {
    return npcRepository.create(data);
  }

  async updateNPC(id, data) {
    await this.getNPCById(id);
    return npcRepository.update(id, data);
  }

  async deleteNPC(id) {
    await this.getNPCById(id);
    return npcRepository.delete(id);
  }

  // --- DIALOGUES ---
  async getDialogues({ npcId = null, chapterId = null, status = null } = {}) {
    return dialogueRepository.findAll({ npcId, chapterId, status });
  }

  async getDialogueById(id) {
    const dialogue = await dialogueRepository.findById(id);
    if (!dialogue) {
      const err = new Error('Dialogue not found');
      err.code = 'NOT_FOUND';
      err.statusCode = 404;
      throw err;
    }
    return dialogue;
  }

  async createDialogue(data) {
    return dialogueRepository.create(data);
  }

  async updateDialogue(id, data) {
    const existing = await this.getDialogueById(id);
    const targetStatus = data.status || existing.status;
    if (targetStatus === 'PUBLISHED') {
      const startNodeId = data.start_node_id || data.startNodeId || existing.start_node_id;
      const rawNodes = data.raw_nodes || data.rawNodes || existing.raw_nodes;
      if (!startNodeId || typeof rawNodes !== 'object' || !rawNodes[startNodeId]) {
        const err = new Error(`Cannot publish dialogue: start node '${startNodeId}' is missing from raw nodes.`);
        err.code = 'VALIDATION_ERROR';
        err.statusCode = 400;
        throw err;
      }
    }
    return dialogueRepository.update(id, data);
  }

  async deleteDialogue(id) {
    await this.getDialogueById(id);
    return dialogueRepository.delete(id);
  }

  // --- COLLECTIBLES ---
  async getCollectibles({ status = null, chapterId = null } = {}) {
    return collectibleRepository.findAll({ status, chapterId });
  }

  async getCollectibleById(id) {
    const item = await collectibleRepository.findById(id);
    if (!item) {
      const err = new Error('Collectible not found');
      err.code = 'NOT_FOUND';
      err.statusCode = 404;
      throw err;
    }
    return item;
  }

  async createCollectible(data) {
    return collectibleRepository.create(data);
  }

  async updateCollectible(id, data) {
    await this.getCollectibleById(id);
    return collectibleRepository.update(id, data);
  }

  async deleteCollectible(id) {
    await this.getCollectibleById(id);
    return collectibleRepository.delete(id);
  }

  // --- JOURNAL & HISTORY ---
  async getJournalEntries({ category = null, status = null } = {}) {
    return journalRepository.findAll({ category, status });
  }

  async createJournalEntry(data) {
    return journalRepository.create(data);
  }

  async updateJournalEntry(id, data) {
    return journalRepository.update(id, data);
  }

  async deleteJournalEntry(id) {
    return journalRepository.delete(id);
  }

  async getHistoricalReferences({ chapterId = null } = {}) {
    return historyRepository.findAll({ chapterId });
  }

  async createHistoricalReference(data) {
    return historyRepository.create(data);
  }

  async updateHistoricalReference(id, data) {
    return historyRepository.update(id, data);
  }

  async deleteHistoricalReference(id) {
    return historyRepository.delete(id);
  }

  // --- PUBLIC CONTENT BUNDLE FOR PLAYERS / GODOT SYNC ---
  async getPublishedContentBundle() {
    const chapters = await chapterRepository.findAll({ status: 'PUBLISHED' });
    const quests = await this.getQuests({ status: 'PUBLISHED' });
    const npcs = await npcRepository.findAll();
    const dialogues = await dialogueRepository.findAll({ status: 'PUBLISHED' });
    const collectibles = await collectibleRepository.findAll({ status: 'PUBLISHED' });
    const journal = await journalRepository.findAll({ status: 'PUBLISHED' });
    const history = await historyRepository.findAll();

    return {
      version: '1.0.0',
      publishedAt: new Date().toISOString(),
      chapters,
      quests,
      npcs,
      dialogues,
      collectibles,
      journal,
      historicalReferences: history,
    };
  }
}

module.exports = new ContentService();
