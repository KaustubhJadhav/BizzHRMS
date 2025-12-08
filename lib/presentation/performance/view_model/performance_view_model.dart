import 'package:flutter/foundation.dart';

enum PerformanceStatus { initial, loading, success, error }

class PerformanceViewModel extends ChangeNotifier {
  PerformanceStatus _status = PerformanceStatus.initial;
  String? _errorMessage;

  PerformanceStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _performanceList = [];
  int _total = 0;
  
  List<Map<String, dynamic>> get performanceList => _performanceList;
  int get total => _total;

  Future<void> loadPerformanceData() async {
    _status = PerformanceStatus.loading;
    _errorMessage = null;
    notifyListeners();

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // Dummy data matching the HTML table structure
      _performanceList = [
        {
          'employee': 'John Doe',
          'department': 'Engineering',
          'designation': 'Senior Developer',
          'appraisal_date': '2024-12-01',
        },
        {
          'employee': 'Jane Smith',
          'department': 'Sales',
          'designation': 'Sales Manager',
          'appraisal_date': '2024-11-28',
        },
        {
          'employee': 'Mike Johnson',
          'department': 'Marketing',
          'designation': 'Marketing Executive',
          'appraisal_date': '2024-11-25',
        },
        {
          'employee': 'Sarah Williams',
          'department': 'HR',
          'designation': 'HR Manager',
          'appraisal_date': '2024-11-20',
        },
        {
          'employee': 'David Brown',
          'department': 'Finance',
          'designation': 'Finance Analyst',
          'appraisal_date': '2024-11-18',
        },
        {
          'employee': 'Emily Davis',
          'department': 'Engineering',
          'designation': 'Junior Developer',
          'appraisal_date': '2024-11-15',
        },
        {
          'employee': 'Robert Wilson',
          'department': 'Operations',
          'designation': 'Operations Manager',
          'appraisal_date': '2024-11-12',
        },
        {
          'employee': 'Lisa Anderson',
          'department': 'Sales',
          'designation': 'Sales Executive',
          'appraisal_date': '2024-11-10',
        },
        {
          'employee': 'James Taylor',
          'department': 'Engineering',
          'designation': 'Tech Lead',
          'appraisal_date': '2024-11-08',
        },
        {
          'employee': 'Maria Garcia',
          'department': 'Marketing',
          'designation': 'Marketing Manager',
          'appraisal_date': '2024-11-05',
        },
      ];

      _total = _performanceList.length;
      _status = PerformanceStatus.success;
      notifyListeners();
    } catch (e) {
      _status = PerformanceStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void refresh() {
    loadPerformanceData();
  }
}

