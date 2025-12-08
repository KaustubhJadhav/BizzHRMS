import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';
import 'package:bizzhrms_flutter_app/data/data_sources/remote_data_source.dart';

enum ProjectDetailsStatus { initial, loading, success, error }

class ProjectDetailsViewModel extends ChangeNotifier {
  ProjectDetailsStatus _status = ProjectDetailsStatus.initial;
  String? _errorMessage;
  final RemoteDataSource _remoteDataSource = RemoteDataSource();
  bool _isUpdating = false;
  bool _isAddingDiscussion = false;
  bool _isLoadingDiscussions = false;
  bool _isLoadingBugs = false;

  ProjectDetailsStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isUpdating => _isUpdating;
  bool get isAddingDiscussion => _isAddingDiscussion;
  bool get isLoadingDiscussions => _isLoadingDiscussions;
  bool get isLoadingBugs => _isLoadingBugs;

  Map<String, dynamic>? _projectDetails;
  List<Map<String, dynamic>> _discussions = [];
  List<Map<String, dynamic>> _bugs = [];

  Map<String, dynamic>? get projectDetails => _projectDetails;
  List<Map<String, dynamic>> get discussions => _discussions;
  List<Map<String, dynamic>> get bugs => _bugs;

  Future<void> loadProjectDetails(String projectId) async {
    if (projectId.isEmpty) {
      _status = ProjectDetailsStatus.error;
      _errorMessage = 'Project ID is required';
      notifyListeners();
      return;
    }

    _status = ProjectDetailsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token and user_id from preferences
      final token = await PreferencesHelper.getUserToken();
      final userId = await PreferencesHelper.getUserId();

      if (token == null || token.isEmpty || userId == null || userId.isEmpty) {
        _status = ProjectDetailsStatus.error;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return;
      }

      // TODO: Replace with actual API call when endpoint is provided
      // For now, we'll use placeholder data
      // final response = await _remoteDataSource.getProjectDetails(token, userId, projectId);

      // Placeholder: Set initial project details from passed data
      // This will be replaced when API is integrated
      _status = ProjectDetailsStatus.success;
      notifyListeners();
    } catch (e) {
      _status = ProjectDetailsStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void setProjectDetails(Map<String, dynamic> project) {
    _projectDetails = project;
    _status = ProjectDetailsStatus.success;
    notifyListeners();
  }

  void refresh() {
    if (_projectDetails != null && _projectDetails!['id'] != null) {
      loadProjectDetails(_projectDetails!['id'].toString());
    }
  }

  /// Update project status, priority, and progress
  Future<bool> updateProjectStatus({
    required String projectId,
    required int priority,
    required int progressValue,
    required int status,
  }) async {
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await PreferencesHelper.getUserToken();

      if (token == null || token.isEmpty) {
        _isUpdating = false;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return false;
      }

      final response = await _remoteDataSource.updateProjectStatus(
        token,
        projectId,
        priority,
        progressValue,
        status,
      );

      _isUpdating = false;

      if (response['status'] == 200 || response['status'] == true) {
        // Update local project details
        if (_projectDetails != null) {
          _projectDetails!['priority'] = priority;
          _projectDetails!['progress'] = progressValue;
          _projectDetails!['status'] = status;
        }
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message']?.toString() ?? 'Failed to update project status';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isUpdating = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Load discussions for a project
  Future<void> loadDiscussions(String projectId) async {
    _isLoadingDiscussions = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await PreferencesHelper.getUserToken();

      if (token == null || token.isEmpty) {
        _isLoadingDiscussions = false;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return;
      }

      final response = await _remoteDataSource.getProjectDiscussionList(
        token,
        projectId,
      );

      _isLoadingDiscussions = false;

      if (response['status'] == true || response['status'] == 200) {
        final discussionsData = response['data'] ?? response['discussions'] ?? [];
        if (discussionsData is List) {
          _discussions = discussionsData.cast<Map<String, dynamic>>();
        } else {
          _discussions = [];
        }
        notifyListeners();
      } else {
        _errorMessage = response['message']?.toString() ?? 'Failed to load discussions';
        notifyListeners();
      }
    } catch (e) {
      _isLoadingDiscussions = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  /// Add a new discussion
  Future<bool> addDiscussion({
    required String projectId,
    required String message,
    File? attachmentFile,
  }) async {
    _isAddingDiscussion = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await PreferencesHelper.getUserToken();
      final userId = await PreferencesHelper.getUserId();

      if (token == null || token.isEmpty || userId == null || userId.isEmpty) {
        _isAddingDiscussion = false;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return false;
      }

      final response = await _remoteDataSource.setProjectDiscussion(
        token,
        userId,
        projectId,
        message,
        attachmentFile: attachmentFile,
      );

      _isAddingDiscussion = false;

      if (response['status'] == 200 || response['status'] == true) {
        // Reload discussions after adding
        await loadDiscussions(projectId);
        return true;
      } else {
        _errorMessage = response['message']?.toString() ?? 'Failed to add discussion';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isAddingDiscussion = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Load bugs for a project
  Future<void> loadBugs(String projectId) async {
    _isLoadingBugs = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await PreferencesHelper.getUserToken();

      if (token == null || token.isEmpty) {
        _isLoadingBugs = false;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return;
      }

      final response = await _remoteDataSource.getProjectBugList(
        token,
        projectId,
      );

      _isLoadingBugs = false;

      if (response['status'] == true || response['status'] == 200) {
        final bugsData = response['data'] ?? response['bugs'] ?? [];
        if (bugsData is List) {
          _bugs = bugsData.cast<Map<String, dynamic>>();
        } else {
          _bugs = [];
        }
        notifyListeners();
      } else {
        _errorMessage = response['message']?.toString() ?? 'Failed to load bugs';
        notifyListeners();
      }
    } catch (e) {
      _isLoadingBugs = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }
}

