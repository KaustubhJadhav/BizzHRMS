import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Firebase imports - TEMPORARILY DISABLED
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'config/theme/app_theme.dart';
import 'core/utils/preferences_helper.dart';
import 'core/constants/app_constants.dart';
import 'config/routes/route_generator.dart';
// import 'core/services/firebase_messaging_service.dart';

// Background message handler (must be top-level) - TEMPORARILY DISABLED
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await firebaseMessagingBackgroundHandler(message);
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase - TEMPORARILY DISABLED
  // try {
  //   await Firebase.initializeApp();
  //   print('=== FIREBASE INITIALIZED ===');
  //   
  //   // Set up background message handler
  //   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  //   
  //   // Initialize Firebase Messaging Service
  //   await FirebaseMessagingService().initialize();
  //   print('=== FIREBASE MESSAGING INITIALIZED ===');
  // } catch (e) {
  //   print('=== FIREBASE INITIALIZATION ERROR ===');
  //   print('Error: $e');
  //   print('Note: Make sure google-services.json is added to android/app/');
  // }

  // Configure system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Transparent status bar
      statusBarIconBrightness:
          Brightness.light, // Light icons for dark status bar
      statusBarBrightness: Brightness.dark, // Dark status bar content
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  // Hide system navigation bar and orientation indicator
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top],
  );

  // Initialize preferences helper
  await PreferencesHelper.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BizzHRMS - HR Management System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Check authentication state and set initial route
      initialRoute: _getInitialRoute(),
      // Use custom route generator for snappy but smooth transitions
      onGenerateRoute: RouteGenerator.generateRoute,
      // Performance optimizations
      builder: (context, child) {
        return MediaQuery(
          // Optimize keyboard and text rendering
          data: MediaQuery.of(context).copyWith(
            textScaler:
                const TextScaler.linear(1.0), // Consistent text rendering
            viewInsets:
                MediaQuery.of(context).viewInsets, // Proper keyboard insets
          ),
          child: child!,
        );
      },
    );
  }

  /// Check if user is authenticated and return appropriate initial route
  /// Always start with splash screen
  String _getInitialRoute() {
    return AppConstants.routeSplash;
  }
}
