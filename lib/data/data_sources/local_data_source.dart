import 'base_data_source.dart';
import '../../core/utils/preferences_helper.dart';

// Local data source for caching and offline storage
class LocalDataSource extends BaseDataSource {
  // Methods for local storage
  // Will be implemented as needed
  
  Future<void> cacheUserData(Map<String, dynamic> userData) async {
    // Cache user data to preferences
    if (userData['token'] != null) {
      await PreferencesHelper.saveUserToken(userData['token']);
    }
    if (userData['userId'] != null) {
      await PreferencesHelper.saveUserId(userData['userId']);
    }
    if (userData['username'] != null) {
      await PreferencesHelper.saveUsername(userData['username']);
    }
  }

  Future<Map<String, dynamic>?> getCachedUserData() async {
    // Get cached user data from preferences
    return {
      'token': PreferencesHelper.getUserToken(),
      'userId': PreferencesHelper.getUserId(),
      'username': PreferencesHelper.getUsername(),
    };
  }
}

