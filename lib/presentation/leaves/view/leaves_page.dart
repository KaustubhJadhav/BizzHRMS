import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../view_model/leaves_view_model.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/sidebar/sidebar_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/header/header_widget.dart';
import 'package:bizzhrms_flutter_app/core/constants/app_constants.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/loading_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/error_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/back_button_widget.dart';

class LeavesPage extends StatefulWidget {
  const LeavesPage({super.key});

  @override
  State<LeavesPage> createState() => _LeavesPageState();
}

class _LeavesPageState extends State<LeavesPage> {
  bool _showAddForm = false;
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _remarksController = TextEditingController();
  String? _selectedLeaveTypeId;
  DateTime? _fromDate;
  DateTime? _toDate;

  // Leave types mapping (1 = Casual Leave, 2 = Medical Leave, etc.)
  final Map<String, String> _leaveTypes = {
    '1': 'Casual Leave',
    '2': 'Medical Leave',
  };

  @override
  void dispose() {
    _reasonController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LeavesViewModel()..loadLeavesData(),
      builder: (context, child) {
        return Scaffold(
          drawer: Drawer(
            child: SafeArea(
              child: SidebarWidget(currentRoute: AppConstants.routeLeaves),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                const HeaderWidget(pageTitle: 'Leave'),
                const BackButtonWidget(title: 'Leave'),
                Expanded(
                  child: Consumer<LeavesViewModel>(
                    builder: (context, viewModel, child) {
                      if (viewModel.status == LeavesStatus.loading &&
                          viewModel.leavesList.isEmpty) {
                        return const LoadingWidget(
                            message: 'Loading leaves...');
                      }

                      if (viewModel.status == LeavesStatus.error &&
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
                            // Add Leave Form
                            if (_showAddForm) _buildAddLeaveForm(context),
                            // Leave Stats
                            _buildLeaveStats(context),
                            const SizedBox(height: 16),
                            // Leaves List
                            _buildLeavesList(context),
                          ],
                        ),
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

  Widget _buildAddLeaveForm(BuildContext context) {
    return Consumer<LeavesViewModel>(
      builder: (context, viewModel, child) {
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
                      const Text(
                        'Add Leave',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showAddForm = false;
                            _formKey.currentState?.reset();
                            _reasonController.clear();
                            _remarksController.clear();
                            _selectedLeaveTypeId = null;
                            _fromDate = null;
                            _toDate = null;
                          });
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Leave Type Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedLeaveTypeId,
                    decoration: const InputDecoration(
                      labelText: 'Leave Type',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(FontAwesomeIcons.calendarDays),
                    ),
                    items: _leaveTypes.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (value) {
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
                  // From Date
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _fromDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
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
                      decoration: const InputDecoration(
                        labelText: 'From Date',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(FontAwesomeIcons.calendar),
                      ),
                      child: Text(
                        _fromDate != null
                            ? DateFormat('yyyy-MM-dd').format(_fromDate!)
                            : 'Select date',
                        style: TextStyle(
                          color: _fromDate != null ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // To Date
                  InkWell(
                    onTap: () async {
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
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _toDate = date;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'To Date',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(FontAwesomeIcons.calendar),
                      ),
                      child: Text(
                        _toDate != null
                            ? DateFormat('yyyy-MM-dd').format(_toDate!)
                            : 'Select date',
                        style: TextStyle(
                          color: _toDate != null ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Reason
                  TextFormField(
                    controller: _reasonController,
                    decoration: const InputDecoration(
                      labelText: 'Reason',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(FontAwesomeIcons.fileLines),
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
                  // Remarks
                  TextFormField(
                    controller: _remarksController,
                    decoration: const InputDecoration(
                      labelText: 'Remarks',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(FontAwesomeIcons.comment),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: viewModel.status == LeavesStatus.loading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                if (_fromDate == null || _toDate == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please select both dates'),
                                    ),
                                  );
                                  return;
                                }

                                final success = await viewModel.addLeave(
                                  _selectedLeaveTypeId!,
                                  DateFormat('yyyy-MM-dd').format(_fromDate!),
                                  DateFormat('yyyy-MM-dd').format(_toDate!),
                                  _reasonController.text.trim(),
                                  _remarksController.text.trim(),
                                );

                                if (mounted) {
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Leave added successfully!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    setState(() {
                                      _showAddForm = false;
                                      _formKey.currentState?.reset();
                                      _reasonController.clear();
                                      _remarksController.clear();
                                      _selectedLeaveTypeId = null;
                                      _fromDate = null;
                                      _toDate = null;
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          viewModel.errorMessage ??
                                              'Failed to add leave',
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
                      child: viewModel.status == LeavesStatus.loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Submit Leave Request'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeaveStats(BuildContext context) {
    return Consumer<LeavesViewModel>(
      builder: (context, viewModel, child) {
        final stats = viewModel.leaveStats;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Leave Days Per Year',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatBox(
                        'Total Casual Leave',
                        stats['totalCasualLeave'].toString(),
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatBox(
                        'Approved Casual Leave',
                        stats['approvedCasualLeave'].toString(),
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatBox(
                        'Total Medical Leave',
                        stats['totalMedicalLeave'].toString(),
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatBox(
                        'Approved Medical Leave',
                        stats['approvedMedicalLeave'].toString(),
                        Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatBox(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeavesList(BuildContext context) {
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
                  'List All Leave',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showAddForm = !_showAddForm;
                    });
                  },
                  icon: Icon(_showAddForm ? Icons.remove : Icons.add),
                  label: Text(_showAddForm ? 'Hide' : 'Add Leave'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<LeavesViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.leavesList.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'No leave records',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  );
                }

                // Leave List as Cards
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: viewModel.leavesList.length,
                  itemBuilder: (context, index) {
                    final leave = viewModel.leavesList[index];
                    return _buildLeaveCard(leave);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveCard(Map<String, dynamic> leave) {
    final employeeName = leave['employee_name']?.toString() ?? 'N/A';
    final leaveType = leave['leave_type']?.toString() ?? 'N/A';
    final fromDate = leave['from_date']?.toString() ?? '';
    final toDate = leave['to_date']?.toString() ?? '';
    final status = leave['status']?.toString() ?? 'N/A';
    final reason = leave['reason']?.toString() ?? '';
    final appliedOn = leave['applied_on']?.toString() ?? '';

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
          ],
        ),
      ),
    );
  }
}
