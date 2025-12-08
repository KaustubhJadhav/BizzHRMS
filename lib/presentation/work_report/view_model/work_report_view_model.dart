import 'package:flutter/foundation.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';
import 'package:bizzhrms_flutter_app/data/data_sources/remote_data_source.dart';

enum WorkReportStatus { initial, loading, success, error }

class WorkReportViewModel extends ChangeNotifier {
  WorkReportStatus _status = WorkReportStatus.initial;
  String? _errorMessage;
  final RemoteDataSource _remoteDataSource = RemoteDataSource();

  WorkReportStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _workReportsList = [];
  int _total = 0;
  
  List<Map<String, dynamic>> get workReportsList => _workReportsList;
  int get total => _total;

  Future<void> loadWorkReportsData() async {
    _status = WorkReportStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token and user_id from preferences
      final token = await PreferencesHelper.getUserToken();
      final userId = await PreferencesHelper.getUserId();

      if (token == null || token.isEmpty || userId == null || userId.isEmpty) {
        _status = WorkReportStatus.error;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return;
      }

      // Fetch task list from API
      final response = await _remoteDataSource.getTaskList(token, userId);

      if (response['status'] == true && response['tasks'] != null) {
        final tasks = response['tasks'];
        if (tasks is List) {
          _workReportsList = tasks.cast<Map<String, dynamic>>();
          _total = response['total'] ?? _workReportsList.length;
        } else {
          _workReportsList = [];
          _total = 0;
        }
        
        _status = WorkReportStatus.success;
        notifyListeners();
      } else {
        _status = WorkReportStatus.error;
        _errorMessage = response['message']?.toString() ?? 'Failed to load work reports';
        notifyListeners();
      }
    } catch (e) {
      _status = WorkReportStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void refresh() {
    loadWorkReportsData();
  }
}

