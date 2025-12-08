import 'package:flutter/foundation.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';
import 'package:bizzhrms_flutter_app/data/data_sources/remote_data_source.dart';

enum AdminLeaveStatus { initial, loading, success, error }

class AdminLeaveViewModel extends ChangeNotifier {
  AdminLeaveStatus _status = AdminLeaveStatus.initial;
  String? _errorMessage;
  final RemoteDataSource _remoteDataSource = RemoteDataSource();
  bool _isDisposed = false;

  AdminLeaveStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _leavesList = [];
  List<Map<String, dynamic>> _employeesList = [];

  List<Map<String, dynamic>> get leavesList => _leavesList;
  List<Map<String, dynamic>> get employeesList => _employeesList;

  // Leave types mapping (can be updated if API provides this)
  final Map<String, String> leaveTypes = {
    '1': 'Casual Leave',
    '2': 'Medical Leave',
  };

  Future<void> loadLeaves() async {
    if (_isDisposed) return;

    _status = AdminLeaveStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await PreferencesHelper.getUserToken();

      if (token == null || token.isEmpty) {
        if (_isDisposed) return;
        _status = AdminLeaveStatus.error;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return;
      }

      final response = await _remoteDataSource.getAdminLeaveList(token);

      if (_isDisposed) return;

      print('=== ADMIN LEAVE LIST RESPONSE (VIEW MODEL) ===');
      print('Response: $response');
      print('Response type: ${response.runtimeType}');
      print('Response keys: ${response.keys.toList()}');
      print('Has status key: ${response.containsKey('status')}');
      if (response.containsKey('status')) {
        final statusValue = response['status'];
        print('Status value: $statusValue (type: ${statusValue.runtimeType})');
      }
      print('Has data key: ${response.containsKey('data')}');
      if (response.containsKey('data')) {
        final dataValue = response['data'];
        print('Data value: $dataValue (type: ${dataValue.runtimeType})');
        if (dataValue is List) {
          print('Data is List with ${dataValue.length} items');
        }
      }
      print('');

      // Handle different response formats
      final statusValue = response['status'];
      // Check for both boolean true and string "true"
      final bool isSuccess = statusValue == true ||
          statusValue == 'true' ||
          statusValue == 1 ||
          statusValue == '1';

      if (isSuccess) {
        dynamic data = response['data'];

        print('Status is success, processing data...');
        print('Data: $data');
        print('Data type: ${data.runtimeType}');

        // If data is null, check if leaves are directly in the response
        if (data == null) {
          if (response.containsKey('leaves') && response['leaves'] is List) {
            data = response['leaves'];
            print('Found data in "leaves" key');
          } else if (response.containsKey('leave_list') &&
              response['leave_list'] is List) {
            data = response['leave_list'];
            print('Found data in "leave_list" key');
          }
        }

        if (data != null) {
          if (data is List) {
            _leavesList = data.cast<Map<String, dynamic>>();
            print('✓ Loaded ${_leavesList.length} leaves');
            if (_leavesList.isNotEmpty) {
              print('First leave: ${_leavesList[0]}');
            }
          } else if (data is Map &&
              data.containsKey('leaves') &&
              data['leaves'] is List) {
            _leavesList = (data['leaves'] as List).cast<Map<String, dynamic>>();
            print(
                '✓ Loaded ${_leavesList.length} leaves from nested structure');
          } else {
            _leavesList = [];
            print(
                '✗ Data is not a list, setting empty list. Data type: ${data.runtimeType}');
          }
        } else {
          _leavesList = [];
          print('✗ Data is null, setting empty list');
        }

        _status = AdminLeaveStatus.success;
        notifyListeners();
      } else {
        _status = AdminLeaveStatus.error;
        _errorMessage =
            response['message']?.toString() ?? 'Failed to load leave list';
        print('✗ Error: $_errorMessage');
        print('Status value was: ${response['status']}');
        notifyListeners();
      }
    } catch (e) {
      if (_isDisposed) return;
      _status = AdminLeaveStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      print('=== ADMIN LEAVE LIST ERROR ===');
      print('Error: $e');
      print('Error type: ${e.runtimeType}');
      print('');
      notifyListeners();
    }
  }

  Future<void> loadEmployees() async {
    try {
      final token = await PreferencesHelper.getUserToken();

      if (token == null || token.isEmpty) {
        return;
      }

      final response = await _remoteDataSource.getAdminEmployees(token);

      if (_isDisposed) return;

      if (response['status'] == true && response['data'] != null) {
        final data = response['data'];
        if (data is List) {
          _employeesList = data.cast<Map<String, dynamic>>();
        } else {
          _employeesList = [];
        }
        notifyListeners();
      }
    } catch (e) {
      // Silently fail for employees, as it's not critical
      if (kDebugMode) {
        print('Failed to load employees: $e');
      }
    }
  }

  Future<bool> addLeave({
    required String employeeId,
    required String leaveType,
    required String startDate,
    required String endDate,
    required String reason,
    String? remarks,
  }) async {
    if (_isDisposed) return false;

    _status = AdminLeaveStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await PreferencesHelper.getUserToken();

      if (token == null || token.isEmpty) {
        if (_isDisposed) return false;
        _status = AdminLeaveStatus.error;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return false;
      }

      final response = await _remoteDataSource.addAdminLeave(
        token,
        employeeId: employeeId,
        leaveType: leaveType,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
        remarks: remarks,
      );

      if (_isDisposed) return false;

      if (response['status'] == true) {
        // Reload the leave list
        await loadLeaves();
        return true;
      } else {
        _status = AdminLeaveStatus.error;
        _errorMessage =
            response['message']?.toString() ?? 'Failed to add leave';
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (_isDisposed) return false;
      _status = AdminLeaveStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateLeave({
    required String leaveId,
    required String employeeId,
    required String leaveType,
    required String startDate,
    required String endDate,
    required String reason,
    String? remarks,
  }) async {
    if (_isDisposed) return false;

    _status = AdminLeaveStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await PreferencesHelper.getUserToken();

      if (token == null || token.isEmpty) {
        if (_isDisposed) return false;
        _status = AdminLeaveStatus.error;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return false;
      }

      final response = await _remoteDataSource.updateAdminLeave(
        token,
        leaveId: leaveId,
        employeeId: employeeId,
        leaveType: leaveType,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
        remarks: remarks,
      );

      if (_isDisposed) return false;

      if (response['status'] == true) {
        // Reload the leave list
        await loadLeaves();
        return true;
      } else {
        _status = AdminLeaveStatus.error;
        _errorMessage =
            response['message']?.toString() ?? 'Failed to update leave';
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (_isDisposed) return false;
      _status = AdminLeaveStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteLeave(String leaveId) async {
    if (_isDisposed) return false;

    _status = AdminLeaveStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await PreferencesHelper.getUserToken();

      if (token == null || token.isEmpty) {
        if (_isDisposed) return false;
        _status = AdminLeaveStatus.error;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return false;
      }

      final response = await _remoteDataSource.deleteAdminLeave(
        token,
        leaveId: leaveId,
      );

      if (_isDisposed) return false;

      if (response['status'] == true) {
        // Reload the leave list
        await loadLeaves();
        return true;
      } else {
        _status = AdminLeaveStatus.error;
        _errorMessage =
            response['message']?.toString() ?? 'Failed to delete leave';
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (_isDisposed) return false;
      _status = AdminLeaveStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateLeaveStatus({
    required String leaveId,
    required String employeeId,
    required int status,
  }) async {
    if (_isDisposed) return false;

    _status = AdminLeaveStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await PreferencesHelper.getUserToken();

      if (token == null || token.isEmpty) {
        if (_isDisposed) return false;
        _status = AdminLeaveStatus.error;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return false;
      }

      final response = await _remoteDataSource.updateAdminLeaveStatus(
        token,
        leaveId: leaveId,
        employeeId: employeeId,
        status: status,
      );

      if (_isDisposed) return false;

      if (response['status'] == true) {
        // Reload the leave list
        await loadLeaves();
        return true;
      } else {
        _status = AdminLeaveStatus.error;
        _errorMessage =
            response['message']?.toString() ?? 'Failed to update leave status';
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (_isDisposed) return false;
      _status = AdminLeaveStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void refresh() {
    loadLeaves();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
