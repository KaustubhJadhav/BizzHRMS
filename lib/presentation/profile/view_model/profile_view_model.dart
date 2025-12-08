import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';
import 'package:bizzhrms_flutter_app/data/data_sources/remote_data_source.dart';
import 'package:intl/intl.dart';

enum ProfileStatus { initial, loading, success, error }

class ProfileViewModel extends ChangeNotifier {
  ProfileStatus _status = ProfileStatus.initial;
  String? _errorMessage;
  Map<String, dynamic>? _userData;
  final RemoteDataSource _remoteDataSource = RemoteDataSource();

  ProfileStatus get status => _status;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get userData => _userData;

  Future<void> loadProfileData() async {
    _status = ProfileStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token and user_id from preferences
      final token = await PreferencesHelper.getUserToken();
      final userId = await PreferencesHelper.getUserId();

      if (token == null || token.isEmpty || userId == null || userId.isEmpty) {
        _status = ProfileStatus.error;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return;
      }

      // Fetch user info from API
      final response = await _remoteDataSource.getUserInfo(token, userId);

      if (response['status'] == true && response['data'] != null) {
        _userData = response['data'] as Map<String, dynamic>;
        _status = ProfileStatus.success;
        notifyListeners();
      } else {
        _status = ProfileStatus.error;
        _errorMessage = response['message']?.toString() ?? 'Failed to load profile data';
        notifyListeners();
      }
    } catch (e) {
      _status = ProfileStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  /// Update profile with provided data
  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    _status = ProfileStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token and user_id from preferences
      final token = await PreferencesHelper.getUserToken();
      final userId = await PreferencesHelper.getUserId();

      if (token == null || token.isEmpty || userId == null || userId.isEmpty) {
        _status = ProfileStatus.error;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return false;
      }

      // Call update profile API
      final response = await _remoteDataSource.updateProfile(token, userId, profileData);

      if (response['status'] == true) {
        // Reload profile data to get updated information
        await loadProfileData();
        return true;
      } else {
        _status = ProfileStatus.error;
        _errorMessage = response['message']?.toString() ?? 'Failed to update profile';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = ProfileStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == 'null') return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd-MMM-yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty || dateTimeStr == 'null') return 'N/A';
    try {
      // Format: "10-11-2025 17:54:17"
      final parts = dateTimeStr.split(' ');
      if (parts.length >= 2) {
        final dateParts = parts[0].split('-');
        if (dateParts.length == 3) {
          final date = DateTime(
            int.parse(dateParts[2]),
            int.parse(dateParts[1]),
            int.parse(dateParts[0]),
          );
          return DateFormat('dd-MMM-yyyy hh:mm a').format(date);
        }
      }
      return dateTimeStr;
    } catch (e) {
      return dateTimeStr;
    }
  }

  String getProfilePictureUrl() {
    if (_userData == null) return '';
    final profilePic = _userData!['profile_picture'];
    if (profilePic == null || profilePic.toString().isEmpty || profilePic == 'null') {
      return '';
    }
    return 'https://arena.creativecrows.co.in/uploads/profile/$profilePic';
  }

  /// Update profile picture
  Future<bool> updateProfilePicture(File imageFile) async {
    _status = ProfileStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token and user_id from preferences
      final token = await PreferencesHelper.getUserToken();
      final userId = await PreferencesHelper.getUserId();

      if (token == null || token.isEmpty || userId == null || userId.isEmpty) {
        _status = ProfileStatus.error;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return false;
      }

      // Call update profile picture API
      final response = await _remoteDataSource.updateProfilePicture(token, userId, imageFile);

      if (response['status'] == true) {
        // Reload profile data to get updated information
        await loadProfileData();
        return true;
      } else {
        _status = ProfileStatus.error;
        _errorMessage = response['message']?.toString() ?? 'Failed to update profile picture';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = ProfileStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void refresh() {
    loadProfileData();
  }
}

