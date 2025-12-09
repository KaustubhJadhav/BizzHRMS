import 'package:flutter/foundation.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';
import 'package:bizzhrms_flutter_app/data/data_sources/remote_data_source.dart';

enum PerformanceStatus { initial, loading, success, error }

class PerformanceViewModel extends ChangeNotifier {
  PerformanceStatus _status = PerformanceStatus.initial;
  String? _errorMessage;
  final RemoteDataSource _remoteDataSource = RemoteDataSource();

  PerformanceStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _performanceList = [];
  int _total = 0;
  
  List<Map<String, dynamic>> get performanceList => _performanceList;
  int get total => _total;

  Future<void> loadPerformanceData({
    String? cookie,
  }) async {
    _status = PerformanceStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token from preferences
      final token = PreferencesHelper.getUserToken();
      if (token == null || token.isEmpty) {
        _status = PerformanceStatus.error;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return;
      }

      // Call API
      final response = await _remoteDataSource.getPerformanceList(
        token,
        cookie,
      );

      if (response['status'] == true) {
        _total = response['total'] ?? 0;
        final data = response['data'] as List<dynamic>?;
        
        if (data != null) {
          _performanceList = data.map((item) {
            final performance = item as Map<String, dynamic>;
            // Map API fields to UI-friendly format
            return {
              'performance_appraisal_id': performance['performance_appraisal_id']?.toString() ?? '',
              'employee_primary_id': performance['employee_primary_id']?.toString() ?? '',
              'employee_id': performance['employee_id']?.toString() ?? '',
              'employee_name': performance['employee_name']?.toString() ?? '',
              'department': performance['department']?.toString() ?? '',
              'designation': performance['designation']?.toString() ?? '',
              'appraisal_date': performance['appraisal_date']?.toString() ?? '',
            };
          }).toList();
        } else {
          _performanceList = [];
        }
        
        _status = PerformanceStatus.success;
        notifyListeners();
      } else {
        _status = PerformanceStatus.error;
        _errorMessage = response['message']?.toString() ?? 'Failed to load performance list';
        notifyListeners();
      }
    } catch (e) {
      _status = PerformanceStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void refresh({
    String? cookie,
  }) {
    loadPerformanceData(cookie: cookie);
  }

  /// Get Performance Details By ID
  Future<Map<String, dynamic>?> getPerformanceDetails(String performanceAppraisalId, {String? cookie}) async {
    try {
      // Get token from preferences
      final token = PreferencesHelper.getUserToken();
      if (token == null || token.isEmpty) {
        throw Exception('User not authenticated');
      }

      // Call API
      final response = await _remoteDataSource.getPerformanceDetailById(
        token,
        cookie,
        performanceAppraisalId,
      );

      if (response['status'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      } else {
        throw Exception(response['message']?.toString() ?? 'Failed to load performance details');
      }
    } catch (e) {
      rethrow;
    }
  }
}

