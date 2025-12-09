import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';
import 'package:bizzhrms_flutter_app/data/data_sources/remote_data_source.dart';

enum TravelsStatus { initial, loading, success, error }

class TravelsViewModel extends ChangeNotifier {
  TravelsStatus _status = TravelsStatus.initial;
  String? _errorMessage;
  final RemoteDataSource _remoteDataSource = RemoteDataSource();

  TravelsStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _travelsList = [];
  int _total = 0;
  
  List<Map<String, dynamic>> get travelsList => _travelsList;
  int get total => _total;

  Color _getApprovalStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color getApprovalStatusColor(String status) => _getApprovalStatusColor(status);

  Future<void> loadTravelsData() async {
    _status = TravelsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token from preferences
      final token = await PreferencesHelper.getUserToken();

      if (token == null || token.isEmpty) {
        _status = TravelsStatus.error;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return;
      }

      // Fetch travel list from API
      final response = await _remoteDataSource.getTravelList(token);

      if (response['status'] == true) {
        // Use total from API response if available
        if (response['total'] != null) {
          _total = response['total'] is int 
              ? response['total'] 
              : int.tryParse(response['total'].toString()) ?? 0;
        }

        // Handle data array and map fields
        if (response['data'] != null && response['data'] is List) {
          _travelsList = (response['data'] as List).map((item) {
            final travel = item as Map<String, dynamic>;
            // Map API fields to UI expected fields
            return {
              ...travel, // Keep all original fields for details page
              'employee': travel['employee_name']?.toString() ?? '',
              'purpose_of_visit': travel['visit_purpose']?.toString() ?? '',
              'place_of_visit': travel['visit_place']?.toString() ?? '',
            };
          }).toList();
          
          // Update total from list length if API total wasn't provided
          if (_total == 0) {
            _total = _travelsList.length;
          }
        } else {
          _travelsList = [];
          if (_total == 0) {
            _total = 0;
          }
        }

        _status = TravelsStatus.success;
        notifyListeners();
      } else {
        _status = TravelsStatus.error;
        _errorMessage = response['message']?.toString() ?? 'Failed to load travels';
        notifyListeners();
      }
    } catch (e) {
      _status = TravelsStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void refresh() {
    loadTravelsData();
  }

  /// Fetch travel details by travel_id
  Future<dynamic> getTravelDetails(String travelId) async {
    try {
      // Get token from preferences
      final token = await PreferencesHelper.getUserToken();

      if (token == null || token.isEmpty) {
        return null;
      }

      // Fetch travel details from API
      final response = await _remoteDataSource.getTravelDetailById(token, travelId);

      if (response['status'] == true && response['data'] != null) {
        // API returns data as object
        return response['data'];
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching travel details: $e');
      return null;
    }
  }
}

