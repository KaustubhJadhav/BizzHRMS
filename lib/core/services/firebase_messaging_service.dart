import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';
import 'package:bizzhrms_flutter_app/data/data_sources/remote_data_source.dart';

/// Top-level function for handling background messages
/// This must be a top-level function, not a class method
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('=== BACKGROUND MESSAGE RECEIVED ===');
  print('Message ID: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
  print('');
}

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final RemoteDataSource _remoteDataSource = RemoteDataSource();
  
  String? _fcmToken;
  StreamSubscription<String>? _tokenSubscription;

  String? get fcmToken => _fcmToken;

  /// Initialize Firebase Messaging
  Future<void> initialize() async {
    try {
      // Request notification permissions
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      print('=== FCM PERMISSION STATUS ===');
      print('Authorization Status: ${settings.authorizationStatus}');
      print('');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Initialize local notifications for Android
        await _initializeLocalNotifications();

        // Set up message handlers
        _setupMessageHandlers();

        // Get and save FCM token
        await _getFCMToken();

        // Listen for token refresh
        _tokenSubscription = _firebaseMessaging.onTokenRefresh.listen(
          (newToken) {
            print('=== FCM TOKEN REFRESHED ===');
            print('New Token: $newToken');
            _fcmToken = newToken;
            _saveTokenToBackend(newToken);
          },
        );
      } else {
        print('User declined or has not accepted notification permissions');
      }
    } catch (e) {
      print('=== FCM INITIALIZATION ERROR ===');
      print('Error: $e');
      print('');
    }
  }

  /// Initialize local notifications for Android
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('=== LOCAL NOTIFICATION TAPPED ===');
        print('Payload: ${response.payload}');
        print('');
      },
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'hrms_notifications', // id
      'HRMS Notifications', // name
      description: 'Notifications for clock in/out and other HRMS updates',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Set up message handlers
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('=== FOREGROUND MESSAGE RECEIVED ===');
      print('Message ID: ${message.messageId}');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
      print('');

      // Show local notification when app is in foreground
      _showLocalNotification(message);
    });

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('=== NOTIFICATION TAPPED (APP IN BACKGROUND) ===');
      print('Message ID: ${message.messageId}');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
      print('');
    });

    // Check if app was opened from a terminated state via notification
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('=== APP OPENED FROM TERMINATED STATE ===');
        print('Message ID: ${message.messageId}');
        print('Title: ${message.notification?.title}');
        print('Body: ${message.notification?.body}');
        print('Data: ${message.data}');
        print('');
      }
    });
  }

  /// Get FCM token
  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      print('=== FCM TOKEN OBTAINED ===');
      print('Token: $_fcmToken');
      print('');

      if (_fcmToken != null) {
        // Save token to backend
        await _saveTokenToBackend(_fcmToken!);
      }
    } catch (e) {
      print('=== FCM TOKEN ERROR ===');
      print('Error: $e');
      print('');
    }
  }

  /// Save FCM token to backend
  Future<void> _saveTokenToBackend(String token) async {
    try {
      final userToken = await PreferencesHelper.getUserToken();
      final userId = await PreferencesHelper.getUserId();

      if (userToken == null || userToken.isEmpty || userId == null || userId.isEmpty) {
        print('=== FCM TOKEN SAVE SKIPPED ===');
        print('User not authenticated yet');
        print('');
        return;
      }

      print('=== SAVING FCM TOKEN TO BACKEND ===');
      print('User ID: $userId');
      print('FCM Token: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
      print('');

      await _remoteDataSource.saveFCMToken(userToken, userId, token);
      
      print('=== FCM TOKEN SAVED SUCCESSFULLY ===');
      print('');
    } catch (e) {
      print('=== FCM TOKEN SAVE ERROR ===');
      print('Error: $e');
      print('');
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'hrms_notifications',
      'HRMS Notifications',
      channelDescription: 'Notifications for clock in/out and other HRMS updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'HRMS Notification',
      message.notification?.body ?? '',
      notificationDetails,
      payload: message.data.toString(),
    );
  }

  /// Manually save token to backend (call after login)
  Future<void> saveTokenAfterLogin() async {
    if (_fcmToken != null) {
      await _saveTokenToBackend(_fcmToken!);
    } else {
      await _getFCMToken();
    }
  }

  /// Dispose resources
  void dispose() {
    _tokenSubscription?.cancel();
  }
}

