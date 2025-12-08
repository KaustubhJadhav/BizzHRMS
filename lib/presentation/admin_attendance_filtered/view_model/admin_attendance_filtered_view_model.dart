import 'package:flutter/foundation.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';
import 'package:bizzhrms_flutter_app/data/data_sources/remote_data_source.dart';

enum AdminAttendanceFilteredStatus { initial, loading, success, error }

class AdminAttendanceFilteredViewModel extends ChangeNotifier {
  AdminAttendanceFilteredStatus _status = AdminAttendanceFilteredStatus.initial;
  String? _errorMessage;
  final RemoteDataSource _remoteDataSource = RemoteDataSource();

  AdminAttendanceFilteredStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _employeesList = [];
  int _total = 0;
  String? _selectedDate;
  String? _selectedStatus;
  
  List<Map<String, dynamic>> get employeesList => _employeesList;
  int get total => _total;
  String? get selectedDate => _selectedDate;
  String? get selectedStatus => _selectedStatus;

  Future<void> loadFilteredEmployees({
    required String statusTime,
    required String date,
  }) async {
    _status = AdminAttendanceFilteredStatus.loading;
    _errorMessage = null;
    _selectedStatus = statusTime;
    _selectedDate = date;
    notifyListeners();

    try {
      final token = await PreferencesHelper.getUserToken();

      if (token == null || token.isEmpty) {
        _status = AdminAttendanceFilteredStatus.error;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return;
      }

      final response = await _remoteDataSource.getAdminAttendanceFilteredEmployees(
        token,
        statusTime: statusTime,
        date: date,
      );

      if (response['status'] == true && response['employees'] != null) {
        final data = response['employees'];
        if (data is List) {
          _employeesList = data.cast<Map<String, dynamic>>();
          _total = response['total'] ?? _employeesList.length;
        } else {
          _employeesList = [];
          _total = 0;
        }
        
        _status = AdminAttendanceFilteredStatus.success;
        notifyListeners();
      } else {
        _status = AdminAttendanceFilteredStatus.error;
        _errorMessage = response['message']?.toString() ?? 'Failed to load employees';
        notifyListeners();
      }
    } catch (e) {
      _status = AdminAttendanceFilteredStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void refresh() {
    if (_selectedStatus != null && _selectedDate != null) {
      loadFilteredEmployees(
        statusTime: _selectedStatus!,
        date: _selectedDate!,
      );
    }
  }
}

