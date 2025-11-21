import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool _isInitialized = false;

  // Initialize notification service
  Future<void> initialize() async {
    try {
      // Request notification permissions
      await _requestPermissions();
      
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      // Initialize Firebase messaging
      await _initializeFirebaseMessaging();
      
      _isInitialized = true;
      print('Notification service initialized successfully');
    } catch (e) {
      print('Failed to initialize notification service: $e');
    }
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    final settings = AndroidInitializationSettings(
      channelId: 'pet_support_channel',
      channelName: 'Pet Support Notifications',
      channelDescription: 'Notifications for pet care reminders and alerts',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings: InitializationSettings(
        android: settings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse:
          _onNotificationReceived,
    );
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidDetails = AndroidNotificationDetails(
      channelId: 'pet_support_channel',
      channelName: 'Pet Support Notifications',
      channelDescription: 'Notifications for pet care reminders and alerts',
      importance: Importance.high,
      priority: Priority.high,
      color: Color.fromARGB(255, 0, 76, 175), // Green color
      ledColor: Color.fromARGB(255, 209, 244, 65),
      ledOnMs: 1000,
      ledOffMs: 1000,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _flutterLocalNotificationsPlugin.createNotificationChannel(
      androidChannel: androidDetails,
      iOS: iosDetails,
    );
  }

  // Initialize Firebase messaging
  Future<void> _initializeFirebaseMessaging() async {
    // Request permission
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Firebase messaging permission granted');
      
      // Get FCM token
      final token = await _firebaseMessaging.getToken();
      print('FCM Token: $token');
      
      // Save token to backend
      await _saveFcmTokenToBackend(token);
      
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
      // Handle background messages
      FirebaseMessaging.onBackgroundMessage.listen(_handleBackgroundMessage);
      
      // Handle token refresh
      FirebaseMessaging.onTokenRefresh.listen(_handleTokenRefresh);
    } else {
      print('Firebase messaging permission denied');
    }
  }

  // Handle notification received
  void _onNotificationReceived(NotificationResponse notificationResponse) {
    print('Notification received: ${notificationResponse.payload}');
  }

  // Handle foreground Firebase message
  void _handleForegroundMessage(RemoteMessage message) {
    print('Foreground Firebase message: ${message.message}');
    
    if (message.data != null) {
      final data = message.data!;
      _showLocalNotification(
        title: data['title'] ?? 'Pet Support',
        body: data['body'] ?? 'You have a new notification',
        payload: data,
      );
    }
  }

  // Handle background Firebase message
  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Background Firebase message: ${message.message}');
    
    if (message.data != null) {
      final data = message.data!;
      await _showLocalNotification(
        title: data['title'] ?? 'Pet Support',
        body: data['body'] ?? 'You have a new notification',
        payload: data,
      );
    }
  }

  // Handle token refresh
  void _handleTokenRefresh(String token) {
    print('FCM Token refreshed: $token');
    _saveFcmTokenToBackend(token);
  }

  // Save FCM token to backend
  Future<void> _saveFcmTokenToBackend(String? token) async {
    if (token == null) return;
    
    try {
      // TODO: Implement API call to save token
      print('FCM token saved to backend: $token');
    } catch (e) {
      print('Failed to save FCM token: $e');
    }
  }

  // Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      channelId: 'pet_support_channel',
      channelName: 'Pet Support Notifications',
      channelDescription: 'Notifications for pet care reminders and alerts',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      visibility: NotificationVisibility.public,
      autoCancel: false,
      ongoing: false,
      icon: '@mipmap/ic_launcher',
      largeIcon: '@mipmap/ic_launcher',
      styleInformation: StyleInformation(
        useStyle: true,
        style: AndroidNotificationStyle.BigText,
      ),
      progress: null,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      threadIdentifier: 'pet_support_thread',
      categoryIdentifier: 'pet_support_category',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      payload: payload,
    );

    await _flutterLocalNotificationsPlugin.show(
      notificationDetails,
    );
  }

  // Schedule notification
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    Map<String, dynamic>? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      channelId: 'pet_support_channel',
      channelName: 'Pet Support Notifications',
      channelDescription: 'Notifications for pet care reminders and alerts',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      largeIcon: '@mipmap/ic_launcher',
      styleInformation: StyleInformation(
        useStyle: true,
        style: AndroidNotificationStyle.BigText,
      ),
      allowWhileIdle: false,
      autoCancel: false,
      ongoing: false,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      threadIdentifier: 'pet_support_thread',
      categoryIdentifier: 'pet_support_category',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      id: scheduledTime.millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      payload: payload,
      scheduledDateTime: scheduledTime,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      notificationDetails,
      uiLocalNotificationDate: scheduledTime,
      matchDateTimeComponents: DateTimeComponents.time,
      exactScheduling: true,
      uiLocalNotificationDismissalDirection: UILocalNotificationDismissalDirection.forward,
    );
  }

  // Cancel notification
  Future<void> cancelNotification(int notificationId) async {
    await _flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  // Check notification permissions
  Future<bool> areNotificationsEnabled() async {
    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final iosPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final isEnabled = await androidPlugin.areNotificationsEnabled();
      return isEnabled ?? false;
    }

    if (iosPlugin != null) {
      final isEnabled = await iosPlugin.checkPermissions();
      return isEnabled ?? false;
    }

    return false;
  }

  // Show feeding reminder notification
  Future<void> showFeedingReminder({
    required String petName,
    required String foodType,
    required DateTime scheduledTime,
  }) async {
    await scheduleNotification(
      title: 'Feeding Reminder',
      body: 'Time to feed $petName with $foodType',
      scheduledTime: scheduledTime,
      payload: {
        'type': 'feeding_reminder',
        'petName': petName,
        'foodType': foodType,
      },
    );
  }

  // Show medication reminder notification
  Future<void> showMedicationReminder({
    required String petName,
    required String medicationName,
    required DateTime scheduledTime,
  }) async {
    await scheduleNotification(
      title: 'Medication Reminder',
      body: 'Time to give $medicationName to $petName',
      scheduledTime: scheduledTime,
      payload: {
        'type': 'medication_reminder',
        'petName': petName,
        'medicationName': medicationName,
      },
    );
  }

  // Show vet appointment notification
  Future<void> showVetAppointmentReminder({
    required String petName,
    required DateTime appointmentTime,
    required String clinicName,
  }) async {
    await scheduleNotification(
      title: 'Vet Appointment',
      body: 'Appointment for $petName at $clinicName',
      scheduledTime: appointmentTime,
      payload: {
        'type': 'vet_appointment',
        'petName': petName,
        'clinicName': clinicName,
        'appointmentTime': appointmentTime.toIso8601String(),
      },
    );
  }

  // Show emergency alert notification
  Future<void> showEmergencyAlert({
    required String petName,
    required String emergencyType,
    required Map<String, dynamic> recommendations,
  }) async {
    await showLocalNotification(
      title: '🚨 Emergency Alert',
      body: '$emergencyType for $petName - Immediate attention required',
      payload: {
        'type': 'emergency_alert',
        'petName': petName,
        'emergencyType': emergencyType,
        'recommendations': recommendations,
      },
    );
  }

  // Show care plan completion notification
  Future<void> showCarePlanCompleted({
    required String petName,
    required String planType,
    required String planTitle,
  }) async {
    await showLocalNotification(
      title: '✅ Care Plan Completed',
      body: '$planType care plan completed for $petName',
      payload: {
        'type': 'care_plan_completed',
        'petName': petName,
        'planType': planType,
        'planTitle': planTitle,
      },
    );
  }

  // Get notification channel
  String getNotificationChannel() {
    return 'pet_support_channel';
  }

  // Create notification channels for different types
  Future<void> createNotificationChannels() async {
    const feedingChannel = AndroidNotificationDetails(
      channelId: 'feeding_reminders',
      channelName: 'Feeding Reminders',
      channelDescription: 'Notifications for pet feeding schedules',
      importance: Importance.high,
      priority: Priority.high,
      sound: 'notification_sound',
    );

    const medicationChannel = AndroidNotificationDetails(
      channelId: 'medication_reminders',
      channelName: 'Medication Reminders',
      channelDescription: 'Notifications for pet medication schedules',
      importance: Importance.high,
      priority: Priority.high,
      sound: 'notification_sound',
    );

    const appointmentChannel = AndroidNotificationDetails(
      channelId: 'vet_appointments',
      channelName: 'Veterinary Appointments',
      channelDescription: 'Notifications for vet appointments',
      importance: Importance.high,
      priority: Priority.high,
      sound: 'notification_sound',
    );

    const emergencyChannel = AndroidNotificationDetails(
      channelId: 'emergency_alerts',
      channelName: 'Emergency Alerts',
      channelDescription: 'Emergency notifications for pet health',
      importance: Importance.max,
      priority: Priority.max,
      sound: 'emergency_sound',
    );

    await _flutterLocalNotificationsPlugin.createNotificationChannels([
      feedingChannel,
      medicationChannel,
      appointmentChannel,
      emergencyChannel,
    ]);
  }

  // Initialize notification channels
  Future<void> initializeNotificationChannels() async {
    if (!_isInitialized) {
      await initialize();
    }
    await createNotificationChannels();
  }
}