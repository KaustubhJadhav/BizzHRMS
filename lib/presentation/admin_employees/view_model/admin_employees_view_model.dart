import 'package:flutter/foundation.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';
import 'package:bizzhrms_flutter_app/data/data_sources/remote_data_source.dart';

enum AdminEmployeesStatus { initial, loading, success, error }

class AdminEmployeesViewModel extends ChangeNotifier {
  AdminEmployeesStatus _status = AdminEmployeesStatus.initial;
  String? _errorMessage;
  final RemoteDataSource _remoteDataSource = RemoteDataSource();

  AdminEmployeesStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _employeesList = [];
  int _total = 0;
  
  List<Map<String, dynamic>> get employeesList => _employeesList;
  int get total => _total;

  Future<void> loadEmployees() async {
    _status = AdminEmployeesStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await PreferencesHelper.getUserToken();

      if (token == null || token.isEmpty) {
        _status = AdminEmployeesStatus.error;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return;
      }

      final response = await _remoteDataSource.getAdminEmployees(token);

      if (response['status'] == true && response['data'] != null) {
        final data = response['data'];
        if (data is List) {
          _employeesList = data.cast<Map<String, dynamic>>();
          _total = response['total_records'] ?? _employeesList.length;
        } else {
          _employeesList = [];
          _total = 0;
        }
        
        _status = AdminEmployeesStatus.success;
        notifyListeners();
      } else {
        _status = AdminEmployeesStatus.error;
        _errorMessage = response['message']?.toString() ?? 'Failed to load employees';
        notifyListeners();
      }
    } catch (e) {
      _status = AdminEmployeesStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void refresh() {
    loadEmployees();
  }
}

