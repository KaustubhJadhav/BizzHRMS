import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';
import 'package:bizzhrms_flutter_app/core/constants/app_constants.dart';
import 'package:bizzhrms_flutter_app/data/data_sources/remote_data_source.dart';

enum ClockingStatus { initial, loading, success, error }

class HomeViewModel extends ChangeNotifier {
  ClockingStatus _clockingStatus = ClockingStatus.initial;
  String? _errorMessage;
  String? _currentClockState; // 'in' or 'out'
  int? _timeId;
  bool _disposed = false;
  bool _allowMobileClock = true; // Default to true, will be updated from API
  final RemoteDataSource _remoteDataSource = RemoteDataSource();

  ClockingStatus get clockingStatus => _clockingStatus;
  String? get errorMessage => _errorMessage;
  String? get currentClockState => _currentClockState;
  int? get timeId => _timeId;
  bool get allowMobileClock => _allowMobileClock;

  /// Load employee permission to check if mobile clocking is allowed
  Future<void> loadEmployeePermission() async {
    try {
      final token = await PreferencesHelper.getUserToken();
      if (token == null || token.isEmpty) {
        print('=== LOAD PERMISSION: User not authenticated ===');
        return;
      }

      print('=== LOAD PERMISSION: Fetching employee permission ===');
      final response = await _remoteDataSource.getEmployeePermission(token);

      if (response['status'] == 200 && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        final allowMobileClock = data['allow_mobile_clock'];
        
        // Handle different data types (int, string, bool)
        if (allowMobileClock is int) {
          _allowMobileClock = allowMobileClock == 1;
        } else if (allowMobileClock is String) {
          _allowMobileClock = allowMobileClock == '1' || allowMobileClock.toLowerCase() == 'true';
        } else if (allowMobileClock is bool) {
          _allowMobileClock = allowMobileClock;
        } else {
          _allowMobileClock = false;
        }
        
        print('=== LOAD PERMISSION: Allow Mobile Clock = $_allowMobileClock ===');
        
        if (!_disposed) {
          notifyListeners();
        }
      } else {
        print('=== LOAD PERMISSION: Failed - ${response['message']} ===');
        // Default to false if API fails
        _allowMobileClock = false;
        if (!_disposed) {
          notifyListeners();
        }
      }
    } catch (e) {
      print('=== LOAD PERMISSION: ERROR ===');
      print('Error: $e');
      // Default to false on error
      _allowMobileClock = false;
      if (!_disposed) {
        notifyListeners();
      }
    }
  }

