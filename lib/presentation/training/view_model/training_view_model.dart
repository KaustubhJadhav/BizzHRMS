import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';
import 'package:bizzhrms_flutter_app/data/data_sources/remote_data_source.dart';

enum TrainingStatus { initial, loading, success, error }

class TrainingViewModel extends ChangeNotifier {
  TrainingStatus _status = TrainingStatus.initial;
  String? _errorMessage;
  final RemoteDataSource _remoteDataSource = RemoteDataSource();

  TrainingStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _trainingList = [];
  int _total = 0;
  
  List<Map<String, dynamic>> get trainingList => _trainingList;
  int get total => _total;

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in progress':
        return Colors.orange;
      case 'pending':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color getStatusColor(String status) => _getStatusColor(status);

  Future<void> loadTrainingData() async {
    _status = TrainingStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token from preferences
      final token = await PreferencesHelper.getUserToken();

      if (token == null || token.isEmpty) {
        _status = TrainingStatus.error;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return;
      }

      // Fetch training list from API
      final response = await _remoteDataSource.getTrainingList(token);

      if (response['status'] == true) {
        // Use total from API response if available
        if (response['total'] != null) {
          _total = response['total'] is int 
              ? response['total'] 
              : int.tryParse(response['total'].toString()) ?? 0;
        }

        // Handle data array and map fields
        if (response['data'] != null && response['data'] is List) {
          _trainingList = (response['data'] as List).map((item) {
            final training = item as Map<String, dynamic>;
            
            // Extract employee names from employees array
            String employeeNames = 'N/A';
            if (training['employees'] != null && training['employees'] is List) {
              final employees = training['employees'] as List;
              employeeNames = employees
                  .map((emp) {
                    if (emp is Map) {
                      return emp['name']?.toString() ?? '';
                    }
                    return '';
                  })
                  .where((name) => name.isNotEmpty)
                  .join(', ');
              if (employeeNames.isEmpty) {
                employeeNames = 'N/A';
              }
            }
            
            // Map API fields to UI expected fields
            return {
              ...training, // Keep all original fields for details page
              'employee': employeeNames,
              'trainer': training['trainer_name']?.toString() ?? '',
            };
          }).toList();
          
          // Update total from list length if API total wasn't provided
          if (_total == 0) {
            _total = _trainingList.length;
          }
        } else {
          _trainingList = [];
          if (_total == 0) {
            _total = 0;
          }
        }

        _status = TrainingStatus.success;
        notifyListeners();
      } else {
        _status = TrainingStatus.error;
        _errorMessage = response['message']?.toString() ?? 'Failed to load training list';
        notifyListeners();
      }
    } catch (e) {
      _status = TrainingStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void refresh() {
    loadTrainingData();
  }

  /// Fetch training details by training_id
  Future<dynamic> getTrainingDetails(String trainingId) async {
    try {
      // Get token from preferences
      final token = await PreferencesHelper.getUserToken();

      if (token == null || token.isEmpty) {
        return null;
      }

      // Fetch training details from API
      final response = await _remoteDataSource.getTrainingDetailById(token, trainingId);

      if (response['status'] == true && response['data'] != null) {
        // API returns data as object
        return response['data'];
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching training details: $e');
      return null;
    }
  }
}

