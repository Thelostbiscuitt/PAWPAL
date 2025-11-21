import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/config/theme.dart';
import '../../../app/config/routes.dart';
import '../../../core/models/message_model.dart';
import '../../../core/utils/validators.dart';
import '../providers/chat_provider.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/message_bubble.dart';
import '../../../shared/widgets/typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  final String? conversationId;
  
  const ChatScreen({
    super.key,
    this.conversationId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    
    // Load conversation if ID is provided, otherwise create new
    if (widget.conversationId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ChatProvider>().loadConversation(widget.conversationId!);
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ChatProvider>().createNewConversation();
      });
    }
    
    _messageController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _messageController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty && !_isTyping) {
      setState(() {
        _isTyping = true;
      });
      
      // Simulate typing indicator
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _isTyping = false;
          });
        }
      });
    } else if (text.isEmpty && _isTyping) {
      setState(() {
        _isTyping = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Pet Care Assistant',
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showChatInfo,
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          return Column(
            children: [
              // Chat Header
              if (chatProvider.currentConversation != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.primaryColor,
                        child: const Icon(
                          Icons.smart_toy,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Pet Assistant',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'I can help with pet care, health questions, and emergencies',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Messages List
              Expanded(
                child: chatProvider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : chatProvider.messages.isEmpty
                        ? _buildEmptyState()
                        : _buildMessagesList(chatProvider.messages),
              ),
              
              // Input Area
              _buildInputArea(chatProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 40,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Start a conversation',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me anything about pet care, health, nutrition, or behavior',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildSuggestedQuestions(),
        ],
      ),
    );
  }

  Widget _buildSuggestedQuestions() {
    final suggestions = [
      'What should I feed my puppy?',
      'How do I know if my pet is sick?',
      'What are common cat health issues?',
      'How much exercise does my dog need?',
    ];

    return Column(
      children: [
        Text(
          'Suggested Questions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...suggestions.map((suggestion) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: InkWell(
            onTap: () {
              _messageController.text = suggestion;
              _sendMessage();
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                ),
              ),
              child: Text(
                suggestion,
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildMessagesList(List<Message> messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: messages.length + (context.read<ChatProvider>().isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length) {
          return const TypingIndicator();
        }

        final message = messages[index];
        return MessageBubble(
          message: message,
          isUser: message.role == 'user',
          showAvatar: index == 0 || messages[index - 1].role != message.role,
        );
      },
    );
  }

  Widget _buildInputArea(ChatProvider chatProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Quick Actions
            if (chatProvider.messages.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    _buildQuickAction('📸', 'Send Photo', _sendPhoto),
                    _buildQuickAction('🏥', 'Food Advice', () {
                      _messageController.text = 'What should I feed my pet?';
                      _sendMessage();
                    }),
                    _buildQuickAction('💊', 'Health Check', () {
                      _messageController.text = 'How do I check my pet\'s health?';
                      _sendMessage();
                    }),
                    _buildQuickAction('🚨', 'Emergency', () {
                      _messageController.text = 'I think my pet has an emergency';
                      _sendMessage();
                    }),
                  ],
                ),
              ),
            
            Row(
              children: [
                // Text Input
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    focusNode: _focusNode,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Ask about pet care...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      prefixIcon: chatProvider.selectedPet != null
                          ? CircleAvatar(
                              radius: 12,
                              backgroundImage: NetworkImage(
                                chatProvider.selectedPet!.profileImageUrl ?? '',
                              ),
                              backgroundColor: Colors.grey[300],
                              child: chatProvider.selectedPet!.profileImageUrl == null
                                  ? Icon(
                                      chatProvider.selectedPet!.species == 'dog'
                                          ? Icons.pets
                                          : Icons.cruelty_free,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : null,
                            )
                          : null,
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.attach_file),
                            onPressed: _sendPhoto,
                            color: AppTheme.textSecondaryColor,
                          ),
                          IconButton(
                            icon: Icon(
                              _messageController.text.isEmpty
                                  ? Icons.mic
                                  : Icons.send,
                              color: AppTheme.primaryColor,
                            ),
                            onPressed: _messageController.text.isEmpty
                                ? _startVoiceInput
                                : _sendMessage,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(String emoji, String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    _focusNode.unfocus();

    await context.read<ChatProvider>().sendMessage(text);
    
    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendPhoto() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        await context.read<ChatProvider>().sendImage(image!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send photo: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _startVoiceInput() {
    // TODO: Implement voice input
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice input coming soon!'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _showChatInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Pet Care Assistant'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'I\'m your AI-powered pet care assistant, here to help with:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 16),
            ...[
              '• General pet care questions',
              '• Health and nutrition advice',
              '• Behavior and training tips',
              '• Emergency triage guidance',
              '• Local resource recommendations',
            ].map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $item'),
            )).toList(),
            SizedBox(height: 16),
            Text(
              'I provide general guidance but always recommend consulting a veterinarian for medical concerns.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}