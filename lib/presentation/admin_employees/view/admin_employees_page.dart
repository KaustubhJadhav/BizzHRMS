import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/admin_employees_view_model.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/sidebar/sidebar_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/header/header_widget.dart';
import 'package:bizzhrms_flutter_app/core/constants/app_constants.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/loading_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/error_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/back_button_widget.dart';

class AdminEmployeesPage extends StatefulWidget {
  const AdminEmployeesPage({super.key});

  @override
  State<AdminEmployeesPage> createState() => _AdminEmployeesPageState();
}

class _AdminEmployeesPageState extends State<AdminEmployeesPage> {
  final TextEditingController _searchController = TextEditingController();
  int _entriesPerPage = 10;
  int _currentPage = 1;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredEmployees(
      AdminEmployeesViewModel viewModel) {
    List<Map<String, dynamic>> employees = viewModel.employeesList;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      employees = employees.where((employee) {
        final fullName = employee['full_name']?.toString().toLowerCase() ?? '';
        final employeeId =
            employee['employee_id']?.toString().toLowerCase() ?? '';
        final email = employee['email']?.toString().toLowerCase() ?? '';
        final department =
            employee['department']?.toString().toLowerCase() ?? '';
        final designation =
            employee['designation']?.toString().toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();

        return fullName.contains(query) ||
            employeeId.contains(query) ||
            email.contains(query) ||
            department.contains(query) ||
            designation.contains(query);
      }).toList();
    }

