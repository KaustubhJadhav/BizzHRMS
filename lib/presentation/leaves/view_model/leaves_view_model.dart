import 'package:flutter/foundation.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';
import 'package:bizzhrms_flutter_app/data/data_sources/remote_data_source.dart';

enum LeavesStatus { initial, loading, success, error }

class LeavesViewModel extends ChangeNotifier {
  LeavesStatus _status = LeavesStatus.initial;
  String? _errorMessage;
  final RemoteDataSource _remoteDataSource = RemoteDataSource();

  LeavesStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _leavesList = [];
  List<Map<String, dynamic>> get leavesList => _leavesList;

  Map<String, dynamic> _leaveStats = {
    'totalCasualLeave': 15,
    'approvedCasualLeave': 0,
    'totalMedicalLeave': 20,
    'approvedMedicalLeave': 0,
  };
  Map<String, dynamic> get leaveStats => _leaveStats;

  Future<void> loadLeavesData() async {
    _status = LeavesStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token and user_id from preferences
      final token = await PreferencesHelper.getUserToken();
      final userId = await PreferencesHelper.getUserId();

      if (token == null || token.isEmpty || userId == null || userId.isEmpty) {
        _status = LeavesStatus.error;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return;
      }

      // Fetch leave list from API
      final response = await _remoteDataSource.getLeaveList(token, userId);

      if (response['status'] == true && response['data'] != null) {
        final leaveData = response['data'];
        if (leaveData is List) {
          _leavesList = leaveData.cast<Map<String, dynamic>>();
          
          // Calculate leave stats from the list
          _calculateLeaveStats();
        } else {
      _leavesList = [];
        }

      _status = LeavesStatus.success;
      notifyListeners();
      } else {
        _status = LeavesStatus.error;
        _errorMessage = response['message']?.toString() ?? 'Failed to load leave data';
        notifyListeners();
      }
    } catch (e) {
      _status = LeavesStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void _calculateLeaveStats() {
    int approvedCasualLeave = 0;
    int approvedMedicalLeave = 0;

    for (var leave in _leavesList) {
      final leaveType = leave['leave_type']?.toString().toLowerCase() ?? '';
      final status = leave['status']?.toString().toLowerCase() ?? '';
      
      if (status == 'approved' || status == 'Approved') {
        if (leaveType.contains('casual')) {
          approvedCasualLeave++;
        } else if (leaveType.contains('medical')) {
          approvedMedicalLeave++;
        }
      }
    }

    _leaveStats = {
      'totalCasualLeave': 15,
      'approvedCasualLeave': approvedCasualLeave,
      'totalMedicalLeave': 20,
      'approvedMedicalLeave': approvedMedicalLeave,
    };
  }

  Future<bool> addLeave(
    String leaveTypeId,
    String fromDate,
    String toDate,
    String reason,
    String remarks,
  ) async {
    _status = LeavesStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token and user_id from preferences
      final token = await PreferencesHelper.getUserToken();
      final userId = await PreferencesHelper.getUserId();

      if (token == null || token.isEmpty || userId == null || userId.isEmpty) {
        _status = LeavesStatus.error;
        _errorMessage = 'User not authenticated';
      notifyListeners();
        return false;
      }

      // Call add leave API
      final response = await _remoteDataSource.addLeave(
        token,
        userId,
        leaveTypeId,
        fromDate,
        toDate,
        reason,
        remarks,
      );

      if (response['status'] == true) {
        // Reload leave list to get updated data
        await loadLeavesData();
      return true;
      } else {
        _status = LeavesStatus.error;
        _errorMessage = response['message']?.toString() ?? 'Failed to add leave';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = LeavesStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void refresh() {
    loadLeavesData();
  }
}
