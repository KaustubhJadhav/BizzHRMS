import 'package:flutter/foundation.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';
import 'package:bizzhrms_flutter_app/data/data_sources/remote_data_source.dart';

enum GeneratePayslipsStatus { initial, loading, success, error }

class GeneratePayslipsViewModel extends ChangeNotifier {
  GeneratePayslipsStatus _status = GeneratePayslipsStatus.initial;
  String? _errorMessage;
  final RemoteDataSource _remoteDataSource = RemoteDataSource();

  GeneratePayslipsStatus get status => _status;
  String? get errorMessage => _errorMessage;

  Map<String, dynamic>? _payslipData;
  Map<String, dynamic>? get payslipData => _payslipData;

  Future<void> generatePayslip({
    required String paymentId,
    String? cookie,
  }) async {
    _status = GeneratePayslipsStatus.loading;
    _errorMessage = null;
    _payslipData = null;
    notifyListeners();

    try {
      // Get token from preferences
      final token = PreferencesHelper.getUserToken();
      if (token == null || token.isEmpty) {
        _status = GeneratePayslipsStatus.error;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return;
      }

      // Call API
      final response = await _remoteDataSource.generatePayslip(
        token,
        cookie,
        paymentId,
      );

      if (response['status'] == true && response['data'] != null) {
        _payslipData = response['data'] as Map<String, dynamic>;
        _status = GeneratePayslipsStatus.success;
        notifyListeners();
      } else {
        _status = GeneratePayslipsStatus.error;
        _errorMessage = response['message']?.toString() ?? 'Failed to generate payslip';
        notifyListeners();
      }
    } catch (e) {
      _status = GeneratePayslipsStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void reset() {
    _status = GeneratePayslipsStatus.initial;
    _errorMessage = null;
    _payslipData = null;
    notifyListeners();
  }
}

