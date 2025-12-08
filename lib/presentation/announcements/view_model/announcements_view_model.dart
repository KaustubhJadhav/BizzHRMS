import 'package:flutter/foundation.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';
import 'package:bizzhrms_flutter_app/data/data_sources/remote_data_source.dart';

enum AnnouncementsStatus { initial, loading, success, error }

class AnnouncementsViewModel extends ChangeNotifier {
  AnnouncementsStatus _status = AnnouncementsStatus.initial;
  String? _errorMessage;
  final RemoteDataSource _remoteDataSource = RemoteDataSource();

  AnnouncementsStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _announcementsList = [];
  int _total = 0;
  
  List<Map<String, dynamic>> get announcementsList => _announcementsList;
  int get total => _total;

  Future<void> loadAnnouncementsData() async {
    _status = AnnouncementsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token and user_id from preferences
      final token = await PreferencesHelper.getUserToken();
      final userId = await PreferencesHelper.getUserId();

      if (token == null || token.isEmpty || userId == null || userId.isEmpty) {
        _status = AnnouncementsStatus.error;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return;
      }

      // Fetch announcement list from API
      final response = await _remoteDataSource.getAnnouncementList(token, userId);

      if (response['status'] == true) {
        // Use total from API response if available
        if (response['total'] != null) {
          _total = response['total'] is int 
              ? response['total'] 
              : int.tryParse(response['total'].toString()) ?? 0;
        }

        // Handle announcements array
        if (response['announcements'] != null && response['announcements'] is List) {
          _announcementsList = (response['announcements'] as List).cast<Map<String, dynamic>>();
          
          // Update total from list length if API total wasn't provided
          if (_total == 0) {
            _total = _announcementsList.length;
          }
        } else {
          _announcementsList = [];
          if (_total == 0) {
            _total = 0;
          }
        }

        _status = AnnouncementsStatus.success;
        notifyListeners();
      } else {
        _status = AnnouncementsStatus.error;
        _errorMessage = response['message']?.toString() ?? 'Failed to load announcements';
        notifyListeners();
      }
    } catch (e) {
      _status = AnnouncementsStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void refresh() {
    loadAnnouncementsData();
  }
}

