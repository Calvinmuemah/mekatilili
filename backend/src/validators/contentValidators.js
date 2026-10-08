const { body, param } = require('express-validator');

const chapterValidator = [
  body('id').trim().notEmpty().withMessage('Chapter ID is required'),
  body('chapterNumber').isInt({ min: 1 }).withMessage('Valid chapter number is required'),
  body('title').trim().notEmpty().withMessage('Chapter title is required'),
];

const questValidator = [
  body('id').trim().notEmpty().withMessage('Quest ID is required'),
  body('chapterId').trim().notEmpty().withMessage('Chapter ID is required'),
  body('title').trim().notEmpty().withMessage('Quest title is required'),
];

const npcValidator = [
  body('id').trim().notEmpty().withMessage('NPC ID is required'),
  body('name').trim().notEmpty().withMessage('NPC name is required'),
];

const dialogueValidator = [
  body('id').trim().notEmpty().withMessage('Dialogue ID is required'),
  body('title').trim().notEmpty().withMessage('Dialogue title is required'),
  body('npcId').trim().notEmpty().withMessage('NPC ID is required'),
];

const collectibleValidator = [
  body('id').trim().notEmpty().withMessage('Collectible ID is required'),
  body('name').trim().notEmpty().withMessage('Collectible name is required'),
];

const eventValidator = [
  body('eventType').trim().notEmpty().withMessage('eventType is required'),
];

module.exports = {
  chapterValidator,
  questValidator,
  npcValidator,
  dialogueValidator,
  collectibleValidator,
  eventValidator,
};
