import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum ComplaintsStatus { initial, loading, success, error }

class ComplaintsViewModel extends ChangeNotifier {
  ComplaintsStatus _status = ComplaintsStatus.initial;
  String? _errorMessage;

  ComplaintsStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _complaintsList = [];
  int _total = 0;
  
  List<Map<String, dynamic>> get complaintsList => _complaintsList;
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

  Future<void> loadComplaintsData() async {
    _status = ComplaintsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // Dummy data matching the HTML table structure
      _complaintsList = [
        {
          'complaint_from': 'John Doe',
          'complaint_against': 'Mike Johnson',
          'complaint_title': 'Unprofessional Behavior',
          'complaint_date': '2024-12-01',
          'approval_status': 'Pending',
          'details': 'Reported unprofessional behavior during team meeting.',
        },
        {
          'complaint_from': 'Jane Smith',
          'complaint_against': 'Sarah Williams',
          'complaint_title': 'Workload Distribution',
          'complaint_date': '2024-11-28',
          'approval_status': 'Approved',
          'details': 'Complaint about unfair workload distribution in the department.',
        },
        {
          'complaint_from': 'David Brown',
          'complaint_against': 'Robert Wilson',
          'complaint_title': 'Harassment Complaint',
          'complaint_date': '2024-11-25',
          'approval_status': 'Pending',
          'details': 'Reported harassment incident in the workplace.',
        },
        {
          'complaint_from': 'Emily Davis',
          'complaint_against': 'Lisa Anderson',
          'complaint_title': 'Discrimination',
          'complaint_date': '2024-11-20',
          'approval_status': 'Approved',
          'details': 'Complaint about discriminatory practices.',
        },
        {
          'complaint_from': 'James Taylor',
          'complaint_against': 'Maria Garcia',
          'complaint_title': 'Resource Allocation',
          'complaint_date': '2024-11-18',
          'approval_status': 'Rejected',
          'details': 'Complaint regarding unfair resource allocation.',
        },
        {
          'complaint_from': 'Sarah Williams',
          'complaint_against': 'John Doe',
          'complaint_title': 'Communication Issues',
          'complaint_date': '2024-11-15',
          'approval_status': 'Pending',
          'details': 'Issues with communication and coordination.',
        },
        {
          'complaint_from': 'Mike Johnson',
          'complaint_against': 'Emily Davis',
          'complaint_title': 'Performance Review',
          'complaint_date': '2024-11-12',
          'approval_status': 'Approved',
          'details': 'Complaint about unfair performance review process.',
        },
        {
          'complaint_from': 'Robert Wilson',
          'complaint_against': 'David Brown',
          'complaint_title': 'Work Environment',
          'complaint_date': '2024-11-10',
          'approval_status': 'Pending',
          'details': 'Complaint about uncomfortable work environment.',
        },
        {
          'complaint_from': 'Lisa Anderson',
          'complaint_against': 'James Taylor',
          'complaint_title': 'Team Collaboration',
          'complaint_date': '2024-11-08',
          'approval_status': 'Approved',
          'details': 'Issues with team collaboration and support.',
        },
        {
          'complaint_from': 'Maria Garcia',
          'complaint_against': 'Sarah Williams',
          'complaint_title': 'Project Management',
          'complaint_date': '2024-11-05',
          'approval_status': 'Rejected',
          'details': 'Complaint about project management practices.',
        },
      ];

      _total = _complaintsList.length;
      _status = ComplaintsStatus.success;
      notifyListeners();
    } catch (e) {
      _status = ComplaintsStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void refresh() {
    loadComplaintsData();
  }
}
