const express = require('express');
const router = express.Router();
const adminController = require('../controllers/admin.controller');
const authMiddleware = require('../middleware/auth.middleware');
const adminMiddleware = require('../middleware/admin.middleware');
const multer = require('multer');
const { body, param, query } = require('express-validator');

// Configure multer for file uploads
const storage = multer.memoryStorage();
const upload = multer({ 
  storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB limit
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/') || file.mimetype.startsWith('video/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image and video files are allowed'));
    }
  }
});

// Apply authentication and admin middleware to all routes
router.use(authMiddleware);
router.use(adminMiddleware);

// Dashboard statistics
router.get('/dashboard', adminController.getDashboardStats);

// User management
router.get('/users', adminController.getUsers);
router.get('/users/:id', adminController.getUserById);
router.put('/users/:id', [
  body('email').optional().isEmail().normalizeEmail(),
  body('firstName').optional().trim().isLength({ min: 1, max: 50 }),
  body('lastName').optional().trim().isLength({ min: 1, max: 50 }),
  body('isActive').optional().isBoolean(),
  body('role').optional().isIn(['user', 'admin'])
], adminController.updateUser);
router.delete('/users/:id', adminController.deleteUser);

// Pet management
router.get('/pets', adminController.getAllPets);
router.get('/pets/:id', adminController.getPetById);
router.put('/pets/:id', [
  body('name').optional().trim().isLength({ min: 1, max: 100 }),
  body('type').optional().trim().isLength({ min: 1, max: 50 }),
  body('breed').optional().trim().isLength({ max: 100 }),
  body('age').optional().isInt({ min: 0, max: 50 }),
  body('weight').optional().isFloat({ min: 0 }),
  body('gender').optional().isIn(['male', 'female', 'unknown'])
], adminController.updatePet);
router.delete('/pets/:id', adminController.deletePet);

// Content management - Educational articles
router.get('/content/articles', adminController.getArticles);
router.post('/content/articles', [
  body('title').trim().isLength({ min: 1, max: 200 }),
  body('content').trim().isLength({ min: 1 }),
  body('category').isIn(['health', 'nutrition', 'behavior', 'training', 'general']),
  body('petType').optional().isIn(['dog', 'cat', 'bird', 'fish', 'other']),
  body('tags').optional().isArray(),
  body('isPublished').optional().isBoolean()
], adminController.createArticle);
router.get('/content/articles/:id', adminController.getArticleById);
router.put('/content/articles/:id', [
  body('title').optional().trim().isLength({ min: 1, max: 200 }),
  body('content').optional().trim().isLength({ min: 1 }),
  body('category').optional().isIn(['health', 'nutrition', 'behavior', 'training', 'general']),
  body('petType').optional().isIn(['dog', 'cat', 'bird', 'fish', 'other']),
  body('tags').optional().isArray(),
  body('isPublished').optional().isBoolean()
], adminController.updateArticle);
router.delete('/content/articles/:id', adminController.deleteArticle);
router.post('/content/articles/:id/image', upload.single('image'), adminController.uploadArticleImage);

// Content management - FAQs
router.get('/content/faqs', adminController.getFAQs);
router.post('/content/faqs', [
  body('question').trim().isLength({ min: 1, max: 500 }),
  body('answer').trim().isLength({ min: 1 }),
  body('category').isIn(['health', 'nutrition', 'behavior', 'training', 'general', 'emergency']),
  body('petType').optional().isIn(['dog', 'cat', 'bird', 'fish', 'other']),
  body('priority').optional().isInt({ min: 1, max: 10 })
], adminController.createFAQ);
router.put('/content/faqs/:id', [
  body('question').optional().trim().isLength({ min: 1, max: 500 }),
  body('answer').optional().trim().isLength({ min: 1 }),
  body('category').optional().isIn(['health', 'nutrition', 'behavior', 'training', 'general', 'emergency']),
  body('petType').optional().isIn(['dog', 'cat', 'bird', 'fish', 'other']),
  body('priority').optional().isInt({ min: 1, max: 10 })
], adminController.updateFAQ);
router.delete('/content/faqs/:id', adminController.deleteFAQ);

// Content management - Emergency protocols
router.get('/content/emergency-protocols', adminController.getEmergencyProtocols);
router.post('/content/emergency-protocols', [
  body('title').trim().isLength({ min: 1, max: 200 }),
  body('description').trim().isLength({ min: 1 }),
  body('symptoms').isArray(),
  body('urgencyLevel').isIn(['low', 'medium', 'high', 'critical']),
  body('recommendations').isArray(),
  body('petTypes').isArray()
], adminController.createEmergencyProtocol);
router.put('/content/emergency-protocols/:id', [
  body('title').optional().trim().isLength({ min: 1, max: 200 }),
  body('description').optional().trim().isLength({ min: 1 }),
  body('symptoms').optional().isArray(),
  body('urgencyLevel').optional().isIn(['low', 'medium', 'high', 'critical']),
  body('recommendations').optional().isArray(),
  body('petTypes').optional().isArray()
], adminController.updateEmergencyProtocol);
router.delete('/content/emergency-protocols/:id', adminController.deleteEmergencyProtocol);

