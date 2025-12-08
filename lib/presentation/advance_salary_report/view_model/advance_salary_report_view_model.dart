import 'package:flutter/foundation.dart';

enum AdvanceSalaryReportStatus { initial, loading, success, error }

class AdvanceSalaryReportViewModel extends ChangeNotifier {
  AdvanceSalaryReportStatus _status = AdvanceSalaryReportStatus.initial;
  String? _errorMessage;

  AdvanceSalaryReportStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _advanceSalaryReportList = [];
  int _total = 0;
  
  List<Map<String, dynamic>> get advanceSalaryReportList => _advanceSalaryReportList;
  int get total => _total;

  Future<void> loadAdvanceSalaryReportData() async {
    _status = AdvanceSalaryReportStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _advanceSalaryReportList = [
        {
          'id': 1,
          'employee': 'John Doe',
          'total_amount': 75000.00,
          'total_paid_amount': 50000.00,
          'remaining_amount': 25000.00,
          'status': 'Partially Paid', // Fully Paid, Partially Paid, Pending
        },
        {
          'id': 2,
          'employee': 'Jane Smith',
          'total_amount': 90000.00,
          'total_paid_amount': 30000.00,
          'remaining_amount': 60000.00,
          'status': 'Partially Paid',
        },
        {
          'id': 3,
          'employee': 'Alice Brown',
          'total_amount': 60000.00,
          'total_paid_amount': 60000.00,
          'remaining_amount': 0.00,
          'status': 'Fully Paid',
        },
        {
          'id': 4,
          'employee': 'Bob Johnson',
          'total_amount': 105000.00,
          'total_paid_amount': 0.00,
          'remaining_amount': 105000.00,
          'status': 'Pending',
        },
        {
          'id': 5,
          'employee': 'Charlie Green',
          'total_amount': 45000.00,
          'total_paid_amount': 45000.00,
          'remaining_amount': 0.00,
          'status': 'Fully Paid',
        },
        {
          'id': 6,
          'employee': 'Diana Prince',
          'total_amount': 120000.00,
          'total_paid_amount': 40000.00,
          'remaining_amount': 80000.00,
          'status': 'Partially Paid',
        },
        {
          'id': 7,
          'employee': 'Eve Adams',
          'total_amount': 54000.00,
          'total_paid_amount': 54000.00,
          'remaining_amount': 0.00,
          'status': 'Fully Paid',
        },
        {
          'id': 8,
          'employee': 'Frank White',
          'total_amount': 84000.00,
          'total_paid_amount': 28000.00,
          'remaining_amount': 56000.00,
          'status': 'Partially Paid',
        },
        {
          'id': 9,
          'employee': 'Grace Lee',
          'total_amount': 66000.00,
          'total_paid_amount': 66000.00,
          'remaining_amount': 0.00,
          'status': 'Fully Paid',
        },
        {
          'id': 10,
          'employee': 'Harry Green',
          'total_amount': 96000.00,
          'total_paid_amount': 0.00,
          'remaining_amount': 96000.00,
          'status': 'Pending',
        },
      ];

      _total = _advanceSalaryReportList.length;
      _status = AdvanceSalaryReportStatus.success;
      notifyListeners();
    } catch (e) {
      _status = AdvanceSalaryReportStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void refresh() {
    loadAdvanceSalaryReportData();
  }
}

