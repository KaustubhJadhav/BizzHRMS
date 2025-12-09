import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';
import 'package:bizzhrms_flutter_app/data/data_sources/remote_data_source.dart';

enum JobAppliedStatus { initial, loading, success, error }

class JobAppliedViewModel extends ChangeNotifier {
  JobAppliedStatus _status = JobAppliedStatus.initial;
  String? _errorMessage;
  final RemoteDataSource _remoteDataSource = RemoteDataSource();

  JobAppliedStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _jobsAppliedList = [];
  int _total = 0;
  
  List<Map<String, dynamic>> get jobsAppliedList => _jobsAppliedList;
  int get total => _total;

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'shortlisted':
        return Colors.blue;
      case 'interview':
        return Colors.purple;
      case 'rejected':
        return Colors.red;
      case 'hired':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color getStatusColor(String status) => _getStatusColor(status);

  Future<void> loadJobsAppliedData() async {
    _status = JobAppliedStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token from preferences
      final token = await PreferencesHelper.getUserToken();

      if (token == null || token.isEmpty) {
        _status = JobAppliedStatus.error;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return;
      }

      // Fetch job applied list from API
      final response = await _remoteDataSource.getJobAppliedList(token);

      if (response['status'] == true) {
        // Use total from API response if available
        if (response['total'] != null) {
          _total = response['total'] is int 
              ? response['total'] 
              : int.tryParse(response['total'].toString()) ?? 0;
        }

        // Handle data array and map fields
        if (response['data'] != null && response['data'] is List) {
          _jobsAppliedList = (response['data'] as List).map((item) {
            final jobApplied = item as Map<String, dynamic>;
            // Map API fields to UI expected fields
            return {
              ...jobApplied, // Keep all original fields for details page
              'job_title': jobApplied['application_title']?.toString() ?? '',
              'candidate_name': jobApplied['employee_name']?.toString() ?? '',
              'email': jobApplied['employee_email']?.toString() ?? '',
              'status': jobApplied['application_status']?.toString() ?? '',
              'apply_date': jobApplied['created_at']?.toString() ?? '',
            };
          }).toList();
          
          // Update total from list length if API total wasn't provided
          if (_total == 0) {
            _total = _jobsAppliedList.length;
          }
        } else {
          _jobsAppliedList = [];
          if (_total == 0) {
            _total = 0;
          }
        }

        _status = JobAppliedStatus.success;
        notifyListeners();
      } else {
        _status = JobAppliedStatus.error;
        _errorMessage = response['message']?.toString() ?? 'Failed to load jobs applied';
        notifyListeners();
      }
    } catch (e) {
      _status = JobAppliedStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void refresh() {
    loadJobsAppliedData();
  }
}

