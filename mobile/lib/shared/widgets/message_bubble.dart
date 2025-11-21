import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../app/config/theme.dart';
import '../../core/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool showAvatar;
  final bool showTime;

  const MessageBubble({
    super.key,
    required this.message,
    this.showAvatar = true,
    this.showTime = true,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar for assistant messages
          if (!isUser && showAvatar)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primaryColor,
                child: const Icon(
                  Icons.smart_toy,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          
          // Message content
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser ? AppTheme.primaryColor : Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text content
                      Text(
                        message.content,
                        style: TextStyle(
                          color: isUser ? Colors.white : AppTheme.textPrimaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      
                      // Media content
                      if (message.hasMedia)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _buildMediaContent(),
                        ),
                      
                      // Metadata (for AI responses)
                      if (message.metadata != null && message.metadata!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _buildMetadataContent(),
                        ),
                    ],
                  ),
                ),
                
                // Time stamp
                if (showTime)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      message.formattedTime,
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Avatar for user messages
          if (isUser && showAvatar)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[300],
                child: Text(
                  'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaContent() {
    final mediaUrls = message.mediaUrls!;
    
    if (mediaUrls.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: mediaUrls.first,
          width: 200,
          height: 200,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 200,
            height: 200,
            color: Colors.grey[200],
            child: const Icon(Icons.image, color: Colors.grey),
          ),
          errorWidget: (context, url, error) => Container(
            width: 200,
            height: 200,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          ),
        ),
      );
    }
    
    // Multiple images
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => const SizedBox(width: 4),
        itemCount: mediaUrls.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: mediaUrls[index],
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 100,
                height: 100,
                color: Colors.grey[200],
                child: const Icon(Icons.image, color: Colors.grey),
              ),
              errorWidget: (context, url, error) => Container(
                width: 100,
                height: 100,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetadataContent() {
    final metadata = message.metadata!;
    final items = <Widget>[];
    
    // Health analysis results
    if (metadata.containsKey('healthAnalysis')) {
      final healthData = metadata['healthAnalysis'] as Map<String, dynamic>;
      
      items.add(_buildMetadataItem(
        'Health Score',
        '${healthData['score'] ?? 'N/A'}',
        Icons.favorite,
        _getHealthScoreColor(healthData['score']),
      ));
      
      if (healthData.containsKey('issues')) {
        final issues = healthData['issues'] as List;
        for (final issue in issues) {
          items.add(_buildMetadataItem(
            issue['title'] ?? 'Issue',
            issue['description'] ?? 'No description',
            Icons.warning,
            AppTheme.warningColor,
          ));
        }
      }
      
      if (healthData.containsKey('recommendations')) {
        final recommendations = healthData['recommendations'] as List;
        for (final rec in recommendations) {
          items.add(_buildMetadataItem(
            rec['title'] ?? 'Recommendation',
            rec['description'] ?? 'No description',
            Icons.lightbulb,
            AppTheme.infoColor,
          ));
        }
      }
    }
    
    // Emergency triage results
    if (metadata.containsKey('triage')) {
      final triageData = metadata['triage'] as Map<String, dynamic>;
      
      items.add(_buildMetadataItem(
        'Urgency Level',
        '${triageData['urgencyLevel'] ?? 'Unknown'}',
        Icons.priority_high,
        _getUrgencyColor(triageData['urgencyLevel']),
      ));
      
      if (triageData.containsKey('recommendations')) {
        final recommendations = triageData['recommendations'] as List;
        for (final rec in recommendations) {
          items.add(_buildMetadataItem(
            rec['title'] ?? 'Recommendation',
            rec['description'] ?? 'No description',
            Icons.medical_services,
            AppTheme.successColor,
          ));
        }
      }
      
      if (triageData.containsKey('timeFrame')) {
        items.add(_buildMetadataItem(
          'Time Frame',
          '${triageData['timeFrame'] ?? 'Unknown'}',
          Icons.schedule,
          AppTheme.infoColor,
        ));
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    );
  }

  Widget _buildMetadataItem(String title, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: AppTheme.textPrimaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getHealthScoreColor(dynamic score) {
    if (score is String) score = int.tryParse(score) ?? 0;
    
    if (score >= 80) return AppTheme.successColor;
    if (score >= 60) return AppTheme.infoColor;
    if (score >= 40) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  Color _getUrgencyColor(String? urgency) {
    if (urgency == null) return AppTheme.textSecondaryColor;
    
    switch (urgency.toLowerCase()) {
      case 'critical':
        return AppTheme.errorColor;
      case 'urgent':
        return AppTheme.warningColor;
      case 'non_urgent':
        return AppTheme.infoColor;
      default:
        return AppTheme.textSecondaryColor;
    }
  }
}