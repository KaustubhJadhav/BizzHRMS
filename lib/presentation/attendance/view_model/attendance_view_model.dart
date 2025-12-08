import 'package:flutter/foundation.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';
import 'package:bizzhrms_flutter_app/data/data_sources/remote_data_source.dart';

enum AttendanceStatus { initial, loading, success, error }

class AttendanceViewModel extends ChangeNotifier {
  AttendanceStatus _status = AttendanceStatus.initial;
  String? _errorMessage;
  final RemoteDataSource _remoteDataSource = RemoteDataSource();

  // Attendance data
  Map<String, dynamic>? _employeeData;
  Map<String, dynamic>? _lastAttendance;
  Map<String, dynamic>? _monthlySummary;
  List<Map<String, dynamic>> _attendanceList = [];
  int? _month;
  int? _year;

  AttendanceStatus get status => _status;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get employeeData => _employeeData;
  Map<String, dynamic>? get lastAttendance => _lastAttendance;
  Map<String, dynamic>? get monthlySummary => _monthlySummary;
  List<Map<String, dynamic>> get attendanceList => _attendanceList;
  int? get month => _month;
  int? get year => _year;

  Future<void> loadAttendanceData({int? month, int? year}) async {
    _status = AttendanceStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token and user_id from preferences
      final token = await PreferencesHelper.getUserToken();
      final userId = await PreferencesHelper.getUserId();

      if (token == null || token.isEmpty || userId == null || userId.isEmpty) {
        _status = AttendanceStatus.error;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return;
      }

      // Use provided month/year or current month/year
      final now = DateTime.now();
      final targetMonth = month ?? now.month;
      final targetYear = year ?? now.year;

      // Fetch attendance summary from API
      final response = await _remoteDataSource.getAttendance(
        token,
        userId,
        targetMonth,
        targetYear,
      );

      // Fetch month attendance list
      final monthResponse = await _remoteDataSource.getMonthAttendance(
        token,
        userId,
        targetMonth,
        targetYear,
      );

      if (response['status'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        _employeeData = data['employee'] as Map<String, dynamic>?;
        _lastAttendance = data['attendance_last'] as Map<String, dynamic>?;
        _monthlySummary = data['monthly_summary'] as Map<String, dynamic>?;
        _month = int.tryParse(data['month']?.toString() ?? '');
        _year = int.tryParse(data['year']?.toString() ?? '');
      }

      // Process month attendance list and generate all days
      if (monthResponse['status'] == true && monthResponse['data'] != null) {
        final monthData = monthResponse['data'];
        List<Map<String, dynamic>> apiRecords = [];
        if (monthData is List) {
          apiRecords = monthData.cast<Map<String, dynamic>>();
        }
        
        // Generate all days of the month
        _attendanceList = _generateAllDaysOfMonth(
          targetYear,
          targetMonth,
          apiRecords,
        );
      } else {
        // Even if API fails, generate all days
        _attendanceList = _generateAllDaysOfMonth(
          targetYear,
          targetMonth,
          [],
        );
      }
        
      _status = AttendanceStatus.success;
      notifyListeners();
    } catch (e) {
      _status = AttendanceStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void refresh() {
    loadAttendanceData();
  }

  /// Generate all days of the month and merge with API data
  /// Days not in API response are marked as holidays or absent
  /// Shows days up to and including today
  List<Map<String, dynamic>> _generateAllDaysOfMonth(
    int year,
    int month,
    List<Map<String, dynamic>> apiRecords,
  ) {
    // Create a map of API records by date for quick lookup
    final Map<String, Map<String, dynamic>> apiRecordsMap = {};
    for (var record in apiRecords) {
      final date = record['date']?.toString();
      if (date != null && date.isNotEmpty) {
        apiRecordsMap[date] = record;
      }
    }

    // Get last day of the month
    final lastDay = DateTime(year, month + 1, 0);
    
    // Get today's date (normalized to start of day for comparison)
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    
    // Check if we're viewing the current month
    final isCurrentMonth = year == today.year && month == today.month;

    // Generate list of all days
    List<Map<String, dynamic>> allDays = [];
    
    for (int day = 1; day <= lastDay.day; day++) {
      final currentDate = DateTime(year, month, day);
      
      // If viewing current month, skip only future dates (include today)
      // If viewing past month, show all days
      if (isCurrentMonth && currentDate.isAfter(todayNormalized)) {
        continue;
      }
      
      final dateString = '${year}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
      
      // Check if we have API data for this date
      if (apiRecordsMap.containsKey(dateString)) {
        // Use API data
        allDays.add(apiRecordsMap[dateString]!);
      } else {
        // No API data - determine if it's a weekend or mark as holiday/absent
        final isWeekend = currentDate.weekday == DateTime.saturday || currentDate.weekday == DateTime.sunday;
        
        allDays.add({
          'date': dateString,
          'status': isWeekend ? 'Weekend' : 'Holiday', // You can change this logic
          'total_work': '00:00',
          'total_rest': '00:00',
          'clock_in': null,
          'clock_out': null,
          'logs': [],
        });
      }
    }

    // Sort by date to ensure chronological order
    allDays.sort((a, b) {
      final dateA = a['date']?.toString() ?? '';
      final dateB = b['date']?.toString() ?? '';
      return dateA.compareTo(dateB);
    });

    return allDays;
  }
}
