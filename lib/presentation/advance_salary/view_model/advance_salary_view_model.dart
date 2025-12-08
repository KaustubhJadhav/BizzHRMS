import 'package:flutter/foundation.dart';

enum AdvanceSalaryStatus { initial, loading, success, error }

class AdvanceSalaryViewModel extends ChangeNotifier {
  AdvanceSalaryStatus _status = AdvanceSalaryStatus.initial;
  String? _errorMessage;

  AdvanceSalaryStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _advanceSalaryList = [];
  int _total = 0;
  
  List<Map<String, dynamic>> get advanceSalaryList => _advanceSalaryList;
  int get total => _total;

  Future<void> loadAdvanceSalaryData() async {
    _status = AdvanceSalaryStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _advanceSalaryList = [
        {
          'id': 1,
          'employee': 'John Doe',
          'amount': 25000.00,
          'month_year': 'January 2024',
          'one_time_deduct': 'Yes',
          'emi': 0.00,
          'created_at': '2024-01-05',
          'status': 'Approved', // Approved, Pending, Rejected
        },
        {
          'id': 2,
          'employee': 'Jane Smith',
          'amount': 30000.00,
          'month_year': 'February 2024',
          'one_time_deduct': 'No',
          'emi': 10000.00,
          'created_at': '2024-02-10',
          'status': 'Pending',
        },
        {
          'id': 3,
          'employee': 'Alice Brown',
          'amount': 20000.00,
          'month_year': 'March 2024',
          'one_time_deduct': 'Yes',
          'emi': 0.00,
          'created_at': '2024-03-15',
          'status': 'Approved',
        },
        {
          'id': 4,
          'employee': 'Bob Johnson',
          'amount': 35000.00,
          'month_year': 'April 2024',
          'one_time_deduct': 'No',
          'emi': 11666.67,
          'created_at': '2024-04-20',
          'status': 'Rejected',
        },
        {
          'id': 5,
          'employee': 'Charlie Green',
          'amount': 15000.00,
          'month_year': 'May 2024',
          'one_time_deduct': 'Yes',
          'emi': 0.00,
          'created_at': '2024-05-01',
          'status': 'Approved',
        },
        {
          'id': 6,
          'employee': 'Diana Prince',
          'amount': 40000.00,
          'month_year': 'June 2024',
          'one_time_deduct': 'No',
          'emi': 13333.33,
          'created_at': '2024-06-10',
          'status': 'Pending',
        },
        {
          'id': 7,
          'employee': 'Eve Adams',
          'amount': 18000.00,
          'month_year': 'July 2024',
          'one_time_deduct': 'Yes',
          'emi': 0.00,
          'created_at': '2024-07-15',
          'status': 'Approved',
        },
        {
          'id': 8,
          'employee': 'Frank White',
          'amount': 28000.00,
          'month_year': 'August 2024',
          'one_time_deduct': 'No',
          'emi': 9333.33,
          'created_at': '2024-08-20',
          'status': 'Pending',
        },
        {
          'id': 9,
          'employee': 'Grace Lee',
          'amount': 22000.00,
          'month_year': 'September 2024',
          'one_time_deduct': 'Yes',
          'emi': 0.00,
          'created_at': '2024-09-05',
          'status': 'Approved',
        },
        {
          'id': 10,
          'employee': 'Harry Green',
          'amount': 32000.00,
          'month_year': 'October 2024',
          'one_time_deduct': 'No',
          'emi': 10666.67,
          'created_at': '2024-10-12',
          'status': 'Rejected',
        },
      ];

      _total = _advanceSalaryList.length;
      _status = AdvanceSalaryStatus.success;
      notifyListeners();
    } catch (e) {
      _status = AdvanceSalaryStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void refresh() {
    loadAdvanceSalaryData();
  }
}

