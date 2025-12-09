import 'package:flutter/foundation.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';
import 'package:bizzhrms_flutter_app/data/data_sources/remote_data_source.dart';

enum AdvanceSalaryReportStatus { initial, loading, success, error }

class AdvanceSalaryReportViewModel extends ChangeNotifier {
  AdvanceSalaryReportStatus _status = AdvanceSalaryReportStatus.initial;
  String? _errorMessage;
  final RemoteDataSource _remoteDataSource = RemoteDataSource();

  AdvanceSalaryReportStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _advanceSalaryReportList = [];
  int _total = 0;
  
  List<Map<String, dynamic>> get advanceSalaryReportList => _advanceSalaryReportList;
  int get total => _total;

  Future<void> loadAdvanceSalaryReportData({
    String? cookie,
  }) async {
    _status = AdvanceSalaryReportStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token from preferences
      final token = PreferencesHelper.getUserToken();
      if (token == null || token.isEmpty) {
        _status = AdvanceSalaryReportStatus.error;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return;
      }

      // Call API
      final response = await _remoteDataSource.getAdvanceSalaryReportList(
        token,
        cookie,
      );

      if (response['status'] == true) {
        _total = response['total'] ?? 0;
        final data = response['data'] as List<dynamic>?;
        
        if (data != null) {
          _advanceSalaryReportList = data.map((item) {
            final report = item as Map<String, dynamic>;
            // Map API fields to UI-friendly format, preserving requested_dates array
            return {
              'employee_id': report['employee_id']?.toString() ?? '',
              'employee_name': report['employee_name']?.toString() ?? '',
              'month_year': report['month_year']?.toString() ?? '',
              'advance_amount': report['advance_amount']?.toString() ?? '',
              'total_paid': report['total_paid']?.toString() ?? '',
              'remaining_amount': report['remaining_amount']?.toString() ?? '',
              'monthly_installment': report['monthly_installment']?.toString() ?? '',
              'one_time_deduct': report['one_time_deduct']?.toString() ?? '',
              'status': report['status']?.toString() ?? '',
              'requested_dates': report['requested_dates'] as List<dynamic>? ?? [],
            };
          }).toList();
        } else {
          _advanceSalaryReportList = [];
        }
        
        _status = AdvanceSalaryReportStatus.success;
        notifyListeners();
      } else {
        _status = AdvanceSalaryReportStatus.error;
        _errorMessage = response['message']?.toString() ?? 'Failed to load advance salary report list';
        notifyListeners();
      }
    } catch (e) {
      _status = AdvanceSalaryReportStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void refresh({
    String? cookie,
  }) {
    loadAdvanceSalaryReportData(cookie: cookie);
  }
}

