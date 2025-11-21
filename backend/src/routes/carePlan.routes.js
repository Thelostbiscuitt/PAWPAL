const express = require('express');
const { body } = require('express-validator');
const { authenticateToken } = require('../middleware/auth.middleware');

const router = express.Router();

// All care plan routes require authentication
router.use(authenticateToken);

// GET /api/care-plans/pet/:petId - Get pet's care plans
router.get('/pet/:petId', (req, res) => {
  res.json({ message: `Get care plans for pet ${req.params.petId} - to be implemented` });
});

// POST /api/care-plans/pet/:petId - Create care plan
router.post('/pet/:petId', [
  body('planType').notEmpty().withMessage('Plan type is required'),
  body('title').notEmpty().withMessage('Title is required'),
], (req, res) => {
  res.json({ message: `Create care plan for pet ${req.params.petId} - to be implemented` });
});

// GET /api/care-plans/:id - Get care plan details
router.get('/:id', (req, res) => {
  res.json({ message: `Get care plan ${req.params.id} - to be implemented` });
});

// PUT /api/care-plans/:id - Update care plan
router.put('/:id', (req, res) => {
  res.json({ message: `Update care plan ${req.params.id} - to be implemented` });
});

// DELETE /api/care-plans/:id - Delete care plan
router.delete('/:id', (req, res) => {
  res.json({ message: `Delete care plan ${req.params.id} - to be implemented` });
});

// POST /api/care-plans/:id/tasks - Add task to care plan
router.post('/:id/tasks', [
  body('taskName').notEmpty().withMessage('Task name is required'),
], (req, res) => {
  res.json({ message: `Add task to care plan ${req.params.id} - to be implemented` });
});

// PUT /api/care-plans/tasks/:taskId - Complete task
router.put('/tasks/:taskId', (req, res) => {
  res.json({ message: `Complete task ${req.params.taskId} - to be implemented` });
});

module.exports = router;