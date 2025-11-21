import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../app/config/theme.dart';
import '../../../app/config/routes.dart';
import '../../../core/models/health_record_model.dart';
import '../../../core/models/pet_model.dart';
import '../providers/health_provider.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/empty_state.dart';

class WeightTrackerScreen extends StatefulWidget {
  final String petId;
  
  const WeightTrackerScreen({
    super.key,
    required this.petId,
  });

  @override
  State<WeightTrackerScreen> createState() => _WeightTrackerScreenState();
}

class _WeightTrackerScreenState extends State<WeightTrackerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthProvider>().loadWeightHistory(petId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Weight Tracker',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              NavigationHelper.navigateToAddHealthRecord(context, petId);
            },
          ),
        ],
      ),
      body: Consumer<HealthProvider>(
        builder: (context, healthProvider, child) {
          if (healthProvider.isLoading) {
            return const LoadingIndicator();
          }

          if (healthProvider.errorMessage != null) {
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
                    healthProvider.errorMessage!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.errorColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      healthProvider.clearError();
                      healthProvider.loadWeightHistory(petId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final weightRecords = healthProvider.weightRecords;
          if (weightRecords.isEmpty) {
            return EmptyState(
              icon: Icons.monitor_weight,
              title: 'No weight records',
              subtitle: 'Start tracking your pet\'s weight to monitor their health',
              actionText: 'Add Weight Record',
              onAction: () {
                NavigationHelper.navigateToAddHealthRecord(context, petId);
              },
            );
          }

          return Column(
            children: [
              // Weight Summary Card
              _buildWeightSummary(weightRecords),
              
              const SizedBox(height: 16),
              
              // Weight Chart
              Expanded(
                child: _buildWeightChart(weightRecords),
              ),
              
              const SizedBox(height: 16),
              
              // Weight History List
              Expanded(
                flex: 2,
                child: _buildWeightList(weightRecords),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          NavigationHelper.navigateToAddHealthRecord(context, petId);
        },
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Weight'),
      ),
    );
  }

  Widget _buildWeightSummary(List<HealthRecord> weightRecords) {
    if (weightRecords.isEmpty) return const SizedBox.shrink();
    
    final latestWeight = weightRecords.first.value;
    final previousWeight = weightRecords.length > 1 ? weightRecords[1].value : null;
    final weightChange = previousWeight != null 
        ? latestWeight - previousWeight 
        : 0.0;
    
    final weightTrend = _getWeightTrend(weightRecords);
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Weight',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${latestWeight.toStringAsFixed(1)} kg',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Weight Change
                if (weightChange != 0)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          weightChange > 0 ? 'Gained' : 'Lost',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: weightChange > 0 ? AppTheme.errorColor : AppTheme.successColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              weightChange > 0 ? Icons.trending_up : Icons.trending_down,
                              color: weightChange > 0 ? AppTheme.errorColor : AppTheme.successColor,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${weightChange.abs().toStringAsFixed(1)} kg',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: weightChange > 0 ? AppTheme.errorColor : AppTheme.successColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Weight Trend
            Row(
              children: [
                Icon(
                  _getTrendIcon(weightTrend),
                  color: _getTrendColor(weightTrend),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _getTrendText(weightTrend),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _getTrendColor(weightTrend),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  'Last 30 days',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // BMI Indicator (if applicable)
            if (latestWeight > 0)
              _buildBMIIndicator(latestWeight),
          ],
        ),
      ),
    );
  }

  Widget _buildBMIIndicator(double weight) {
    // This is a simplified BMI calculation for pets
    // In a real app, you'd need pet's length/breed-specific data
    final bmi = weight / (0.5 * 0.5); // Simplified calculation
    
    String bmiStatus;
    Color bmiColor;
    
    if (bmi < 18.5) {
      bmiStatus = 'Underweight';
      bmiColor = Colors.orange;
    } else if (bmi < 25) {
      bmiStatus = 'Healthy';
      bmiColor = Colors.green;
    } else if (bmi < 30) {
      bmiStatus = 'Overweight';
      bmiColor = Colors.red;
    } else {
      bmiStatus = 'Obese';
      bmiColor = Colors.red;
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bmiColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: bmiColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            'BMI: ${bmi.toStringAsFixed(1)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: bmiColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              bmiStatus,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightChart(List<HealthRecord> weightRecords) {
    if (weightRecords.length < 2) {
      return const Center(
        child: Text(
          'Need at least 2 weight records to show chart',
          style: TextStyle(
            color: AppTheme.textSecondaryColor,
            fontSize: 16,
          ),
        ),
      );
    }

    final spots = weightRecords.asMap().entries.map((entry) {
      final date = entry.value.recordedAt;
      final weight = entry.value.value ?? 0.0;
      
      return FlSpot(
        date,
        weight,
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppTheme.textSecondaryColor.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: AppTheme.textSecondaryColor.withOpacity(0.2)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              gradient: const LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.accentColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppTheme.primaryColor,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
            ),
          ],
          minY: _getMinWeight(weightRecords) - 1,
          maxY: _getMaxWeight(weightRecords) + 1,
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (value, meta) {
                  final weight = value.toInt();
                  return Text(
                    '${weight}kg',
                    style: const TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() % 2 == 0) {
                    final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                    return Text(
                      DateFormat('MMM dd').format(date),
                      style: const TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          tooltipBgColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildWeightList(List<HealthRecord> weightRecords) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Weight History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: weightRecords.length,
              itemBuilder: (context, index) {
                final record = weightRecords[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.monitor_weight,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    '${record.value?.toStringAsFixed(1) ?? '0.0'} kg',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    DateFormat('MMM dd, yyyy').format(record.recordedAt),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      _showWeightOptions(record);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getWeightTrend(List<HealthRecord> records) {
    if (records.length < 2) return 'stable';
    
    final recentWeights = records.take(5).map((r) => r.value ?? 0.0).toList();
    if (recentWeights.length < 2) return 'stable';
    
    double totalChange = 0;
    for (int i = 1; i < recentWeights.length; i++) {
      totalChange += recentWeights[i] - recentWeights[i-1];
    }
    
    if (totalChange > 0.5) return 'increasing';
    if (totalChange < -0.5) return 'decreasing';
    return 'stable';
  }

  IconData _getTrendIcon(String trend) {
    switch (trend) {
      case 'increasing':
        return Icons.trending_up;
      case 'decreasing':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }

  Color _getTrendColor(String trend) {
    switch (trend) {
      case 'increasing':
        return AppTheme.errorColor;
      case 'decreasing':
        return AppTheme.successColor;
      default:
        return AppTheme.infoColor;
    }
  }

  String _getTrendText(String trend) {
    switch (trend) {
      case 'increasing':
        return 'Weight increasing';
      case 'decreasing':
        return 'Weight decreasing';
      default:
        return 'Weight stable';
    }
  }

  double _getMinWeight(List<HealthRecord> records) {
    if (records.isEmpty) return 0.0;
    return records.map((r) => r.value ?? 0.0).reduce((a, b) => a < b ? a : b);
  }

  double _getMaxWeight(List<HealthRecord> records) {
    if (records.isEmpty) return 10.0;
    return records.map((r) => r.value ?? 0.0).reduce((a, b) => a > b ? a : b);
  }

  void _showWeightOptions(HealthRecord record) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Record'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to edit screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppTheme.errorColor),
              title: const Text('Delete Record'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(record);
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.note_add),
              title: const Text('Add Note'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Add note to record
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(HealthRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Weight Record'),
        content: Text(
          'Are you sure you want to delete the weight record from ${DateFormat('MMM dd, yyyy').format(record.recordedAt)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<HealthProvider>().deleteHealthRecord(record.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Weight record deleted'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}