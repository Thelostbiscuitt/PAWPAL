import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/config/theme.dart';
import '../../../app/config/routes.dart';
import '../../../core/models/pet_model.dart';
import '../providers/pet_provider.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/pet_card.dart';

class PetListScreen extends StatefulWidget {
  const PetListScreen({super.key});

  @override
  State<PetListScreen> createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PetProvider>().loadPets();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Pets',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              NavigationHelper.navigateToAddPet(context);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'All Pets', icon: Icon(Icons.pets)),
            Tab(text: 'Health', icon: Icon(Icons.favorite)),
          ],
        ),
      ),
      body: Consumer<PetProvider>(
        builder: (context, petProvider, child) {
          if (petProvider.isLoading) {
            return const LoadingIndicator();
          }

          if (petProvider.errorMessage != null) {
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
                    petProvider.errorMessage!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.errorColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      petProvider.clearError();
                      petProvider.loadPets();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // All Pets Tab
              _buildPetsTab(petProvider.pets),
              
              // Health Overview Tab
              _buildHealthTab(petProvider.pets),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          NavigationHelper.navigateToAddPet(context);
        },
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Pet'),
      ),
    );
  }

  Widget _buildPetsTab(List<Pet> pets) {
    if (pets.isEmpty) {
      return EmptyState(
        icon: Icons.pets_outlined,
        title: 'No pets yet',
        subtitle: 'Add your first pet to get started with personalized care',
        actionText: 'Add Pet',
        onAction: () {
          NavigationHelper.navigateToAddPet(context);
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<PetProvider>().loadPets();
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: pets.length,
        itemBuilder: (context, index) {
          final pet = pets[index];
          return PetCard(
            pet: pet,
            onTap: () {
              NavigationHelper.navigateToPetDetail(context, pet.id);
            },
            onEdit: () {
              // TODO: Navigate to edit pet
            },
            onDelete: () {
              _showDeletePetDialog(pet);
            },
          );
        },
      ),
    );
  }

  Widget _buildHealthTab(List<Pet> pets) {
    if (pets.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_outline,
        title: 'No health data',
        subtitle: 'Add pets to start tracking their health and wellness',
        actionText: 'Add Pet',
        onAction: () {
          NavigationHelper.navigateToAddPet(context);
        },
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Health Summary Cards
        Row(
          children: [
            Expanded(
              child: _buildHealthSummaryCard(
                'Upcoming Checkups',
                '3',
                Icons.calendar_today,
                AppTheme.infoColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildHealthSummaryCard(
                'Vaccinations Due',
                '2',
                Icons.vaccines,
                AppTheme.warningColor,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildHealthSummaryCard(
                'Active Medications',
                '1',
                Icons.medication,
                AppTheme.successColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildHealthSummaryCard(
                'Health Alerts',
                '1',
                Icons.warning,
                AppTheme.errorColor,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Pet Health List
        Text(
          'Pet Health Status',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 16),
        
        ...pets.map((pet) => _buildPetHealthItem(pet)).toList(),
      ],
    );
  }

  Widget _buildHealthSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const Spacer(),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetHealthItem(Pet pet) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: pet.profileImageUrl != null
              ? NetworkImage(pet.profileImageUrl!)
              : null,
          child: pet.profileImageUrl == null
              ? Icon(
                  pet.species == 'dog' ? Icons.pets : Icons.cruelty_free,
                  color: Colors.white,
                )
              : null,
          backgroundColor: AppTheme.primaryColor,
        ),
        title: Text(
          pet.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${pet.breed} • ${pet.age} old',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.monitor_weight,
                  size: 16,
                  color: AppTheme.textSecondaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${pet.weight} kg',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getHealthStatusColor(pet.healthStatus),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    pet.healthStatus,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          NavigationHelper.navigateToHealthRecords(context, pet.id);
        },
      ),
    );
  }

  Color _getHealthStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'excellent':
        return AppTheme.successColor;
      case 'good':
        return AppTheme.infoColor;
      case 'attention needed':
        return AppTheme.warningColor;
      case 'urgent':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondaryColor;
    }
  }

  void _showDeletePetDialog(Pet pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pet'),
        content: Text(
          'Are you sure you want to delete ${pet.name}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await context.read<PetProvider>().deletePet(pet.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pet deleted successfully'),
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