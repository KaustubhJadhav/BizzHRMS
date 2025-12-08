import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum WarningsStatus { initial, loading, success, error }

class WarningsViewModel extends ChangeNotifier {
  WarningsStatus _status = WarningsStatus.initial;
  String? _errorMessage;

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
    switch (type.toLowerCase()) {
      case 'verbal':
        return Colors.blue;
      case 'written':
        return Colors.orange;
      case 'final':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color getWarningTypeColor(String type) => _getWarningTypeColor(type);

  Future<void> loadWarningsData() async {
    _status = WarningsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // Dummy data matching the HTML table structure
      _warningsList = [
        {
          'warning_date': '2024-12-01',
          'subject': 'Late Arrival',
          'warning_type': 'Verbal',
          'approval_status': 'Approved',
          'warning_by': 'HR Manager',
          'details': 'Warning issued for repeated late arrivals to work.',
        },
        {
          'warning_date': '2024-11-28',
          'subject': 'Inappropriate Behavior',
          'warning_type': 'Written',
          'approval_status': 'Pending',
          'warning_by': 'Department Head',
          'details': 'Written warning for inappropriate behavior in the workplace.',
        },
        {
          'warning_date': '2024-11-25',
          'subject': 'Violation of Company Policy',
          'warning_type': 'Written',
          'approval_status': 'Approved',
          'warning_by': 'HR Manager',
          'details': 'Warning for violation of company policy regarding attendance.',
        },
        {
          'warning_date': '2024-11-20',
          'subject': 'Poor Performance',
          'warning_type': 'Verbal',
          'approval_status': 'Approved',
          'warning_by': 'Supervisor',
          'details': 'Verbal warning regarding poor performance and missed deadlines.',
        },
        {
          'warning_date': '2024-11-18',
          'subject': 'Final Warning',
          'warning_type': 'Final',
          'approval_status': 'Approved',
          'warning_by': 'HR Director',
          'details': 'Final warning issued for repeated policy violations.',
        },
        {
          'warning_date': '2024-11-15',
          'subject': 'Unprofessional Conduct',
          'warning_type': 'Written',
          'approval_status': 'Pending',
          'warning_by': 'Manager',
          'details': 'Warning for unprofessional conduct during client meetings.',
        },
        {
          'warning_date': '2024-11-12',
          'subject': 'Absenteeism',
          'warning_type': 'Written',
          'approval_status': 'Approved',
          'warning_by': 'HR Manager',
          'details': 'Written warning for excessive absenteeism without proper notice.',
        },
        {
          'warning_date': '2024-11-10',
          'subject': 'Code of Conduct Violation',
          'warning_type': 'Verbal',
          'approval_status': 'Rejected',
          'warning_by': 'Department Head',
          'details': 'Verbal warning for violation of company code of conduct.',
        },
        {
          'warning_date': '2024-11-08',
          'subject': 'Work Quality Issues',
          'warning_type': 'Written',
          'approval_status': 'Approved',
          'warning_by': 'Supervisor',
          'details': 'Warning regarding consistent work quality issues and errors.',
        },
        {
          'warning_date': '2024-11-05',
          'subject': 'Team Disruption',
          'warning_type': 'Verbal',
          'approval_status': 'Pending',
          'warning_by': 'Team Lead',
          'details': 'Verbal warning for behavior that disrupts team harmony.',
        },
      ];

      _total = _warningsList.length;
      _status = WarningsStatus.success;
      notifyListeners();
    } catch (e) {
      _status = WarningsStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void refresh() {
    loadWarningsData();
  }
}

