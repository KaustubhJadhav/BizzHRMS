import 'package:flutter/foundation.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';
import 'package:bizzhrms_flutter_app/data/data_sources/remote_data_source.dart';

enum JobInterviewStatus { initial, loading, success, error }

class JobInterviewViewModel extends ChangeNotifier {
  JobInterviewStatus _status = JobInterviewStatus.initial;
  String? _errorMessage;
  final RemoteDataSource _remoteDataSource = RemoteDataSource();

  JobInterviewStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _jobInterviewsList = [];
  int _total = 0;
  
  List<Map<String, dynamic>> get jobInterviewsList => _jobInterviewsList;
  int get total => _total;

  Future<void> loadJobInterviewsData() async {
    _status = JobInterviewStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token from preferences
      final token = await PreferencesHelper.getUserToken();

      if (token == null || token.isEmpty) {
        _status = JobInterviewStatus.error;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return;
      }

      // Fetch job interview list from API
      final response = await _remoteDataSource.getJobInterviewList(token);

      if (response['status'] == true) {
        // Use total from API response if available
        if (response['total'] != null) {
          _total = response['total'] is int 
              ? response['total'] 
              : int.tryParse(response['total'].toString()) ?? 0;
        }

        // Handle data array and map fields
        if (response['data'] != null && response['data'] is List) {
          _jobInterviewsList = (response['data'] as List).map((item) {
            final jobInterview = item as Map<String, dynamic>;
            // Map API fields to UI expected fields
            return {
              ...jobInterview, // Keep all original fields for details page
              'message': jobInterview['description']?.toString() ?? '',
            };
          }).toList();
          
          // Update total from list length if API total wasn't provided
          if (_total == 0) {
            _total = _jobInterviewsList.length;
          }
        } else {
          _jobInterviewsList = [];
          if (_total == 0) {
            _total = 0;
          }
        }

        _status = JobInterviewStatus.success;
        notifyListeners();
      } else {
        _status = JobInterviewStatus.error;
        _errorMessage = response['message']?.toString() ?? 'Failed to load job interviews';
        notifyListeners();
      }
    } catch (e) {
      _status = JobInterviewStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void refresh() {
    loadJobInterviewsData();
  }
}

