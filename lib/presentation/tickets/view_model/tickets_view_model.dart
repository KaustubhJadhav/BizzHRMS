import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';
import 'package:bizzhrms_flutter_app/data/data_sources/remote_data_source.dart';

enum TicketsStatus { initial, loading, success, error }

class TicketsViewModel extends ChangeNotifier {
  TicketsStatus _status = TicketsStatus.initial;
  String? _errorMessage;
  final RemoteDataSource _remoteDataSource = RemoteDataSource();

  TicketsStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _ticketsList = [];
  int _total = 0;
  
  List<Map<String, dynamic>> get ticketsList => _ticketsList;
  int get total => _total;

  // Convert string priority to integer for backward compatibility
  int _getPriorityInt(String? priority) {
    if (priority == null) return 0;
    switch (priority.toLowerCase()) {
      case 'low':
        return 1;
      case 'medium':
        return 2;
      case 'high':
        return 3;
      case 'critical':
        return 4;
      default:
        return 0;
    }
  }

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

  // Get priority color from string priority
  Color getPriorityColorFromString(String? priority) {
    return _getPriorityColor(_getPriorityInt(priority));
  }

  String getPriorityText(int priority) => _getPriorityText(priority);
  Color getPriorityColor(int priority) => _getPriorityColor(priority);

  Future<void> loadTicketsData() async {
    _status = TicketsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token from preferences
      final token = await PreferencesHelper.getUserToken();

      if (token == null || token.isEmpty) {
        _status = TicketsStatus.error;
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return;
      }

      // Fetch ticket list from API
      final response = await _remoteDataSource.getTicketList(token);

      if (response['status'] == true) {
        // Use total from API response if available
        if (response['total'] != null) {
          _total = response['total'] is int 
              ? response['total'] 
              : int.tryParse(response['total'].toString()) ?? 0;
        }

        // Handle data array and map fields
        if (response['data'] != null && response['data'] is List) {
          _ticketsList = (response['data'] as List).map((item) {
            final ticket = item as Map<String, dynamic>;
            // Map API fields to UI expected fields
            final priorityString = ticket['priority']?.toString() ?? '';
            return {
              ...ticket, // Keep all original fields for details page
              'employee': ticket['employee_name']?.toString() ?? '',
              'priority': _getPriorityInt(priorityString), // Convert string to int for backward compatibility
              'date': ticket['created_at']?.toString() ?? '',
            };
          }).toList();
          
          // Update total from list length if API total wasn't provided
          if (_total == 0) {
            _total = _ticketsList.length;
          }
        } else {
          _ticketsList = [];
          if (_total == 0) {
            _total = 0;
          }
        }

        _status = TicketsStatus.success;
        notifyListeners();
      } else {
        _status = TicketsStatus.error;
        _errorMessage = response['message']?.toString() ?? 'Failed to load tickets';
        notifyListeners();
      }
    } catch (e) {
      _status = TicketsStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void refresh() {
    loadTicketsData();
  }

  // Convert integer priority to string for API
  String _getPriorityString(int priority) {
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
        return 'Medium';
    }
  }

  /// Add a new ticket
  Future<Map<String, dynamic>?> addTicket(
      String subject, String description, int priority) async {
    try {
      // Get token from preferences
      final token = await PreferencesHelper.getUserToken();

      if (token == null || token.isEmpty) {
        return {'error': 'User not authenticated'};
      }

      // Convert priority to string
      final priorityString = _getPriorityString(priority);

      // Call API to add ticket
      final response = await _remoteDataSource.addTicket(
          token, subject, description, priorityString);

      if (response['status'] == true) {
        // Refresh the ticket list
        await loadTicketsData();
        return response;
      } else {
        return {'error': response['message']?.toString() ?? 'Failed to create ticket'};
      }
    } catch (e) {
      debugPrint('Error adding ticket: $e');
      return {'error': e.toString().replaceFirst('Exception: ', '')};
    }
  }

