import 'package:flutter/foundation.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';
// Firebase Messaging Service - TEMPORARILY DISABLED
// import 'package:bizzhrms_flutter_app/core/services/firebase_messaging_service.dart';
import 'package:bizzhrms_flutter_app/data/data_sources/remote_data_source.dart';
import '../models/auth_model.dart';

enum AuthStatus { initial, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  AuthModel? _authModel;
  final RemoteDataSource _remoteDataSource = RemoteDataSource();

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  AuthModel? get authModel => _authModel;

  Future<bool> signIn(String username, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Call actual login API
      final response = await _remoteDataSource.login(username, password);

      // Check if login was successful
      if (response['status'] == true) {
        _authModel = AuthModel(
          username: username,
          password: password,
          email: response['email'] ?? '',
          token: response['token'] ?? '',
          userId: response['user_id']?.toString() ?? '',
        );

      // Save to preferences
        if (_authModel!.token != null && _authModel!.token!.isNotEmpty) {
        await PreferencesHelper.saveUserToken(_authModel!.token!);
      }
        if (_authModel!.userId != null && _authModel!.userId!.isNotEmpty) {
        await PreferencesHelper.saveUserId(_authModel!.userId!);
      }
        if (_authModel!.username != null && _authModel!.username!.isNotEmpty) {
        await PreferencesHelper.saveUsername(_authModel!.username!);
      }

      // Save FCM token to backend after successful login - TEMPORARILY DISABLED
      // try {
      //   await FirebaseMessagingService().saveTokenAfterLogin();
      // } catch (e) {
      //   debugPrint('FCM token save error: $e');
      //   // Don't fail login if FCM token save fails
      // }

      _status = AuthStatus.success;
      notifyListeners();
      return true;
      } else {
        _status = AuthStatus.error;
        _errorMessage = response['message']?.toString().replaceAll(RegExp(r'<[^>]*>'), '') ?? 'Login failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> logout() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await PreferencesHelper.getUserToken();
      
      debugPrint('=== LOGOUT API CALL ===');
      debugPrint('Token available: ${token != null && token.isNotEmpty}');
      
      if (token != null && token.isNotEmpty) {
        try {
          final response = await _remoteDataSource.logout(token);
          debugPrint('Logout API Response: $response');
          
          if (response['status'] == true) {
            debugPrint('✅ Logout successful from API');
          } else {
            debugPrint('⚠️ Logout API returned status: false');
          }
        } catch (e) {
          debugPrint('❌ Logout API error: $e');
          // Continue to clear local data even if API fails
        }
      } else {
        debugPrint('⚠️ No token available, skipping API call');
      }
      
      // Always clear preferences and reset state, even if API fails
      await PreferencesHelper.clearAll();
      debugPrint('✅ Local data cleared');
      
      // Reset state
      _status = AuthStatus.initial;
      _errorMessage = null;
      _authModel = null;
      notifyListeners();
      
      debugPrint('✅ Logout completed successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      // Even if logout API fails, clear local data
      await PreferencesHelper.clearAll();
      _status = AuthStatus.initial;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _authModel = null;
      notifyListeners();
      return false;
    }
  }

  Future<bool> quickLogin(
      String username, String email, String password) async {
    return await signIn(username, password);
  }

  void reset() {
    _status = AuthStatus.initial;
    _errorMessage = null;
    _authModel = null;
    notifyListeners();
  }
}
