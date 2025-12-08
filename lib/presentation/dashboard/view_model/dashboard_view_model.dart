import 'package:flutter/foundation.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';
import 'package:bizzhrms_flutter_app/data/data_sources/remote_data_source.dart';
import 'package:intl/intl.dart';

enum DashboardStatus { initial, loading, success, error }

class DashboardViewModel extends ChangeNotifier {
  DashboardStatus _status = DashboardStatus.initial;
  String? _errorMessage;
  Map<String, dynamic>? _dashboardData;
  final RemoteDataSource _remoteDataSource = RemoteDataSource();

  DashboardStatus get status => _status;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get dashboardData => _dashboardData;

  Future<void> loadDashboardData() async {
    _status = DashboardStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token and user_id from preferences
      final token = await PreferencesHelper.getUserToken();
      final userId = await PreferencesHelper.getUserId();

      if (token == null || token.isEmpty || userId == null || userId.isEmpty) {
        _status = DashboardStatus.error;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return;
      }

      // Fetch user info from API
      final response = await _remoteDataSource.getUserInfo(token, userId);

      if (response['status'] == true && response['data'] != null) {
        final userData = response['data'] as Map<String, dynamic>;
        
        // Debug: Print all keys to see what's available
        debugPrint('=== DASHBOARD API RESPONSE DEBUG ===');
        debugPrint('All API Keys: ${userData.keys.toList()}');
        debugPrint('');
        debugPrint('=== LAST LOGIN DATE COMPARISON ===');
        debugPrint('last_login_date (raw): ${userData['last_login_date']}');
        debugPrint('last_login_date type: ${userData['last_login_date']?.runtimeType}');
        debugPrint('last_logout_date (raw): ${userData['last_logout_date']}');
        debugPrint('last_logout_date type: ${userData['last_logout_date']?.runtimeType}');
        debugPrint('');
        
        // Format date of birth
        String formattedDob = 'N/A';
        if (userData['date_of_birth'] != null && userData['date_of_birth'].toString().isNotEmpty) {
          try {
            final dobDate = DateTime.parse(userData['date_of_birth']);
            formattedDob = DateFormat('dd-MMM-yyyy').format(dobDate);
          } catch (e) {
            formattedDob = userData['date_of_birth'].toString();
          }
        }

        // Format last login date - MUST use API value, never current time
        String formattedLastLogin = 'N/A';
        
        // Compare both date fields from API
        final lastLoginDate = userData['last_login_date'];
        final lastLogoutDate = userData['last_logout_date'];
        
        debugPrint('=== COMPARING BOTH DATE FIELDS ===');
        debugPrint('last_login_date: $lastLoginDate');
        debugPrint('last_logout_date: $lastLogoutDate');
        debugPrint('');
        
        // Use last_login_date (this is the actual last login time)
        final lastLoginValue = lastLoginDate;
        
        debugPrint('Using last_login_date field: $lastLoginValue');
        
        if (lastLoginValue != null && 
            lastLoginValue.toString().isNotEmpty &&
            lastLoginValue.toString().toLowerCase() != 'null' &&
            lastLoginValue.toString().trim().isNotEmpty) {
          try {
            // Format: "10-11-2025 17:54:17" (dd-MM-yyyy HH:mm:ss)
            final lastLoginStr = lastLoginValue.toString().trim();
            debugPrint('Parsing last login string: "$lastLoginStr"');
            
            if (lastLoginStr.isNotEmpty) {
              final parts = lastLoginStr.split(' ');
              debugPrint('Split by space: $parts');
              
              if (parts.length >= 2) {
                final dateParts = parts[0].split('-');
                final timeParts = parts[1].split(':');
                debugPrint('Date parts: $dateParts');
                debugPrint('Time parts: $timeParts');
                
                if (dateParts.length == 3 && timeParts.length >= 2) {
                  final year = int.parse(dateParts[2]);
                  final month = int.parse(dateParts[1]);
                  final day = int.parse(dateParts[0]);
                  final hour = timeParts.length >= 1 ? int.parse(timeParts[0]) : 0;
                  final minute = timeParts.length >= 2 ? int.parse(timeParts[1]) : 0;
                  final second = timeParts.length >= 3 ? int.parse(timeParts[2]) : 0;
                  
                  debugPrint('Parsed values: year=$year, month=$month, day=$day, hour=$hour, minute=$minute, second=$second');
                  
                  final date = DateTime(year, month, day, hour, minute, second);
                  formattedLastLogin = DateFormat('dd-MMM-yyyy hh:mm a').format(date);
                  debugPrint('✅ Formatted last login: "$formattedLastLogin"');
                } else {
                  // Fallback: show raw value if format doesn't match
                  formattedLastLogin = lastLoginStr;
                  debugPrint('❌ Format mismatch, using raw: "$formattedLastLogin"');
                }
              } else {
                // Fallback: show raw value if no space separator
                formattedLastLogin = lastLoginStr;
                debugPrint('❌ No space separator, using raw: "$formattedLastLogin"');
              }
            }
          } catch (e) {
            // If parsing fails, show the raw value
            formattedLastLogin = lastLoginValue.toString();
            debugPrint('❌ Parsing error: $e, using raw: "$formattedLastLogin"');
          }
        } else {
          debugPrint('❌ last_login_date is null/empty, showing N/A');
        }
        
        debugPrint('');
        debugPrint('=== FINAL RESULT ===');
        debugPrint('Final formattedLastLogin: "$formattedLastLogin"');
        debugPrint('================================');

        // Build profile picture URL
        String avatarUrl = '';
        if (userData['profile_picture'] != null && userData['profile_picture'].toString().isNotEmpty) {
          avatarUrl = 'https://arena.creativecrows.co.in/uploads/profile/${userData['profile_picture']}';
        }

        // Map API response to dashboard format
        _dashboardData = {
    'userInfo': {
            'name': '${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}'.trim(),
            'employeeId': userData['employee_id'] ?? 'N/A',
            'username': userData['username'] ?? 'N/A',
            'email': userData['email'] ?? '',
            'designation': userData['designation_id']?.toString() ?? '',
            'dob': formattedDob,
            'contact': userData['contact_no'] ?? 'N/A',
            'lastLogin': formattedLastLogin,
            'avatarUrl': avatarUrl,
            'status': userData['is_logged_in'] == '1' ? 'online' : 'offline',
    },
    'projects': [],
    'tasks': [],
    'attendance': {
            'month': DateFormat('MMMM').format(DateTime.now()),
      'total': 0,
            'days': DateTime.now().day,
            'today': _getTodayStatus(),
    },
    'awards': {
      'total': 0,
    },
    'announcements': [],
    'myAwards': [],
  };

    _status = DashboardStatus.success;
    notifyListeners();
      } else {
        _status = DashboardStatus.error;
        _errorMessage = response['message']?.toString() ?? 'Failed to load dashboard data';
        notifyListeners();
      }
    } catch (e) {
      _status = DashboardStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  String _getTodayStatus() {
    final now = DateTime.now();
    final weekday = now.weekday;
    if (weekday == DateTime.friday) {
      return 'Friday - Holiday';
    } else if (weekday == DateTime.saturday) {
      return 'Saturday - Holiday';
    } else if (weekday == DateTime.sunday) {
      return 'Sunday - Holiday';
    } else {
      return 'Working Day';
    }
  }

  void refresh() {
    loadDashboardData();
  }
}
