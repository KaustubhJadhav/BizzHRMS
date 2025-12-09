import 'package:flutter/foundation.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';
import 'package:bizzhrms_flutter_app/data/data_sources/remote_data_source.dart';

enum PayslipsStatus { initial, loading, success, error }

class PayslipsViewModel extends ChangeNotifier {
  PayslipsStatus _status = PayslipsStatus.initial;
  String? _errorMessage;
  final RemoteDataSource _remoteDataSource = RemoteDataSource();

  PayslipsStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _payslipsList = [];
  int _total = 0;
  
  List<Map<String, dynamic>> get payslipsList => _payslipsList;
  int get total => _total;

  Future<void> loadPayslipsData({
    String? monthYear,
    String? amount,
    String? reason,
    String? oneTimeDeduct,
    String? monthlyInstallment,
    String? cookie,
  }) async {
    _status = PayslipsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token from preferences
      final token = PreferencesHelper.getUserToken();
      if (token == null || token.isEmpty) {
        _status = PayslipsStatus.error;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return;
      }

      // Use provided values or defaults
      final response = await _remoteDataSource.getPayslipList(
        token,
        cookie, // Cookie is optional
        monthYear ?? '', // Default empty if not provided
        amount ?? '', // Default empty if not provided
        reason ?? '', // Default empty if not provided
        oneTimeDeduct ?? '0', // Default '0' if not provided
        monthlyInstallment ?? '', // Default empty if not provided
      );

      if (response['status'] == true) {
        _total = response['total'] ?? 0;
        final data = response['data'] as List<dynamic>?;
        
        if (data != null) {
          _payslipsList = data.map((item) {
            final payslip = item as Map<String, dynamic>;
            // Map API fields to UI-friendly format
            return {
              'payslip_id': payslip['payslip_id']?.toString() ?? '',
              'employee_id': payslip['employee_id']?.toString() ?? '',
              'payment_amount': payslip['payment_amount']?.toString() ?? '',
              'month_payment': payslip['month_payment']?.toString() ?? '',
              'created_at': payslip['created_at']?.toString() ?? '',
              'payment_method': payslip['payment_method']?.toString() ?? '',
            };
          }).toList();
        } else {
          _payslipsList = [];
        }
        
        _status = PayslipsStatus.success;
        notifyListeners();
      } else {
        _status = PayslipsStatus.error;
        _errorMessage = response['message']?.toString() ?? 'Failed to load payslips';
        notifyListeners();
      }
    } catch (e) {
      _status = PayslipsStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void refresh({
    String? monthYear,
    String? amount,
    String? reason,
    String? oneTimeDeduct,
    String? monthlyInstallment,
    String? cookie,
  }) {
    loadPayslipsData(
      monthYear: monthYear,
      amount: amount,
      reason: reason,
      oneTimeDeduct: oneTimeDeduct,
      monthlyInstallment: monthlyInstallment,
      cookie: cookie,
    );
  }
}

