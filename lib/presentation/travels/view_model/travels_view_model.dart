import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum TravelsStatus { initial, loading, success, error }

class TravelsViewModel extends ChangeNotifier {
  TravelsStatus _status = TravelsStatus.initial;
  String? _errorMessage;

  TravelsStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _travelsList = [];
  int _total = 0;
  
  List<Map<String, dynamic>> get travelsList => _travelsList;
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

  Future<void> loadTravelsData() async {
    _status = TravelsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // Dummy data matching the HTML table structure
      _travelsList = [
        {
          'employee': 'John Doe',
          'purpose_of_visit': 'Client Meeting',
          'place_of_visit': 'New York',
          'start_date': '2024-12-15',
          'end_date': '2024-12-18',
          'approval_status': 'Approved',
          'added_by': 'HR Manager',
        },
        {
          'employee': 'Jane Smith',
          'purpose_of_visit': 'Training Program',
          'place_of_visit': 'London',
          'start_date': '2024-12-20',
          'end_date': '2024-12-22',
          'approval_status': 'Pending',
          'added_by': 'Department Head',
        },
        {
          'employee': 'Mike Johnson',
          'purpose_of_visit': 'Conference',
          'place_of_visit': 'San Francisco',
          'start_date': '2024-12-10',
          'end_date': '2024-12-12',
          'approval_status': 'Approved',
          'added_by': 'HR Manager',
        },
        {
          'employee': 'Sarah Williams',
          'purpose_of_visit': 'Site Visit',
          'place_of_visit': 'Chicago',
          'start_date': '2024-12-25',
          'end_date': '2024-12-27',
          'approval_status': 'Pending',
          'added_by': 'Project Manager',
        },
        {
          'employee': 'David Brown',
          'purpose_of_visit': 'Business Development',
          'place_of_visit': 'Tokyo',
          'start_date': '2024-12-05',
          'end_date': '2024-12-08',
          'approval_status': 'Approved',
          'added_by': 'Sales Director',
        },
        {
          'employee': 'Emily Davis',
          'purpose_of_visit': 'Workshop',
          'place_of_visit': 'Boston',
          'start_date': '2024-12-28',
          'end_date': '2024-12-30',
          'approval_status': 'Rejected',
          'added_by': 'HR Manager',
        },
        {
          'employee': 'Robert Wilson',
          'purpose_of_visit': 'Client Presentation',
          'place_of_visit': 'Los Angeles',
          'start_date': '2024-12-01',
          'end_date': '2024-12-03',
          'approval_status': 'Approved',
          'added_by': 'Manager',
        },
        {
          'employee': 'Lisa Anderson',
          'purpose_of_visit': 'Team Building',
          'place_of_visit': 'Miami',
          'start_date': '2024-12-22',
          'end_date': '2024-12-24',
          'approval_status': 'Pending',
          'added_by': 'HR Manager',
        },
        {
          'employee': 'James Taylor',
          'purpose_of_visit': 'Vendor Meeting',
          'place_of_visit': 'Seattle',
          'start_date': '2024-12-08',
          'end_date': '2024-12-10',
          'approval_status': 'Approved',
          'added_by': 'Operations Manager',
        },
        {
          'employee': 'Maria Garcia',
          'purpose_of_visit': 'Seminar',
          'place_of_visit': 'Denver',
          'start_date': '2024-12-18',
          'end_date': '2024-12-20',
          'approval_status': 'Pending',
          'added_by': 'Department Head',
        },
      ];

      _total = _travelsList.length;
      _status = TravelsStatus.success;
      notifyListeners();
    } catch (e) {
      _status = TravelsStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void refresh() {
    loadTravelsData();
  }
}