  /// Load current clock state from attendance API
  /// This should be called when the view model is initialized
  Future<void> loadCurrentClockState() async {
    try {
      // Get token and user_id from preferences
      final token = await PreferencesHelper.getUserToken();
      final userId = await PreferencesHelper.getUserId();

      if (token == null || token.isEmpty || userId == null || userId.isEmpty) {
        print('=== LOAD CLOCK STATE: User not authenticated ===');
        return;
      }

      // Get current month and year
      final now = DateTime.now();
      final currentMonth = now.month;
      final currentYear = now.year;
      final todayString = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      print('=== LOAD CLOCK STATE: Fetching attendance ===');
      print('Month: $currentMonth, Year: $currentYear');
      print('Today: $todayString');

      // Fetch month attendance list to find today's record
      final monthResponse = await _remoteDataSource.getMonthAttendance(
        token,
        userId,
        currentMonth,
        currentYear,
      );

      print('=== LOAD CLOCK STATE: Month Response ===');
      print('Status: ${monthResponse['status']}');

      if (monthResponse['status'] == true && monthResponse['data'] != null) {
        final monthData = monthResponse['data'];
        List<Map<String, dynamic>> attendanceRecords = [];
        
        if (monthData is List) {
          attendanceRecords = monthData.cast<Map<String, dynamic>>();
        }

        // Find today's attendance record
        Map<String, dynamic>? todayAttendance;
        for (var record in attendanceRecords) {
          // Check both 'date' and 'attendance_date' fields
          final recordDate = record['date']?.toString() ?? record['attendance_date']?.toString();
          if (recordDate == todayString) {
            todayAttendance = record;
            break;
          }
        }

        if (todayAttendance != null) {
          print('=== LOAD CLOCK STATE: Found today\'s attendance ===');
          
          // Extract the MOST RECENT clock_in and clock_out from logs
          // This handles multiple clock in/out cycles in a day
          String? lastClockIn;
          String? lastClockOut;
          DateTime? lastClockInTime;
          DateTime? lastClockOutTime;

          // Check logs array first
          final logs = todayAttendance['logs'];
          if (logs != null && logs is List && logs.isNotEmpty) {
            // Iterate through all logs to find the most recent clock_in and clock_out
            for (var log in logs) {
              if (log is Map<String, dynamic>) {
                // Check for clock_in
                final logClockIn = log['clock_in']?.toString();
                if (logClockIn != null && 
                    logClockIn.isNotEmpty && 
                    logClockIn != '00:00' && 
                    logClockIn != 'null') {
                  // Try to parse as DateTime to compare timestamps
                  try {
                    // Handle both "2025-11-13 11:39:05" and "11:39:05" formats
                    DateTime? parsedTime;
                    if (logClockIn.contains(' ')) {
                      // Full datetime format
                      parsedTime = DateTime.tryParse(logClockIn);
                    } else {
                      // Time only format - use today's date
                      final timeParts = logClockIn.split(':');
                      if (timeParts.length >= 2) {
                        final now = DateTime.now();
                        parsedTime = DateTime(
                          now.year,
                          now.month,
                          now.day,
                          int.tryParse(timeParts[0]) ?? 0,
                          int.tryParse(timeParts[1]) ?? 0,
                          timeParts.length >= 3 ? int.tryParse(timeParts[2]) ?? 0 : 0,
                        );
                      }
                    }
                    
                    if (parsedTime != null) {
                      if (lastClockInTime == null || parsedTime.isAfter(lastClockInTime)) {
                        lastClockIn = logClockIn;
                        lastClockInTime = parsedTime;
                      }
                    } else {
                      // If parsing fails, just use the string value (fallback)
                      if (lastClockIn == null) {
                        lastClockIn = logClockIn;
                      }
                    }
                  } catch (e) {
                    // If parsing fails, just use the string value (fallback)
                    if (lastClockIn == null) {
                      lastClockIn = logClockIn;
                    }
                  }
                }

                // Check for clock_out
                final logClockOut = log['clock_out']?.toString();
                if (logClockOut != null && 
                    logClockOut.isNotEmpty && 
                    logClockOut != '00:00' && 
                    logClockOut != 'null') {
                  // Try to parse as DateTime to compare timestamps
                  try {
                    // Handle both "2025-11-13 12:24:21" and "12:24:21" formats
                    DateTime? parsedTime;
                    if (logClockOut.contains(' ')) {
                      // Full datetime format
                      parsedTime = DateTime.tryParse(logClockOut);
                    } else {
                      // Time only format - use today's date
                      final timeParts = logClockOut.split(':');
                      if (timeParts.length >= 2) {
                        final now = DateTime.now();
                        parsedTime = DateTime(
                          now.year,
                          now.month,
                          now.day,
                          int.tryParse(timeParts[0]) ?? 0,
                          int.tryParse(timeParts[1]) ?? 0,
                          timeParts.length >= 3 ? int.tryParse(timeParts[2]) ?? 0 : 0,
                        );
                      }
                    }
                    
                    if (parsedTime != null) {
                      if (lastClockOutTime == null || parsedTime.isAfter(lastClockOutTime)) {
                        lastClockOut = logClockOut;
                        lastClockOutTime = parsedTime;
                      }
                    } else {
                      // If parsing fails, just use the string value (fallback)
                      if (lastClockOut == null) {
                        lastClockOut = logClockOut;
                      }
                    }
                  } catch (e) {
                    // If parsing fails, just use the string value (fallback)
                    if (lastClockOut == null) {
                      lastClockOut = logClockOut;
                    }
                  }
                }
              }
            }
          }

          // Fallback to direct clock_in/clock_out fields if logs didn't have them
          if (lastClockIn == null) {
            final directClockIn = todayAttendance['clock_in']?.toString();
            if (directClockIn != null && 
                directClockIn.isNotEmpty && 
                directClockIn != '00:00' && 
                directClockIn != 'null') {
              lastClockIn = directClockIn;
              // Try to parse for comparison
              try {
                if (directClockIn.contains(' ')) {
                  lastClockInTime = DateTime.tryParse(directClockIn);
                }
              } catch (e) {
                // Ignore parsing errors
              }
            }
          }
          
          if (lastClockOut == null) {
            final directClockOut = todayAttendance['clock_out']?.toString();
            if (directClockOut != null && 
                directClockOut.isNotEmpty && 
                directClockOut != '00:00' && 
                directClockOut != 'null') {
              lastClockOut = directClockOut;
              // Try to parse for comparison
              try {
                if (directClockOut.contains(' ')) {
                  lastClockOutTime = DateTime.tryParse(directClockOut);
                }
              } catch (e) {
                // Ignore parsing errors
              }
            }
          }

          print('Last Clock In: $lastClockIn');
          print('Last Clock Out: $lastClockOut');

          // Determine clock state based on most recent clock_in vs most recent clock_out
          if (lastClockIn != null && lastClockIn.isNotEmpty && lastClockIn != '00:00' && lastClockIn != 'null') {
            if (lastClockOut == null || lastClockOut.isEmpty || lastClockOut == '00:00' || lastClockOut == 'null') {
              // No clock out at all - user is clocked in
              _currentClockState = 'in';
              print('Clock State: IN (clocked in at $lastClockIn, no clock out)');
            } else {
              // Both exist - compare timestamps to see which is more recent
              if (lastClockInTime != null && lastClockOutTime != null) {
                // Compare parsed timestamps
                if (lastClockInTime.isAfter(lastClockOutTime)) {
                  // Most recent action was clock in - user is clocked in
                  _currentClockState = 'in';
                  print('Clock State: IN (last clock in at $lastClockIn is after last clock out at $lastClockOut)');
                } else {
                  // Most recent action was clock out - user is clocked out
                  _currentClockState = 'out';
                  print('Clock State: OUT (last clock out at $lastClockOut is after last clock in at $lastClockIn)');
                }
              } else {
                // Can't parse timestamps, use fallback logic
                // If we have both, assume clocked out (conservative approach)
                _currentClockState = 'out';
                print('Clock State: OUT (both exist but timestamps not parseable, defaulting to out)');
              }
            }
          } else {
            // No clock in for today
            _currentClockState = 'out';
            print('Clock State: OUT (no clock in for today)');
          }
        } else {
          // No attendance record for today
          _currentClockState = 'out';
          print('Clock State: OUT (no attendance record for today)');
        }

        // Only notify listeners if the view model hasn't been disposed
        if (!_disposed) {
          notifyListeners();
        }
      } else {
        print('Failed to load clock state: ${monthResponse['message']}');
        _currentClockState = 'out';
        if (!_disposed) {
          notifyListeners();
        }
      }
    } catch (e) {
      print('=== LOAD CLOCK STATE: ERROR ===');
      print('Error: $e');
      // Don't set error state here, just log it
      // The user can still clock in/out even if loading state fails
      _currentClockState = 'out';
      if (!_disposed) {
        notifyListeners();
      }
    }
  }

