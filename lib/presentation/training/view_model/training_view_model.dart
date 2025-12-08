import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum TrainingStatus { initial, loading, success, error }

class TrainingViewModel extends ChangeNotifier {
  TrainingStatus _status = TrainingStatus.initial;
  String? _errorMessage;

  TrainingStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _trainingList = [];
  int _total = 0;
  
  List<Map<String, dynamic>> get trainingList => _trainingList;
  int get total => _total;

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in progress':
        return Colors.orange;
      case 'pending':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color getStatusColor(String status) => _getStatusColor(status);

  Future<void> loadTrainingData() async {
    _status = TrainingStatus.loading;
    _errorMessage = null;
    notifyListeners();

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // Dummy data matching the HTML table structure
      _trainingList = [
        {
          'employee': 'John Doe',
          'training_type': 'Leadership Development',
          'trainer': 'Dr. Sarah Johnson',
          'training_duration': '5 Days',
          'cost': '₹ 25,000',
          'status': 'Completed',
        },
        {
          'employee': 'Jane Smith',
          'training_type': 'Project Management',
          'trainer': 'Michael Brown',
          'training_duration': '3 Days',
          'cost': '₹ 15,000',
          'status': 'In Progress',
        },
        {
          'employee': 'Mike Johnson',
          'training_type': 'Communication Skills',
          'trainer': 'Emily Davis',
          'training_duration': '2 Days',
          'cost': '₹ 10,000',
          'status': 'Pending',
        },
        {
          'employee': 'Sarah Williams',
          'training_type': 'Technical Training',
          'trainer': 'Robert Wilson',
          'training_duration': '7 Days',
          'cost': '₹ 35,000',
          'status': 'Completed',
        },
        {
          'employee': 'David Brown',
          'training_type': 'Sales Training',
          'trainer': 'Lisa Anderson',
          'training_duration': '4 Days',
          'cost': '₹ 20,000',
          'status': 'In Progress',
        },
        {
          'employee': 'Emily Davis',
          'training_type': 'Customer Service',
          'trainer': 'James Taylor',
          'training_duration': '2 Days',
          'cost': '₹ 8,000',
          'status': 'Completed',
        },
        {
          'employee': 'Robert Wilson',
          'training_type': 'Data Analysis',
          'trainer': 'Maria Garcia',
          'training_duration': '6 Days',
          'cost': '₹ 30,000',
          'status': 'Pending',
        },
        {
          'employee': 'Lisa Anderson',
          'training_type': 'Team Building',
          'trainer': 'John Martinez',
          'training_duration': '1 Day',
          'cost': '₹ 5,000',
          'status': 'Completed',
        },
        {
          'employee': 'James Taylor',
          'training_type': 'Time Management',
          'trainer': 'Patricia Lee',
          'training_duration': '2 Days',
          'cost': '₹ 12,000',
          'status': 'In Progress',
        },
        {
          'employee': 'Maria Garcia',
          'training_type': 'Digital Marketing',
          'trainer': 'Christopher White',
          'training_duration': '5 Days',
          'cost': '₹ 22,000',
          'status': 'Pending',
        },
      ];

      _total = _trainingList.length;
      _status = TrainingStatus.success;
      notifyListeners();
    } catch (e) {
      _status = TrainingStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void refresh() {
    loadTrainingData();
  }
}

