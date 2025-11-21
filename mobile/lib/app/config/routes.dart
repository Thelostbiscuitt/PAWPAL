import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../widgets/bottom_navigation.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/splash_screen.dart';
import '../widgets/onboarding_screen.dart';
import '../widgets/no_internet_screen.dart';

import '../../features/authentication/screens/login_screen.dart';
import '../../features/authentication/screens/register_screen.dart';
import '../../features/authentication/screens/forgot_password_screen.dart';
import '../../features/authentication/screens/profile_screen.dart';

import '../../features/pets/screens/pet_list_screen.dart';
import '../../features/pets/screens/add_pet_screen.dart';
import '../../features/pets/screens/pet_detail_screen.dart';

import '../../features/ai_chat/screens/chat_screen.dart';
import '../../features/ai_chat/screens/chat_list_screen.dart';

import '../../features/health_tracking/screens/weight_tracker_screen.dart';
import '../../features/health_tracking/screens/health_records_screen.dart';
import '../../features/health_tracking/screens/add_health_record_screen.dart';

import '../../features/care_plans/screens/care_plans_screen.dart';
import '../../features/care_plans/screens/create_plan_screen.dart';
import '../../features/care_plans/screens/plan_detail_screen.dart';

import '../../features/emergency/screens/emergency_triage_screen.dart';
import '../../features/emergency/screens/emergency_contacts_screen.dart';

import '../../features/resources/screens/resource_finder_screen.dart';
import '../../features/resources/screens/resource_detail_screen.dart';

import '../../features/reminders/screens/reminders_screen.dart';
import '../../features/reminders/screens/add_reminder_screen.dart';

