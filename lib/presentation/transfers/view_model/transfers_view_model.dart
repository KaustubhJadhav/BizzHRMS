import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';
import 'package:bizzhrms_flutter_app/data/data_sources/remote_data_source.dart';

enum TransfersStatus { initial, loading, success, error }

class TransfersViewModel extends ChangeNotifier {
  TransfersStatus _status = TransfersStatus.initial;
  String? _errorMessage;
  final RemoteDataSource _remoteDataSource = RemoteDataSource();

  TransfersStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _transfersList = [];
  int _total = 0;
  
  List<Map<String, dynamic>> get transfersList => _transfersList;
  int get total => _total;

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color getStatusColor(String status) => _getStatusColor(status);

  Future<void> loadTransfersData() async {
    _status = TransfersStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token from preferences
      final token = await PreferencesHelper.getUserToken();

      if (token == null || token.isEmpty) {
        _status = TransfersStatus.error;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return;
      }

      // Fetch transfer list from API
      final response = await _remoteDataSource.getTransferList(token);

      if (response['status'] == true) {
        // Use total from API response if available
        if (response['total'] != null) {
          _total = response['total'] is int 
              ? response['total'] 
              : int.tryParse(response['total'].toString()) ?? 0;
        }

        // Handle data array and map API fields to UI-expected fields
        if (response['data'] != null && response['data'] is List) {
          final transfersData = response['data'] as List;
          _transfersList = transfersData.map((item) {
            if (item is Map<String, dynamic>) {
              // Map API fields to UI-expected fields
              final mappedItem = Map<String, dynamic>.from(item);
              
              // Map transfer_from to transfer_to_department for UI compatibility
              if (item['transfer_from'] != null && item['transfer_to_department'] == null) {
                mappedItem['transfer_to_department'] = item['transfer_from'];
              }
              
              // Map transfer_to to transfer_to_branch for UI compatibility
              if (item['transfer_to'] != null && item['transfer_to_branch'] == null) {
                mappedItem['transfer_to_branch'] = item['transfer_to'];
              }
              
              // Map transfer_status to status for UI compatibility
              if (item['transfer_status'] != null && item['status'] == null) {
                mappedItem['status'] = item['transfer_status'];
              }
              
              return mappedItem;
            }
            return item as Map<String, dynamic>;
          }).toList();
          
          // Update total from list length if API total wasn't provided
          if (_total == 0) {
            _total = _transfersList.length;
          }
        } else {
          _transfersList = [];
          if (_total == 0) {
            _total = 0;
          }
        }

        _status = TransfersStatus.success;
        notifyListeners();
      } else {
        _status = TransfersStatus.error;
        _errorMessage = response['message']?.toString() ?? 'Failed to load transfers';
        notifyListeners();
      }
    } catch (e) {
      _status = TransfersStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void refresh() {
    loadTransfersData();
  }

  /// Fetch transfer details by transfer_id
  Future<Map<String, dynamic>?> getTransferDetails(String transferId) async {
    try {
      // Get token from preferences
      final token = await PreferencesHelper.getUserToken();

      if (token == null || token.isEmpty) {
        return null;
      }

      // Fetch transfer details from API
      final response = await _remoteDataSource.getTransferDetailById(token, transferId);

      if (response['status'] == true && response['data'] != null) {
        final transferData = response['data'] as Map<String, dynamic>;
        
        // Map API fields to UI-expected fields
        final mappedData = Map<String, dynamic>.from(transferData);
        
        // Map transfer_from to transfer_to_department for UI compatibility
        if (transferData['transfer_from'] != null && transferData['transfer_to_department'] == null) {
          mappedData['transfer_to_department'] = transferData['transfer_from'];
        }
        
        // Map transfer_to to transfer_to_branch for UI compatibility
        if (transferData['transfer_to'] != null && transferData['transfer_to_branch'] == null) {
          mappedData['transfer_to_branch'] = transferData['transfer_to'];
        }
        
        // Map transfer_status to status for UI compatibility
        if (transferData['transfer_status'] != null && transferData['status'] == null) {
          mappedData['status'] = transferData['transfer_status'];
        }
        
        return mappedData;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching transfer details: $e');
      return null;
    }
  }
}

