class ApiEndpoints {
  // Base URL - change this for different environments
  static const String baseUrl = 'http://localhost:3000/api';
  
  // Authentication endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String sendVerification = '/auth/send-verification';
  static const String verifyEmail = '/auth/verify-email';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';
  static const String getProfile = '/auth/profile';
  static const String updateProfile = '/auth/profile';
  
  // Pet management endpoints
  static const String getPets = '/pets';
  static const String addPet = '/pets';
  static const String updatePet = '/pets';
  static const String deletePet = '/pets';
  static const String getPetDetail = '/pets';
  
  // Health tracking endpoints
  static const String getHealthRecords = '/health/records';
  static const String addHealthRecord = '/health/records';
  static const String getWeightHistory = '/health/weight';
  static const String logWeight = '/health/weight';
  
  // AI Chat endpoints
  static const String sendMessage = '/ai/chat';
  static const String analyzeImage = '/ai/analyze-image';
  static const String emergencyTriage = '/ai/emergency-triage';
  static const String getConversations = '/ai/conversations';
  static const String createConversation = '/ai/conversations';
  static const String getConversationMessages = '/ai/conversations';
  
  // Care plans endpoints
  static const String getCarePlans = '/care-plans/pet';
  static const String createCarePlan = '/care-plans/pet';
  static const String updateCarePlan = '/care-plans';
  static const String deleteCarePlan = '/care-plans';
  static const String addTaskToPlan = '/care-plans';
  static const String completeTask = '/care-plans/tasks';
  
  // Resource finder endpoints
  static const String findNearbyResources = '/resources/nearby';
  static const String searchResources = '/resources/search';
  static const String getResourceDetail = '/resources';
  static const String addResourceReview = '/resources';
  static const String getResourceReviews = '/resources';
  
  // Reminders endpoints
  static const String getReminders = '/reminders';
  static const String addReminder = '/reminders';
  static const String updateReminder = '/reminders';
  static const String deleteReminder = '/reminders';
  static const String completeReminder = '/reminders';
  static const String getUpcomingReminders = '/reminders/upcoming';
}