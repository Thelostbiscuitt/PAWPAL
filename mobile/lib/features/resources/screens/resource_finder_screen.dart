import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../app/config/theme.dart';
import '../../../app/config/routes.dart';
import '../../../core/models/resource_model.dart';
import '../../../core/utils/validators.dart';
import '../providers/resource_provider.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/resource_card.dart';

class ResourceFinderScreen extends StatefulWidget {
  const ResourceFinderScreen({super.key});

  @override
  State<ResourceFinderScreen> createState() => _ResourceFinderScreenState();
}

class _ResourceFinderScreenState extends State<ResourceFinderScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _selectedCategory = 'all';
  double _searchRadius = 10.0;
  bool _useCurrentLocation = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ResourceProvider>().loadResources();
      _requestLocationPermission();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showLocationPermissionDialog();
      }
    } catch (e) {
      print('Location permission error: $e');
    }
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission'),
        content: const Text(
          'Location permission is required to find nearby pet services. Please enable location access in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Geolocator.openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Pet Services Near You',
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: _showMapOptions,
          ),
        ],
      ),
      body: Consumer<ResourceProvider>(
        builder: (context, resourceProvider, child) {
          if (resourceProvider.isLoading) {
            return const LoadingIndicator();
          }

          if (resourceProvider.errorMessage != null) {
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
                    resourceProvider.errorMessage!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.errorColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      resourceProvider.clearError();
                      resourceProvider.loadResources();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Search Section
              _buildSearchSection(resourceProvider),
              
              const SizedBox(height: 16),
              
              // Category Filter
              _buildCategoryFilter(resourceProvider),
              
              const SizedBox(height: 16),
              
              // Location Settings
              _buildLocationSettings(resourceProvider),
              
              const SizedBox(height: 16),
              
              // Results List
              Expanded(
                child: resourceProvider.resources.isEmpty
                    ? _buildEmptyState()
                    : _buildResourcesList(resourceProvider.resources),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchSection(ResourceProvider resourceProvider) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Find Pet Services',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Search for vets, pet stores, groomers, and more in your area',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            
            // Search Input
            TextField(
              controller: _searchController,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _performSearch(value, resourceProvider);
                }
              },
              decoration: InputDecoration(
                hintText: 'Search services...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          resourceProvider.clearSearchResults();
                        },
                      ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(ResourceProvider resourceProvider) {
    final categories = [
      {'value': 'all', 'label': 'All Services', 'icon': Icons.pets},
      {'value': 'vet', 'label': 'Veterinarians', 'icon': Icons.local_hospital},
      {'value': 'pet_store', 'label': 'Pet Stores', 'icon': Icons.store},
      {'value': 'groomer', 'label': 'Groomers', 'icon': Icons.content_cut},
      {'value': 'trainer', 'label': 'Trainers', 'icon': Icons.school},
      {'value': 'shelter', 'label': 'Shelters', 'icon': Icons.home},
    ];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            final isSelected = _selectedCategory == category['value'];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                label: Text(category['label']),
                selected: isSelected,
                onSelected: () {
                  setState(() {
                    _selectedCategory = category['value'];
                  });
                  resourceProvider.filterByCategory(category['value']);
                },
                backgroundColor: isSelected ? AppTheme.primaryColor : null,
                avatar: Icon(category['icon']),
              );
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLocationSettings(ResourceProvider resourceProvider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search Settings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            
            // Use Current Location
            SwitchListTile(
              title: const Text('Use Current Location'),
              subtitle: const Text('Find services near your current location'),
              value: _useCurrentLocation,
              onChanged: (value) {
                setState(() {
                  _useCurrentLocation = value;
                });
              },
            ),
            
            // Search Radius
            ExpansionTile(
              title: Text('Search Radius: ${_searchRadius.toStringAsFixed(1)} km'),
              subtitle: const Text('Adjust search distance'),
              children: [
                Slider(
                  value: _searchRadius,
                  min: 1.0,
                  max: 50.0,
                  divisions: 49,
                  onChanged: (value) {
                    setState(() {
                      _searchRadius = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('1 km'),
                    Expanded(child: Container()),
                    Text('50 km'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      icon: Icons.store_outlined,
      title: 'No Services Found',
      subtitle: 'Try adjusting your search or location settings',
      actionText: 'Search Again',
      onAction: () {
        _searchController.clear();
        context.read<ResourceProvider>().loadResources();
      },
    );
  }

  Widget _buildResourcesList(List<Resource> resources) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<ResourceProvider>().loadResources();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: resources.length,
        itemBuilder: (context, index) {
          final resource = resources[index];
          return ResourceCard(
            resource: resource,
            onTap: () {
              NavigationHelper.navigateToResourceDetail(context, resource.id);
            },
            onCall: () {
              // TODO: Implement phone call
            },
            onDirections: () {
              // TODO: Open in maps app
            },
          );
        },
      ),
    );
  }

  Future<void> _performSearch(String query, ResourceProvider resourceProvider) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    final searchParams = {
      'q': query.trim(),
      'category': _selectedCategory == 'all' ? null : _selectedCategory,
      'lat': _useCurrentLocation ? resourceProvider.currentLocation?.latitude : null,
      'lng': _useCurrentLocation ? resourceProvider.currentLocation?.longitude : null,
      'radius': _useCurrentLocation ? _searchRadius : null,
    };

    await resourceProvider.searchResources(searchParams);

    setState(() {
      _isSearching = false;
    });
  }

  void _showMapOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Map Options',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Open in Google Maps'),
              subtitle: const Text('View all resources on map'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement map view
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('List View'),
              subtitle: const Text('Show as searchable list'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}