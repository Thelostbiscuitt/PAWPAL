const express = require('express');
const { body } = require('express-validator');
const { authenticateToken } = require('../middleware/auth.middleware');

const router = express.Router();

// All reminder routes require authentication
router.use(authenticateToken);

// GET /api/reminders - Get user reminders
router.get('/', (req, res) => {
  res.json({ message: 'Get user reminders - to be implemented' });
});

// POST /api/reminders - Create reminder
router.post('/', [
  body('title').notEmpty().withMessage('Title is required'),
  body('reminderType').notEmpty().withMessage('Reminder type is required'),
  body('scheduledFor').isISO8601().withMessage('Valid scheduled date is required'),
  body('petId').optional().isUUID().withMessage('Invalid pet ID')
], (req, res) => {
  res.json({ message: 'Create reminder - to be implemented' });
});

// GET /api/reminders/:id - Get reminder details
router.get('/:id', (req, res) => {
  res.json({ message: `Get reminder ${req.params.id} - to be implemented` });
});

// PUT /api/reminders/:id - Update reminder
router.put('/:id', (req, res) => {
  res.json({ message: `Update reminder ${req.params.id} - to be implemented` });
});

// DELETE /api/reminders/:id - Delete reminder
router.delete('/:id', (req, res) => {
  res.json({ message: `Delete reminder ${req.params.id} - to be implemented` });
});

// POST /api/reminders/:id/complete - Mark reminder as completed
router.post('/:id/complete', (req, res) => {
  res.json({ message: `Complete reminder ${req.params.id} - to be implemented` });
});

// GET /api/reminders/upcoming - Get upcoming reminders
router.get('/upcoming', [
  body('daysAhead').optional().isInt({ min: 1, max: 30 }).withMessage('Days ahead must be between 1 and 30')
], (req, res) => {
  res.json({ message: 'Get upcoming reminders - to be implemented' });
});

module.exports = router;