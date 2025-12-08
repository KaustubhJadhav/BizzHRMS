import 'package:flutter/foundation.dart';

enum JobInterviewStatus { initial, loading, success, error }

class JobInterviewViewModel extends ChangeNotifier {
  JobInterviewStatus _status = JobInterviewStatus.initial;
  String? _errorMessage;

  JobInterviewStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _jobInterviewsList = [];
  int _total = 0;
  
  List<Map<String, dynamic>> get jobInterviewsList => _jobInterviewsList;
  int get total => _total;

  Future<void> loadJobInterviewsData() async {
    _status = JobInterviewStatus.loading;
    _errorMessage = null;
    notifyListeners();

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // Dummy data matching the HTML table structure
      _jobInterviewsList = [
        {
          'job_title': 'Senior Software Engineer',
          'message': 'Please attend the interview at the scheduled time.',
          'interview_place': 'Conference Room A',
          'interview_date_time': '2024-12-15 10:00 AM',
          'added_by': 'HR Manager',
        },
        {
          'job_title': 'Product Manager',
          'message': 'Technical and HR round interview scheduled.',
          'interview_place': 'Main Office - Room 201',
          'interview_date_time': '2024-12-18 02:00 PM',
          'added_by': 'Department Head',
        },
        {
          'job_title': 'UX Designer',
          'message': 'Portfolio review and design discussion.',
          'interview_place': 'Design Studio',
          'interview_date_time': '2024-12-20 11:00 AM',
          'added_by': 'HR Manager',
        },
        {
          'job_title': 'Data Analyst',
          'message': 'Case study presentation required.',
          'interview_place': 'Meeting Room B',
          'interview_date_time': '2024-12-22 09:30 AM',
          'added_by': 'Project Manager',
        },
        {
          'job_title': 'Marketing Manager',
          'message': 'Final round interview with senior management.',
          'interview_place': 'Executive Conference Room',
          'interview_date_time': '2024-12-25 03:00 PM',
          'added_by': 'Sales Director',
        },
        {
          'job_title': 'DevOps Engineer',
          'message': 'Technical assessment and system architecture discussion.',
          'interview_place': 'Tech Lab',
          'interview_date_time': '2024-12-28 10:30 AM',
          'added_by': 'HR Manager',
        },
        {
          'job_title': 'Sales Executive',
          'message': 'Role play and sales strategy discussion.',
          'interview_place': 'Sales Office',
          'interview_date_time': '2024-12-30 01:00 PM',
          'added_by': 'Manager',
        },
        {
          'job_title': 'HR Manager',
          'message': 'Behavioral and situational interview.',
          'interview_place': 'HR Department',
          'interview_date_time': '2025-01-02 10:00 AM',
          'added_by': 'HR Director',
        },
        {
          'job_title': 'Financial Analyst',
          'message': 'Financial modeling and analysis test.',
          'interview_place': 'Finance Office',
          'interview_date_time': '2025-01-05 11:00 AM',
          'added_by': 'Operations Manager',
        },
        {
          'job_title': 'Content Writer',
          'message': 'Writing sample and content strategy discussion.',
          'interview_place': 'Marketing Department',
          'interview_date_time': '2025-01-08 02:30 PM',
          'added_by': 'Department Head',
        },
      ];

      _total = _jobInterviewsList.length;
      _status = JobInterviewStatus.success;
      notifyListeners();
    } catch (e) {
      _status = JobInterviewStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void refresh() {
    loadJobInterviewsData();
  }
}

