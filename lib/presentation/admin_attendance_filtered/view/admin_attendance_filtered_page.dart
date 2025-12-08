import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/admin_attendance_filtered_view_model.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/sidebar/sidebar_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/header/header_widget.dart';
import 'package:bizzhrms_flutter_app/core/constants/app_constants.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/loading_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/error_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/back_button_widget.dart';

class AdminAttendanceFilteredPage extends StatefulWidget {
  final String statusTime;
  final String date;

  const AdminAttendanceFilteredPage({
    super.key,
    required this.statusTime,
    required this.date,
  });

  @override
  State<AdminAttendanceFilteredPage> createState() =>
      _AdminAttendanceFilteredPageState();
}

class _AdminAttendanceFilteredPageState
    extends State<AdminAttendanceFilteredPage> {
  final TextEditingController _searchController = TextEditingController();
  int _entriesPerPage = 10;
  int _currentPage = 1;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredEmployees(
      AdminAttendanceFilteredViewModel viewModel) {
    List<Map<String, dynamic>> employees = viewModel.employeesList;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      employees = employees.where((employee) {
        final employeeName =
            employee['employee_name']?.toString().toLowerCase() ?? '';
        final userId = employee['user_id']?.toString().toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();

        return employeeName.contains(query) || userId.contains(query);
      }).toList();
    }

    return employees;
  }

  List<Map<String, dynamic>> _getPaginatedEmployees(
      AdminAttendanceFilteredViewModel viewModel) {
    final filtered = _getFilteredEmployees(viewModel);
    final startIndex = (_currentPage - 1) * _entriesPerPage;
    final endIndex = startIndex + _entriesPerPage;

    if (startIndex >= filtered.length) {
      return [];
    }

    return filtered.sublist(
      startIndex,
      endIndex > filtered.length ? filtered.length : endIndex,
    );
  }

  int _getTotalPages(AdminAttendanceFilteredViewModel viewModel) {
    final filtered = _getFilteredEmployees(viewModel);
    return (filtered.length / _entriesPerPage).ceil();
  }

  String _getDayType(String? dateStr) {
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

      // Default to Working Day
      return 'Working Day';
    } catch (e) {
      return 'Working Day';
    }
  }

  Widget _buildEmployeeCard(Map<String, dynamic> employee) {
    final employeeName = employee['employee_name']?.toString() ?? 'N/A';
    final userId = employee['user_id']?.toString() ?? 'N/A';
    final clockIn = employee['clock_in']?.toString() ?? '-';
    final clockOut = employee['clock_out']?.toString() ?? '-';
    final totalWork = employee['total_work']?.toString() ?? '00:00';
    final totalRest = employee['total_rest']?.toString() ?? '00:00';
    final status = employee['attendance_status']?.toString() ?? 'N/A';
    final dayType = _getDayType(widget.date);

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Employee Header with View Logs button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '$userId | $employeeName',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {
                    // TODO: Implement View Logs functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('View Logs for $employeeName'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Text('View Logs'),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            // Content - Responsive Layout
            LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 600;

                if (isSmallScreen) {
                  // Stack vertically on small screens
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Day Type
                      Row(
                        children: [
                          const Text(
                            'Day Type: ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            dayType,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Status Buttons
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildStatusButton(
                              'P | Present', status == 'Present'),
                          _buildStatusButton('A | Absent', status == 'Absent'),
                          _buildStatusButton('HD | Half Day',
                              status.toLowerCase().contains('half')),
                          _buildStatusButton('L | Leave',
                              status.toLowerCase().contains('leave')),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Total Work and Total Rest
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Total Work: ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
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
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Total Rest: ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
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
                      const SizedBox(height: 12),

                      // Clock In and Clock Out
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Clock In: ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                clockIn == '-' ? '00:00' : clockIn,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Clock Out: ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                clockOut == '-' ? '00:00' : clockOut,
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
                    ],
                  );
                } else {
                  // Two columns on larger screens
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Day Type
                            Row(
                              children: [
                                const Text(
                                  'Day Type: ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  dayType,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Status Buttons
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildStatusButton(
                                    'P | Present', status == 'Present'),
                                _buildStatusButton(
                                    'A | Absent', status == 'Absent'),
                                _buildStatusButton('HD | Half Day',
                                    status.toLowerCase().contains('half')),
                                _buildStatusButton('L | Leave',
                                    status.toLowerCase().contains('leave')),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Right Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Total Work and Total Rest
                            Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Total Work: ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        totalWork,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Total Rest: ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        totalRest,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Clock In and Clock Out
                            Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Clock In: ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        clockIn == '-' ? '00:00' : clockIn,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Clock Out: ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        clockOut == '-' ? '00:00' : clockOut,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red,
                                        ),
                                        overflow: TextOverflow.ellipsis,
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
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.transparent,
        border: Border.all(
          color: isActive ? Colors.green : Colors.grey.shade400,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isActive ? Colors.white : Colors.grey.shade700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = AdminAttendanceFilteredViewModel();
        viewModel.loadFilteredEmployees(
          statusTime: widget.statusTime,
          date: widget.date,
        );
        return viewModel;
      },
      builder: (context, child) {
        return Scaffold(
          drawer: Drawer(
            child: SafeArea(
              child: SidebarWidget(
                  currentRoute: AppConstants.routeAdminAttendanceFiltered),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                HeaderWidget(pageTitle: '${widget.statusTime} Employees'),
                BackButtonWidget(title: '${widget.statusTime} Employees'),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Consumer<AdminAttendanceFilteredViewModel>(
                      builder: (context, viewModel, child) {
                        if (viewModel.status ==
                            AdminAttendanceFilteredStatus.loading) {
                          return const LoadingWidget(
                              message: 'Loading employees...');
                        }

                        if (viewModel.status ==
                            AdminAttendanceFilteredStatus.error) {
                          return ErrorDisplayWidget(
                            message: viewModel.errorMessage ??
                                'Failed to load employees',
                            onRetry: () => viewModel.refresh(),
                          );
                        }

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title with date
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final isSmallScreen =
                                        constraints.maxWidth < 600;
                                    if (isSmallScreen) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${widget.statusTime} Employees - ${widget.date}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Total: ${viewModel.total}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      );
                                    } else {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${widget.statusTime} Employees - ${widget.date}',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Total: ${viewModel.total}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Search Control
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final isSmallScreen =
                                        constraints.maxWidth < 600;

                                    if (isSmallScreen) {
                                      return Row(
                                        children: [
                                          const Text('Search:'),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: TextField(
                                              controller: _searchController,
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8),
                                              ),
                                              onChanged: (value) {
                                                setState(() {
                                                  _searchQuery = value;
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    } else {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          const Text('Search:'),
                                          const SizedBox(width: 8),
                                          SizedBox(
                                            width: 200,
                                            child: TextField(
                                              controller: _searchController,
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8),
                                              ),
                                              onChanged: (value) {
                                                setState(() {
                                                  _searchQuery = value;
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Employee Cards List
                                Expanded(
                                  child: _getPaginatedEmployees(viewModel)
                                          .isEmpty
                                      ? const Center(
                                          child: Text(
                                            'No employees found',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          itemCount:
                                              _getPaginatedEmployees(viewModel)
                                                  .length,
                                          itemBuilder: (context, index) {
                                            final employee =
                                                _getPaginatedEmployees(
                                                    viewModel)[index];
                                            return _buildEmployeeCard(employee);
                                          },
                                        ),
                                ),
                                const SizedBox(height: 16),

                                // Pagination
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final totalPages =
                                        _getTotalPages(viewModel);
                                    final filteredCount =
                                        _getFilteredEmployees(viewModel).length;
                                    final startIndex =
                                        (_currentPage - 1) * _entriesPerPage +
                                            1;
                                    final endIndex = startIndex +
                                        _getPaginatedEmployees(viewModel)
                                            .length -
                                        1;

                                    if (constraints.maxWidth < 600) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Showing $startIndex to $endIndex of $filteredCount entries',
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 4,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.chevron_left),
                                                onPressed: _currentPage > 1
                                                    ? () {
                                                        setState(() {
                                                          _currentPage--;
                                                        });
                                                      }
                                                    : null,
                                              ),
                                              ...List.generate(
                                                totalPages,
                                                (index) {
                                                  final pageNum = index + 1;
                                                  if (pageNum == _currentPage ||
                                                      pageNum == 1 ||
                                                      pageNum == totalPages ||
                                                      (pageNum >=
                                                              _currentPage -
                                                                  1 &&
                                                          pageNum <=
                                                              _currentPage +
                                                                  1)) {
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 4),
                                                      child: TextButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            _currentPage =
                                                                pageNum;
                                                          });
                                                        },
                                                        style: TextButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              _currentPage ==
                                                                      pageNum
                                                                  ? Colors.blue
                                                                  : Colors
                                                                      .transparent,
                                                          foregroundColor:
                                                              _currentPage ==
                                                                      pageNum
                                                                  ? Colors.white
                                                                  : Colors.blue,
                                                          minimumSize:
                                                              const Size(
                                                                  40, 40),
                                                          padding:
                                                              EdgeInsets.zero,
                                                        ),
                                                        child: Text(
                                                            pageNum.toString()),
                                                      ),
                                                    );
                                                  } else if (pageNum ==
                                                          _currentPage - 2 ||
                                                      pageNum ==
                                                          _currentPage + 2) {
                                                    return const Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 4),
                                                      child: Text('...'),
                                                    );
                                                  }
                                                  return const SizedBox
                                                      .shrink();
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.chevron_right),
                                                onPressed:
                                                    _currentPage < totalPages
                                                        ? () {
                                                            setState(() {
                                                              _currentPage++;
                                                            });
                                                          }
                                                        : null,
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    } else {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Showing $startIndex to $endIndex of $filteredCount entries',
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.chevron_left),
                                                onPressed: _currentPage > 1
                                                    ? () {
                                                        setState(() {
                                                          _currentPage--;
                                                        });
                                                      }
                                                    : null,
                                              ),
                                              ...List.generate(
                                                totalPages,
                                                (index) {
                                                  final pageNum = index + 1;
                                                  if (pageNum == _currentPage ||
                                                      pageNum == 1 ||
                                                      pageNum == totalPages ||
                                                      (pageNum >=
                                                              _currentPage -
                                                                  1 &&
                                                          pageNum <=
                                                              _currentPage +
                                                                  1)) {
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 4),
                                                      child: TextButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            _currentPage =
                                                                pageNum;
                                                          });
                                                        },
                                                        style: TextButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              _currentPage ==
                                                                      pageNum
                                                                  ? Colors.blue
                                                                  : Colors
                                                                      .transparent,
                                                          foregroundColor:
                                                              _currentPage ==
                                                                      pageNum
                                                                  ? Colors.white
                                                                  : Colors.blue,
                                                          minimumSize:
                                                              const Size(
                                                                  40, 40),
                                                          padding:
                                                              EdgeInsets.zero,
                                                        ),
                                                        child: Text(
                                                            pageNum.toString()),
                                                      ),
                                                    );
                                                  } else if (pageNum ==
                                                          _currentPage - 2 ||
                                                      pageNum ==
                                                          _currentPage + 2) {
                                                    return const Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 4),
                                                      child: Text('...'),
                                                    );
                                                  }
                                                  return const SizedBox
                                                      .shrink();
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.chevron_right),
                                                onPressed:
                                                    _currentPage < totalPages
                                                        ? () {
                                                            setState(() {
                                                              _currentPage++;
                                                            });
                                                          }
                                                        : null,
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