  /// Clock in or clock out
  /// clockState should be 'clock_in' or 'clock_out'
  Future<bool> setClocking(String clockState) async {
    if (_disposed) return false;
    
    _clockingStatus = ClockingStatus.loading;
    _errorMessage = null;
    if (!_disposed) {
      notifyListeners();
    }

    try {
      // Get token and user_id from preferences
      final token = await PreferencesHelper.getUserToken();
      final userId = await PreferencesHelper.getUserId();

      if (token == null || token.isEmpty || userId == null || userId.isEmpty) {
        if (_disposed) return false;
        _clockingStatus = ClockingStatus.error;
        _errorMessage = 'User not authenticated';
        if (!_disposed) {
          notifyListeners();
        }
        return false;
      }

      // Use user_id as employee_id directly
      final employeeId = userId;

      // Get device location
      double? latitude;
      double? longitude;
      
      try {
        // Check if location services are enabled
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          print('=== LOCATION: Location services are disabled ===');
          _clockingStatus = ClockingStatus.error;
          _errorMessage = 'Location services are disabled. Please enable location services to clock in/out.';
          if (!_disposed) {
            notifyListeners();
          }
          return false;
        }

        // Check location permissions
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            print('=== LOCATION: Location permissions denied ===');
            _clockingStatus = ClockingStatus.error;
            _errorMessage = 'Location permissions are denied. Please grant location permission to clock in/out.';
            if (!_disposed) {
              notifyListeners();
            }
            return false;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          print('=== LOCATION: Location permissions denied forever ===');
          _clockingStatus = ClockingStatus.error;
          _errorMessage = 'Location permissions are permanently denied. Please enable them in app settings.';
          if (!_disposed) {
            notifyListeners();
          }
          return false;
        }

        // Get current position
        print('=== LOCATION: Getting current position ===');
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
        
        latitude = position.latitude;
        longitude = position.longitude;
        
        print('=== LOCATION: Position obtained ===');
        print('Latitude: $latitude');
        print('Longitude: $longitude');
        print('');
      } catch (e) {
        print('=== LOCATION: Error getting location ===');
        print('Error: $e');
        print('');
        // Continue with null lat/lng - API will handle it
        // Some APIs might still work without location, or return appropriate error
      }