    return employees;
  }

  List<Map<String, dynamic>> _getPaginatedEmployees(
      AdminEmployeesViewModel viewModel) {
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

  int _getTotalPages(AdminEmployeesViewModel viewModel) {
    final filtered = _getFilteredEmployees(viewModel);
    return (filtered.length / _entriesPerPage).ceil();
  }

  String _getStatusText(dynamic status) {
    if (status == null) return 'N/A';
    if (status.toString() == '1' ||
        status.toString().toLowerCase() == 'active') {
      return 'Active';
    }
    return 'Inactive';
  }

  Color _getStatusColor(dynamic status) {
    if (status == null) return Colors.grey;
    if (status.toString() == '1' ||
        status.toString().toLowerCase() == 'active') {
      return Colors.green;
    }
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminEmployeesViewModel()..loadEmployees(),
      builder: (context, child) {
        return Scaffold(
          drawer: Drawer(
            child: SafeArea(
              child:
                  SidebarWidget(currentRoute: AppConstants.routeAdminEmployees),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                const HeaderWidget(pageTitle: 'Employees'),
                const BackButtonWidget(title: 'Employees'),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Consumer<AdminEmployeesViewModel>(
                      builder: (context, viewModel, child) {
                        if (viewModel.status == AdminEmployeesStatus.loading) {
                          return const LoadingWidget(
                              message: 'Loading employees...');
                        }

                        if (viewModel.status == AdminEmployeesStatus.error) {
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
                                // Title
                                const Text(
                                  'List All Employees',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Controls: Entries per page and Search
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final isSmallScreen =
                                        constraints.maxWidth < 600;

                                    if (isSmallScreen) {
                                      // Stack vertically on small screens
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Entries per page
                                          Row(
                                            children: [
                                              const Text('Show'),
                                              const SizedBox(width: 8),
                                              DropdownButton<int>(
                                                value: _entriesPerPage,
                                                items: [10, 25, 50, 100]
                                                    .map((value) =>
                                                        DropdownMenuItem(
                                                          value: value,
                                                          child: Text(
                                                              value.toString()),
                                                        ))
                                                    .toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    _entriesPerPage =
                                                        value ?? 10;
                                                    _currentPage = 1;
                                                  });
                                                },
                                              ),
                                              const SizedBox(width: 8),
                                              const Text('entries'),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          // Search
                                          Row(
                                            children: [
                                              const Text('Search:'),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: TextField(
                                                  controller: _searchController,
                                                  decoration:
                                                      const InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 8),
                                                  ),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _searchQuery = value;
                                                      _currentPage = 1;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    } else {
                                      // Horizontal layout on larger screens
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Entries per page
                                          Row(
                                            children: [
                                              const Text('Show'),
                                              const SizedBox(width: 8),
                                              DropdownButton<int>(
                                                value: _entriesPerPage,
                                                items: [10, 25, 50, 100]
                                                    .map((value) =>
                                                        DropdownMenuItem(
                                                          value: value,
                                                          child: Text(
                                                              value.toString()),
                                                        ))
                                                    .toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    _entriesPerPage =
                                                        value ?? 10;
                                                    _currentPage = 1;
                                                  });
                                                },
                                              ),
                                              const SizedBox(width: 8),
                                              const Text('entries'),
                                            ],
                                          ),
                                          // Search
                                          Row(
                                            children: [
                                              const Text('Search:'),
                                              const SizedBox(width: 8),
                                              SizedBox(
                                                width: 200,
                                                child: TextField(
                                                  controller: _searchController,
                                                  decoration:
                                                      const InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 8),
                                                  ),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _searchQuery = value;
                                                      _currentPage = 1;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Table
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SingleChildScrollView(
                                      child: DataTable(
                                        columns: const [
                                          DataColumn(
                                            label: Row(
                                              children: [
                                                Text('Employee ID'),
                                                SizedBox(width: 4),
                                                Icon(Icons.swap_vert, size: 16),
                                              ],
                                            ),
                                          ),
                                          DataColumn(
                                            label: Row(
                                              children: [
                                                Text('Full Name'),
                                                SizedBox(width: 4),
                                                Icon(Icons.swap_vert, size: 16),
                                              ],
                                            ),
                                          ),
                                          DataColumn(
                                            label: Row(
                                              children: [
                                                Text('Email'),
                                                SizedBox(width: 4),
                                                Icon(Icons.swap_vert, size: 16),
                                              ],
                                            ),
                                          ),
                                          DataColumn(
                                            label: Row(
                                              children: [
                                                Text('Role'),
                                                SizedBox(width: 4),
                                                Icon(Icons.swap_vert, size: 16),
                                              ],
                                            ),
                                          ),
                                          DataColumn(
                                            label: Row(
                                              children: [
                                                Text('Designation'),
                                                SizedBox(width: 4),
                                                Icon(Icons.swap_vert, size: 16),
                                              ],
                                            ),
                                          ),
                                          DataColumn(
                                            label: Row(
                                              children: [
                                                Text('Department'),
                                                SizedBox(width: 4),
                                                Icon(Icons.swap_vert, size: 16),
                                              ],
                                            ),
                                          ),
                                          DataColumn(
                                            label: Row(
                                              children: [
                                                Text('Status'),
                                                SizedBox(width: 4),
                                                Icon(Icons.swap_vert, size: 16),
                                              ],
                                            ),
                                          ),
                                        ],
                                        rows: _getPaginatedEmployees(viewModel)
                                            .map((employee) {
                                          return DataRow(
                                            cells: [
                                              // Employee ID
                                              DataCell(
                                                Text(
                                                  employee['employee_id']
                                                          ?.toString() ??
                                                      'N/A',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                              // Full Name
                                              DataCell(
                                                Text(
                                                  employee['full_name']
                                                          ?.toString() ??
                                                      'N/A',
                                                ),
                                              ),
                                              // Email
                                              DataCell(
                                                Text(
                                                  employee['email']
                                                              ?.toString()
                                                              .isEmpty ??
                                                          true
                                                      ? 'N/A'
                                                      : employee['email']
                                                              ?.toString() ??
                                                          'N/A',
                                                ),
                                              ),
                                              // Role
                                              DataCell(
                                                Text(
                                                  employee['role']
                                                          ?.toString() ??
                                                      'N/A',
                                                ),
                                              ),
                                              // Designation
                                              DataCell(
                                                Text(
                                                  employee['designation']
                                                          ?.toString() ??
                                                      'N/A',
                                                ),
                                              ),
                                              // Department
                                              DataCell(
                                                Text(
                                                  employee['department']
                                                          ?.toString() ??
                                                      'N/A',
                                                ),
                                              ),
                                              // Status
                                              DataCell(
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _getStatusColor(
                                                            employee['status'])
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    border: Border.all(
                                                      color: _getStatusColor(
                                                          employee['status']),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    _getStatusText(
                                                        employee['status']),
                                                    style: TextStyle(
                                                      color: _getStatusColor(
                                                          employee['status']),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
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
                                      // Stack vertically on small screens
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
                                              // Previous button
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
                                              // Page numbers
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
                                              // Next button
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
                                      // Horizontal layout on larger screens
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
                                              // Previous button
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
                                              // Page numbers
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
                                              // Next button
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
