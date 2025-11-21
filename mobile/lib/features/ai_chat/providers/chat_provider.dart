import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../../../core/services/api_service.dart';
import '../../../core/models/api_response.dart';
import '../../../core/models/message_model.dart';
import '../../../core/models/pet_model.dart';

class ChatProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Message> _messages = [];
  List<dynamic> _conversations = [];
  String? _currentConversationId;
  Pet? _selectedPet;
  bool _isLoading = false;
  bool _isTyping = false;
  String? _errorMessage;

  // Getters
  List<Message> get messages => _messages;
  List<dynamic> get conversations => _conversations;
  String? get currentConversationId => _currentConversationId;
  Pet? get selectedPet => _selectedPet;
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;
  String? get errorMessage => _errorMessage;

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error message
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Create new conversation
  Future<void> createNewConversation() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.post('/ai/conversations', data: {
        'title': 'New Conversation',
      });

      if (response.success && response.data != null) {
        _currentConversationId = response.data['id'];
        _messages = [];
        _setError(null);
      } else {
        _setError(response.error ?? 'Failed to create conversation');
      }
    } catch (e) {
      _setError('Failed to create conversation: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load existing conversation
  Future<void> loadConversation(String conversationId) async {
    _setLoading(true);
    _setError(null);

    try {
      // Load conversation details
      final conversationResponse = await _apiService.get('/ai/conversations/$conversationId');
      
      if (conversationResponse.success && conversationResponse.data != null) {
        _currentConversationId = conversationId;
        
        // Load messages for this conversation
        await _loadMessages(conversationId);
      } else {
        _setError(conversationResponse.error ?? 'Failed to load conversation');
      }
    } catch (e) {
      _setError('Failed to load conversation: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load messages for a conversation
  Future<void> _loadMessages(String conversationId) async {
    try {
      final response = await _apiService.get('/ai/conversations/$conversationId/messages');
      
      if (response.success && response.data != null) {
        final messagesData = response.data['messages'] as List;
        _messages = messagesData.map((msg) => Message.fromJson(msg)).toList();
        notifyListeners();
      } else {
        _setError(response.error ?? 'Failed to load messages');
      }
    } catch (e) {
      _setError('Failed to load messages: ${e.toString()}');
    }
  }

  // Send text message
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message immediately
    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: _currentConversationId,
      role: 'user',
      content: text,
      createdAt: DateTime.now(),
    );

    _messages.add(userMessage);
    _setTyping(true);
    notifyListeners();

    try {
      final response = await _apiService.post('/ai/chat', data: {
        'message': text,
        'conversationId': _currentConversationId,
        'petId': _selectedPet?.id,
      });

      if (response.success && response.data != null) {
        // Add AI response
        final aiMessage = Message(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          conversationId: _currentConversationId,
          role: 'assistant',
          content: response.data['response'],
          createdAt: DateTime.now(),
          metadata: response.data['metadata'],
        );

        _messages.add(aiMessage);
        _setError(null);
      } else {
        _setError(response.error ?? 'Failed to send message');
      }
    } catch (e) {
      _setError('Failed to send message: ${e.toString()}');
      
      // Remove the user message if AI response failed
      if (_messages.isNotEmpty) {
        _messages.removeLast();
      }
    } finally {
      _setTyping(false);
    }
  }

  // Send image message
  Future<void> sendImage(dynamic imageFile) async {
    _setLoading(true);
    _setError(null);

    try {
      // Upload image first
      final uploadResponse = await _apiService.uploadFile(
        '/ai/upload-image',
        imageFile,
        fields: {
          'conversationId': _currentConversationId ?? '',
          'petId': _selectedPet?.id ?? '',
        },
      );

      if (uploadResponse.success && uploadResponse.data != null) {
        final imageUrl = uploadResponse.data['url'];
        
        // Add user message with image
        final userMessage = Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          conversationId: _currentConversationId,
          role: 'user',
          content: 'Shared an image',
          mediaUrls: [imageUrl],
          createdAt: DateTime.now(),
        );

        _messages.add(userMessage);
        _setTyping(true);
        notifyListeners();

        // Analyze image with AI
        final analysisResponse = await _apiService.post('/ai/analyze-image', data: {
          'imageUrl': imageUrl,
          'analysisType': 'health',
          'conversationId': _currentConversationId,
        });

        if (analysisResponse.success && analysisResponse.data != null) {
          // Add AI analysis response
          final aiMessage = Message(
            id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
            conversationId: _currentConversationId,
            role: 'assistant',
            content: analysisResponse.data['analysis'],
            mediaUrls: [imageUrl],
            createdAt: DateTime.now(),
            metadata: analysisResponse.data['metadata'],
          );

          _messages.add(aiMessage);
          _setError(null);
        } else {
          _setError(analysisResponse.error ?? 'Failed to analyze image');
        }
      } else {
        _setError(uploadResponse.error ?? 'Failed to upload image');
      }
    } catch (e) {
      _setError('Failed to send image: ${e.toString()}');
    } finally {
      _setLoading(false);
      _setTyping(false);
    }
  }

  // Get user's conversations
  Future<void> loadConversations() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.get('/ai/conversations');
      
      if (response.success && response.data != null) {
        _conversations = response.data['conversations'] as List;
        _setError(null);
      } else {
        _setError(response.error ?? 'Failed to load conversations');
      }
    } catch (e) {
      _setError('Failed to load conversations: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Emergency triage
  Future<Map<String, dynamic>?> performEmergencyTriage(List<String> symptoms, String petId) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.post('/ai/emergency-triage', data: {
        'symptoms': symptoms,
        'petId': petId,
      });

      if (response.success && response.data != null) {
        _setError(null);
        return response.data;
      } else {
        _setError(response.error ?? 'Failed to perform emergency triage');
        return null;
      }
    } catch (e) {
      _setError('Emergency triage failed: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Select pet for context
  void selectPet(Pet? pet) {
    _selectedPet = pet;
    notifyListeners();
  }

  // Clear current conversation
  void clearConversation() {
    _messages = [];
    _currentConversationId = null;
    _selectedPet = null;
    _setError(null);
    notifyListeners();
  }

  // Delete conversation
  Future<bool> deleteConversation(String conversationId) async {
    try {
      final response = await _apiService.delete('/ai/conversations/$conversationId');
      
      if (response.success) {
        _conversations.removeWhere((conv) => conv['id'] == conversationId);
        
        if (_currentConversationId == conversationId) {
          clearConversation();
        }
        
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to delete conversation');
        return false;
      }
    } catch (e) {
      _setError('Failed to delete conversation: ${e.toString()}');
      return false;
    }
  }

  // Get suggested questions based on pet type
  List<String> getSuggestedQuestions() {
    if (_selectedPet == null) {
      return [
        'What should I feed my puppy?',
        'How do I know if my pet is sick?',
        'What are common cat health issues?',
        'How much exercise does my dog need?',
      ];
    }

    final pet = _selectedPet!;
    final questions = <String>[];

    switch (pet.species.toLowerCase()) {
      case 'dog':
        questions.addAll([
          'What vaccinations does my dog need?',
          'How often should I walk my dog?',
          'What are signs of dog illness?',
          'How do I train my puppy?',
        ]);
        break;
      case 'cat':
        questions.addAll([
          'What should I feed my cat?',
          'How do I litter train my cat?',
          'What are common cat diseases?',
          'How do I groom my cat?',
        ]);
        break;
      case 'bird':
        questions.addAll([
          'What should I feed my bird?',
          'How do I train my bird?',
          'What are signs of bird illness?',
          'How do I set up a bird cage?',
        ]);
        break;
      default:
        questions.addAll([
          'What should I feed my pet?',
          'How do I know if my pet is sick?',
          'What are common health issues?',
          'How much exercise does my pet need?',
        ]);
    }

    // Add age-specific questions
    if (pet.ageInMonths < 6) {
      questions.addAll([
        'How do I care for a baby ${pet.species}?',
        'What vaccinations does a young ${pet.species} need?',
      ]);
    } else if (pet.ageInMonths > 84) { // 7 years
      questions.addAll([
        'What are senior ${pet.species} health concerns?',
        'How do I care for an elderly ${pet.species}?',
      ]);
    }

    return questions;
  }

  // Get quick actions
  List<Map<String, dynamic>> getQuickActions() {
    return [
      {
        'icon': '📸',
        'label': 'Camera',
        'action': 'camera',
      },
      {
        'icon': '🏥',
        'label': 'Food & Nutrition',
        'action': 'nutrition',
      },
      {
        'icon': '💊',
        'label': 'Health Check',
        'action': 'health',
      },
      {
        'icon': '🚨',
        'label': 'Emergency',
        'action': 'emergency',
      },
    ];
  }

  // Handle quick action
  Future<void> handleQuickAction(String action) async {
    switch (action) {
      case 'camera':
        // TODO: Open camera
        break;
      case 'nutrition':
        await sendMessage('What should I feed my ${_selectedPet?.species ?? 'pet'}?');
        break;
      case 'health':
        await sendMessage('How do I check if my ${_selectedPet?.species ?? 'pet'} is healthy?');
        break;
      case 'emergency':
        await sendMessage('I think my ${_selectedPet?.species ?? 'pet'} has an emergency. What should I do?');
        break;
    }
  }
}