import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';
import 'package:bizzhrms_flutter_app/data/data_sources/remote_data_source.dart';

enum WarningsStatus { initial, loading, success, error }

class WarningsViewModel extends ChangeNotifier {
  WarningsStatus _status = WarningsStatus.initial;
  String? _errorMessage;
  final RemoteDataSource _remoteDataSource = RemoteDataSource();

  WarningsStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _warningsList = [];
  int _total = 0;
  
  List<Map<String, dynamic>> get warningsList => _warningsList;
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

  Color _getWarningTypeColor(String type) {
    // Handle various warning type formats
    final typeLower = type.toLowerCase();
    if (typeLower.contains('verbal') || typeLower.contains('first')) {
      return Colors.blue;
    } else if (typeLower.contains('written') || typeLower.contains('second')) {
      return Colors.orange;
    } else if (typeLower.contains('final') || typeLower.contains('third')) {
      return Colors.red;
    }
    return Colors.grey;
  }

  Color getWarningTypeColor(String type) => _getWarningTypeColor(type);

  Future<void> loadWarningsData() async {
    _status = WarningsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token from preferences
      final token = await PreferencesHelper.getUserToken();

      if (token == null || token.isEmpty) {
        _status = WarningsStatus.error;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return;
      }

      // Fetch warning list from API
      final response = await _remoteDataSource.getWarningList(token);

      if (response['status'] == true) {
        // Use total from API response if available
        if (response['total'] != null) {
          _total = response['total'] is int 
              ? response['total'] 
              : int.tryParse(response['total'].toString()) ?? 0;
        }

        // Handle data array and map fields
        if (response['data'] != null && response['data'] is List) {
          _warningsList = (response['data'] as List).map((item) {
            final warning = item as Map<String, dynamic>;
            // Map API fields to UI expected fields
            return {
              ...warning, // Keep all original fields for details page
              'details': warning['description']?.toString() ?? '', // Map description to details
            };
          }).toList();
          
          // Update total from list length if API total wasn't provided
          if (_total == 0) {
            _total = _warningsList.length;
          }
        } else {
          _warningsList = [];
          if (_total == 0) {
            _total = 0;
          }
        }

        _status = WarningsStatus.success;
        notifyListeners();
      } else {
        _status = WarningsStatus.error;
        _errorMessage = response['message']?.toString() ?? 'Failed to load warnings';
        notifyListeners();
      }
    } catch (e) {
      _status = WarningsStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void refresh() {
    loadWarningsData();
  }

  /// Fetch warning details by warning_id
  Future<dynamic> getWarningDetails(String warningId) async {
    try {
      // Get token from preferences
      final token = await PreferencesHelper.getUserToken();

      if (token == null || token.isEmpty) {
        return null;
      }

      // Fetch warning details from API
      final response = await _remoteDataSource.getWarningDetailById(token, warningId);

      if (response['status'] == true && response['data'] != null) {
        // API returns data as array
        return response['data'];
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching warning details: $e');
      return null;
    }
  }
}

