import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import 'base_data_source.dart';

// Remote data source for API calls
class RemoteDataSource extends BaseDataSource {
  Dio get dio => _dio;
  late Dio _dio;

  RemoteDataSource() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );
  }

  /// Login API - uses JSON data
  /// Returns: {status: bool, message: String, user_id: String, company_id: String, allow_mobile_clock: int, token: String}
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // Send JSON data (Dio automatically JSON encodes Map when Content-Type is application/json)
      final response = await _dio.post(
        AppConstants.loginEndpoint,
        data: {
          'username': username,
          'password': password,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Login failed');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Logout API - requires Bearer token in Authorization header
  /// Returns: {status: bool, message: String}
  Future<Map<String, dynamic>> logout(String token) async {
    try {
      final response = await _dio.post(
        AppConstants.logoutEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Logout failed');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get User Info API - requires Bearer token and user_id
  /// Returns: {status: bool, message: String, data: {...}}
  Future<Map<String, dynamic>> getUserInfo(String token, String userId) async {
    try {
      final response = await _dio.post(
        '${AppConstants.userInfoEndpoint}/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data['message'] ?? 'Failed to fetch user info');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Change Password API - requires Bearer token, user_id, and password fields
  /// Returns: {status: bool, message: String}
  Future<Map<String, dynamic>> changePassword(
    String token,
    String userId,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      final response = await _dio.post(
        AppConstants.changePasswordEndpoint,
        data: {
          'user_id': userId,
          'new_password': newPassword,
          'new_password_confirm': confirmPassword,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        // Handle different response formats
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to change password');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to change password');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Update Profile API - requires Bearer token, user_id, and profile fields to update
  /// Returns: {status: bool, message: String, updated_data: {...}}
  Future<Map<String, dynamic>> updateProfile(
    String token,
    String userId,
    Map<String, dynamic> profileData,
  ) async {
    try {
      // Add user_id to the data
      final data = {
        'user_id': userId,
        ...profileData,
      };

      final response = await _dio.post(
        AppConstants.updateProfileEndpoint,
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        // Handle different response formats
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to update profile');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to update profile');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Update Profile Picture API - requires Bearer token, user_id, and image file
  /// Returns: {status: bool, message: String, updated_data: {...}}
  Future<Map<String, dynamic>> updateProfilePicture(
    String token,
    String userId,
    File imageFile,
  ) async {
    try {
      // Create multipart form data
      final formData = FormData.fromMap({
        'user_id': userId,
        'profile_picture': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        AppConstants.updateProfileEndpoint,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        // Handle different response formats
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to update profile picture');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to update profile picture');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Attendance API - requires Bearer token, user_id, month, and year
  /// Returns: {status: bool, message: String, data: {...}}
  Future<Map<String, dynamic>> getAttendance(
    String token,
    String userId,
    int month,
    int year,
  ) async {
    try {
      final response = await _dio.post(
        AppConstants.attendanceEndpoint,
        data: {
          'user_id': userId,
          'month': month.toString(),
          'year': year.toString(),
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        // Handle different response formats
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to fetch attendance');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to fetch attendance');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Month Attendance Log API - returns list of all attendance records for a month
  /// Requires Bearer token, user_id, month, and year
  /// Returns: {status: bool, message: String, data: [...]}
  Future<Map<String, dynamic>> getMonthAttendance(
    String token,
    String userId,
    int month,
    int year,
  ) async {
    try {
      final response = await _dio.post(
        AppConstants.monthAttendanceEndpoint,
        data: {
          'user_id': userId,
          'month': month.toString(),
          'year': year.toString(),
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        // Handle different response formats
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to fetch month attendance');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to fetch month attendance');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Set Clocking API - requires Bearer token, employee_id, clock_state (clock_in or clock_out), and location (lat/lng)
  /// Returns: {status: int, message: bool, data: {clock_state: String, time_id?: int}}
  Future<Map<String, dynamic>> setClocking(
    String token,
    String employeeId,
    String clockState,
    double? latitude,
    double? longitude,
  ) async {
    try {
      final requestData = {
        'employee_id': employeeId,
        'clock_state': clockState,
        if (latitude != null) 'lat': latitude.toString(),
        if (longitude != null) 'lng': longitude.toString(),
      };

      print('=== REMOTE DATA SOURCE: SET CLOCKING ===');
      print('URL: ${AppConstants.baseUrl}${AppConstants.setClockingEndpoint}');
      print('Request Data: $requestData');
      print(
          'Headers: Authorization: Bearer ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
      print('');

      final response = await _dio.post(
        AppConstants.setClockingEndpoint,
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      print('=== REMOTE DATA SOURCE: RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('');

      return response.data;
    } on DioException catch (e) {
      print('=== REMOTE DATA SOURCE: DIO EXCEPTION ===');
      print('Error Type: ${e.type}');
      print('Error Message: ${e.message}');
      if (e.response != null) {
        print('Response Status Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
      }
      print('');

      if (e.response != null) {
        // Handle different response formats
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(responseData['message'] ?? 'Failed to set clocking');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to set clocking');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Leave List API - requires Bearer token and user_id
  /// Returns: {status: bool, message: String, total: int, data: [...]}
  Future<Map<String, dynamic>> getLeaveList(
    String token,
    String userId,
  ) async {
    try {
      final response = await _dio.post(
        AppConstants.leaveListEndpoint,
        data: {
          'user_id': userId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to fetch leave list');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to fetch leave list');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Add Leave API - requires Bearer token, user_id, leave_type_id, from_date, to_date, reason, remarks
  /// Returns: {status: bool, message: String}
  Future<Map<String, dynamic>> addLeave(
    String token,
    String userId,
    String leaveTypeId,
    String fromDate,
    String toDate,
    String reason,
    String remarks,
  ) async {
    try {
      final response = await _dio.post(
        AppConstants.leaveAddEndpoint,
        data: {
          'user_id': userId,
          'leave_type_id': leaveTypeId,
          'from_date': fromDate,
          'to_date': toDate,
          'reason': reason,
          'remarks': remarks,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(responseData['message'] ?? 'Failed to add leave');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to add leave');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Task List API - requires Bearer token and user_id
  /// Returns: {status: bool, message: String, total: int, tasks: [...]}
  Future<Map<String, dynamic>> getTaskList(
    String token,
    String userId,
  ) async {
    try {
      final response = await _dio.post(
        AppConstants.taskListEndpoint,
        data: {
          'user_id': userId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to fetch task list');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to fetch task list');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Project List API - requires Bearer token and user_id
  /// Returns: {status: bool, message: String, total: int, projects: [...]}
  Future<Map<String, dynamic>> getProjectList(
    String token,
    String userId,
  ) async {
    try {
      final response = await _dio.post(
        AppConstants.projectListEndpoint,
        data: {
          'user_id': userId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to fetch project list');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to fetch project list');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Update Project Status API - requires Bearer token, project_id, priority, progres_val, status
  /// Returns: {status: int, message: String}
  Future<Map<String, dynamic>> updateProjectStatus(
    String token,
    String projectId,
    int priority,
    int progressValue,
    int status,
  ) async {
    try {
      final response = await _dio.post(
        AppConstants.projectUpdateStatusEndpoint,
        data: {
          'project_id': projectId,
          'priority': priority,
          'progres_val': progressValue,
          'status': status,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          contentType: Headers.jsonContentType,
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to update project status');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to update project status');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Set Project Discussion API - requires Bearer token and FormData with message and optional file
  /// Returns: {status: int, message: String}
  Future<Map<String, dynamic>> setProjectDiscussion(
    String token,
    String userId,
    String projectId,
    String message, {
    File? attachmentFile,
  }) async {
    try {
      // Build FormData - start with fields
      // Note: Based on HTML form, we need: discussion_project_id, user_id, xin_message
      // The user's API code also includes 'add_type', so we'll include it
      final formData = FormData.fromMap({
        'add_type': 'set_discussion',
        'xin_message': message,
        'user_id': userId,
        'discussion_project_id': projectId,
      });

      // Validate required fields
      if (message.isEmpty) {
        throw Exception('Message is required');
      }
      if (userId.isEmpty) {
        throw Exception('User ID is required');
      }
      if (projectId.isEmpty) {
        throw Exception('Project ID is required');
      }

      // Add file if provided
      // The API expects 'files[]' as an array - using 'files[]' as the field name
      // Note: Some APIs expect array notation in the field name
      if (attachmentFile != null && await attachmentFile.exists()) {
        final fileName = attachmentFile.path.split(Platform.pathSeparator).last;
        formData.files.add(
          MapEntry(
            'files[]', // Using array notation as shown in the user's API example
            await MultipartFile.fromFile(
              attachmentFile.path,
              filename: fileName,
            ),
          ),
        );
        print('Added file: $fileName');
      } else {
        print('No file attached');
      }

      print('=== SET DISCUSSION API REQUEST ===');
      print(
          'URL: ${AppConstants.baseUrl}${AppConstants.projectSetDiscussionEndpoint}');
      print(
          'Fields: add_type=set_discussion, xin_message=$message, user_id=$userId, discussion_project_id=$projectId');
      print('Has file: ${attachmentFile != null}');
      if (attachmentFile != null) {
        print('File path: ${attachmentFile.path}');
      }
      print('');

      final response = await _dio.post(
        AppConstants.projectSetDiscussionEndpoint,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      print('=== SET DISCUSSION API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('');

      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to add discussion');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to add discussion');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Project Discussion List API - requires Bearer token and project_id
  /// Returns: {status: bool, data: [...]}
  Future<Map<String, dynamic>> getProjectDiscussionList(
    String token,
    String projectId,
  ) async {
    try {
      final response = await _dio.post(
        AppConstants.projectDiscussionListEndpoint,
        data: {
          'project_id': projectId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to fetch discussions');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to fetch discussions');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Project Bug List API - requires Bearer token and project_id
  /// Returns: {status: bool, message: String, data: [...]}
  Future<Map<String, dynamic>> getProjectBugList(
    String token,
    String projectId,
  ) async {
    try {
      // Use FormData with project_id parameter (multipart/form-data)
      final formData = FormData.fromMap({
        'project_id': projectId,
      });

      final response = await _dio.post(
        AppConstants.projectBugListEndpoint,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            // Dio will automatically set Content-Type for FormData
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to fetch bug list');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to fetch bug list');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Announcement List API - requires Bearer token and user_id
  /// Returns: {status: bool, message: String, total: int, announcements: [...]}
  Future<Map<String, dynamic>> getAnnouncementList(
    String token,
    String userId,
  ) async {
    try {
      // Use FormData as per API requirements
      final formData = FormData.fromMap({
        'user_id': userId,
      });

      final response = await _dio.post(
        AppConstants.announcementListEndpoint,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            // Dio will automatically set Content-Type for FormData
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to fetch announcement list');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to fetch announcement list');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Awards List API - requires Bearer token
  /// Returns: {status: bool, message: String, total: int, data: [...]}
  Future<Map<String, dynamic>> getAwardsList(String token) async {
    try {
      final response = await _dio.post(
        AppConstants.awardsListEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to fetch awards list');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to fetch awards list');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Award Detail by ID API - requires Bearer token and award_id
  /// Returns: {status: bool, message: String, data: {...}}
  Future<Map<String, dynamic>> getAwardDetailById(
      String token, String awardId) async {
    try {
      // Use FormData as per API requirements
      final formData = FormData.fromMap({
        'award_id': awardId,
      });

      final response = await _dio.post(
        AppConstants.awardDetailEndpoint,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            // Dio will automatically set Content-Type for FormData
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to fetch award details');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to fetch award details');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Transfer List API - requires Bearer token
  /// Returns: {status: bool, message: String, total: int, data: [...]}
  Future<Map<String, dynamic>> getTransferList(String token) async {
    try {
      final response = await _dio.post(
        AppConstants.transferListEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to fetch transfer list');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to fetch transfer list');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Transfer Detail by ID API - requires Bearer token and transfer_id
  /// Returns: {status: bool, message: String, data: {...}}
  Future<Map<String, dynamic>> getTransferDetailById(
      String token, String transferId) async {
    try {
      // Use FormData as per API requirements
      final formData = FormData.fromMap({
        'transfer_id': transferId,
      });

      final response = await _dio.post(
        AppConstants.transferDetailEndpoint,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            // Dio will automatically set Content-Type for FormData
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to fetch transfer details');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to fetch transfer details');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Promotion List API - requires Bearer token
  /// Returns: {status: bool, message: String, total: int, data: [...]}
  Future<Map<String, dynamic>> getPromotionList(String token) async {
    try {
      final response = await _dio.post(
        AppConstants.promotionListEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to fetch promotion list');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to fetch promotion list');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Promotion Detail by ID API - requires Bearer token and promotion_id
  /// Returns: {status: bool, message: String, data: {...}}
  Future<Map<String, dynamic>> getPromotionDetailById(
      String token, String promotionId) async {
    try {
      // Use FormData as per API requirements
      final formData = FormData.fromMap({
        'promotion_id': promotionId,
      });

      final response = await _dio.post(
        AppConstants.promotionDetailEndpoint,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            // Dio will automatically set Content-Type for FormData
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to fetch promotion details');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to fetch promotion details');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Job Applied List API - requires Bearer token
  /// Returns: {status: bool, message: String, total: int, data: [...]}
  Future<Map<String, dynamic>> getJobAppliedList(String token) async {
    try {
      final response = await _dio.post(
        AppConstants.jobAppliedListEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to fetch job applied list');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to fetch job applied list');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Job Interview List API - requires Bearer token
  /// Returns: {status: bool, message: String, total: int, data: [...]}
  Future<Map<String, dynamic>> getJobInterviewList(String token) async {
    try {
      final response = await _dio.post(
        AppConstants.jobInterviewListEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to fetch job interview list');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to fetch job interview list');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Complaint List API - requires Bearer token
  /// Returns: {status: bool, message: String, total: int, data: [...]}
  Future<Map<String, dynamic>> getComplaintList(String token) async {
    try {
      final response = await _dio.post(
        AppConstants.complaintListEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to fetch complaint list');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to fetch complaint list');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Complaint Detail by ID API - requires Bearer token and complaint_id
  /// Returns: {status: bool, message: String, data: [...]}
  Future<Map<String, dynamic>> getComplaintDetailById(
      String token, String complaintId) async {
    try {
      // Use FormData as per API requirements
      final formData = FormData.fromMap({
        'complaint_id': complaintId,
      });

      final response = await _dio.post(
        AppConstants.complaintDetailEndpoint,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            // Dio will automatically set Content-Type for FormData
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to fetch complaint details');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to fetch complaint details');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Warning List API - requires Bearer token
  /// Returns: {status: bool, message: String, total: int, data: [...]}
  Future<Map<String, dynamic>> getWarningList(String token) async {
    try {
      final response = await _dio.post(
        AppConstants.warningListEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to fetch warning list');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to fetch warning list');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Warning Detail by ID API - requires Bearer token and warning_id
  /// Returns: {status: bool, message: String, data: [...]}
  Future<Map<String, dynamic>> getWarningDetailById(
      String token, String warningId) async {
    try {
      // Use FormData as per API requirements
      final formData = FormData.fromMap({
        'warning_id': warningId,
      });

      final response = await _dio.post(
        AppConstants.warningDetailEndpoint,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            // Dio will automatically set Content-Type for FormData
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to fetch warning details');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to fetch warning details');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Travel List API - requires Bearer token
  /// Returns: {status: bool, message: String, total: int, data: [...]}
  Future<Map<String, dynamic>> getTravelList(String token) async {
    try {
      final response = await _dio.post(
        AppConstants.travelListEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to fetch travel list');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to fetch travel list');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Travel Detail by ID API - requires Bearer token and travel_id
  /// Returns: {status: bool, message: String, data: {...}}
  Future<Map<String, dynamic>> getTravelDetailById(
      String token, String travelId) async {
    try {
      // Use FormData as per API requirements
      final formData = FormData.fromMap({
        'travel_id': travelId,
      });

      // Note: API has query parameter but also FormData
      final response = await _dio.post(
        '${AppConstants.travelDetailEndpoint}?travel_id=$travelId',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            // Dio will automatically set Content-Type for FormData
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to fetch travel details');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to fetch travel details');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Office Shift List API - requires Bearer token
  /// Returns: {status: bool, message: String, total: int, data: [...]}
  Future<Map<String, dynamic>> getOfficeShiftList(String token) async {
    try {
      final response = await _dio.post(
        AppConstants.officeShiftListEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to fetch office shift list');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to fetch office shift list');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Training List API - requires Bearer token
  /// Returns: {status: bool, message: String, total: int, data: [...]}
  Future<Map<String, dynamic>> getTrainingList(String token) async {
    try {
      final response = await _dio.post(
        AppConstants.trainingListEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to fetch training list');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to fetch training list');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Training Detail by ID API - requires Bearer token and training_id
  /// Returns: {status: bool, message: String, data: {...}}
  Future<Map<String, dynamic>> getTrainingDetailById(
      String token, String trainingId) async {
    try {
      // Use FormData as per API requirements
      final formData = FormData.fromMap({
        'training_id': trainingId,
      });

      final response = await _dio.post(
        AppConstants.trainingDetailEndpoint,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            // Dio will automatically set Content-Type for FormData
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to fetch training details');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to fetch training details');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Ticket List API - requires Bearer token
  /// Returns: {status: bool, message: String, total: int, data: [...]}
  Future<Map<String, dynamic>> getTicketList(String token) async {
    try {
      final response = await _dio.post(
        AppConstants.ticketListEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to fetch ticket list');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to fetch ticket list');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Ticket Detail by ID API - requires Bearer token and ticket_id
  /// Returns: {status: bool, message: String, data: {...}}
  Future<Map<String, dynamic>> getTicketDetailById(
      String token, String ticketId) async {
    try {
      // Use FormData as per API requirements
      final formData = FormData.fromMap({
        'ticket_id': ticketId,
      });

      final response = await _dio.post(
        AppConstants.ticketDetailEndpoint,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            // Dio will automatically set Content-Type for FormData
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to fetch ticket details');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to fetch ticket details');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Add Ticket API - requires Bearer token, ticket_subject, ticket_description, and ticket_priority
  /// Returns: {status: bool, message: String, ticket_code: String}
  Future<Map<String, dynamic>> addTicket(
      String token, String subject, String description, String priority) async {
    try {
      // Use FormData as per API requirements
      final formData = FormData.fromMap({
        'ticket_subject': subject,
        'ticket_description': description,
        'ticket_priority': priority,
      });

      final response = await _dio.post(
        AppConstants.addTicketEndpoint,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            // Dio will automatically set Content-Type for FormData
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(responseData['message'] ?? 'Failed to create ticket');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to create ticket');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Edit Ticket API - requires Bearer token, ticket_id, status, remarks, and ticket_note
  /// Returns: {status: bool, message: String}
  Future<Map<String, dynamic>> editTicket(String token, String ticketId,
      String status, String remarks, String ticketNote) async {
    try {
      // Use FormData as per API requirements
      final formData = FormData.fromMap({
        'ticket_id': ticketId,
        'status': status,
        'remarks': remarks,
        'ticket_note': ticketNote,
      });

      final response = await _dio.post(
        AppConstants.editTicketEndpoint,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            // Dio will automatically set Content-Type for FormData
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(responseData['message'] ?? 'Failed to update ticket');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to update ticket');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Add Ticket Comment API - requires Bearer token, ticket_id, and comment
  /// Returns: {status: bool, message: String}
  Future<Map<String, dynamic>> addTicketComment(
      String token, String ticketId, String comment) async {
    try {
      // Use FormData as per API requirements
      final formData = FormData.fromMap({
        'ticket_id': ticketId,
        'comment': comment,
      });

      final response = await _dio.post(
        AppConstants.addTicketCommentEndpoint,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            // Dio will automatically set Content-Type for FormData
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(responseData['message'] ?? 'Failed to add comment');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to add comment');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Delete Ticket Comment API - requires Bearer token and comment_id
  /// Returns: {status: bool, message: String}
  Future<Map<String, dynamic>> deleteTicketComment(
      String token, String commentId) async {
    try {
      // Use FormData as per API requirements
      final formData = FormData.fromMap({
        'comment_id': commentId,
      });

      final response = await _dio.post(
        AppConstants.deleteTicketCommentEndpoint,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            // Dio will automatically set Content-Type for FormData
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to delete comment');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to delete comment');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Add Ticket Attachment API - requires Bearer token, ticket_id, files, file_title, and file_description
  /// Returns: {status: bool, message: String}
  Future<Map<String, dynamic>> addTicketAttachment(
      String token,
      String ticketId,
      List<File> files,
      String fileTitle,
      String fileDescription) async {
    try {
      // Create FormData with files
      final formData = FormData();

      // Add files as MultipartFile
      final multipartFiles = <MultipartFile>[];
      for (var file in files) {
        final multipartFile = await MultipartFile.fromFile(
          file.path,
          filename: file.path.split(Platform.pathSeparator).last,
        );
        multipartFiles.add(multipartFile);
      }

      // Add fields
      formData.fields.addAll([
        MapEntry('ticket_id', ticketId),
        MapEntry('file_title', fileTitle),
        MapEntry('file_description', fileDescription),
      ]);

      // Add files array - use 'files[]' as key for array format
      for (var file in multipartFiles) {
        formData.files.add(MapEntry('files[]', file));
      }

      final response = await _dio.post(
        AppConstants.addTicketAttachmentEndpoint,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            // Dio will automatically set Content-Type for FormData with files
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to add attachment');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to add attachment');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Delete Ticket Attachment API - requires Bearer token and attachment_id
  /// Returns: {status: bool, message: String}
  Future<Map<String, dynamic>> deleteTicketAttachment(
      String token, String attachmentId) async {
    try {
      // Use FormData as per API requirements
      final formData = FormData.fromMap({
        'attachment_id': attachmentId,
      });

      final response = await _dio.post(
        AppConstants.deleteTicketAttachmentEndpoint,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            // Dio will automatically set Content-Type for FormData
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to delete attachment');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to delete attachment');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Save FCM Token API - requires Bearer token, user_id, and token
  /// Returns: {status: int, message: String}
  Future<Map<String, dynamic>> saveFCMToken(
    String token,
    String userId,
    String fcmToken,
  ) async {
    try {
      final requestData = {
        'user_id': userId,
        'token': fcmToken,
      };

      print('=== SAVE FCM TOKEN API REQUEST ===');
      print('URL: ${AppConstants.baseUrl}${AppConstants.saveFCMTokenEndpoint}');
      print('Request Data: $requestData');
      print('');

      final response = await _dio.post(
        AppConstants.saveFCMTokenEndpoint,
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      print('=== SAVE FCM TOKEN API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('');

      return response.data;
    } on DioException catch (e) {
      print('=== SAVE FCM TOKEN API ERROR ===');
      print('Error Type: ${e.type}');
      print('Error Message: ${e.message}');
      if (e.response != null) {
        print('Response Status Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
      }
      print('');

      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to save FCM token');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to save FCM token');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Admin Dashboard API - requires Bearer token
  /// Returns: {status: bool, message: String, attendance: {...}, attendance_date: String, ...}
  Future<Map<String, dynamic>> getAdminDashboard(String token,
      {String? date}) async {
    try {
      // Use FormData with ddate parameter
      final formData = FormData.fromMap({});
      if (date != null && date.isNotEmpty) {
        formData.fields.add(MapEntry('ddate', date));
      }

      print('=== ADMIN DASHBOARD API REQUEST ===');
      print(
          'URL: ${AppConstants.baseUrl}${AppConstants.adminDashboardEndpoint}');
      print('Method: POST');
      if (date != null) {
        print('ddate: $date');
      }
      print('');

      final response = await _dio.post(
        AppConstants.adminDashboardEndpoint,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            // Dio will automatically set Content-Type for FormData
          },
        ),
      );

      print('=== ADMIN DASHBOARD API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('');

      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to load admin dashboard');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to load admin dashboard');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Admin Employees List API - requires Bearer token
  /// Returns: {status: bool, total_records: int, data: [...]}
  Future<Map<String, dynamic>> getAdminEmployees(String token) async {
    try {
      print('=== ADMIN EMPLOYEES API REQUEST ===');
      print(
          'URL: ${AppConstants.baseUrl}${AppConstants.adminEmployeesEndpoint}');
      print('Method: GET');
      print('');

      final response = await _dio.get(
        AppConstants.adminEmployeesEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('=== ADMIN EMPLOYEES API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('');

      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to load employees');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to load employees');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Admin Attendance Filtered Employees API - requires Bearer token
  /// Parameters: statusTime (e.g., 'Present', 'Absent'), date (yyyy-MM-dd)
  /// Returns: {status: bool, date: String, total: int, employees: [...]}
  Future<Map<String, dynamic>> getAdminAttendanceFilteredEmployees(
    String token, {
    required String statusTime,
    required String date,
  }) async {
    try {
      // Use FormData with statusTime and date parameters
      final formData = FormData.fromMap({
        'statusTime': statusTime,
        'date': date,
      });

      print('=== ADMIN ATTENDANCE FILTERED API REQUEST ===');
      print(
          'URL: ${AppConstants.baseUrl}${AppConstants.adminAttendanceFilteredEndpoint}');
      print('Method: POST');
      print('statusTime: $statusTime');
      print('date: $date');
      print('');

      final response = await _dio.post(
        AppConstants.adminAttendanceFilteredEndpoint,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            // Dio will automatically set Content-Type for FormData
          },
        ),
      );

      print('=== ADMIN ATTENDANCE FILTERED API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('');

      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to load filtered employees');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to load filtered employees');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Admin Leave List API - requires Bearer token
  /// Returns: {status: bool, data: [...], message: String}
  Future<Map<String, dynamic>> getAdminLeaveList(String token) async {
    try {
      print('=== ADMIN LEAVE LIST API REQUEST ===');
      print('URL: ${AppConstants.baseUrl}${AppConstants.adminLeaveEndpoint}');
      print('Method: GET');
      print(
          'Token: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
      print('');

      final response = await _dio.get(
        AppConstants.adminLeaveEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('=== ADMIN LEAVE LIST API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('Response Data Type: ${response.data.runtimeType}');
      if (response.data is Map) {
        print('Has status: ${(response.data as Map).containsKey('status')}');
        print('Status value: ${(response.data as Map)['status']}');
        print('Has data: ${(response.data as Map).containsKey('data')}');
        if ((response.data as Map).containsKey('data')) {
          final data = (response.data as Map)['data'];
          print('Data type: ${data.runtimeType}');
          if (data is List) {
            print('Data length: ${data.length}');
          }
        }
      }
      print('');

      return response.data;
    } on DioException catch (e) {
      print('=== ADMIN LEAVE LIST API ERROR ===');
      print('Error Type: ${e.type}');
      print('Error Message: ${e.message}');
      if (e.response != null) {
        print('Response Status Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
      }
      print('');

      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to load leave list');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to load leave list');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Add Admin Leave API - requires Bearer token
  /// Parameters: employeeId, leaveType, startDate, endDate, reason, remarks
  /// Returns: {status: bool, message: String}
  Future<Map<String, dynamic>> addAdminLeave(
    String token, {
    required String employeeId,
    required String leaveType,
    required String startDate,
    required String endDate,
    required String reason,
    String? remarks,
  }) async {
    try {
      // Send as JSON, not FormData
      final requestData = {
        'employee_id': employeeId,
        'leave_type': leaveType,
        'start_date': startDate,
        'end_date': endDate,
        'reason': reason,
        if (remarks != null && remarks.isNotEmpty) 'remarks': remarks,
      };

      print('=== ADD ADMIN LEAVE API REQUEST ===');
      print(
          'URL: ${AppConstants.baseUrl}${AppConstants.adminLeaveAddEndpoint}');
      print('Method: POST');
      print('Data: $requestData');
      print('');

      final response = await _dio.post(
        AppConstants.adminLeaveAddEndpoint,
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('=== ADD ADMIN LEAVE API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('');

      return response.data;
    } on DioException catch (e) {
      print('=== ADD ADMIN LEAVE API ERROR ===');
      print('Error Type: ${e.type}');
      print('Error Message: ${e.message}');
      if (e.response != null) {
        print('Response Status Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
      }
      print('');

      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(responseData['message'] ?? 'Failed to add leave');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to add leave');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Update Admin Leave API - requires Bearer token
  /// Parameters: leaveId, employeeId, leaveType, startDate, endDate, reason, remarks
  /// Returns: {status: bool, message: String}
  Future<Map<String, dynamic>> updateAdminLeave(
    String token, {
    required String leaveId,
    required String employeeId,
    required String leaveType,
    required String startDate,
    required String endDate,
    required String reason,
    String? remarks,
  }) async {
    try {
      // Send as JSON, not FormData
      final requestData = {
        'employee_id': employeeId,
        'leave_type': leaveType,
        'start_date': startDate,
        'end_date': endDate,
        'reason': reason,
        if (remarks != null && remarks.isNotEmpty) 'remarks': remarks,
      };

      final endpoint = '${AppConstants.adminLeaveEditEndpoint}/$leaveId';

      print('=== UPDATE ADMIN LEAVE API REQUEST ===');
      print('URL: ${AppConstants.baseUrl}$endpoint');
      print('Method: POST');
      print('Leave ID: $leaveId');
      print('Data: $requestData');
      print('');

      final response = await _dio.post(
        endpoint,
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('=== UPDATE ADMIN LEAVE API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('');

      return response.data;
    } on DioException catch (e) {
      print('=== UPDATE ADMIN LEAVE API ERROR ===');
      print('Error Type: ${e.type}');
      print('Error Message: ${e.message}');
      if (e.response != null) {
        print('Response Status Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
      }
      print('');

      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(responseData['message'] ?? 'Failed to update leave');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to update leave');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Delete Admin Leave API - requires Bearer token
  /// Parameters: leaveId (in URL path)
  /// Returns: {status: bool, message: String}
  Future<Map<String, dynamic>> deleteAdminLeave(
    String token, {
    required String leaveId,
  }) async {
    try {
      final endpoint = '${AppConstants.adminLeaveDeleteEndpoint}/$leaveId';

      print('=== DELETE ADMIN LEAVE API REQUEST ===');
      print('URL: ${AppConstants.baseUrl}$endpoint');
      print('Method: DELETE');
      print('Leave ID: $leaveId');
      print('');

      final response = await _dio.delete(
        endpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('=== DELETE ADMIN LEAVE API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('');

      return response.data;
    } on DioException catch (e) {
      print('=== DELETE ADMIN LEAVE API ERROR ===');
      print('Error Type: ${e.type}');
      print('Error Message: ${e.message}');
      if (e.response != null) {
        print('Response Status Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
      }
      print('');

      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(responseData['message'] ?? 'Failed to delete leave');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to delete leave');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Update Admin Leave Status API - requires Bearer token
  /// Parameters: leaveId, employeeId, status
  /// Returns: {status: bool, message: String}
  Future<Map<String, dynamic>> updateAdminLeaveStatus(
    String token, {
    required String leaveId,
    required String employeeId,
    required int status,
  }) async {
    try {
      final requestData = {
        'leave_id': int.parse(leaveId),
        'employee_id': int.parse(employeeId),
        'status': status,
      };

      print('=== UPDATE ADMIN LEAVE STATUS API REQUEST ===');
      print(
          'URL: ${AppConstants.baseUrl}${AppConstants.adminLeaveUpdateStatusEndpoint}');
      print('Method: POST');
      print('Data: $requestData');
      print('');

      final response = await _dio.post(
        AppConstants.adminLeaveUpdateStatusEndpoint,
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('=== UPDATE ADMIN LEAVE STATUS API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('');

      return response.data;
    } on DioException catch (e) {
      print('=== UPDATE ADMIN LEAVE STATUS API ERROR ===');
      print('Error Type: ${e.type}');
      print('Error Message: ${e.message}');
      if (e.response != null) {
        print('Response Status Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
      }
      print('');

      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to update leave status');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to update leave status');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Employee Permission API - checks if mobile clocking is allowed
  /// Requires Bearer token
  /// Returns: {status: int, message: String, data: {allow_mobile_clock: int}}
  Future<Map<String, dynamic>> getEmployeePermission(String token) async {
    try {
      final response = await _dio.post(
        AppConstants.employeePermissionEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to fetch employee permission');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to fetch employee permission');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Payslip List API - requires Bearer token, Cookie, and FormData
  /// Returns: {status: bool, message: String, total: int, data: [...]}
  Future<Map<String, dynamic>> getPayslipList(
    String token,
    String? cookie,
    String monthYear,
    String amount,
    String reason,
    String oneTimeDeduct,
    String monthlyInstallment,
  ) async {
    try {
      final formData = FormData.fromMap({
        'month_year': monthYear,
        'amount': amount,
        'reason': reason,
        'one_time_deduct': oneTimeDeduct,
        'monthly_installment': monthlyInstallment,
      });

      final headers = <String, dynamic>{
        'Authorization': 'Bearer $token',
      };

      // Add Cookie header if provided
      if (cookie != null && cookie.isNotEmpty) {
        headers['Cookie'] = cookie;
      }

      final response = await _dio.post(
        AppConstants.payslipListEndpoint,
        data: formData,
        options: Options(
          headers: headers,
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to fetch payslip list');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to fetch payslip list');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Generate Payslip API - requires Bearer token, Cookie, payment_id in FormData
  /// Returns: {status: bool, message: String, data: {employee: {...}, payslip: {...}, payslip_download_link: String}}
  Future<Map<String, dynamic>> generatePayslip(
    String token,
    String? cookie,
    String paymentId,
  ) async {
    try {
      final formData = FormData.fromMap({
        'payment_id': paymentId,
      });

      final headers = <String, dynamic>{
        'Authorization': 'Bearer $token',
      };

      // Add Cookie header if provided
      if (cookie != null && cookie.isNotEmpty) {
        headers['Cookie'] = cookie;
      }

      final response = await _dio.post(
        AppConstants.generatePayslipEndpoint,
        data: formData,
        options: Options(
          headers: headers,
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to generate payslip');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to generate payslip');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Payslip Details API - requires Bearer token, Cookie, and pay_id in FormData
  /// Returns: {status: bool, message: String, data: {employee: {...}, salary: {...}, allowances: {...}, deductions: {...}, total_salary_details: {...}}}
  Future<Map<String, dynamic>> getPayslipDetails(
    String token,
    String? cookie,
    String payId,
  ) async {
    try {
      final formData = FormData.fromMap({
        'pay_id': payId,
      });

      final headers = <String, dynamic>{
        'Authorization': 'Bearer $token',
      };

      // Add Cookie header if provided
      if (cookie != null && cookie.isNotEmpty) {
        headers['Cookie'] = cookie;
      }

      final response = await _dio.post(
        AppConstants.payslipDetailEndpoint,
        data: formData,
        options: Options(
          headers: headers,
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to fetch payslip details');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to fetch payslip details');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Advance Salary List API - requires Bearer token and optional Cookie
  /// Returns: {status: bool, message: String, total: int, data: [...]}
  Future<Map<String, dynamic>> getAdvanceSalaryList(
    String token,
    String? cookie,
  ) async {
    try {
      final headers = <String, dynamic>{
        'Authorization': 'Bearer $token',
      };

      // Add Cookie header if provided
      if (cookie != null && cookie.isNotEmpty) {
        headers['Cookie'] = cookie;
      }

      final response = await _dio.post(
        AppConstants.advanceSalaryListEndpoint,
        options: Options(
          headers: headers,
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to fetch advance salary list');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to fetch advance salary list');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Add Advance Salary API - requires Bearer token, Cookie, and FormData
  /// Returns: {status: bool, message: String}
  Future<Map<String, dynamic>> addAdvanceSalary(
    String token,
    String? cookie,
    String monthYear,
    String amount,
    String reason,
    String oneTimeDeduct,
    String monthlyInstallment,
  ) async {
    try {
      final formData = FormData.fromMap({
        'month_year': monthYear,
        'amount': amount,
        'reason': reason,
        'one_time_deduct': oneTimeDeduct,
        'monthly_installment': monthlyInstallment,
      });

      final headers = <String, dynamic>{
        'Authorization': 'Bearer $token',
      };

      // Add Cookie header if provided
      if (cookie != null && cookie.isNotEmpty) {
        headers['Cookie'] = cookie;
      }

      final response = await _dio.post(
        AppConstants.addAdvanceSalaryEndpoint,
        data: formData,
        options: Options(
          headers: headers,
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to add advance salary');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to add advance salary');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Advance Salary Report List API - requires Bearer token and optional Cookie
  /// Returns: {status: bool, message: String, total: int, data: [...]}
  Future<Map<String, dynamic>> getAdvanceSalaryReportList(
    String token,
    String? cookie,
  ) async {
    try {
      final headers = <String, dynamic>{
        'Authorization': 'Bearer $token',
      };

      // Add Cookie header if provided
      if (cookie != null && cookie.isNotEmpty) {
        headers['Cookie'] = cookie;
      }

      final response = await _dio.post(
        AppConstants.advanceSalaryReportListEndpoint,
        options: Options(
          headers: headers,
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to fetch advance salary report list');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to fetch advance salary report list');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Performance List API - requires Bearer token and optional Cookie
  /// Returns: {status: bool, message: String, total: int, data: [...]}
  Future<Map<String, dynamic>> getPerformanceList(
    String token,
    String? cookie,
  ) async {
    try {
      final headers = <String, dynamic>{
        'Authorization': 'Bearer $token',
      };

      // Add Cookie header if provided
      if (cookie != null && cookie.isNotEmpty) {
        headers['Cookie'] = cookie;
      }

      final response = await _dio.post(
        AppConstants.performanceListEndpoint,
        options: Options(
          headers: headers,
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to fetch performance list');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to fetch performance list');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  /// Get Performance Detail By ID API - requires Bearer token, Cookie, and FormData
  /// Returns: {status: bool, message: String, data: {...}}
  Future<Map<String, dynamic>> getPerformanceDetailById(
    String token,
    String? cookie,
    String performanceAppraisalId,
  ) async {
    try {
      final formData = FormData.fromMap({
        'performance_appraisal_id': performanceAppraisalId,
      });

      final headers = <String, dynamic>{
        'Authorization': 'Bearer $token',
      };

      // Add Cookie header if provided
      if (cookie != null && cookie.isNotEmpty) {
        headers['Cookie'] = cookie;
      }

      final response = await _dio.post(
        AppConstants.performanceDetailEndpoint,
        data: formData,
        options: Options(
          headers: headers,
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          throw Exception(
              responseData['message'] ?? 'Failed to fetch performance details');
        } else if (responseData is String) {
          throw Exception(responseData);
        } else {
          throw Exception('Failed to fetch performance details');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }
}
