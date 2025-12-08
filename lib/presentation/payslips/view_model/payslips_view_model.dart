import 'package:flutter/foundation.dart';

enum PayslipsStatus { initial, loading, success, error }

class PayslipsViewModel extends ChangeNotifier {
  PayslipsStatus _status = PayslipsStatus.initial;
  String? _errorMessage;

  PayslipsStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _payslipsList = [];
  int _total = 0;
  
  List<Map<String, dynamic>> get payslipsList => _payslipsList;
  int get total => _total;

  Future<void> loadPayslipsData() async {
    _status = PayslipsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Dummy data matching the HTML table structure
      _payslipsList = [
        {
          'id': 1,
          'payment_id': 'PAY001',
          'paid_amount': 50000.00,
          'payment_month': 'January 2024',
          'payment_date': '2024-01-31',
          'payment_type': 'Monthly',
        },
        {
          'id': 2,
          'payment_id': 'PAY002',
          'paid_amount': 50000.00,
          'payment_month': 'February 2024',
          'payment_date': '2024-02-29',
          'payment_type': 'Monthly',
        },
        {
          'id': 3,
          'payment_id': 'PAY003',
          'paid_amount': 50000.00,
          'payment_month': 'March 2024',
          'payment_date': '2024-03-31',
          'payment_type': 'Monthly',
        },
        {
          'id': 4,
          'payment_id': 'PAY004',
          'paid_amount': 50000.00,
          'payment_month': 'April 2024',
          'payment_date': '2024-04-30',
          'payment_type': 'Monthly',
        },
        {
          'id': 5,
          'payment_id': 'PAY005',
          'paid_amount': 50000.00,
          'payment_month': 'May 2024',
          'payment_date': '2024-05-31',
          'payment_type': 'Monthly',
        },
        {
          'id': 6,
          'payment_id': 'PAY006',
          'paid_amount': 50000.00,
          'payment_month': 'June 2024',
          'payment_date': '2024-06-30',
          'payment_type': 'Monthly',
        },
        {
          'id': 7,
          'payment_id': 'PAY007',
          'paid_amount': 50000.00,
          'payment_month': 'July 2024',
          'payment_date': '2024-07-31',
          'payment_type': 'Monthly',
        },
        {
          'id': 8,
          'payment_id': 'PAY008',
          'paid_amount': 50000.00,
          'payment_month': 'August 2024',
          'payment_date': '2024-08-31',
          'payment_type': 'Monthly',
        },
        {
          'id': 9,
          'payment_id': 'PAY009',
          'paid_amount': 50000.00,
          'payment_month': 'September 2024',
          'payment_date': '2024-09-30',
          'payment_type': 'Monthly',
        },
        {
          'id': 10,
          'payment_id': 'PAY010',
          'paid_amount': 50000.00,
          'payment_month': 'October 2024',
          'payment_date': '2024-10-31',
          'payment_type': 'Monthly',
        },
      ];

      _total = _payslipsList.length;
      _status = PayslipsStatus.success;
      notifyListeners();
    } catch (e) {
      _status = PayslipsStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void refresh() {
    loadPayslipsData();
  }
}

