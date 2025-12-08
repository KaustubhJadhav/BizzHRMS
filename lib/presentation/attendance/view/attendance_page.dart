import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../view_model/attendance_view_model.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/sidebar/sidebar_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/header/header_widget.dart';
import 'package:bizzhrms_flutter_app/core/constants/app_constants.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/loading_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/error_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/back_button_widget.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  String? _selectedFilter; // null, 'Present', 'Absent', 'Half Day'

  String _formatTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty || dateTimeStr == 'null') {
      return 'N/A';
    }
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('hh:mm a').format(dateTime);
    } catch (e) {
      return dateTimeStr;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == 'null') {
      return 'N/A';
    }
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd-MMM-yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AttendanceViewModel()
        ..loadAttendanceData(month: _selectedMonth, year: _selectedYear),
      builder: (context, child) {
        return Scaffold(
          drawer: Drawer(
            child: SafeArea(
              child: SidebarWidget(currentRoute: AppConstants.routeAttendance),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                const HeaderWidget(pageTitle: 'Attendance'),
                const BackButtonWidget(title: 'Attendance'),
                Expanded(
                  child: Consumer<AttendanceViewModel>(
                    builder: (context, viewModel, child) {
                      if (viewModel.status == AttendanceStatus.loading) {
                        return const LoadingWidget(
                            message: 'Loading attendance...');
                      }

                      if (viewModel.status == AttendanceStatus.error) {
                        return ErrorDisplayWidget(
                          message: viewModel.errorMessage ??
                              'Failed to load attendance',
                          onRetry: () => viewModel.refresh(),
                        );
                      }

                      return Column(
                        children: [
                          // Monthly Summary Card - Fixed at top
                          if (viewModel.monthlySummary != null)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  16.0, 16.0, 16.0, 16.0),
                              child: ElasticCard(
                                autoBounce: true,
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(18.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Monthly Summary',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Builder(
                                          builder: (context) {
                                            // Sync selected month/year with view model
                                            if (viewModel.month != null &&
                                                viewModel.year != null) {
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) {
                                                if (mounted &&
                                                    (_selectedMonth !=
                                                            viewModel.month ||
                                                        _selectedYear !=
                                                            viewModel.year)) {
                                                  setState(() {
                                                    _selectedMonth =
                                                        viewModel.month!;
                                                    _selectedYear =
                                                        viewModel.year!;
                                                  });
                                                }
                                              });
                                            }
                                            return _buildMonthPicker(
                                                context, viewModel);
                                          },
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildSummaryCard(
                                                'Present',
                                                viewModel.monthlySummary![
                                                            'present']
                                                        ?.toString() ??
                                                    '0',
                                                Colors.green,
                                                onTap: () {
                                                  setState(() {
                                                    _selectedFilter = 'Present';
                                                  });
                                                },
                                                isSelected: _selectedFilter ==
                                                    'Present',
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: _buildSummaryCard(
                                                'Absent',
                                                viewModel.monthlySummary![
                                                            'absent']
                                                        ?.toString() ??
                                                    '0',
                                                Colors.red,
                                                onTap: () {
                                                  setState(() {
                                                    _selectedFilter = 'Absent';
                                                  });
                                                },
                                                isSelected:
                                                    _selectedFilter == 'Absent',
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: _buildSummaryCard(
                                                'Half Day',
                                                viewModel.monthlySummary![
                                                            'half_day']
                                                        ?.toString() ??
                                                    '0',
                                                Colors.orange,
                                                onTap: () {
                                                  setState(() {
                                                    _selectedFilter =
                                                        'Half Day';
                                                  });
                                                },
                                                isSelected: _selectedFilter ==
                                                    'Half Day',
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Reset button row - only show when filter is active
                                        if (_selectedFilter != null) ...[
                                          const SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              TextButton.icon(
                                                onPressed: () {
                                                  setState(() {
                                                    _selectedFilter = null;
                                                  });
                                                },
                                                icon: const Icon(Icons.refresh,
                                                    size: 18),
                                                label:
                                                    const Text('Reset Filter'),
                                                style: TextButton.styleFrom(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          // Scrollable content below Monthly Summary
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Last Attendance Card - Collapsible
                                  if (viewModel.lastAttendance != null)
                                    _CollapsibleLastAttendanceCard(
                                      lastAttendance: viewModel.lastAttendance!,
                                      formatTime: _formatTime,
                                      formatDate: _formatDate,
                                      getStatusColor: _getStatusColor,
                                    ),

                                  const SizedBox(height: 16),

                                  // Attendance List
                                  Builder(
                                    builder: (context) {
                                      // Filter attendance list based on selected filter
                                      List<Map<String, dynamic>> filteredList =
                                          viewModel.attendanceList;
                                      if (_selectedFilter != null) {
                                        filteredList = viewModel.attendanceList
                                            .where((attendance) {
                                          final status = attendance['status']
                                                  ?.toString()
                                                  .toLowerCase() ??
                                              '';
                                          final filterLower =
                                              _selectedFilter!.toLowerCase();

                                          if (filterLower == 'present') {
                                            return status == 'present';
                                          } else if (filterLower == 'absent') {
                                            return status == 'absent';
                                          } else if (filterLower ==
                                              'half day') {
                                            return status.contains('half');
                                          }
                                          return false;
                                        }).toList();
                                      }

                                      if (filteredList.isNotEmpty) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _selectedFilter != null
                                                  ? 'Filtered Attendance Records (${_selectedFilter})'
                                                  : 'All Attendance Records',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount: filteredList.length,
                                              itemBuilder: (context, index) {
                                                final attendance =
                                                    filteredList[index];
                                                return _CollapsibleAttendanceCard(
                                                  attendance: attendance,
                                                  employeeData:
                                                      viewModel.employeeData,
                                                  formatTime: _formatTime,
                                                  formatDate: _formatDate,
                                                  getStatusButtonForStatus:
                                                      _buildStatusButtonForStatus,
                                                );
                                              },
                                            ),
                                          ],
                                        );
                                      } else if (viewModel.status ==
                                          AttendanceStatus.success) {
                                        return const Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(32.0),
                                            child: Text(
                                              'No attendance records found',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        );
                                      } else {
                                        return const SizedBox.shrink();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor ?? const Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthPicker(
      BuildContext context, AttendanceViewModel viewModel) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final currentYear = DateTime.now().year;
    final years = List.generate(5, (index) => currentYear - 2 + index);

    return GestureDetector(
      onTap: () => _showMonthYearPicker(context, months, years, viewModel),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${months[_selectedMonth - 1]} $_selectedYear',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.calendar_today, size: 16),
          ],
        ),
      ),
    );
  }

  void _showMonthYearPicker(
    BuildContext context,
    List<String> months,
    List<int> years,
    AttendanceViewModel viewModel,
  ) {
    int tempMonth = _selectedMonth;
    int tempYear = _selectedYear;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Month & Year',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedMonth = tempMonth;
                      _selectedYear = tempYear;
                    });
                    viewModel.loadAttendanceData(
                      month: _selectedMonth,
                      year: _selectedYear,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                children: [
                  // Month Picker
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Month',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // const SizedBox(height: 5),
                        Expanded(
                          child: Stack(
                            children: [
                              ListWheelScrollView.useDelegate(
                                itemExtent: 50,
                                diameterRatio: 1.5,
                                physics: const FixedExtentScrollPhysics(),
                                controller: FixedExtentScrollController(
                                  initialItem: tempMonth - 1,
                                ),
                                onSelectedItemChanged: (index) {
                                  tempMonth = index + 1;
                                },
                                childDelegate: ListWheelChildBuilderDelegate(
                                  builder: (context, index) {
                                    return Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        months[index],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    );
                                  },
                                  childCount: months.length,
                                ),
                              ),
                              // Fixed center indicator
                              Center(
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(25),
                                    // border: Border.all(
                                    //   color: Colors.blue,
                                    //   width: 1,
                                    // ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Year Picker
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Year',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // const SizedBox(height: 5),
                        Expanded(
                          child: Stack(
                            children: [
                              ListWheelScrollView.useDelegate(
                                itemExtent: 50,
                                diameterRatio: 1.5,
                                physics: const FixedExtentScrollPhysics(),
                                controller: FixedExtentScrollController(
                                  initialItem: years.indexOf(tempYear),
                                ),
                                onSelectedItemChanged: (index) {
                                  tempYear = years[index];
                                },
                                childDelegate: ListWheelChildBuilderDelegate(
                                  builder: (context, index) {
                                    return Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${years[index]}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    );
                                  },
                                  childCount: years.length,
                                ),
                              ),
                              // Fixed center indicator
                              Center(
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(25),
                                    // border: Border.all(
                                    //   color: Colors.blue,
                                    //   width: 0,
                                    // ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    Color color, {
    VoidCallback? onTap,
    bool isSelected = false,
  }) {
    return ElasticCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isSelected ? color : color.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'half day':
        return Colors.orange;
      default:
        return const Color(0xFF2C3E50);
    }
  }

  String _getDayType(String? dateStr, String status) {
    if (dateStr == null || dateStr.isEmpty || dateStr == 'null') {
      return 'Working Day';
    }

    try {
      final date = DateTime.parse(dateStr);
      final weekday = date.weekday;

      // Check if it's Sunday (weekday 7) - only Sundays are Weekly Off
      if (weekday == DateTime.sunday) {
        return 'Weekly Off';
      }

      // Check if status is Holiday
      if (status.toLowerCase() == 'holiday' ||
          status.toLowerCase() == 'weekend') {
        return 'Holiday';
      }

      // Default to Working Day
      return 'Working Day';
    } catch (e) {
      return 'Working Day';
    }
  }

  Widget _buildAttendanceCard(
    Map<String, dynamic> attendance,
    Map<String, dynamic>? employeeData,
  ) {
    final employeeId = employeeData?['employee_id']?.toString() ?? 'N/A';
    final firstName = employeeData?['first_name']?.toString() ?? '';
    final lastName = employeeData?['last_name']?.toString() ?? '';
    final fullName = '$firstName $lastName'.trim();
    final attendanceDate = attendance['date']?.toString() ??
        ''; // API uses 'date' not 'attendance_date'

    // Debug: Print raw attendance data
    if (attendanceDate == DateTime.now().toIso8601String().split('T')[0]) {
      print('=== TODAY ATTENDANCE DEBUG ===');
      print('Full attendance data: $attendance');
      print('clock_in raw: ${attendance['clock_in']}');
      print('clock_out raw: ${attendance['clock_out']}');
      print('logs: ${attendance['logs']}');
      print('');
    }

    // Extract clock_in and clock_out - check if they're in logs array
    String? clockIn;
    String? clockOut;

    // Check if there's a logs array
    if (attendance['logs'] != null && attendance['logs'] is List) {
      final logs = attendance['logs'] as List;

      // Find the FIRST clock_in (earliest) from logs
      for (var log in logs) {
        if (log is Map<String, dynamic>) {
          final logClockIn = log['clock_in']?.toString();
          if (clockIn == null &&
              logClockIn != null &&
              logClockIn.isNotEmpty &&
              logClockIn != '00:00' &&
              logClockIn != 'null') {
            clockIn = logClockIn;
            break; // Found the first one, stop
          }
        }
      }

      // Find the LAST valid clock_out (most recent) by iterating backwards
      for (var log in logs.reversed) {
        if (log is Map<String, dynamic>) {
          final logClockOut = log['clock_out']?.toString();
          // Check if it's a valid clock_out (not null, not empty, not "00:00")
          if (logClockOut != null &&
              logClockOut.isNotEmpty &&
              logClockOut != '00:00' &&
              logClockOut != 'null') {
            clockOut = logClockOut;
            break; // Found the last valid one, stop
          }
        }
      }
    }

    // Fallback to direct clock_in/clock_out fields if logs didn't have them
    clockIn ??= attendance['clock_in']?.toString();
    clockOut ??= attendance['clock_out']?.toString();

    // Debug print for today
    if (attendanceDate == DateTime.now().toIso8601String().split('T')[0]) {
      print('Extracted clock_in: $clockIn');
      print('Extracted clock_out: $clockOut');
      print(
          'Formatted clock_in: ${clockIn != null ? _formatTime(clockIn) : "N/A"}');
      print(
          'Formatted clock_out: ${clockOut != null ? _formatTime(clockOut) : "N/A"}');
      print('');
    }

    final totalWork = attendance['total_work']?.toString() ?? '00:00';
    final totalRest = attendance['total_rest']?.toString() ?? '';
    final attendanceStatus = attendance['status']?.toString() ??
        ''; // API uses 'status' not 'attendance_status'
    final dayType = _getDayType(attendanceDate, attendanceStatus);

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Date and Status Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(attendanceDate),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                // Status Button - Only show the matching status
                _buildStatusButtonForStatus(attendanceStatus),
              ],
            ),
            const SizedBox(height: 12),

            // Day Type - Commented out for now
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text(
            //       'Day Type: $dayType',
            //       style: const TextStyle(
            //         fontSize: 14,
            //         color: Colors.grey,
            //       ),
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 12),

            // Clock In/Out - Clock In on left, Clock Out on right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Clock In: ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      (clockIn != null &&
                              clockIn.isNotEmpty &&
                              clockIn != 'null')
                          ? _formatTime(clockIn)
                          : '00:00',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      'Clock Out: ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      (clockOut != null &&
                              clockOut.isNotEmpty &&
                              clockOut != 'null')
                          ? _formatTime(clockOut)
                          : '00:00',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Total Work and Total Rest - Total Work on left, Total Rest on right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Total Work: ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      totalWork,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                if (totalRest.isNotEmpty)
                  Row(
                    children: [
                      Text(
                        'Total Rest: ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        totalRest,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButtonForStatus(String status) {
    final statusLower = status.toLowerCase();

    // Determine which status button to show based on API response
    if (statusLower == 'present') {
      return _buildStatusButton('P | Present', true, Colors.green);
    } else if (statusLower == 'absent') {
      return _buildStatusButton('A | Absent', true, Colors.red);
    } else if (statusLower.contains('half')) {
      return _buildStatusButton('HD | Half Day', true, Colors.orange);
    } else if (statusLower == 'holiday' || statusLower == 'weekend') {
      return _buildStatusButton('H | Holiday', true, Colors.blue);
    } else {
      // Default fallback - show the status as-is
      return _buildStatusButton(status, true, const Color(0xFF2C3E50));
    }
  }

  Widget _buildStatusButton(String label, bool isActive, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? color : Colors.transparent,
        border: Border.all(
          color: color,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isActive ? Colors.white : color,
        ),
      ),
    );
  }
}

// Collapsible Attendance Card Widget
class _CollapsibleAttendanceCard extends StatefulWidget {
  final Map<String, dynamic> attendance;
  final Map<String, dynamic>? employeeData;
  final String Function(String?) formatTime;
  final String Function(String?) formatDate;
  final Widget Function(String) getStatusButtonForStatus;

  const _CollapsibleAttendanceCard({
    required this.attendance,
    required this.employeeData,
    required this.formatTime,
    required this.formatDate,
    required this.getStatusButtonForStatus,
  });

  @override
  State<_CollapsibleAttendanceCard> createState() =>
      _CollapsibleAttendanceCardState();
}

class _CollapsibleAttendanceCardState extends State<_CollapsibleAttendanceCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
    });
    if (_expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  String _getDayType(String? dateStr, String status) {
    if (dateStr == null || dateStr.isEmpty || dateStr == 'null') {
      return 'Working Day';
    }

    try {
      final date = DateTime.parse(dateStr);
      final weekday = date.weekday;

      if (weekday == DateTime.sunday) {
        return 'Weekly Off';
      }

      if (status.toLowerCase() == 'holiday' ||
          status.toLowerCase() == 'weekend') {
        return 'Holiday';
      }

      return 'Working Day';
    } catch (e) {
      return 'Working Day';
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendanceDate = widget.attendance['date']?.toString() ?? '';
    final attendanceStatus = widget.attendance['status']?.toString() ?? '';
    final dayType = _getDayType(attendanceDate, attendanceStatus);

    // Extract clock_in and clock_out
    String? clockIn;
    String? clockOut;

    if (widget.attendance['logs'] != null &&
        widget.attendance['logs'] is List) {
      final logs = widget.attendance['logs'] as List;

      for (var log in logs) {
        if (log is Map<String, dynamic>) {
          final logClockIn = log['clock_in']?.toString();
          if (clockIn == null &&
              logClockIn != null &&
              logClockIn.isNotEmpty &&
              logClockIn != '00:00' &&
              logClockIn != 'null') {
            clockIn = logClockIn;
            break;
          }
        }
      }

      for (var log in logs.reversed) {
        if (log is Map<String, dynamic>) {
          final logClockOut = log['clock_out']?.toString();
          if (logClockOut != null &&
              logClockOut.isNotEmpty &&
              logClockOut != '00:00' &&
              logClockOut != 'null') {
            clockOut = logClockOut;
            break;
          }
        }
      }
    }

    clockIn ??= widget.attendance['clock_in']?.toString();
    clockOut ??= widget.attendance['clock_out']?.toString();

    final totalWork = widget.attendance['total_work']?.toString() ?? '00:00';
    final totalRest = widget.attendance['total_rest']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Date, Status Button, and Toggle Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.formatDate(attendanceDate),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    widget.getStatusButtonForStatus(attendanceStatus),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: AnimatedRotation(
                        turns: _expanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOutCubic,
                        child: const Icon(Icons.keyboard_arrow_down),
                      ),
                      onPressed: _toggle,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
            // Collapsible Content
            SizeTransition(
              sizeFactor: _animation,
              axisAlignment: -1.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // Clock In/Out - Clock In on left, Clock Out on right
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Clock In: ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            (clockIn != null &&
                                    clockIn.isNotEmpty &&
                                    clockIn != 'null')
                                ? widget.formatTime(clockIn)
                                : '00:00',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            'Clock Out: ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            (clockOut != null &&
                                    clockOut.isNotEmpty &&
                                    clockOut != 'null')
                                ? widget.formatTime(clockOut)
                                : '00:00',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Total Work and Total Rest
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Total Work: ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            totalWork,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      if (totalRest.isNotEmpty)
                        Row(
                          children: [
                            Text(
                              'Total Rest: ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Text(
                              totalRest,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Collapsible Last Attendance Record Card Widget
class _CollapsibleLastAttendanceCard extends StatefulWidget {
  final Map<String, dynamic> lastAttendance;
  final String Function(String?) formatTime;
  final String Function(String?) formatDate;
  final Color Function(String) getStatusColor;

  const _CollapsibleLastAttendanceCard({
    required this.lastAttendance,
    required this.formatTime,
    required this.formatDate,
    required this.getStatusColor,
  });

  @override
  State<_CollapsibleLastAttendanceCard> createState() =>
      _CollapsibleLastAttendanceCardState();
}

class _CollapsibleLastAttendanceCardState
    extends State<_CollapsibleLastAttendanceCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
    });
    if (_expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = widget.formatDate(
      widget.lastAttendance['attendance_date']?.toString(),
    );
    final status =
        widget.lastAttendance['attendance_status']?.toString() ?? 'N/A';
    final statusColor = widget.getStatusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Title and Toggle Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Last Attendance Record',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: AnimatedRotation(
                    turns: _expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(Icons.keyboard_arrow_down),
                  ),
                  onPressed: _toggle,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            // Collapsible Content
            SizeTransition(
              sizeFactor: _animation,
              axisAlignment: -1.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Date',
                    date,
                  ),
                  _buildInfoRow(
                    'Clock In',
                    widget.formatTime(
                      widget.lastAttendance['clock_in']?.toString(),
                    ),
                  ),
                  _buildInfoRow(
                    'Clock Out',
                    widget.formatTime(
                      widget.lastAttendance['clock_out']?.toString(),
                    ),
                  ),
                  _buildInfoRow(
                    'Total Work',
                    widget.lastAttendance['total_work']?.toString() ?? 'N/A',
                  ),
                  _buildInfoRow(
                    'Status',
                    status,
                    valueColor: statusColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor ?? const Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }
}

class ElasticCard extends StatefulWidget {
  final Widget child;
  final bool autoBounce; // NEW

  const ElasticCard({
    super.key,
    required this.child,
    this.autoBounce = false, // default: no auto bounce
  });

  @override
  State<ElasticCard> createState() => _ElasticCardState();
}

class _ElasticCardState extends State<ElasticCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Trigger bounce on screen load
    if (widget.autoBounce) {
      Future.delayed(const Duration(milliseconds: 180), () {
        _startAutoBounce();
      });
    }
  }

  void _startAutoBounce() {
    setState(() => _dragOffset = 40); // push downward a bit

    _controller.reset();
    _controller.addListener(() {
      setState(() {
        _dragOffset = _dragOffset * (1 - _controller.value);
      });
    });

    _controller.forward();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dy * 0.4;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    _controller.reset();
    _controller.addListener(() {
      setState(() {
        _dragOffset = _dragOffset * (1 - _controller.value);
      });
    });
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final stretch = (_dragOffset / 250).clamp(-0.25, 0.25);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragUpdate: _onDragUpdate,
      onVerticalDragEnd: _onDragEnd,
      child: Transform.scale(
        scaleY: 1 + stretch,
        child: widget.child,
      ),
    );
  }
}