  /// Edit a ticket
  Future<Map<String, dynamic>?> editTicket(
      String ticketId, String status, String remarks, String ticketNote) async {
    try {
      // Get token from preferences
      final token = await PreferencesHelper.getUserToken();

      if (token == null || token.isEmpty) {
        return {'error': 'User not authenticated'};
      }

      // Call API to edit ticket
      final response = await _remoteDataSource.editTicket(
          token, ticketId, status, remarks, ticketNote);

      if (response['status'] == true) {
        // Refresh the ticket list
        await loadTicketsData();
        return response;
      } else {
        return {'error': response['message']?.toString() ?? 'Failed to update ticket'};
      }
    } catch (e) {
      debugPrint('Error editing ticket: $e');
      return {'error': e.toString().replaceFirst('Exception: ', '')};
    }
  }

  /// Add a comment to a ticket
  Future<Map<String, dynamic>?> addTicketComment(String ticketId, String comment) async {
    try {
      // Get token from preferences
      final token = await PreferencesHelper.getUserToken();

      if (token == null || token.isEmpty) {
        return {'error': 'User not authenticated'};
      }

      // Call API to add comment
      final response = await _remoteDataSource.addTicketComment(token, ticketId, comment);

      if (response['status'] == true) {
        return response;
      } else {
        return {'error': response['message']?.toString() ?? 'Failed to add comment'};
      }
    } catch (e) {
      debugPrint('Error adding comment: $e');
      return {'error': e.toString().replaceFirst('Exception: ', '')};
    }
  }

  /// Delete a comment from a ticket
  Future<Map<String, dynamic>?> deleteTicketComment(String commentId) async {
    try {
      // Get token from preferences
      final token = await PreferencesHelper.getUserToken();

      if (token == null || token.isEmpty) {
        return {'error': 'User not authenticated'};
      }

      // Call API to delete comment
      final response = await _remoteDataSource.deleteTicketComment(token, commentId);

      if (response['status'] == true) {
        return response;
      } else {
        return {'error': response['message']?.toString() ?? 'Failed to delete comment'};
      }
    } catch (e) {
      debugPrint('Error deleting comment: $e');
      return {'error': e.toString().replaceFirst('Exception: ', '')};
    }
  }

  /// Add an attachment to a ticket
  Future<Map<String, dynamic>?> addTicketAttachment(
      String ticketId, List<File> files, String fileTitle, String fileDescription) async {
    try {
      // Get token from preferences
      final token = await PreferencesHelper.getUserToken();

      if (token == null || token.isEmpty) {
        return {'error': 'User not authenticated'};
      }

      // Call API to add attachment
      final response = await _remoteDataSource.addTicketAttachment(
          token, ticketId, files, fileTitle, fileDescription);

      if (response['status'] == true) {
        return response;
      } else {
        return {'error': response['message']?.toString() ?? 'Failed to add attachment'};
      }
    } catch (e) {
      debugPrint('Error adding attachment: $e');
      return {'error': e.toString().replaceFirst('Exception: ', '')};
    }
  }

  /// Delete an attachment from a ticket
  Future<Map<String, dynamic>?> deleteTicketAttachment(String attachmentId) async {
    try {
      // Get token from preferences
      final token = await PreferencesHelper.getUserToken();

      if (token == null || token.isEmpty) {
        return {'error': 'User not authenticated'};
      }

      // Call API to delete attachment
      final response = await _remoteDataSource.deleteTicketAttachment(token, attachmentId);

      if (response['status'] == true) {
        return response;
      } else {
        return {'error': response['message']?.toString() ?? 'Failed to delete attachment'};
      }
    } catch (e) {
      debugPrint('Error deleting attachment: $e');
      return {'error': e.toString().replaceFirst('Exception: ', '')};
    }
  }

  /// Fetch ticket details by ticket_id
  Future<dynamic> getTicketDetails(String ticketId) async {
    try {
      // Get token from preferences
      final token = await PreferencesHelper.getUserToken();

      if (token == null || token.isEmpty) {
        return null;
      }

      // Fetch ticket details from API
      final response = await _remoteDataSource.getTicketDetailById(token, ticketId);

      if (response['status'] == true && response['data'] != null) {
        // API returns data as object
        return response['data'];
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching ticket details: $e');
      return null;
    }
  }
}

