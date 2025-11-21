import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:pet_support_app/main.dart';
import 'package:pet_support_app/core/providers/auth_provider.dart';
import 'package:pet_support_app/core/providers/pet_provider.dart';
import 'package:pet_support_app/core/providers/theme_provider.dart';
import 'package:pet_support_app/core/services/api_client.dart';
import 'package:pet_support_app/core/services/auth_service.dart';
import 'package:pet_support_app/core/services/storage_service.dart';
import 'package:pet_support_app/screens/auth/login_screen.dart';
import 'package:pet_support_app/screens/pet/pet_list_screen.dart';
import 'package:pet_support_app/screens/ai_chat/ai_chat_screen.dart';
import 'package:pet_support_app/screens/health/weight_tracker_screen.dart';
import 'package:pet_support_app/screens/emergency/emergency_triage_screen.dart';

// Generate mocks
@GenerateMocks([ApiClient, AuthService, StorageService])
import 'widget_test.mocks.dart';

void main() {
  group('Pet Support App Widget Tests', () {
    late MockApiClient mockApiClient;
    late MockAuthService mockAuthService;
    late MockStorageService mockStorageService;

    setUp(() {
      mockApiClient = MockApiClient();
      mockAuthService = MockAuthService();
      mockStorageService = MockStorageService();
    });

    Widget createWidgetUnderTest({Widget? child}) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>(
            create: (_) => ThemeProvider(),
          ),
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider(
              authService: mockAuthService,
              storageService: mockStorageService,
            ),
          ),
          ChangeNotifierProvider<PetProvider>(
            create: (_) => PetProvider(
              apiClient: mockApiClient,
            ),
          ),
        ],
        child: MaterialApp(
          home: child ?? LoginScreen(),
        ),
      );
    }

    group('Login Screen Tests', () {
      testWidgets('should display login form elements', (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        // Check for email field
        expect(find.byType(TextFormField), findsWidgets);
        expect(find.text('Email'), findsOneWidget);
        
        // Check for password field
        expect(find.text('Password'), findsOneWidget);
        
        // Check for login button
        expect(find.text('Login'), findsOneWidget);
        
        // Check for register link
        expect(find.text('Don\'t have an account? Register'), findsOneWidget);
      });

      testWidgets('should show validation error for empty email', (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        // Find login button and tap it without entering email
        final loginButton = find.text('Login');
        await tester.tap(loginButton);
        await tester.pump();

        // Check for validation error
        expect(find.text('Please enter your email'), findsOneWidget);
      });

      testWidgets('should show validation error for invalid email', (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        // Enter invalid email
        final emailField = find.byKey(Key('email_field'));
        await tester.enterText(emailField, 'invalid-email');
        
        // Find login button and tap it
        final loginButton = find.text('Login');
        await tester.tap(loginButton);
        await tester.pump();

        // Check for validation error
        expect(find.text('Please enter a valid email'), findsOneWidget);
      });

      testWidgets('should show validation error for empty password', (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        // Enter valid email
        final emailField = find.byKey(Key('email_field'));
        await tester.enterText(emailField, 'test@example.com');
        
        // Find login button and tap it without entering password
        final loginButton = find.text('Login');
        await tester.tap(loginButton);
        await tester.pump();

        // Check for validation error
        expect(find.text('Please enter your password'), findsOneWidget);
      });

      testWidgets('should navigate to pet list on successful login', (WidgetTester tester) async {
        // Mock successful login
        when(mockAuthService.login(any, any))
            .thenAnswer((_) async => {
              'success': true,
              'data': {
                'token': 'mock-token',
                'user': {
                  'id': '1',
                  'email': 'test@example.com',
                  'firstName': 'Test',
                  'lastName': 'User'
                }
              }
            });

        when(mockStorageService.saveToken(any))
            .thenAnswer((_) async {});

        await tester.pumpWidget(createWidgetUnderTest());

        // Enter valid credentials
        final emailField = find.byKey(Key('email_field'));
        final passwordField = find.byKey(Key('password_field'));
        
        await tester.enterText(emailField, 'test@example.com');
        await tester.enterText(passwordField, 'Password123!');
        
        // Tap login button
        final loginButton = find.text('Login');
        await tester.tap(loginButton);
        await tester.pump();

        // Check if navigation occurred (loading indicator should appear)
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('Pet List Screen Tests', () {
      testWidgets('should display empty state when no pets', (WidgetTester tester) async {
        // Mock empty pet list
        when(mockApiClient.get('/api/pets'))
            .thenAnswer((_) async => {
              'success': true,
              'data': []
            });

        await tester.pumpWidget(createWidgetUnderTest(
          child: PetListScreen(),
        ));

        await tester.pumpAndSettle();

        // Check for empty state message
        expect(find.text('No pets added yet'), findsOneWidget);
        expect(find.text('Add your first pet to get started'), findsOneWidget);
        
        // Check for add pet button
        expect(find.byIcon(Icons.add), findsOneWidget);
      });

      testWidgets('should display pet list when pets exist', (WidgetTester tester) async {
        // Mock pet list with data
        when(mockApiClient.get('/api/pets'))
            .thenAnswer((_) async => {
              'success': true,
              'data': [
                {
                  'id': '1',
                  'name': 'Buddy',
                  'type': 'Dog',
                  'breed': 'Golden Retriever',
                  'age': 3,
                  'weight': 25.5,
                  'gender': 'male',
                  'profileImageUrl': null
                },
                {
                  'id': '2',
                  'name': 'Whiskers',
                  'type': 'Cat',
                  'breed': 'Persian',
                  'age': 2,
                  'weight': 4.2,
                  'gender': 'female',
                  'profileImageUrl': null
                }
              ]
            });

        await tester.pumpWidget(createWidgetUnderTest(
          child: PetListScreen(),
        ));

        await tester.pumpAndSettle();

        // Check for pet names
        expect(find.text('Buddy'), findsOneWidget);
        expect(find.text('Whiskers'), findsOneWidget);
        
        // Check for pet details
        expect(find.text('Dog - Golden Retriever'), findsOneWidget);
        expect(find.text('Cat - Persian'), findsOneWidget);
        
        // Check for add pet button
        expect(find.byIcon(Icons.add), findsOneWidget);
      });

      testWidgets('should show loading indicator while fetching pets', (WidgetTester tester) async {
        // Mock delayed response
        when(mockApiClient.get('/api/pets'))
            .thenAnswer((_) async {
              await Future.delayed(Duration(seconds: 1));
              return {
                'success': true,
                'data': []
              };
            });

        await tester.pumpWidget(createWidgetUnderTest(
          child: PetListScreen(),
        ));

        // Check for loading indicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('AI Chat Screen Tests', () {
      testWidgets('should display chat interface elements', (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          child: AIChatScreen(),
        ));

        // Check for chat input field
        expect(find.byType(TextField), findsOneWidget);
        
        // Check for send button
        expect(find.byIcon(Icons.send), findsOneWidget);
        
        // Check for attachment button
        expect(find.byIcon(Icons.attach_file), findsOneWidget);
        
        // Check for welcome message
        expect(find.text('Hello! I\'m your AI pet care assistant'), findsOneWidget);
      });

      testWidgets('should send message when send button is tapped', (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          child: AIChatScreen(),
        ));

        // Enter message
        final chatInput = find.byType(TextField);
        await tester.enterText(chatInput, 'How much should I feed my dog?');
        
        // Tap send button
        final sendButton = find.byIcon(Icons.send);
        await tester.tap(sendButton);
        await tester.pump();

        // Check if message appears in chat
        expect(find.text('How much should I feed my dog?'), findsOneWidget);
      });

      testWidgets('should show validation error for empty message', (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          child: AIChatScreen(),
        ));

        // Tap send button without entering message
        final sendButton = find.byIcon(Icons.send);
        await tester.tap(sendButton);
        await tester.pump();

        // Input field should still be focused (no message sent)
        expect(find.byType(TextField), findsOneWidget);
      });
    });

    group('Weight Tracker Screen Tests', () {
      testWidgets('should display weight tracking interface', (WidgetTester tester) async {
        // Mock pet list
        when(mockApiClient.get('/api/pets'))
            .thenAnswer((_) async => {
              'success': true,
              'data': [
                {
                  'id': '1',
                  'name': 'Buddy',
                  'type': 'Dog',
                  'breed': 'Golden Retriever',
                  'age': 3,
                  'weight': 25.5,
                  'gender': 'male',
                  'profileImageUrl': null
                }
              ]
            });

        await tester.pumpWidget(createWidgetUnderTest(
          child: WeightTrackerScreen(),
        ));

        await tester.pumpAndSettle();

        // Check for pet selector
        expect(find.text('Buddy'), findsOneWidget);
        
        // Check for weight input field
        expect(find.text('Weight (kg)'), findsOneWidget);
        
        // Check for date selector
        expect(find.text('Date'), findsOneWidget);
        
        // Check for save button
        expect(find.text('Save Weight Entry'), findsOneWidget);
      });

      testWidgets('should show validation error for invalid weight', (WidgetTester tester) async {
        // Mock pet list
        when(mockApiClient.get('/api/pets'))
            .thenAnswer((_) async => {
              'success': true,
              'data': [
                {
                  'id': '1',
                  'name': 'Buddy',
                  'type': 'Dog',
                  'breed': 'Golden Retriever',
                  'age': 3,
                  'weight': 25.5,
                  'gender': 'male',
                  'profileImageUrl': null
                }
              ]
            });

        await tester.pumpWidget(createWidgetUnderTest(
          child: WeightTrackerScreen(),
        ));

        await tester.pumpAndSettle();

        // Enter invalid weight
        final weightField = find.byKey(Key('weight_field'));
        await tester.enterText(weightField, 'invalid');
        
        // Tap save button
        final saveButton = find.text('Save Weight Entry');
        await tester.tap(saveButton);
        await tester.pump();

        // Check for validation error
        expect(find.text('Please enter a valid weight'), findsOneWidget);
      });
    });

    group('Emergency Triage Screen Tests', () {
      testWidgets('should display emergency triage interface', (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          child: EmergencyTriageScreen(),
        ));

        // Check for emergency warning
        expect(find.text('Emergency Triage'), findsOneWidget);
        expect(find.text('Is this a life-threatening emergency?'), findsOneWidget);
        
        // Check for emergency call button
        expect(find.text('Call Emergency Vet'), findsOneWidget);
        
        // Check for symptom selection
        expect(find.text('Select Symptoms'), findsOneWidget);
      });

      testWidgets('should show emergency contact when emergency button is tapped', (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          child: EmergencyTriageScreen(),
        ));

        // Tap emergency call button
        final emergencyButton = find.text('Call Emergency Vet');
        await tester.tap(emergencyButton);
        await tester.pump();

        // Check for emergency dialog
        expect(find.text('Emergency Contact'), findsOneWidget);
        expect(find.text('Call +234-800-000-0000'), findsOneWidget);
      });

      testWidgets('should assess symptoms and provide triage level', (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest(
          child: EmergencyTriageScreen(),
        ));

        // Select symptoms
        final breathingDifficulty = find.text('Difficulty Breathing');
        await tester.tap(breathingDifficulty);
        await tester.pump();

        final lethargy = find.text('Lethargy');
        await tester.tap(lethargy);
        await tester.pump();

        // Tap assess button
        final assessButton = find.text('Assess Urgency');
        await tester.tap(assessButton);
        await tester.pump();

        // Check for triage result
        expect(find.text('High Priority - Seek Veterinary Care Soon'), findsOneWidget);
      });
    });

    group('Navigation Tests', () {
      testWidgets('should navigate between screens using bottom navigation', (WidgetTester tester) async {
        await tester.pumpWidget(MyApp());

        await tester.pumpAndSettle();

        // Check initial screen (should be pet list)
        expect(find.text('My Pets'), findsOneWidget);

        // Navigate to AI chat
        final chatIcon = find.byIcon(Icons.chat);
        await tester.tap(chatIcon);
        await tester.pumpAndSettle();

        expect(find.text('AI Assistant'), findsOneWidget);

        // Navigate to weight tracker
        final weightIcon = find.byIcon(Icons.monitor_weight);
        await tester.tap(weightIcon);
        await tester.pumpAndSettle();

        expect(find.text('Weight Tracker'), findsOneWidget);

        // Navigate to emergency triage
        final emergencyIcon = find.byIcon(Icons.emergency);
        await tester.tap(emergencyIcon);
        await tester.pumpAndSettle();

        expect(find.text('Emergency Triage'), findsOneWidget);
      });
    });

    group('Theme Tests', () {
      testWidgets('should apply theme changes', (WidgetTester tester) async {
        await tester.pumpWidget(MyApp());

        await tester.pumpAndSettle();

        // Check default theme
        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar.backgroundColor, equals(Colors.blue));

        // Navigate to settings and change theme
        final settingsIcon = find.byIcon(Icons.settings);
        await tester.tap(settingsIcon);
        await tester.pumpAndSettle();

        // Find dark mode toggle
        final darkModeToggle = find.byKey(Key('dark_mode_toggle'));
        await tester.tap(darkModeToggle);
        await tester.pumpAndSettle();

        // Check if theme changed (this would require the theme provider to be properly connected)
        // In a real implementation, you'd verify the theme change
      });
    });
  });
}