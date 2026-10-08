const express = require('express');
const contentController = require('../controllers/contentController');

const router = express.Router();

// Full bundle for sync
router.get('/bundle', (req, res, next) => contentController.getBundle(req, res, next));

// Chapters (published only)
router.get('/chapters', (req, res, next) => {
  req.query.status = 'PUBLISHED';
  contentController.getChapters(req, res, next);
});
router.get('/chapters/:id', (req, res, next) => contentController.getChapterById(req, res, next));

// Quests (published only)
router.get('/quests', (req, res, next) => {
  req.query.status = 'PUBLISHED';
  contentController.getQuests(req, res, next);
});
router.get('/quests/:id', (req, res, next) => contentController.getQuestById(req, res, next));

// NPCs
router.get('/npcs', (req, res, next) => contentController.getNPCs(req, res, next));
router.get('/npcs/:id', (req, res, next) => contentController.getNPCById(req, res, next));

// Dialogues (published only)
router.get('/dialogues/:id', (req, res, next) => contentController.getDialogueById(req, res, next));

// Collectibles (published only)
router.get('/collectibles', (req, res, next) => {
  req.query.status = 'PUBLISHED';
  contentController.getCollectibles(req, res, next);
});

// Journal (published only)
router.get('/journal', (req, res, next) => {
  req.query.status = 'PUBLISHED';
  contentController.getJournalEntries(req, res, next);
});

// History
router.get('/history', (req, res, next) => contentController.getHistoricalReferences(req, res, next));

module.exports = router;
