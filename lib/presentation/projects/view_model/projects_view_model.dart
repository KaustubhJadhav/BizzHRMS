import 'package:flutter/foundation.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';
import 'package:bizzhrms_flutter_app/data/data_sources/remote_data_source.dart';

enum ProjectsStatus { initial, loading, success, error }

class ProjectsViewModel extends ChangeNotifier {
  ProjectsStatus _status = ProjectsStatus.initial;
  String? _errorMessage;
  final RemoteDataSource _remoteDataSource = RemoteDataSource();

  ProjectsStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _projectsList = [];
  int _total = 0;
  
  List<Map<String, dynamic>> get projectsList => _projectsList;
  int get total => _total;

  Future<void> loadProjectsData() async {
    _status = ProjectsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token and user_id from preferences
      final token = await PreferencesHelper.getUserToken();
      final userId = await PreferencesHelper.getUserId();

      if (token == null || token.isEmpty || userId == null || userId.isEmpty) {
        _status = ProjectsStatus.error;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return;
      }

      // Fetch project list from API
      final response = await _remoteDataSource.getProjectList(token, userId);

      if (response['status'] == true && response['projects'] != null) {
        final projects = response['projects'];
        if (projects is List) {
          _projectsList = projects.cast<Map<String, dynamic>>();
          _total = response['total'] ?? _projectsList.length;
        } else {
          _projectsList = [];
          _total = 0;
        }
        
        _status = ProjectsStatus.success;
        notifyListeners();
      } else {
        _status = ProjectsStatus.error;
        _errorMessage = response['message']?.toString() ?? 'Failed to load projects';
        notifyListeners();
      }
    } catch (e) {
      _status = ProjectsStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void refresh() {
    loadProjectsData();
  }
}
