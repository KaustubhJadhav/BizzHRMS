import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Auth related
  static Future<bool> saveUserToken(String token) async {
    return await _prefs?.setString('user_token', token) ?? false;
  }

  static String? getUserToken() {
    return _prefs?.getString('user_token');
  }

  static Future<bool> saveUserId(String userId) async {
    return await _prefs?.setString('user_id', userId) ?? false;
  }

  static String? getUserId() {
    return _prefs?.getString('user_id');
  }

  static Future<bool> saveUsername(String username) async {
    return await _prefs?.setString('username', username) ?? false;
  }

  static String? getUsername() {
    return _prefs?.getString('username');
  }

  // Remember Me functionality
  static Future<bool> setRememberMe(bool value) async {
    return await _prefs?.setBool('remember_me', value) ?? false;
  }

  static bool getRememberMe() {
    return _prefs?.getBool('remember_me') ?? false;
  }

  static Future<bool> savePassword(String password) async {
    return await _prefs?.setString('saved_password', password) ?? false;
  }

  static String? getPassword() {
    return _prefs?.getString('saved_password');
  }

  static Future<bool> clearAll() async {
    return await _prefs?.clear() ?? false;
  }

  // Theme preferences
  static Future<bool> setDarkMode(bool value) async {
    return await _prefs?.setBool('dark_mode', value) ?? false;
  }

  static bool getDarkMode() {
    return _prefs?.getBool('dark_mode') ?? false;
  }

  // User role (admin/user)
  static Future<bool> saveUserRole(String role) async {
    return await _prefs?.setString('user_role', role) ?? false;
  }

  static String? getUserRole() {
    return _prefs?.getString('user_role');
  }

  static bool isAdmin() {
    final role = getUserRole();
    return role != null && role.toLowerCase() == 'admin';
  }
}
