const express = require('express');
const { body } = require('express-validator');
const { authenticateToken } = require('../middleware/auth.middleware');

const router = express.Router();

// All AI routes require authentication
router.use(authenticateToken);

// POST /api/ai/chat - Send message to AI assistant
router.post('/chat', [
  body('message').notEmpty().withMessage('Message is required'),
  body('conversationId').optional().isUUID().withMessage('Invalid conversation ID')
], (req, res) => {
  res.json({ message: 'AI chat - to be implemented' });
});

// POST /api/ai/analyze-image - Analyze pet photo/video
router.post('/analyze-image', [
  body('imageUrl').notEmpty().withMessage('Image URL is required'),
  body('analysisType').optional().isIn(['health', 'behavior', 'general']).withMessage('Invalid analysis type')
], (req, res) => {
  res.json({ message: 'Image analysis - to be implemented' });
});

// POST /api/ai/emergency-triage - Get emergency assessment
router.post('/emergency-triage', [
  body('symptoms').isArray().withMessage('Symptoms must be an array'),
  body('petId').isUUID().withMessage('Invalid pet ID')
], (req, res) => {
  res.json({ message: 'Emergency triage - to be implemented' });
});

// GET /api/ai/conversations - Get user's conversations
router.get('/conversations', (req, res) => {
  res.json({ message: 'Get conversations - to be implemented' });
});

// POST /api/ai/conversations - Create new conversation
router.post('/conversations', [
  body('title').optional().isString().withMessage('Title must be a string'),
  body('petId').optional().isUUID().withMessage('Invalid pet ID')
], (req, res) => {
  res.json({ message: 'Create conversation - to be implemented' });
});

// GET /api/ai/conversations/:id/messages - Get conversation messages
router.get('/conversations/:id/messages', (req, res) => {
  res.json({ message: `Get messages for conversation ${req.params.id} - to be implemented` });
});

module.exports = router;