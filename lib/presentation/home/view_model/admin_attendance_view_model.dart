import 'package:flutter/foundation.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';
import 'package:bizzhrms_flutter_app/data/data_sources/remote_data_source.dart';

class AdminAttendanceViewModel extends ChangeNotifier {
  final RemoteDataSource _remoteDataSource = RemoteDataSource();
  
  Map<String, dynamic> _dashboardData = {};
  Map<String, dynamic> _attendanceSummary = {};
  List<Map<String, dynamic>> _attendanceList = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedDate;
  bool _isDisposed = false;

  Map<String, dynamic> get dashboardData => _dashboardData;
  Map<String, dynamic> get attendanceSummary => _attendanceSummary;
  List<Map<String, dynamic>> get attendanceList => _attendanceList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedDate => _selectedDate;

  /// Load admin dashboard data
  Future<void> loadDashboard({String? date}) async {
    _isLoading = true;
    _errorMessage = null;
    
    // Update selected date immediately if provided
    if (date != null && date.isNotEmpty) {
      _selectedDate = date;
    }
    
    notifyListeners();

    try {
      final token = await PreferencesHelper.getUserToken();
      
      if (token == null || token.isEmpty) {
        _isLoading = false;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return;
      }

      print('=== LOADING ADMIN DASHBOARD ===');
      if (date != null) {
        print('Date: $date');
      }
      print('');

      final response = await _remoteDataSource.getAdminDashboard(token, date: date);

      // Check if view model is still active before updating state
      if (!_isDisposed) {
        if (response['status'] == true) {
          _dashboardData = response;
          // Use the date from response (attendance_date), or the date we sent, or keep current if neither available
          final responseDate = response['attendance_date']?.toString();
          if (responseDate != null && responseDate.isNotEmpty && responseDate != 'null') {
            _selectedDate = responseDate;
          } else if (date != null && date.isNotEmpty) {
            _selectedDate = date;
          }
          // If neither is available, keep the current _selectedDate
          
          // Extract attendance summary
          if (response['attendance'] != null && 
              response['attendance'] is Map<String, dynamic>) {
            final attendance = response['attendance'] as Map<String, dynamic>;
            _attendanceSummary = attendance['summary'] ?? {};
          }
          
          // Extract time_status array (employee attendance details)
          if (response['time_status'] != null && response['time_status'] is List) {
            _attendanceList = List<Map<String, dynamic>>.from(
              response['time_status'] ?? [],
            );
          } else {
            _attendanceList = [];
          }

          _isLoading = false;
          _errorMessage = null;
          notifyListeners();
        } else {
          _isLoading = false;
          _errorMessage = response['message']?.toString() ?? 'Failed to load dashboard';
          notifyListeners();
        }
      }
    } catch (e) {
      // Check if view model is still active before updating state
      if (!_isDisposed) {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        notifyListeners();
      }
    }
  }

  /// Get attendance statistics for display
  Map<String, int> getAttendanceStats() {
    return {
      'total': _attendanceSummary['total_employees'] ?? 0,
      'present': _attendanceSummary['present'] ?? 0,
      'absent': _attendanceSummary['absent'] ?? 0,
      'halfDay': _attendanceSummary['half_day'] ?? 0,
      'lateComers': 0, // Not available in new API response
      'holiday': _attendanceSummary['holiday'] ?? 0,
      'onBreak': 0, // Not available in API
      'onLeave': _attendanceSummary['on_leave'] ?? 0,
      'weeklyOff': _attendanceSummary['weekly_off'] ?? 0,
    };
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

