import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../view_model/admin_leave_view_model.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/sidebar/sidebar_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/header/header_widget.dart';
import 'package:bizzhrms_flutter_app/core/constants/app_constants.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/loading_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/error_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/back_button_widget.dart';

class AdminLeaveManagementPage extends StatefulWidget {
  const AdminLeaveManagementPage({super.key});

  @override
  State<AdminLeaveManagementPage> createState() =>
      _AdminLeaveManagementPageState();
}

class _AdminLeaveManagementPageState extends State<AdminLeaveManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showAddForm = false;
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _remarksController = TextEditingController();
  String? _selectedEmployeeId;
  String? _selectedLeaveTypeId;
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _editingLeaveId;
  String? _selectedStatus; // For editing status only

  @override
  void dispose() {
    _searchController.dispose();
    _reasonController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _reasonController.clear();
    _remarksController.clear();
    _selectedEmployeeId = null;
    _selectedLeaveTypeId = null;
    _fromDate = null;
    _toDate = null;
    _editingLeaveId = null;
    _selectedStatus = null;
    _showAddForm = false;
  }

  void _openEditForm(Map<String, dynamic> leave) {
    setState(() {
      _editingLeaveId = leave['leave_id']?.toString();
      _selectedEmployeeId = leave['employee_id']?.toString();
      _selectedLeaveTypeId = leave['leave_type_id']?.toString();

      // Parse dates
      try {
        if (leave['from_date'] != null) {
          _fromDate = DateTime.parse(leave['from_date'].toString());
        }
        if (leave['to_date'] != null) {
          _toDate = DateTime.parse(leave['to_date'].toString());
        }
      } catch (e) {
        // Handle date parsing error
      }

      _reasonController.text = leave['reason']?.toString() ?? '';
      _remarksController.text = leave['remarks']?.toString() ?? '';
      // Set current status for editing
      _selectedStatus = leave['status']?.toString() ?? '1';
      _showAddForm = true;
    });
  }

  List<Map<String, dynamic>> _getFilteredLeaves(AdminLeaveViewModel viewModel) {
    List<Map<String, dynamic>> leaves = viewModel.leavesList;

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      leaves = leaves.where((leave) {
        final employeeName =
            leave['employee_name']?.toString().toLowerCase() ?? '';
        final leaveType = leave['leave_type']?.toString().toLowerCase() ?? '';
        final reason = leave['reason']?.toString().toLowerCase() ?? '';
        final status = leave['status']?.toString().toLowerCase() ?? '';

        return employeeName.contains(query) ||
            leaveType.contains(query) ||
            reason.contains(query) ||
            status.contains(query);
      }).toList();
    }

    return leaves;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = AdminLeaveViewModel();
        // Load data immediately when view model is created
        WidgetsBinding.instance.addPostFrameCallback((_) {
          viewModel.loadLeaves();
          viewModel.loadEmployees();
        });
        return viewModel;
      },
      child: Scaffold(
        drawer: Drawer(
          child: SafeArea(
            child: SidebarWidget(
                currentRoute: AppConstants.routeAdminLeaveManagement),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              const HeaderWidget(pageTitle: 'Leave Management'),
              const BackButtonWidget(title: 'Leave Management'),
              Expanded(
                child: Consumer<AdminLeaveViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.status == AdminLeaveStatus.loading &&
                        viewModel.leavesList.isEmpty) {
                      return const LoadingWidget(message: 'Loading leaves...');
                    }

                    if (viewModel.status == AdminLeaveStatus.error &&
                        viewModel.leavesList.isEmpty) {
                      return ErrorDisplayWidget(
                        message:
                            viewModel.errorMessage ?? 'Failed to load leaves',
                        onRetry: () => viewModel.refresh(),
                      );
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search and Add Button
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Search by employee, type, reason...',
                                    prefixIcon: const Icon(Icons.search),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    if (_showAddForm &&
                                        _editingLeaveId == null) {
                                      _resetForm();
                                    } else {
                                      _showAddForm = !_showAddForm;
                                      if (!_showAddForm) {
                                        _resetForm();
                                      }
                                    }
                                  });
                                },
                                icon: Icon(
                                    _showAddForm ? Icons.close : Icons.add),
                                label:
                                    Text(_showAddForm ? 'Cancel' : 'Add Leave'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2C3E50),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Add/Edit Leave Form
                          if (_showAddForm) _buildLeaveForm(context, viewModel),
                          // Leaves List
                          _buildLeavesList(context, viewModel),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveForm(BuildContext context, AdminLeaveViewModel viewModel) {
    final isEditing = _editingLeaveId != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Leave' : 'Add Leave',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isEditing)
                    IconButton(
                      onPressed: () {
                        _resetForm();
                        setState(() {});
                      },
                      icon: const Icon(Icons.close),
                    ),
                ],
              ),
              // Status Dropdown (only shown when editing)
              if (isEditing) ...[
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(FontAwesomeIcons.checkCircle),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: '1',
                      child: Text('Pending'),
                    ),
                    DropdownMenuItem(
                      value: '2',
                      child: Text('Approved'),
                    ),
                    DropdownMenuItem(
                      value: '3',
                      child: Text('Rejected'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select status';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              // Employee Dropdown (disabled when editing)
              DropdownButtonFormField<String>(
                value: _selectedEmployeeId,
                decoration: InputDecoration(
                  labelText: 'Employee',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(FontAwesomeIcons.user),
                  filled: isEditing,
                  fillColor: isEditing ? Colors.grey.shade100 : null,
                ),
                items: viewModel.employeesList.map((employee) {
                  final employeeId = employee['user_id']?.toString() ?? '';
                  final employeeName =
                      employee['full_name']?.toString() ?? 'Unknown';
                  return DropdownMenuItem(
                    value: employeeId,
                    child: Text('$employeeId - $employeeName'),
                  );
                }).toList(),
                onChanged: isEditing
                    ? null
                    : (value) {
                        setState(() {
                          _selectedEmployeeId = value;
                        });
                      },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select employee';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Leave Type Dropdown (disabled when editing)
              DropdownButtonFormField<String>(
                value: _selectedLeaveTypeId,
                decoration: InputDecoration(
                  labelText: 'Leave Type',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(FontAwesomeIcons.calendarDays),
                  filled: isEditing,
                  fillColor: isEditing ? Colors.grey.shade100 : null,
                ),
                items: viewModel.leaveTypes.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: isEditing
                    ? null
                    : (value) {
                        setState(() {
                          _selectedLeaveTypeId = value;
                        });
                      },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select leave type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // From Date (disabled when editing)
              InkWell(
                onTap: isEditing
                    ? null
                    : () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _fromDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            _fromDate = date;
                            if (_toDate != null && _toDate!.isBefore(date)) {
                              _toDate = null;
                            }
                          });
                        }
                      },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'From Date',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(FontAwesomeIcons.calendar),
                    filled: isEditing,
                    fillColor: isEditing ? Colors.grey.shade100 : null,
                  ),
                  child: Text(
                    _fromDate != null
                        ? DateFormat('yyyy-MM-dd').format(_fromDate!)
                        : 'Select date',
                    style: TextStyle(
                      color: isEditing
                          ? Colors.grey.shade600
                          : (_fromDate != null ? Colors.black : Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // To Date (disabled when editing)
              InkWell(
                onTap: isEditing
                    ? null
                    : () async {
                        if (_fromDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select from date first'),
                            ),
                          );
                          return;
                        }
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _toDate ?? _fromDate!,
                          firstDate: _fromDate!,
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            _toDate = date;
                          });
                        }
                      },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'To Date',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(FontAwesomeIcons.calendar),
                    filled: isEditing,
                    fillColor: isEditing ? Colors.grey.shade100 : null,
                  ),
                  child: Text(
                    _toDate != null
                        ? DateFormat('yyyy-MM-dd').format(_toDate!)
                        : 'Select date',
                    style: TextStyle(
                      color: isEditing
                          ? Colors.grey.shade600
                          : (_toDate != null ? Colors.black : Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Reason (disabled when editing)
              TextFormField(
                controller: _reasonController,
                enabled: !isEditing,
                decoration: InputDecoration(
                  labelText: 'Reason',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(FontAwesomeIcons.fileLines),
                  filled: isEditing,
                  fillColor: isEditing ? Colors.grey.shade100 : null,
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter reason';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Remarks (disabled when editing)
              TextFormField(
                controller: _remarksController,
                enabled: !isEditing,
                decoration: InputDecoration(
                  labelText: 'Remarks',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(FontAwesomeIcons.comment),
                  filled: isEditing,
                  fillColor: isEditing ? Colors.grey.shade100 : null,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: viewModel.status == AdminLeaveStatus.loading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            bool success;
                            if (isEditing) {
                              // Only update status when editing
                              if (_selectedStatus == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please select status'),
                                  ),
                                );
                                return;
                              }
                              success = await viewModel.updateLeaveStatus(
                                leaveId: _editingLeaveId!,
                                employeeId: _selectedEmployeeId!,
                                status: int.parse(_selectedStatus!),
                              );
                            } else {
                              // Validate dates for adding new leave
                              if (_fromDate == null || _toDate == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please select both dates'),
                                  ),
                                );
                                return;
                              }
                              success = await viewModel.addLeave(
                                employeeId: _selectedEmployeeId!,
                                leaveType: _selectedLeaveTypeId!,
                                startDate:
                                    DateFormat('yyyy-MM-dd').format(_fromDate!),
                                endDate:
                                    DateFormat('yyyy-MM-dd').format(_toDate!),
                                reason: _reasonController.text.trim(),
                                remarks: _remarksController.text.trim(),
                              );
                            }

                            if (mounted) {
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(isEditing
                                        ? 'Leave updated successfully!'
                                        : 'Leave added successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                _resetForm();
                                setState(() {});
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      viewModel.errorMessage ??
                                          'Failed to ${isEditing ? 'update' : 'add'} leave',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C3E50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: viewModel.status == AdminLeaveStatus.loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          isEditing ? 'Update Leave' : 'Submit Leave Request'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeavesList(BuildContext context, AdminLeaveViewModel viewModel) {
    final filteredLeaves = _getFilteredLeaves(viewModel);

    // Debug: Print leaves count
    print('=== BUILDING LEAVES LIST ===');
    print('Total leaves in viewModel: ${viewModel.leavesList.length}');
    print('Filtered leaves: ${filteredLeaves.length}');
    print('');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'All Leaves',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Total: ${filteredLeaves.length}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (filteredLeaves.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        viewModel.leavesList.isEmpty
                            ? 'No leave records found'
                            : 'No leaves match your search',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredLeaves.length,
                itemBuilder: (context, index) {
                  final leave = filteredLeaves[index];
                  print(
                      'Building leave card $index: ${leave['employee_name']}');
                  return _buildLeaveCard(context, leave, viewModel);
                },
              ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String statusCode) {
    switch (statusCode) {
      case '1':
        return 'Pending';
      case '2':
        return 'Approved';
      case '3':
        return 'Rejected';
      default:
        return 'Pending';
    }
  }

  Widget _buildLeaveCard(BuildContext context, Map<String, dynamic> leave,
      AdminLeaveViewModel viewModel) {
    final employeeName = leave['employee_name']?.toString() ?? 'N/A';
    final leaveType = leave['leave_type']?.toString() ?? 'N/A';
    final fromDate = leave['from_date']?.toString() ?? '';
    final toDate = leave['to_date']?.toString() ?? '';
    final statusCode =
        leave['status']?.toString() ?? '1'; // Default to Pending (1)
    final status = _getStatusText(statusCode);
    final reason = leave['reason']?.toString() ?? '';
    final appliedOn = leave['applied_on']?.toString() ?? '';
    final leaveId = leave['leave_id']?.toString() ?? '';

    String formatDate(String? dateStr) {
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

    String formatDateTime(String? dateTimeStr) {
      if (dateTimeStr == null || dateTimeStr.isEmpty || dateTimeStr == 'null') {
        return 'N/A';
      }
      try {
        final dateTime = DateTime.parse(dateTimeStr);
        return DateFormat('dd-MMM-yyyy hh:mm a').format(dateTime);
      } catch (e) {
        return dateTimeStr;
      }
    }

    Color getStatusColor(String status) {
      switch (status.toLowerCase()) {
        case 'approved':
          return Colors.green;
        case 'pending':
          return Colors.orange;
        case 'rejected':
          return Colors.red;
        case 'cancelled':
          return Colors.grey;
        default:
          return Colors.grey;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employeeName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        leaveType,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: getStatusColor(status),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: getStatusColor(status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  FontAwesomeIcons.calendar,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  '${formatDate(fromDate)} to ${formatDate(toDate)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            if (reason.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    FontAwesomeIcons.fileLines,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reason,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (appliedOn.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    FontAwesomeIcons.clock,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Applied on: ${formatDateTime(appliedOn)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    _openEditForm(leave);
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Leave'),
                        content: Text(
                            'Are you sure you want to delete this leave for $employeeName?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && mounted) {
                      final success = await viewModel.deleteLeave(leaveId);
                      if (mounted) {
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Leave deleted successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                viewModel.errorMessage ??
                                    'Failed to delete leave',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
