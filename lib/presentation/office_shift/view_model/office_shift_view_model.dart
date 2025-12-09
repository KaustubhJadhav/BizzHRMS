import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';
import 'package:bizzhrms_flutter_app/data/data_sources/remote_data_source.dart';

enum OfficeShiftStatus { initial, loading, success, error }

class OfficeShiftViewModel extends ChangeNotifier {
  OfficeShiftStatus _status = OfficeShiftStatus.initial;
  String? _errorMessage;
  final RemoteDataSource _remoteDataSource = RemoteDataSource();

  OfficeShiftStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _officeShiftsList = [];
  int _total = 0;
  
  List<Map<String, dynamic>> get officeShiftsList => _officeShiftsList;
  int get total => _total;

  Future<void> loadOfficeShiftsData() async {
    _status = OfficeShiftStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token from preferences
      final token = await PreferencesHelper.getUserToken();

      if (token == null || token.isEmpty) {
        _status = OfficeShiftStatus.error;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return;
      }

      // Fetch office shift list from API
      final response = await _remoteDataSource.getOfficeShiftList(token);

      if (response['status'] == true) {
        // Use total from API response if available
        if (response['total'] != null) {
          _total = response['total'] is int 
              ? response['total'] 
              : int.tryParse(response['total'].toString()) ?? 0;
        }

        // Handle data array and map fields
        if (response['data'] != null && response['data'] is List) {
          _officeShiftsList = (response['data'] as List).map((item) {
            final shift = item as Map<String, dynamic>;
            // Map API fields to UI expected fields
            return {
              ...shift, // Keep all original fields
              'office_shift': shift['shift_name']?.toString() ?? '',
              'duration': shift['shift_date']?.toString() ?? '',
            };
          }).toList();
          
          // Update total from list length if API total wasn't provided
          if (_total == 0) {
            _total = _officeShiftsList.length;
          }
        } else {
          _officeShiftsList = [];
          if (_total == 0) {
            _total = 0;
          }
        }

        _status = OfficeShiftStatus.success;
        notifyListeners();
      } else {
        _status = OfficeShiftStatus.error;
        _errorMessage = response['message']?.toString() ?? 'Failed to load office shifts';
        notifyListeners();
      }
    } catch (e) {
      _status = OfficeShiftStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void refresh() {
    loadOfficeShiftsData();
  }
}