import '../../core/providers/auth_provider.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    errorBuilder: (context, state) => const NoInternetScreen(),
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isAuthenticated = authProvider.isAuthenticated;
      final isFirstTime = authProvider.isFirstTime;
      
      // Check if user is authenticated
      if (!isAuthenticated && !state.location.startsWith('/auth')) {
        return '/auth/login';
      }
      
      // Check if it's first time user
      if (isAuthenticated && isFirstTime && !state.location.startsWith('/onboarding')) {
        return '/onboarding';
      }
      
      // Redirect authenticated users from auth screens
      if (isAuthenticated && state.location.startsWith('/auth')) {
        return '/home';
      }
      
      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Onboarding
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Authentication Routes
      GoRoute(
        path: '/auth',
        builder: (context, state) => const LoginScreen(),
        routes: [
          GoRoute(
            path: '/login',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: '/register',
            builder: (context, state) => const RegisterScreen(),
          ),
          GoRoute(
            path: '/forgot-password',
            builder: (context, state) => const ForgotPasswordScreen(),
          ),
        ],
      ),
      
      // Main App Navigation (Bottom Navigation)
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithBottomNav(child: child);
        },
        routes: [
          // Home Tab
          GoRoute(
            path: '/home',
            builder: (context, state) => const PetListScreen(),
            routes: [
              GoRoute(
                path: '/add-pet',
                builder: (context, state) => const AddPetScreen(),
              ),
              GoRoute(
                path: '/pet/:id',
                builder: (context, state) => PetDetailScreen(
                  petId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          
          // AI Chat Tab
          GoRoute(
            path: '/chat',
            builder: (context, state) => const ChatListScreen(),
            routes: [
              GoRoute(
                path: '/conversation/:id',
                builder: (context, state) => ChatScreen(
                  conversationId: state.pathParameters['id'],
                ),
              ),
              GoRoute(
                path: '/new',
                builder: (context, state) => ChatScreen(),
              ),
            ],
          ),
          
          // Health Tracking Tab
          GoRoute(
            path: '/health',
            builder: (context, state) => const WeightTrackerScreen(),
            routes: [
              GoRoute(
                path: '/records/:petId',
                builder: (context, state) => HealthRecordsScreen(
                  petId: state.pathParameters['petId']!,
                ),
              ),
              GoRoute(
                path: '/add-record/:petId',
                builder: (context, state) => AddHealthRecordScreen(
                  petId: state.pathParameters['petId']!,
                ),
              ),
            ],
          ),
          
          // Care Plans Tab
          GoRoute(
            path: '/care-plans',
            builder: (context, state) => const CarePlansScreen(),
            routes: [
              GoRoute(
                path: '/create/:petId',
                builder: (context, state) => CreatePlanScreen(
                  petId: state.pathParameters['petId']!,
                ),
              ),
              GoRoute(
                path: '/detail/:id',
                builder: (context, state) => PlanDetailScreen(
                  planId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          
          // Profile Tab
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: '/reminders',
                builder: (context, state) => const RemindersScreen(),
              ),
              GoRoute(
                path: '/add-reminder',
                builder: (context, state) => const AddReminderScreen(),
              ),
              GoRoute(
                path: '/emergency',
                builder: (context, state) => const EmergencyTriageScreen(),
              ),
              GoRoute(
                path: '/emergency-contacts',
                builder: (context, state) => const EmergencyContactsScreen(),
              ),
            ],
          ),
        ],
      ),
      
      // Resource Finder (Full Screen)
      GoRoute(
        path: '/resources',
        builder: (context, state) => const ResourceFinderScreen(),
        routes: [
          GoRoute(
            path: '/detail/:id',
            builder: (context, state) => ResourceDetailScreen(
              resourceId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
    ],
  );
}

// Custom Shell Route for Bottom Navigation
class ScaffoldWithBottomNav extends StatelessWidget {
  final Widget child;
  
  const ScaffoldWithBottomNav({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const BottomNavigation(),
    );
  }
}

// Route Names for easier navigation
class RouteNames {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String home = '/home';
  static const String addPet = '/home/add-pet';
  static const String petDetail = '/home/pet';
  static const String chat = '/chat';
  static const String newChat = '/chat/new';
  static const String chatDetail = '/chat/conversation';
  static const String health = '/health';
  static const String healthRecords = '/health/records';
  static const String addHealthRecord = '/health/add-record';
  static const String carePlans = '/care-plans';
  static const String createCarePlan = '/care-plans/create';
  static const String carePlanDetail = '/care-plans/detail';
  static const String profile = '/profile';
  static const String reminders = '/profile/reminders';
  static const String addReminder = '/profile/add-reminder';
  static const String emergency = '/profile/emergency';
  static const String emergencyContacts = '/profile/emergency-contacts';
  static const String resources = '/resources';
  static const String resourceDetail = '/resources/detail';
}

// Navigation Helper Class
class NavigationHelper {
  static void navigateToLogin(BuildContext context) {
    GoRouter.of(context).go(RouteNames.login);
  }
  
  static void navigateToRegister(BuildContext context) {
    GoRouter.of(context).go(RouteNames.register);
  }
  
  static void navigateToHome(BuildContext context) {
    GoRouter.of(context).go(RouteNames.home);
  }
  
  static void navigateToPetDetail(BuildContext context, String petId) {
    GoRouter.of(context).go('${RouteNames.petDetail}/$petId');
  }
  
  static void navigateToAddPet(BuildContext context) {
    GoRouter.of(context).go(RouteNames.addPet);
  }
  
  static void navigateToChat(BuildContext context) {
    GoRouter.of(context).go(RouteNames.chat);
  }
  
  static void navigateToNewChat(BuildContext context) {
    GoRouter.of(context).go(RouteNames.newChat);
  }
  
  static void navigateToChatDetail(BuildContext context, String conversationId) {
    GoRouter.of(context).go('${RouteNames.chatDetail}/$conversationId');
  }
  
  static void navigateToHealth(BuildContext context) {
    GoRouter.of(context).go(RouteNames.health);
  }
  
  static void navigateToHealthRecords(BuildContext context, String petId) {
    GoRouter.of(context).go('${RouteNames.healthRecords}/$petId');
  }
  
  static void navigateToAddHealthRecord(BuildContext context, String petId) {
    GoRouter.of(context).go('${RouteNames.addHealthRecord}/$petId');
  }
  
  static void navigateToCarePlans(BuildContext context) {
    GoRouter.of(context).go(RouteNames.carePlans);
  }
  
  static void navigateToCreateCarePlan(BuildContext context, String petId) {
    GoRouter.of(context).go('${RouteNames.createCarePlan}/$petId');
  }
  
  static void navigateToCarePlanDetail(BuildContext context, String planId) {
    GoRouter.of(context).go('${RouteNames.carePlanDetail}/$planId');
  }
  
  static void navigateToProfile(BuildContext context) {
    GoRouter.of(context).go(RouteNames.profile);
  }
  
  static void navigateToReminders(BuildContext context) {
    GoRouter.of(context).go(RouteNames.reminders);
  }
  
  static void navigateToAddReminder(BuildContext context) {
    GoRouter.of(context).go(RouteNames.addReminder);
  }
  
  static void navigateToEmergency(BuildContext context) {
    GoRouter.of(context).go(RouteNames.emergency);
  }
  
  static void navigateToResources(BuildContext context) {
    GoRouter.of(context).go(RouteNames.resources);
  }
  
  static void navigateToResourceDetail(BuildContext context, String resourceId) {
    GoRouter.of(context).go('${RouteNames.resourceDetail}/$resourceId');
  }
}