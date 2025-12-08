import 'package:flutter/foundation.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';
import 'package:bizzhrms_flutter_app/data/data_sources/remote_data_source.dart';

enum AwardsStatus { initial, loading, success, error }

class AwardsViewModel extends ChangeNotifier {
  AwardsStatus _status = AwardsStatus.initial;
  String? _errorMessage;
  final RemoteDataSource _remoteDataSource = RemoteDataSource();

  AwardsStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _awardsList = [];
  int _total = 0;
  
  List<Map<String, dynamic>> get awardsList => _awardsList;
  int get total => _total;

  Future<void> loadAwardsData() async {
    _status = AwardsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token from preferences
      final token = await PreferencesHelper.getUserToken();

      if (token == null || token.isEmpty) {
        _status = AwardsStatus.error;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return;
      }

      // Fetch awards list from API
      final response = await _remoteDataSource.getAwardsList(token);

      if (response['status'] == true) {
        // Use total from API response if available
        if (response['total'] != null) {
          _total = response['total'] is int 
              ? response['total'] 
              : int.tryParse(response['total'].toString()) ?? 0;
        }

        // Handle data array and map API fields to UI-expected fields
        if (response['data'] != null && response['data'] is List) {
          final awardsData = response['data'] as List;
          _awardsList = awardsData.map((item) {
            if (item is Map<String, dynamic>) {
              // Map API fields to UI-expected fields
              final mappedItem = Map<String, dynamic>.from(item);
              
              // Map award_gift to gift for UI compatibility
              if (item['award_gift'] != null && item['gift'] == null) {
                mappedItem['gift'] = item['award_gift'];
              }
              
              // Map award_cash_price to cash_price for UI compatibility
              if (item['award_cash_price'] != null && item['cash_price'] == null) {
                mappedItem['cash_price'] = item['award_cash_price'];
              }
              
              return mappedItem;
            }
            return item as Map<String, dynamic>;
          }).toList();
          
          // Update total from list length if API total wasn't provided
          if (_total == 0) {
            _total = _awardsList.length;
          }
        } else {
          _awardsList = [];
          if (_total == 0) {
            _total = 0;
          }
        }

        _status = AwardsStatus.success;
        notifyListeners();
      } else {
        _status = AwardsStatus.error;
        _errorMessage = response['message']?.toString() ?? 'Failed to load awards';
        notifyListeners();
      }
    } catch (e) {
      _status = AwardsStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void refresh() {
    loadAwardsData();
  }

  /// Fetch award details by award_id
  Future<Map<String, dynamic>?> getAwardDetails(String awardId) async {
    try {
      // Get token from preferences
      final token = await PreferencesHelper.getUserToken();

      if (token == null || token.isEmpty) {
        return null;
      }

      // Fetch award details from API
      final response = await _remoteDataSource.getAwardDetailById(token, awardId);

      if (response['status'] == true && response['data'] != null) {
        final awardData = response['data'] as Map<String, dynamic>;
        
        // Map API fields to UI-expected fields
        final mappedData = Map<String, dynamic>.from(awardData);
        
        // Map award_gift to gift for UI compatibility
        if (awardData['award_gift'] != null && awardData['gift'] == null) {
          mappedData['gift'] = awardData['award_gift'];
        }
        
        // Map award_cash_price to cash_price for UI compatibility
        if (awardData['award_cash_price'] != null && awardData['cash_price'] == null) {
          mappedData['cash_price'] = awardData['award_cash_price'];
        }
        
        return mappedData;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching award details: $e');
      return null;
    }
  }
}

