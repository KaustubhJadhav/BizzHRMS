import 'package:flutter/foundation.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';
import 'package:bizzhrms_flutter_app/data/data_sources/remote_data_source.dart';

enum PromotionsStatus { initial, loading, success, error }

class PromotionsViewModel extends ChangeNotifier {
  PromotionsStatus _status = PromotionsStatus.initial;
  String? _errorMessage;
  final RemoteDataSource _remoteDataSource = RemoteDataSource();

  PromotionsStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _promotionsList = [];
  int _total = 0;

  List<Map<String, dynamic>> get promotionsList => _promotionsList;
  int get total => _total;

  Future<void> loadPromotionsData() async {
    _status = PromotionsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token from preferences
      final token = await PreferencesHelper.getUserToken();

      if (token == null || token.isEmpty) {
        _status = PromotionsStatus.error;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return;
      }

      // Fetch promotion list from API
      final response = await _remoteDataSource.getPromotionList(token);

      if (response['status'] == true) {
        // Use total from API response if available
        if (response['total'] != null) {
          _total = response['total'] is int
              ? response['total']
              : int.tryParse(response['total'].toString()) ?? 0;
        }

        // Handle data array
        if (response['data'] != null && response['data'] is List) {
          _promotionsList =
              (response['data'] as List).cast<Map<String, dynamic>>();

          // Update total from list length if API total wasn't provided
          if (_total == 0) {
            _total = _promotionsList.length;
          }
        } else {
          _promotionsList = [];
          if (_total == 0) {
            _total = 0;
          }
        }

        _status = PromotionsStatus.success;
        notifyListeners();
      } else {
        _status = PromotionsStatus.error;
        _errorMessage =
            response['message']?.toString() ?? 'Failed to load promotions';
        notifyListeners();
      }
    } catch (e) {
      _status = PromotionsStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void refresh() {
    loadPromotionsData();
  }

  /// Fetch promotion details by promotion_id
  Future<Map<String, dynamic>?> getPromotionDetails(String promotionId) async {
    try {
      // Get token from preferences
      final token = await PreferencesHelper.getUserToken();

      if (token == null || token.isEmpty) {
        return null;
      }

      // Fetch promotion details from API
      final response =
          await _remoteDataSource.getPromotionDetailById(token, promotionId);

      if (response['status'] == true && response['data'] != null) {
        final promotionData = response['data'] as Map<String, dynamic>;
        return promotionData;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching promotion details: $e');
      return null;
    }
  }
}
