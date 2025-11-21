const express = require('express');
const { body } = require('express-validator');
const { authenticateToken } = require('../middleware/auth.middleware');

const router = express.Router();

// All pet routes require authentication
router.use(authenticateToken);

// GET /api/pets - Get user's pets
router.get('/', (req, res) => {
  res.json({ message: 'Get user pets - to be implemented' });
});

// POST /api/pets - Add new pet
router.post('/', [
  body('name').notEmpty().withMessage('Pet name is required'),
  body('species').notEmpty().withMessage('Species is required'),
], (req, res) => {
  res.json({ message: 'Add new pet - to be implemented' });
});

// GET /api/pets/:id - Get pet details
router.get('/:id', (req, res) => {
  res.json({ message: `Get pet ${req.params.id} - to be implemented` });
});

// PUT /api/pets/:id - Update pet information
router.put('/:id', (req, res) => {
  res.json({ message: `Update pet ${req.params.id} - to be implemented` });
});

// DELETE /api/pets/:id - Delete pet
router.delete('/:id', (req, res) => {
  res.json({ message: `Delete pet ${req.params.id} - to be implemented` });
});

module.exports = router;