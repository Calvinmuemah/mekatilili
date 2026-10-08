const express = require('express');
const contentController = require('../controllers/contentController');
const { userController } = require('../controllers/analyticsController');
const { authenticateAdmin, requireRole } = require('../middleware/authMiddleware');
const { validateRequest } = require('../middleware/validationMiddleware');
const {
  chapterValidator,
  questValidator,
  npcValidator,
  dialogueValidator,
  collectibleValidator,
} = require('../validators/contentValidators');

const router = express.Router();

// Require admin authentication for all routes here
router.use(authenticateAdmin);

// Chapters
router.get('/chapters', (req, res, next) => contentController.getChapters(req, res, next));
router.get('/chapters/:id', (req, res, next) => contentController.getChapterById(req, res, next));
router.post('/chapters', requireRole('SUPER_ADMIN', 'CONTENT_EDITOR'), chapterValidator, validateRequest, (req, res, next) => contentController.createChapter(req, res, next));
router.put('/chapters/:id', requireRole('SUPER_ADMIN', 'CONTENT_EDITOR'), (req, res, next) => contentController.updateChapter(req, res, next));
router.patch('/chapters/:id/status', requireRole('SUPER_ADMIN', 'CONTENT_EDITOR'), (req, res, next) => contentController.setChapterStatus(req, res, next));
router.delete('/chapters/:id', requireRole('SUPER_ADMIN'), (req, res, next) => contentController.deleteChapter(req, res, next));

// Quests
router.get('/quests', (req, res, next) => contentController.getQuests(req, res, next));
router.get('/quests/:id', (req, res, next) => contentController.getQuestById(req, res, next));
router.post('/quests', requireRole('SUPER_ADMIN', 'CONTENT_EDITOR'), questValidator, validateRequest, (req, res, next) => contentController.createQuest(req, res, next));
router.put('/quests/:id', requireRole('SUPER_ADMIN', 'CONTENT_EDITOR'), (req, res, next) => contentController.updateQuest(req, res, next));
router.delete('/quests/:id', requireRole('SUPER_ADMIN'), (req, res, next) => contentController.deleteQuest(req, res, next));

// NPCs
router.get('/npcs', (req, res, next) => contentController.getNPCs(req, res, next));
router.get('/npcs/:id', (req, res, next) => contentController.getNPCById(req, res, next));
router.post('/npcs', requireRole('SUPER_ADMIN', 'CONTENT_EDITOR'), npcValidator, validateRequest, (req, res, next) => contentController.createNPC(req, res, next));
router.put('/npcs/:id', requireRole('SUPER_ADMIN', 'CONTENT_EDITOR'), (req, res, next) => contentController.updateNPC(req, res, next));
router.delete('/npcs/:id', requireRole('SUPER_ADMIN'), (req, res, next) => contentController.deleteNPC(req, res, next));

// Dialogues
router.get('/dialogues', (req, res, next) => contentController.getDialogues(req, res, next));
router.get('/dialogues/:id', (req, res, next) => contentController.getDialogueById(req, res, next));
router.post('/dialogues', requireRole('SUPER_ADMIN', 'CONTENT_EDITOR'), dialogueValidator, validateRequest, (req, res, next) => contentController.createDialogue(req, res, next));
router.put('/dialogues/:id', requireRole('SUPER_ADMIN', 'CONTENT_EDITOR'), (req, res, next) => contentController.updateDialogue(req, res, next));
router.delete('/dialogues/:id', requireRole('SUPER_ADMIN'), (req, res, next) => contentController.deleteDialogue(req, res, next));

// Collectibles
router.get('/collectibles', (req, res, next) => contentController.getCollectibles(req, res, next));
router.get('/collectibles/:id', (req, res, next) => contentController.getCollectibleById(req, res, next));
router.post('/collectibles', requireRole('SUPER_ADMIN', 'CONTENT_EDITOR'), collectibleValidator, validateRequest, (req, res, next) => contentController.createCollectible(req, res, next));
router.put('/collectibles/:id', requireRole('SUPER_ADMIN', 'CONTENT_EDITOR'), (req, res, next) => contentController.updateCollectible(req, res, next));
router.delete('/collectibles/:id', requireRole('SUPER_ADMIN'), (req, res, next) => contentController.deleteCollectible(req, res, next));

// Journal
router.get('/journal', (req, res, next) => contentController.getJournalEntries(req, res, next));
router.post('/journal', requireRole('SUPER_ADMIN', 'CONTENT_EDITOR'), (req, res, next) => contentController.createJournalEntry(req, res, next));
router.put('/journal/:id', requireRole('SUPER_ADMIN', 'CONTENT_EDITOR'), (req, res, next) => contentController.updateJournalEntry(req, res, next));
router.delete('/journal/:id', requireRole('SUPER_ADMIN'), (req, res, next) => contentController.deleteJournalEntry(req, res, next));

// History
router.get('/history', (req, res, next) => contentController.getHistoricalReferences(req, res, next));
router.post('/history', requireRole('SUPER_ADMIN', 'CONTENT_EDITOR'), (req, res, next) => contentController.createHistoricalReference(req, res, next));
router.put('/history/:id', requireRole('SUPER_ADMIN', 'CONTENT_EDITOR'), (req, res, next) => contentController.updateHistoricalReference(req, res, next));
router.delete('/history/:id', requireRole('SUPER_ADMIN'), (req, res, next) => contentController.deleteHistoricalReference(req, res, next));

// Player list (Admin only)
router.get('/players', (req, res, next) => userController.listPlayers(req, res, next));

module.exports = router;
