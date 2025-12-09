import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../view_model/advance_salary_report_view_model.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/sidebar/sidebar_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/header/header_widget.dart';
import 'package:bizzhrms_flutter_app/core/constants/app_constants.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/loading_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/error_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/back_button_widget.dart';

class AdvanceSalaryReportPage extends StatefulWidget {
  const AdvanceSalaryReportPage({super.key});

  @override
  State<AdvanceSalaryReportPage> createState() =>
      _AdvanceSalaryReportPageState();
}

class _AdvanceSalaryReportPageState extends State<AdvanceSalaryReportPage> {
  final TextEditingController _searchController = TextEditingController();
  int _entriesPerPage = 10;
  int _currentPage = 1;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredAdvanceSalaryReport(
      AdvanceSalaryReportViewModel viewModel) {
    List<Map<String, dynamic>> reports = viewModel.advanceSalaryReportList;

    if (_searchQuery.isNotEmpty) {
      reports = reports.where((report) {
        final employeeName =
            report['employee_name']?.toString().toLowerCase() ?? '';
        final status = report['status']?.toString().toLowerCase() ?? '';
        final monthYear = report['month_year']?.toString().toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        return employeeName.contains(query) ||
            status.contains(query) ||
            monthYear.contains(query);
      }).toList();
    }

    return reports;
  }

  List<Map<String, dynamic>> _getPaginatedAdvanceSalaryReport(
      AdvanceSalaryReportViewModel viewModel) {
    final filtered = _getFilteredAdvanceSalaryReport(viewModel);
    final startIndex = (_currentPage - 1) * _entriesPerPage;
    final endIndex = startIndex + _entriesPerPage;
    if (endIndex > filtered.length) {
      return filtered.sublist(startIndex);
    }
    return filtered.sublist(startIndex, endIndex);
  }

  int _getTotalPages(AdvanceSalaryReportViewModel viewModel) {
    return (_getFilteredAdvanceSalaryReport(viewModel).length / _entriesPerPage)
        .ceil();
  }

