import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum JobAppliedStatus { initial, loading, success, error }

class JobAppliedViewModel extends ChangeNotifier {
  JobAppliedStatus _status = JobAppliedStatus.initial;
  String? _errorMessage;

  JobAppliedStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _jobsAppliedList = [];
  int _total = 0;
  
  List<Map<String, dynamic>> get jobsAppliedList => _jobsAppliedList;
  int get total => _total;

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'shortlisted':
        return Colors.blue;
      case 'interview':
        return Colors.purple;
      case 'rejected':
        return Colors.red;
      case 'hired':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color getStatusColor(String status) => _getStatusColor(status);

  Future<void> loadJobsAppliedData() async {
    _status = JobAppliedStatus.loading;
    _errorMessage = null;
    notifyListeners();

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // Dummy data matching the HTML table structure
      _jobsAppliedList = [
        {
          'job_title': 'Senior Software Engineer',
          'candidate_name': 'John Doe',
          'email': 'john.doe@example.com',
          'status': 'Pending',
          'apply_date': '2024-12-01',
        },
        {
          'job_title': 'Product Manager',
          'candidate_name': 'Jane Smith',
          'email': 'jane.smith@example.com',
          'status': 'Shortlisted',
          'apply_date': '2024-11-28',
        },
        {
          'job_title': 'UX Designer',
          'candidate_name': 'Mike Johnson',
          'email': 'mike.johnson@example.com',
          'status': 'Interview',
          'apply_date': '2024-11-25',
        },
        {
          'job_title': 'Data Analyst',
          'candidate_name': 'Sarah Williams',
          'email': 'sarah.williams@example.com',
          'status': 'Rejected',
          'apply_date': '2024-11-20',
        },
        {
          'job_title': 'Marketing Manager',
          'candidate_name': 'David Brown',
          'email': 'david.brown@example.com',
          'status': 'Hired',
          'apply_date': '2024-11-18',
        },
        {
          'job_title': 'DevOps Engineer',
          'candidate_name': 'Emily Davis',
          'email': 'emily.davis@example.com',
          'status': 'Pending',
          'apply_date': '2024-11-15',
        },
        {
          'job_title': 'Sales Executive',
          'candidate_name': 'Robert Wilson',
          'email': 'robert.wilson@example.com',
          'status': 'Shortlisted',
          'apply_date': '2024-11-12',
        },
        {
          'job_title': 'HR Manager',
          'candidate_name': 'Lisa Anderson',
          'email': 'lisa.anderson@example.com',
          'status': 'Interview',
          'apply_date': '2024-11-10',
        },
        {
          'job_title': 'Financial Analyst',
          'candidate_name': 'James Taylor',
          'email': 'james.taylor@example.com',
          'status': 'Pending',
          'apply_date': '2024-11-08',
        },
        {
          'job_title': 'Content Writer',
          'candidate_name': 'Maria Garcia',
          'email': 'maria.garcia@example.com',
          'status': 'Rejected',
          'apply_date': '2024-11-05',
        },
      ];

      _total = _jobsAppliedList.length;
      _status = JobAppliedStatus.success;
      notifyListeners();
    } catch (e) {
      _status = JobAppliedStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void refresh() {
    loadJobsAppliedData();
  }
}

