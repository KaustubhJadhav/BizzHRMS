import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum TicketsStatus { initial, loading, success, error }

class TicketsViewModel extends ChangeNotifier {
  TicketsStatus _status = TicketsStatus.initial;
  String? _errorMessage;

  TicketsStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _ticketsList = [];
  int _total = 0;
  
  List<Map<String, dynamic>> get ticketsList => _ticketsList;
  int get total => _total;

  String _getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return 'Low';
      case 2:
        return 'Medium';
      case 3:
        return 'High';
      case 4:
        return 'Critical';
      default:
        return 'Unknown';
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getPriorityText(int priority) => _getPriorityText(priority);
  Color getPriorityColor(int priority) => _getPriorityColor(priority);

  Future<void> loadTicketsData() async {
    _status = TicketsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // Dummy data matching the HTML table structure
      _ticketsList = [
        {
          'ticket_code': 'TKT-001',
          'subject': 'System Login Issue',
          'employee': 'John Doe',
          'priority': 3, // High
          'status': 'Open',
          'date': '2024-12-01',
        },
        {
          'ticket_code': 'TKT-002',
          'subject': 'Email Configuration',
          'employee': 'Jane Smith',
          'priority': 2, // Medium
          'status': 'In Progress',
          'date': '2024-11-28',
        },
        {
          'ticket_code': 'TKT-003',
          'subject': 'Password Reset Request',
          'employee': 'Mike Johnson',
          'priority': 1, // Low
          'status': 'Resolved',
          'date': '2024-11-25',
        },
        {
          'ticket_code': 'TKT-004',
          'subject': 'Server Downtime',
          'employee': 'Sarah Williams',
          'priority': 4, // Critical
          'status': 'Open',
          'date': '2024-12-03',
        },
        {
          'ticket_code': 'TKT-005',
          'subject': 'Software Installation',
          'employee': 'David Brown',
          'priority': 2, // Medium
          'status': 'In Progress',
          'date': '2024-11-30',
        },
        {
          'ticket_code': 'TKT-006',
          'subject': 'Network Connectivity',
          'employee': 'Emily Davis',
          'priority': 3, // High
          'status': 'Resolved',
          'date': '2024-11-22',
        },
        {
          'ticket_code': 'TKT-007',
          'subject': 'Printer Setup',
          'employee': 'Robert Wilson',
          'priority': 1, // Low
          'status': 'Open',
          'date': '2024-12-02',
        },
        {
          'ticket_code': 'TKT-008',
          'subject': 'Database Access Issue',
          'employee': 'Lisa Anderson',
          'priority': 4, // Critical
          'status': 'In Progress',
          'date': '2024-11-29',
        },
        {
          'ticket_code': 'TKT-009',
          'subject': 'VPN Configuration',
          'employee': 'James Taylor',
          'priority': 2, // Medium
          'status': 'Resolved',
          'date': '2024-11-20',
        },
        {
          'ticket_code': 'TKT-010',
          'subject': 'Application Update',
          'employee': 'Maria Garcia',
          'priority': 3, // High
          'status': 'Open',
          'date': '2024-12-04',
        },
      ];

      _total = _ticketsList.length;
      _status = TicketsStatus.success;
      notifyListeners();
    } catch (e) {
      _status = TicketsStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void refresh() {
    loadTicketsData();
  }
}

