import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';
import 'package:bizzhrms_flutter_app/data/data_sources/remote_data_source.dart';

enum ComplaintsStatus { initial, loading, success, error }

class ComplaintsViewModel extends ChangeNotifier {
  ComplaintsStatus _status = ComplaintsStatus.initial;
  String? _errorMessage;
  final RemoteDataSource _remoteDataSource = RemoteDataSource();

  ComplaintsStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _complaintsList = [];
  int _total = 0;
  
  List<Map<String, dynamic>> get complaintsList => _complaintsList;
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

  Future<void> loadComplaintsData() async {
    _status = ComplaintsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token from preferences
      final token = await PreferencesHelper.getUserToken();

      if (token == null || token.isEmpty) {
        _status = ComplaintsStatus.error;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return;
      }

      // Fetch complaint list from API
      final response = await _remoteDataSource.getComplaintList(token);

      if (response['status'] == true) {
        // Use total from API response if available
        if (response['total'] != null) {
          _total = response['total'] is int 
              ? response['total'] 
              : int.tryParse(response['total'].toString()) ?? 0;
        }

        // Handle data array and map fields
        if (response['data'] != null && response['data'] is List) {
          _complaintsList = (response['data'] as List).map((item) {
            final complaint = item as Map<String, dynamic>;
            // Handle complaint_against as array - convert to comma-separated string
            String complaintAgainst = '';
            if (complaint['complaint_against'] != null) {
              if (complaint['complaint_against'] is List) {
                complaintAgainst = (complaint['complaint_against'] as List)
                    .map((e) => e.toString())
                    .join(', ');
              } else {
                complaintAgainst = complaint['complaint_against'].toString();
              }
            }
            
            // Map API fields to UI expected fields
            return {
              ...complaint, // Keep all original fields for details page
              'complaint_against': complaintAgainst, // Convert array to string
              'details': complaint['description']?.toString() ?? '', // Map description to details
            };
          }).toList();
          
          // Update total from list length if API total wasn't provided
          if (_total == 0) {
            _total = _complaintsList.length;
          }
        } else {
          _complaintsList = [];
          if (_total == 0) {
            _total = 0;
          }
        }

        _status = ComplaintsStatus.success;
        notifyListeners();
      } else {
        _status = ComplaintsStatus.error;
        _errorMessage = response['message']?.toString() ?? 'Failed to load complaints';
        notifyListeners();
      }
    } catch (e) {
      _status = ComplaintsStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void refresh() {
    loadComplaintsData();
  }

  /// Fetch complaint details by complaint_id
  Future<dynamic> getComplaintDetails(String complaintId) async {
    try {
      // Get token from preferences
      final token = await PreferencesHelper.getUserToken();

      if (token == null || token.isEmpty) {
        return null;
      }

      // Fetch complaint details from API
      final response = await _remoteDataSource.getComplaintDetailById(token, complaintId);

      if (response['status'] == true && response['data'] != null) {
        // API returns data as array
        return response['data'];
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching complaint details: $e');
      return null;
    }
  }
}
