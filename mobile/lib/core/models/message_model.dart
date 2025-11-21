import 'package:json_annotation/json_annotation.dart';

part 'message_model.g.dart';

@JsonSerializable()
class Message {
  final String id;
  final String? conversationId;
  final String role; // 'user' or 'assistant'
  final String content;
  final List<String>? mediaUrls;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  const Message({
    required this.id,
    this.conversationId,
    required this.role,
    required this.content,
    this.mediaUrls,
    this.metadata,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);

  Message copyWith({
    String? id,
    String? conversationId,
    String? role,
    String? content,
    List<String>? mediaUrls,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Getters
  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
  
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return createdAt.day == now.day && 
             createdAt.month == now.month && 
             createdAt.year == now.year
          ? 'Today at ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}'
          : '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  String get displayContent {
    if (content.length <= 50) return content;
    return '${content.substring(0, 47)}...';
  }

  bool get hasMedia => mediaUrls != null && mediaUrls!.isNotEmpty;
  String? get firstMediaUrl => hasMedia ? mediaUrls!.first : null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Message(id: $id, role: $role, content: $content)';
  }
}