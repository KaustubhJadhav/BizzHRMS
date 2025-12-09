import 'package:flutter/foundation.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';
import 'package:bizzhrms_flutter_app/data/data_sources/remote_data_source.dart';

enum AdvanceSalaryStatus { initial, loading, success, error }

class AdvanceSalaryViewModel extends ChangeNotifier {
  AdvanceSalaryStatus _status = AdvanceSalaryStatus.initial;
  String? _errorMessage;
  final RemoteDataSource _remoteDataSource = RemoteDataSource();

  AdvanceSalaryStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _advanceSalaryList = [];
  int _total = 0;
  
  List<Map<String, dynamic>> get advanceSalaryList => _advanceSalaryList;
  int get total => _total;

  Future<void> loadAdvanceSalaryData({
    String? cookie,
  }) async {
    _status = AdvanceSalaryStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token from preferences
      final token = PreferencesHelper.getUserToken();
      if (token == null || token.isEmpty) {
        _status = AdvanceSalaryStatus.error;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return;
      }

      // Call API
      final response = await _remoteDataSource.getAdvanceSalaryList(
        token,
        cookie,
      );

      if (response['status'] == true) {
        _total = response['total'] ?? 0;
        final data = response['data'] as List<dynamic>?;
        
        if (data != null) {
          _advanceSalaryList = data.map((item) {
            final advanceSalary = item as Map<String, dynamic>;
            // Map API fields to UI-friendly format
            return {
              'employee_id': advanceSalary['employee_id']?.toString() ?? '',
              'employee_name': advanceSalary['employee_name']?.toString() ?? '',
              'advance_amount': advanceSalary['advance_amount']?.toString() ?? '',
              'month_year': advanceSalary['month_year']?.toString() ?? '',
              'one_time_deduct': advanceSalary['one_time_deduct']?.toString() ?? '',
              'monthly_installment': advanceSalary['monthly_installment']?.toString() ?? '',
              'reason': advanceSalary['reason']?.toString() ?? '',
              'status': advanceSalary['status']?.toString() ?? '',
              'created_at': advanceSalary['created_at']?.toString() ?? '',
            };
          }).toList();
        } else {
          _advanceSalaryList = [];
        }
        
        _status = AdvanceSalaryStatus.success;
        notifyListeners();
      } else {
        _status = AdvanceSalaryStatus.error;
        _errorMessage = response['message']?.toString() ?? 'Failed to load advance salary list';
        notifyListeners();
      }
    } catch (e) {
      _status = AdvanceSalaryStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void refresh({
    String? cookie,
  }) {
    loadAdvanceSalaryData(cookie: cookie);
  }

  /// Add Advance Salary
  Future<bool> addAdvanceSalary({
    required String monthYear,
    required String amount,
    required String reason,
    required String oneTimeDeduct,
    required String monthlyInstallment,
    String? cookie,
  }) async {
    try {
      // Get token from preferences
      final token = PreferencesHelper.getUserToken();
      if (token == null || token.isEmpty) {
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return false;
      }

      // Call API
      final response = await _remoteDataSource.addAdvanceSalary(
        token,
        cookie,
        monthYear,
        amount,
        reason,
        oneTimeDeduct,
        monthlyInstallment,
      );

      if (response['status'] == true) {
        // Refresh the list after successful addition
        await loadAdvanceSalaryData(cookie: cookie);
        return true;
      } else {
        _errorMessage = response['message']?.toString() ?? 'Failed to add advance salary';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}

