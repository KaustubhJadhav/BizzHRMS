import 'package:flutter/foundation.dart';

enum OfficeShiftStatus { initial, loading, success, error }

class OfficeShiftViewModel extends ChangeNotifier {
  OfficeShiftStatus _status = OfficeShiftStatus.initial;
  String? _errorMessage;

  OfficeShiftStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _officeShiftsList = [];
  int _total = 0;
  
  List<Map<String, dynamic>> get officeShiftsList => _officeShiftsList;
  int get total => _total;

  Future<void> loadOfficeShiftsData() async {
    _status = OfficeShiftStatus.loading;
    _errorMessage = null;
    notifyListeners();

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // Dummy data matching the HTML table structure
      _officeShiftsList = [
        {
          'office_shift': 'Morning Shift',
          'duration': '09:00 - 17:00',
        },
        {
          'office_shift': 'Afternoon Shift',
          'duration': '13:00 - 21:00',
        },
        {
          'office_shift': 'Night Shift',
          'duration': '21:00 - 05:00',
        },
        {
          'office_shift': 'Flexible Shift',
          'duration': '10:00 - 18:00',
        },
        {
          'office_shift': 'Part-time Morning',
          'duration': '09:00 - 13:00',
        },
        {
          'office_shift': 'Part-time Evening',
          'duration': '17:00 - 21:00',
        },
        {
          'office_shift': 'Weekend Shift',
          'duration': '10:00 - 16:00',
        },
        {
          'office_shift': 'Rotating Shift',
          'duration': '08:00 - 16:00',
        },
        {
          'office_shift': 'Extended Shift',
          'duration': '08:00 - 18:00',
        },
        {
          'office_shift': 'Short Shift',
          'duration': '10:00 - 14:00',
        },
      ];

      _total = _officeShiftsList.length;
      _status = OfficeShiftStatus.success;
      notifyListeners();
    } catch (e) {
      _status = OfficeShiftStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void refresh() {
    loadOfficeShiftsData();
  }
}