// Resource management
router.get('/resources', adminController.getResources);
router.post('/resources', [
  body('name').trim().isLength({ min: 1, max: 200 }),
  body('type').isIn(['veterinary', 'pet_store', 'grooming', 'training', 'boarding', 'emergency']),
  body('address').trim().isLength({ min: 1 }),
  body('city').trim().isLength({ min: 1, max: 100 }),
  body('state').trim().isLength({ min: 1, max: 100 }),
  body('country').trim().isLength({ min: 1, max: 100 }),
  body('latitude').isFloat({ min: -90, max: 90 }),
  body('longitude').isFloat({ min: -180, max: 180 }),
  body('phone').optional().trim().isLength({ min: 10, max: 20 }),
  body('email').optional().isEmail().normalizeEmail(),
  body('website').optional().isURL(),
  body('isVerified').optional().isBoolean(),
  body('isActive').optional().isBoolean()
], adminController.createResource);
router.put('/resources/:id', [
  body('name').optional().trim().isLength({ min: 1, max: 200 }),
  body('type').optional().isIn(['veterinary', 'pet_store', 'grooming', 'training', 'boarding', 'emergency']),
  body('address').optional().trim().isLength({ min: 1 }),
  body('city').optional().trim().isLength({ min: 1, max: 100 }),
  body('state').optional().trim().isLength({ min: 1, max: 100 }),
  body('country').optional().trim().isLength({ min: 1, max: 100 }),
  body('latitude').optional().isFloat({ min: -90, max: 90 }),
  body('longitude').optional().isFloat({ min: -180, max: 180 }),
  body('phone').optional().trim().isLength({ min: 10, max: 20 }),
  body('email').optional().isEmail().normalizeEmail(),
  body('website').optional().isURL(),
  body('isVerified').optional().isBoolean(),
  body('isActive').optional().isBoolean()
], adminController.updateResource);
router.delete('/resources/:id', adminController.deleteResource);
router.post('/resources/:id/verify', adminController.verifyResource);

// Analytics and reports
router.get('/analytics/users', adminController.getUserAnalytics);
router.get('/analytics/pets', adminController.getPetAnalytics);
router.get('/analytics/usage', adminController.getUsageAnalytics);
router.get('/analytics/content', adminController.getContentAnalytics);
router.get('/reports/export', adminController.exportData);

// System settings
router.get('/settings', adminController.getSystemSettings);
router.put('/settings', [
  body('appVersion').optional().trim(),
  body('maintenanceMode').optional().isBoolean(),
  body('registrationEnabled').optional().isBoolean(),
  body('maxPetsPerUser').optional().isInt({ min: 1, max: 50 }),
  body('aiFeaturesEnabled').optional().isBoolean(),
  body('notificationSettings').optional().isObject()
], adminController.updateSystemSettings);

// AI model management
router.get('/ai/models', adminController.getAIModels);
router.put('/ai/models/:id', [
  body('name').optional().trim(),
  body('provider').optional().trim(),
  body('model').optional().trim(),
  body('isActive').optional().isBoolean(),
  body('settings').optional().isObject()
], adminController.updateAIModel);
router.post('/ai/models/:id/test', adminController.testAIModel);

// Notification management
router.get('/notifications', adminController.getNotifications);
router.post('/notifications', [
  body('title').trim().isLength({ min: 1, max: 200 }),
  body('message').trim().isLength({ min: 1 }),
  body('type').isIn(['general', 'emergency', 'maintenance', 'feature']),
  body('targetAudience').isIn(['all', 'active_users', 'new_users', 'premium_users']),
  body('scheduledFor').optional().isISO8601(),
  body('isScheduled').optional().isBoolean()
], adminController.createNotification);
router.put('/notifications/:id', adminController.updateNotification);
router.delete('/notifications/:id', adminController.deleteNotification);
router.post('/notifications/:id/send', adminController.sendNotification);

// Health checks and system status
router.get('/system/health', adminController.getSystemHealth);
router.get('/system/logs', [
  query('level').optional().isIn(['error', 'warn', 'info', 'debug']),
  query('startDate').optional().isISO8601(),
  query('endDate').optional().isISO8601(),
  query('limit').optional().isInt({ min: 1, max: 1000 })
], adminController.getSystemLogs);

module.exports = router;