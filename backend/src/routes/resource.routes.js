const express = require('express');
const { query } = require('express-validator');
const { optionalAuth } = require('../middleware/auth.middleware');

const router = express.Router();

// Use optional auth for resource finder (can work without login)
router.use(optionalAuth);

// GET /api/resources/nearby - Find nearby resources
router.get('/nearby', [
  query('lat').isFloat().withMessage('Latitude is required'),
  query('lng').isFloat().withMessage('Longitude is required'),
  query('radius').optional().isFloat({ min: 0.1, max: 100 }).withMessage('Radius must be between 0.1 and 100 km'),
  query('category').optional().isIn(['vet', 'pet_store', 'groomer', 'trainer', 'shelter']).withMessage('Invalid category')
], (req, res) => {
  res.json({ message: 'Find nearby resources - to be implemented' });
});

// GET /api/resources/search - Search resources
router.get('/search', [
  query('q').notEmpty().withMessage('Search query is required'),
  query('category').optional().isIn(['vet', 'pet_store', 'groomer', 'trainer', 'shelter']).withMessage('Invalid category'),
  query('lat').optional().isFloat().withMessage('Invalid latitude'),
  query('lng').optional().isFloat().withMessage('Invalid longitude')
], (req, res) => {
  res.json({ message: 'Search resources - to be implemented' });
});

// GET /api/resources/:id - Get resource details
router.get('/:id', (req, res) => {
  res.json({ message: `Get resource ${req.params.id} - to be implemented` });
});

// POST /api/resources/:id/reviews - Add review (requires auth)
router.post('/:id/reviews', [
  require('express-validator').body('rating').isInt({ min: 1, max: 5 }).withMessage('Rating must be between 1 and 5'),
  require('express-validator').body('reviewText').optional().isString().withMessage('Review text must be a string')
], (req, res) => {
  if (!req.user) {
    return res.status(401).json({ error: 'Authentication required for reviews' });
  }
  res.json({ message: `Add review for resource ${req.params.id} - to be implemented` });
});

// GET /api/resources/:id/reviews - Get resource reviews
router.get('/:id/reviews', (req, res) => {
  res.json({ message: `Get reviews for resource ${req.params.id} - to be implemented` });
});

module.exports = router;