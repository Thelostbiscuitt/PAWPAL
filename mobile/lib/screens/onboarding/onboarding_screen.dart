import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/services/storage_service.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../home/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isSkipped = false;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to Pet Support',
      description: 'Your comprehensive companion for pet care, designed specifically for first-time pet owners.',
      image: 'assets/images/onboarding_welcome.png',
      icon: Icons.pets,
    ),
    OnboardingPage(
      title: 'AI-Powered Assistance',
      description: 'Get instant answers to your pet care questions with our intelligent AI assistant, available 24/7.',
      image: 'assets/images/onboarding_ai.png',
      icon: Icons.smart_toy,
    ),
    OnboardingPage(
      title: 'Health Tracking',
      description: 'Monitor your pet\'s weight, medications, and milestones with comprehensive health tracking tools.',
      image: 'assets/images/onboarding_health.png',
      icon: Icons.monitor_heart,
    ),
    OnboardingPage(
      title: 'Emergency Triage',
      description: 'Quick assessment when your pet needs urgent care. Get immediate guidance on what to do in emergencies.',
      image: 'assets/images/onboarding_emergency.png',
      icon: Icons.emergency,
    ),
    OnboardingPage(
      title: 'Personalized Care Plans',
      description: 'Receive customized care recommendations based on your pet\'s specific needs and your lifestyle.',
      image: 'assets/images/onboarding_care.png',
      icon: Icons.assignment,
    ),
    OnboardingPage(
      title: 'Local Resources',
      description: 'Find vets, pet stores, and services in your area with reviews and ratings from other pet owners.',
      image: 'assets/images/onboarding_resources.png',
      icon: Icons.location_on,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
      
      if (!mounted) return;
      
      // Check if user is already logged in
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      // Handle error gracefully
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> _skipOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
      await prefs.setBool('onboarding_skipped', true);
      
      if (!mounted) return;
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      // Handle error gracefully
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            
            // Page view
            Expanded(
              flex: 4,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPageWidget(
                    page: _pages[index],
                    themeProvider: themeProvider,
                  );
                },
              ),
            ),
            
            // Page indicators
            Container(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _buildDotIndicator(index),
                ),
              ),
            ),
            
            // Navigation buttons
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Previous button
                    if (_currentPage > 0)
                      TextButton(
                        onPressed: _previousPage,
                        child: Text(
                          'Previous',
                          style: TextStyle(
                            color: themeProvider.primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 80),
                    
                    // Next/Get Started button
                    ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeProvider.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDotIndicator(int index) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? themeProvider.primaryColor
            : themeProvider.isDarkMode ? Colors.white24 : Colors.black26,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;
  final ThemeProvider themeProvider;

  const OnboardingPageWidget({
    Key? key,
    required this.page,
    required this.themeProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon or image
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: themeProvider.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: page.image != null
                ? Image.asset(
                    page.image!,
                    width: 150,
                    height: 150,
                  )
                : Icon(
                    page.icon,
                    size: 100,
                    color: themeProvider.primaryColor,
                  ),
          ),
          
          const SizedBox(height: 40),
          
          // Title
          Text(
            page.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 20),
          
          // Description
          Text(
            page.description,
            style: TextStyle(
              fontSize: 16,
              color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          // Feature highlights for certain pages
          if (page.title.contains('AI') || page.title.contains('Emergency'))
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: _buildFeatureHighlights(page.title),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureHighlights(String title) {
    List<String> features = [];
    
    if (title.contains('AI')) {
      features = [
        '24/7 availability',
        'Image analysis',
        'Personalized answers',
        'Expert knowledge base'
      ];
    } else if (title.contains('Emergency')) {
      features = [
        'Quick symptom assessment',
        'Urgency classification',
        'Emergency contacts',
        'First aid guidance'
      ];
    }
    
    return Column(
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 16,
                color: themeProvider.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                feature,
                style: TextStyle(
                  fontSize: 14,
                  color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String? image;
  final IconData? icon;

  OnboardingPage({
    required this.title,
    required this.description,
    this.image,
    this.icon,
  });
}

// Quick Start Screen - shown after onboarding for new users
class QuickStartScreen extends StatefulWidget {
  const QuickStartScreen({Key? key}) : super(key: key);

  @override
  State<QuickStartScreen> createState() => _QuickStartScreenState();
}

class _QuickStartScreenState extends State<QuickStartScreen> {
  int _selectedPetType = 0;
  final List<String> _petTypes = ['Dog', 'Cat', 'Bird', 'Fish', 'Other'];
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text('Quick Setup'),
        backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: themeProvider.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Let\'s personalize your experience',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Answer a few questions to get personalized recommendations',
              style: TextStyle(
                fontSize: 16,
                color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Pet type selection
            Text(
              'What type of pet do you have?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _petTypes.asMap().entries.map((entry) {
                final index = entry.key;
                final petType = entry.value;
                final isSelected = _selectedPetType == index;
                
                return ChoiceChip(
                  label: Text(petType),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedPetType = index;
                      });
                    }
                  },
                  backgroundColor: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  selectedColor: themeProvider.primaryColor.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? themeProvider.primaryColor : 
                           themeProvider.isDarkMode ? Colors.white : Colors.black,
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 32),
            
            // Notifications toggle
            SwitchListTile(
              title: Text(
                'Enable Notifications',
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              subtitle: Text(
                'Get reminders for medications and appointments',
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
              activeColor: themeProvider.primaryColor,
            ),
            
            const SizedBox(height: 16),
            
            // Location toggle
            SwitchListTile(
              title: Text(
                'Enable Location Services',
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              subtitle: Text(
                'Find local pet resources and services',
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              value: _locationEnabled,
              onChanged: (value) {
                setState(() {
                  _locationEnabled = value;
                });
              },
              activeColor: themeProvider.primaryColor,
            ),
            
            const Spacer(),
            
            // Continue button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _saveQuickStartPreferences();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeProvider.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveQuickStartPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('primary_pet_type', _petTypes[_selectedPetType]);
      await prefs.setBool('notifications_enabled', _notificationsEnabled);
      await prefs.setBool('location_enabled', _locationEnabled);
      await prefs.setBool('quick_start_completed', true);
    } catch (e) {
      // Handle error gracefully
    }
  }
}