import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/config/theme.dart';
import '../../../app/config/routes.dart';
import '../../../core/models/emergency_triage_model.dart';
import '../providers/emergency_provider.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/loading_indicator.dart';

class EmergencyTriageScreen extends StatefulWidget {
  final String? petId;
  
  const EmergencyTriageScreen({
    super.key,
    this.petId,
  });

  @override
  State<EmergencyTriageScreen> createState() => _EmergencyTriageScreenState();
}

class _EmergencyTriageScreenState extends State<EmergencyTriageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  List<String> _selectedSymptoms = [];
  bool _isAssessing = false;
  int _currentStep = 0;

  // Emergency symptoms categorized by urgency
  final Map<String, List<String>> _symptomsByCategory = {
    'Critical': [
      'Difficulty breathing',
      'Unconsciousness',
      'Severe bleeding',
      'Seizures',
      'Inability to stand',
      'Pale gums',
      'Rapid heartbeat',
    ],
    'Urgent': [
      'Vomiting multiple times',
      'Diarrhea with blood',
      'Loss of appetite',
      'Extreme lethargy',
      'Difficulty urinating',
      'Swollen abdomen',
      'Persistent coughing',
    ],
    'Concerning': [
      'Mild vomiting',
      'Diarrhea without blood',
      'Decreased appetite',
      'Lethargy',
      'Excessive thirst',
      'Changes in behavior',
      'Mild lameness',
    ],
    'Non-urgent': [
      'Reduced appetite',
      'Slight weight loss',
      'Occasional vomiting',
      'Minor injuries',
      'Skin issues',
      'Ear problems',
      'Eye discharge',
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Emergency Triage',
        backgroundColor: AppTheme.errorColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.local_hospital, color: Colors.white),
            onPressed: _showEmergencyInfo,
          ),
        ],
      ),
      body: Consumer<EmergencyProvider>(
        builder: (context, emergencyProvider, child) {
          if (emergencyProvider.isAssessing) {
            return const LoadingIndicator();
          }

          if (emergencyProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    emergencyProvider.errorMessage!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.errorColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      emergencyProvider.clearError();
                      _currentStep = 0;
                      _selectedSymptoms.clear();
                    },
                    child: const Text('Start Over'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Emergency Warning
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.warning,
                      color: AppTheme.errorColor,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This is an emergency assessment tool, not a substitute for veterinary care.',
                      style: TextStyle(
                        color: AppTheme.errorColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'If your pet is experiencing severe symptoms, contact a veterinarian immediately.',
                      style: TextStyle(
                        color: AppTheme.errorColor,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // Progress Indicator
              if (_currentStep < 4)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildStepIndicator(1, 'Select Symptoms'),
                          Expanded(child: _buildProgressLine(1)),
                          _buildStepIndicator(2, 'Assessment'),
                          Expanded(child: _buildProgressLine(2)),
                          _buildStepIndicator(3, 'Results'),
                          Expanded(child: _buildProgressLine(3)),
                          _buildStepIndicator(4, 'Recommendations'),
                          Expanded(child: _buildProgressLine(4)),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              
              // Content based on current step
              Expanded(
                child: _buildStepContent(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStepIndicator(int step, String title) {
    final isActive = _currentStep >= step;
    return Column(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: isActive ? AppTheme.primaryColor : Colors.grey[300],
          child: Text(
            step.toString(),
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: isActive ? AppTheme.primaryColor : Colors.grey[600],
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(int step) {
    final isActive = _currentStep >= step;
    return Container(
      height: 2,
      color: isActive ? AppTheme.primaryColor : Colors.grey[300],
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildSymptomSelection();
      case 2:
        return _buildAssessment();
      case 3:
        return _buildResults();
      case 4:
        return _buildRecommendations();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSymptomSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select all symptoms that apply to your pet:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        // Symptom categories
        Expanded(
          child: ListView(
            controller: _scrollController,
            children: _symptomsByCategory.entries.map((entry) {
              return _buildSymptomCategory(entry.key, entry.value);
            }).toList(),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Selected symptoms
        if (_selectedSymptoms.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selected Symptoms (${_selectedSymptoms.length}):',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _selectedSymptoms.map((symptom) => Chip(
                  label: symptom,
                  onDeleted: () {
                    setState(() {
                      _selectedSymptoms.remove(symptom);
                    });
                  },
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  deleteIcon: const Icon(Icons.close, size: 16),
                )).toList(),
              ),
            ],
          ),
        
        const SizedBox(height: 16),
        
        // Continue button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedSymptoms.isEmpty ? null : _proceedToAssessment,
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedSymptoms.isEmpty ? Colors.grey : AppTheme.errorColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Continue to Assessment'),
          ),
        ),
      ],
    );
  }

  Widget _buildSymptomCategory(String category, List<String> symptoms) {
    final isExpanded = _selectedSymptoms.any((symptom) => symptoms.contains(symptom));
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(
              _getCategoryIcon(category),
              color: _getCategoryColor(category),
            ),
            title: Text(
              category,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: _getCategoryColor(category),
              ),
            ),
            trailing: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: _getCategoryColor(category),
            ),
            onTap: () {
              setState(() {
                if (isExpanded) {
                  // Collapse all categories
                  _selectedSymptoms.clear();
                } else {
                  // Expand this category
                }
              });
            },
          ),
          
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: symptoms.map((symptom) => FilterChip(
                  label: symptom,
                  selected: _selectedSymptoms.contains(symptom),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedSymptoms.add(symptom);
                      } else {
                        _selectedSymptoms.remove(symptom);
                      }
                    });
                  },
                  backgroundColor: _selectedSymptoms.contains(symptom) 
                      ? AppTheme.primaryColor.withOpacity(0.2) 
                      : Colors.transparent,
                  )).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAssessment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assessing symptoms...',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        // Assessment questions
        Expanded(
          child: ListView(
            children: [
              _buildAssessmentQuestion(
                'Is your pet breathing normally?',
                'Yes - Normal breathing\nNo - Difficulty breathing',
              ),
              _buildAssessmentQuestion(
                'Is your pet conscious and responsive?',
                'Yes - Alert and responsive\nNo - Unconscious or unresponsive',
              ),
              _buildAssessmentQuestion(
                'Is there any bleeding?',
                'Yes - Minor bleeding\nNo - No bleeding',
              ),
              _buildAssessmentQuestion(
                'Is your pet able to stand and walk?',
                'Yes - Mobile\nNo - Unable to stand or walk',
              ),
              _buildAssessmentQuestion(
                'Is your pet eating and drinking normally?',
                'Yes - Normal\nNo - Not eating or drinking',
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Complete assessment button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              _completeAssessment();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Complete Assessment'),
          ),
        ),
      ],
    );
  }

  Widget _buildAssessmentQuestion(String question, String options) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              options,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    return Consumer<EmergencyProvider>(
      builder: (context, emergencyProvider, child) {
        if (emergencyProvider.triageResult == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final result = emergencyProvider.triageResult!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Urgency Level
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getUrgencyColor(result.urgencyLevel),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    _getUrgencyIcon(result.urgencyLevel),
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.urgencyLevel.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getUrgencyDescription(result.urgencyLevel),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Recommendations
            Text(
              'Immediate Actions:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            
            ...result.recommendations.map((rec) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppTheme.successColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            rec,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )).toList(),
            
            const SizedBox(height: 16),
            
            // Emergency contacts
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showEmergencyContacts,
                icon: const Icon(Icons.phone),
                label: const Text('Emergency Contacts'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecommendations() {
    return Consumer<EmergencyProvider>(
      builder: (context, emergencyProvider, child) {
        if (emergencyProvider.triageResult == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Based on the assessment, here are our recommendations:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            // Detailed recommendations
            ...emergencyProvider.triageResult!.recommendations.map((rec) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                    rec['title'] ?? 'Recommendation',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      rec['description'] ?? 'No description',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    if (rec['timeFrame'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Time frame: ${rec['timeFrame']}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            )).toList(),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _restartAssessment,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Restart Assessment'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _callVet,
                    icon: const Icon(Icons.phone),
                    label: const Text('Call Vet'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'critical':
        return Colors.red[700] ?? Colors.red;
      case 'urgent':
        return Colors.orange[700] ?? Colors.orange;
      case 'non_urgent':
        return Colors.blue[700] ?? Colors.blue;
      default:
        return Colors.grey[600] ?? Colors.grey;
    }
  }

  IconData _getUrgencyIcon(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'critical':
        return Icons.priority_high;
      case 'urgent':
        return Icons.warning;
      case 'non_urgent':
        return Icons.info;
      default:
        return Icons.help;
    }
  }

  String _getUrgencyDescription(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'critical':
        return 'Seek immediate veterinary care - This could be life-threatening';
      case 'urgent':
        return 'See a veterinarian within 1-2 hours';
      case 'non_urgent':
        return 'Schedule a veterinary visit when convenient';
      default:
        return 'Monitor your pet closely';
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Critical':
        return Icons.dangerous;
      case 'Urgent':
        return Icons.warning;
      case 'Concerning':
        return Icons.help_outline;
      case 'Non-urgent':
        return Icons.info_outline;
      default:
        return Icons.help;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Critical':
        return Colors.red;
      case 'Urgent':
        return Colors.orange;
      case 'Concerning':
        return Colors.blue;
      case 'Non-urgent':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _proceedToAssessment() {
    setState(() {
      _currentStep = 2;
      _isAssessing = true;
    });
    
    // Perform triage assessment
    context.read<EmergencyProvider>().performTriage(_selectedSymptoms, petId ?? '').then((_) {
      setState(() {
        _currentStep = 3;
        _isAssessing = false;
      });
    });
  }

  void _completeAssessment() {
    setState(() {
      _currentStep = 3;
      _isAssessing = true;
    });
    
    // Complete the assessment
    context.read<EmergencyProvider>().completeAssessment().then((_) {
      setState(() {
        _currentStep = 4;
        _isAssessing = false;
      });
    });
  }

  void _restartAssessment() {
    setState(() {
      _currentStep = 0;
      _selectedSymptoms.clear();
      _isAssessing = false;
    });
    
    context.read<EmergencyProvider>().clearAssessment();
  }

  void _callVet() {
    // TODO: Implement emergency call functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Emergency call feature coming soon!'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _showEmergencyInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Triage'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This tool helps assess the urgency of your pet\'s symptoms.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 16),
            Text(
              '⚠️ Important: This is not a substitute for professional veterinary care.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'If your pet is experiencing severe symptoms like difficulty breathing, unconsciousness, or severe bleeding, contact a veterinarian immediately.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }
}