  void _showAdvanceSalaryReportDetails(
      BuildContext context, Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'View Advance Salary Report Details',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          'Employee ID',
                          report['employee_id']?.toString() ?? 'N/A',
                        ),
                        _buildDetailRow(
                          'Employee Name',
                          report['employee_name']?.toString() ?? 'N/A',
                        ),
                        _buildDetailRow(
                          'Month & Year',
                          report['month_year']?.toString() ?? 'N/A',
                        ),
                        _buildDetailRow(
                          'Advance Amount',
                          report['advance_amount'] != null &&
                                  report['advance_amount'].toString().isNotEmpty
                              ? '₹ ${report['advance_amount']}'
                              : 'N/A',
                        ),
                        _buildDetailRow(
                          'Total Paid',
                          report['total_paid'] != null &&
                                  report['total_paid'].toString().isNotEmpty
                              ? '₹ ${report['total_paid']}'
                              : '₹ 0',
                        ),
                        _buildDetailRow(
                          'Remaining Amount',
                          report['remaining_amount'] != null &&
                                  report['remaining_amount']
                                      .toString()
                                      .isNotEmpty
                              ? '₹ ${report['remaining_amount']}'
                              : 'N/A',
                        ),
                        _buildDetailRow(
                          'Monthly Installment',
                          report['monthly_installment'] != null &&
                                  report['monthly_installment']
                                      .toString()
                                      .isNotEmpty
                              ? report['monthly_installment'] == '0'
                                  ? 'N/A'
                                  : '₹ ${report['monthly_installment']}'
                              : 'N/A',
                        ),
                        _buildDetailRow(
                          'One Time Deduct',
                          report['one_time_deduct']?.toString() ?? 'N/A',
                        ),
                        _buildDetailRow(
                          'Status',
                          report['status']?.toString() ?? 'N/A',
                        ),
                        // Requested Dates Section
                        if (report['requested_dates'] != null &&
                            (report['requested_dates'] as List).isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Requested Dates',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2C3E50),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...((report['requested_dates'] as List)
                                    .map((dateItem) {
                                  final date = dateItem as Map<String, dynamic>;
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    elevation: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildDetailRow(
                                            'Advance Amount',
                                            date['advance_amount']
                                                    ?.toString() ??
                                                'N/A',
                                          ),
                                          _buildDetailRow(
                                            'Month & Year',
                                            date['month_year']?.toString() ??
                                                'N/A',
                                          ),
                                          _buildDetailRow(
                                            'One Time Deduct',
                                            date['one_time_deduct']
                                                    ?.toString() ??
                                                'N/A',
                                          ),
                                          _buildDetailRow(
                                            'Deducted Amount',
                                            date['deducted_amount']
                                                    ?.toString() ??
                                                'N/A',
                                          ),
                                          _buildDetailRow(
                                            'Deduction Date',
                                            date['deduction_date']
                                                    ?.toString() ??
                                                'N/A',
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList()),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C3E50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'fully paid':
      case 'paid':
        return Colors.green;
      case 'partially paid':
        return Colors.orange;
      case 'pending':
        return Colors.blue;
      case 'remaining':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          AdvanceSalaryReportViewModel()..loadAdvanceSalaryReportData(),
      builder: (context, child) {
        return Scaffold(
          drawer: const Drawer(
            child: SafeArea(
              child: SidebarWidget(
                  currentRoute: AppConstants.routeAdvanceSalaryReport),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                const HeaderWidget(pageTitle: 'Advance Salary Report'),
                const BackButtonWidget(title: 'Advance Salary Report'),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Consumer<AdvanceSalaryReportViewModel>(
                      builder: (context, viewModel, child) {
                        if (viewModel.status ==
                            AdvanceSalaryReportStatus.loading) {
                          return const LoadingWidget(
                              message: 'Loading advance salary report...');
                        }

                        if (viewModel.status ==
                            AdvanceSalaryReportStatus.error) {
                          return ErrorDisplayWidget(
                            message: viewModel.errorMessage ??
                                'Failed to load advance salary report',
                            onRetry: () => viewModel.refresh(),
                          );
                        }

                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withOpacity(0.2),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Advance Salary Report',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final isSmallScreen =
                                        constraints.maxWidth < 600;

                                    if (isSmallScreen) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
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
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
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
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SingleChildScrollView(
                                      child: DataTable(
                                        columns: const [
                                          DataColumn(
                                            label: Row(
                                              children: [
                                                Text('Action'),
                                                SizedBox(width: 4),
                                                Icon(Icons.swap_vert, size: 16),
                                              ],
                                            ),
                                          ),
                                          DataColumn(
                                            label: Row(
                                              children: [
                                                Text('Employee Name'),
                                                SizedBox(width: 4),
                                                Icon(Icons.swap_vert, size: 16),
                                              ],
                                            ),
                                          ),
                                          DataColumn(
                                            label: Row(
                                              children: [
                                                Text('Month & Year'),
                                                SizedBox(width: 4),
                                                Icon(Icons.swap_vert, size: 16),
                                              ],
                                            ),
                                          ),
                                          DataColumn(
                                            label: Row(
                                              children: [
                                                Text('Advance Amount'),
                                                SizedBox(width: 4),
                                                Icon(Icons.swap_vert, size: 16),
                                              ],
                                            ),
                                          ),
                                          DataColumn(
                                            label: Row(
                                              children: [
                                                Text('Total Paid'),
                                                SizedBox(width: 4),
                                                Icon(Icons.swap_vert, size: 16),
                                              ],
                                            ),
                                          ),
                                          DataColumn(
                                            label: Row(
                                              children: [
                                                Text('Remaining Amount'),
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
                                        rows: _getPaginatedAdvanceSalaryReport(
                                                viewModel)
                                            .map((report) {
                                          final status =
                                              report['status']?.toString() ??
                                                  'N/A';
                                          return DataRow(
                                            cells: [
                                              DataCell(
                                                IconButton(
                                                  icon: const Icon(
                                                    FontAwesomeIcons.eye,
                                                    size: 18,
                                                    color: Colors.grey,
                                                  ),
                                                  onPressed: () {
                                                    _showAdvanceSalaryReportDetails(
                                                        context, report);
                                                  },
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  report['employee_name']
                                                          ?.toString() ??
                                                      'N/A',
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  report['month_year']
                                                          ?.toString() ??
                                                      'N/A',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  report['advance_amount'] !=
                                                              null &&
                                                          report['advance_amount']
                                                              .toString()
                                                              .isNotEmpty
                                                      ? '₹ ${report['advance_amount']}'
                                                      : 'N/A',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  report['total_paid'] !=
                                                              null &&
                                                          report['total_paid']
                                                              .toString()
                                                              .isNotEmpty
                                                      ? '₹ ${report['total_paid']}'
                                                      : '₹ 0',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  report['remaining_amount'] !=
                                                              null &&
                                                          report['remaining_amount']
                                                              .toString()
                                                              .isNotEmpty
                                                      ? '₹ ${report['remaining_amount']}'
                                                      : 'N/A',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ),
                                              DataCell(
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        _getStatusColor(status)
                                                            .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    border: Border.all(
                                                      color: _getStatusColor(
                                                          status),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    status,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: _getStatusColor(
                                                          status),
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                Builder(
                                  builder: (context) {
                                    final filteredReports =
                                        _getFilteredAdvanceSalaryReport(
                                            viewModel);
                                    final paginatedReports =
                                        _getPaginatedAdvanceSalaryReport(
                                            viewModel);
                                    final totalPages =
                                        _getTotalPages(viewModel);

                                    return LayoutBuilder(
                                      builder: (context, constraints) {
                                        final isSmallScreen =
                                            constraints.maxWidth < 600;

                                        if (isSmallScreen) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Showing ${paginatedReports.isEmpty ? 0 : (_currentPage - 1) * _entriesPerPage + 1} to ${paginatedReports.isEmpty ? 0 : (_currentPage - 1) * _entriesPerPage + paginatedReports.length} of ${filteredReports.length} entries',
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                              const SizedBox(height: 12),
                                              Wrap(
                                                alignment: WrapAlignment.start,
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: [
                                                  TextButton(
                                                    onPressed: _currentPage > 1
                                                        ? () {
                                                            setState(() {
                                                              _currentPage--;
                                                            });
                                                          }
                                                        : null,
                                                    child:
                                                        const Text('Previous'),
                                                  ),
                                                  ...List.generate(
                                                    totalPages,
                                                    (index) {
                                                      final pageNum = index + 1;
                                                      return TextButton(
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
                                                                  : null,
                                                          foregroundColor:
                                                              _currentPage ==
                                                                      pageNum
                                                                  ? Colors.white
                                                                  : null,
                                                          minimumSize:
                                                              const Size(
                                                                  40, 40),
                                                          padding:
                                                              EdgeInsets.zero,
                                                        ),
                                                        child: Text(
                                                            pageNum.toString()),
                                                      );
                                                    },
                                                  ),
                                                  TextButton(
                                                    onPressed: _currentPage <
                                                            totalPages
                                                        ? () {
                                                            setState(() {
                                                              _currentPage++;
                                                            });
                                                          }
                                                        : null,
                                                    child: const Text('Next'),
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
                                              Flexible(
                                                child: Text(
                                                  'Showing ${paginatedReports.isEmpty ? 0 : (_currentPage - 1) * _entriesPerPage + 1} to ${paginatedReports.isEmpty ? 0 : (_currentPage - 1) * _entriesPerPage + paginatedReports.length} of ${filteredReports.length} entries',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Flexible(
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    TextButton(
                                                      onPressed:
                                                          _currentPage > 1
                                                              ? () {
                                                                  setState(() {
                                                                    _currentPage--;
                                                                  });
                                                                }
                                                              : null,
                                                      child: const Text(
                                                          'Previous'),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    ...List.generate(
                                                      totalPages > 10
                                                          ? 10
                                                          : totalPages,
                                                      (index) {
                                                        final pageNum =
                                                            index + 1;
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      4),
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
                                                                      ? Colors
                                                                          .blue
                                                                      : null,
                                                              foregroundColor:
                                                                  _currentPage ==
                                                                          pageNum
                                                                      ? Colors
                                                                          .white
                                                                      : null,
                                                              minimumSize:
                                                                  const Size(
                                                                      40, 40),
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                            ),
                                                            child: Text(pageNum
                                                                .toString()),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    const SizedBox(width: 8),
                                                    TextButton(
                                                      onPressed: _currentPage <
                                                              totalPages
                                                          ? () {
                                                              setState(() {
                                                                _currentPage++;
                                                              });
                                                            }
                                                          : null,
                                                      child: const Text('Next'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                      },
                                    );
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