      // Print request details
      print('=== CLOCKING API REQUEST ===');
      print('Endpoint: ${AppConstants.baseUrl}${AppConstants.setClockingEndpoint}');
      print('Employee ID: $employeeId');
      print('Clock State: $clockState');
      print('Latitude: ${latitude ?? "N/A"}');
      print('Longitude: ${longitude ?? "N/A"}');
      print('Token: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
      print('');

      // Call the API
      final response = await _remoteDataSource.setClocking(
        token,
        employeeId,
        clockState,
        latitude,
        longitude,
      );

      if (_disposed) return false;

      // Print response
      print('=== CLOCKING API RESPONSE ===');
      print('Full Response: $response');
      print('Status: ${response['status']}');
      print('Message: ${response['message']}');
      if (response['data'] != null) {
        print('Data: ${response['data']}');
      }
      print('');

      // Check response
      if (response['status'] == 200) {
        final data = response['data'] as Map<String, dynamic>?;
        if (data != null) {
          _currentClockState = data['clock_state'] as String?;
          _timeId = data['time_id'] as int?;
          print('Clock State Updated: $_currentClockState');
          print('Time ID: $_timeId');
        }
        _clockingStatus = ClockingStatus.success;
        if (!_disposed) {
          notifyListeners();
        }
        return true;
      } else {
        _clockingStatus = ClockingStatus.error;
        _errorMessage = response['message']?.toString() ?? 'Failed to set clocking';
        print('ERROR: $_errorMessage');
        if (!_disposed) {
          notifyListeners();
        }
        return false;
      }
    } catch (e) {
      if (_disposed) return false;
      print('=== CLOCKING API ERROR ===');
      print('Error: $e');
      print('');
      _clockingStatus = ClockingStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      if (!_disposed) {
        notifyListeners();
      }
      return false;
    }
  }

  /// Clock in
  Future<bool> clockIn() async {
    return await setClocking('clock_in');
  }

  /// Clock out
  Future<bool> clockOut() async {
    return await setClocking('clock_out');
  }

  /// Refresh both clock state and employee permission
  Future<void> refresh() async {
    await Future.wait([
      loadCurrentClockState(),
      loadEmployeePermission(),
    ]);
  }

  void reset() {
    _clockingStatus = ClockingStatus.initial;
    _errorMessage = null;
    _currentClockState = null;
    _timeId = null;
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

