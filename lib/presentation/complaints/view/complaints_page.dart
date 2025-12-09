import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../view_model/complaints_view_model.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/sidebar/sidebar_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/header/header_widget.dart';
import 'package:bizzhrms_flutter_app/core/constants/app_constants.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/loading_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/error_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/back_button_widget.dart';

class ComplaintsPage extends StatefulWidget {
  const ComplaintsPage({super.key});

  @override
  State<ComplaintsPage> createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  final TextEditingController _searchController = TextEditingController();
  int _entriesPerPage = 10;
  int _currentPage = 1;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredComplaints(ComplaintsViewModel viewModel) {
    List<Map<String, dynamic>> complaints = viewModel.complaintsList;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      complaints = complaints.where((item) {
        final complaintFrom = item['complaint_from']?.toString().toLowerCase() ?? '';
        final complaintAgainst = item['complaint_against']?.toString().toLowerCase() ?? '';
        final complaintTitle = item['complaint_title']?.toString().toLowerCase() ?? '';
        final approvalStatus = item['approval_status']?.toString().toLowerCase() ?? '';
        final details = item['details']?.toString().toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        return complaintFrom.contains(query) ||
            complaintAgainst.contains(query) ||
            complaintTitle.contains(query) ||
            approvalStatus.contains(query) ||
            details.contains(query);
      }).toList();
    }

    return complaints;
  }

  List<Map<String, dynamic>> _getPaginatedComplaints(ComplaintsViewModel viewModel) {
    final filtered = _getFilteredComplaints(viewModel);
    final startIndex = (_currentPage - 1) * _entriesPerPage;
    final endIndex = startIndex + _entriesPerPage;
    if (endIndex > filtered.length) {
      return filtered.sublist(startIndex);
    }
    return filtered.sublist(startIndex, endIndex);
  }

  int _getTotalPages(ComplaintsViewModel viewModel) {
    return (_getFilteredComplaints(viewModel).length / _entriesPerPage).ceil();
  }

  void _showComplaintDetails(BuildContext context, Map<String, dynamic> complaint) {
    // Try to get complaint_id from the complaint object
    final complaintId = complaint['complaint_id']?.toString() ?? '';
    
    if (complaintId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complaint ID not available'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Navigate to complaint details page
    Navigator.pushNamed(
      context,
      AppConstants.routeComplaintDetails,
      arguments: {
        'complaint_id': complaintId,
        'complaint': complaint,
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ComplaintsViewModel()..loadComplaintsData(),
      builder: (context, child) {
        return Scaffold(
          drawer: const Drawer(
            child: SafeArea(
              child: SidebarWidget(currentRoute: AppConstants.routeComplaints),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                const HeaderWidget(pageTitle: 'Complaints'),
                const BackButtonWidget(title: 'Complaints'),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Consumer<ComplaintsViewModel>(
                      builder: (context, viewModel, child) {
                        if (viewModel.status == ComplaintsStatus.loading) {
                          return const LoadingWidget(
                              message: 'Loading complaints...');
                        }

                        if (viewModel.status == ComplaintsStatus.error) {
                          return ErrorDisplayWidget(
                            message: viewModel.errorMessage ??
                                'Failed to load complaints',
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
                                // Title
                            const Text(
                              'List All Complaints',
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
                                                Text('Action'),
                                                SizedBox(width: 4),
                                                Icon(Icons.swap_vert, size: 16),
                                              ],
                                            ),
                                          ),
                                          DataColumn(
                                            label: Row(
                                              children: [
                                                Text('Complaint From'),
                                                SizedBox(width: 4),
                                                Icon(Icons.swap_vert, size: 16),
                                              ],
                                            ),
                                          ),
                                          DataColumn(
                                            label: Row(
                                              children: [
                                                Text('Complaint Against'),
                                                SizedBox(width: 4),
                                                Icon(Icons.swap_vert, size: 16),
                                              ],
                                            ),
                                          ),
                                          DataColumn(
                                            label: Row(
                                              children: [
                                                Text('Complaint Title'),
                                                SizedBox(width: 4),
                                                Icon(Icons.swap_vert, size: 16),
                                              ],
                                            ),
                                          ),
                                          DataColumn(
                                            label: Row(
                                              children: [
                                                Text('Complaint Date'),
                                                SizedBox(width: 4),
                                                Icon(Icons.swap_vert, size: 16),
                                              ],
                                            ),
                                          ),
                                          DataColumn(
                                            label: Row(
                                              children: [
                                                Text('Approval Status'),
                                                SizedBox(width: 4),
                                                Icon(Icons.swap_vert, size: 16),
                                              ],
                                            ),
                                          ),
                                          DataColumn(
                                            label: Row(
                                              children: [
                                                Text('Details'),
                                                SizedBox(width: 4),
                                                Icon(Icons.swap_vert, size: 16),
                                              ],
                                            ),
                                          ),
                                        ],
                                        rows: _getPaginatedComplaints(viewModel)
                                            .map((complaint) {
                                          final approvalStatus = complaint['approval_status']?.toString() ?? 'N/A';
                                          final statusColor = viewModel.getApprovalStatusColor(approvalStatus);
                                          
                                          return DataRow(
                                            cells: [
                                              // Action - Eye icon button
                                              DataCell(
                                                IconButton(
                                                  icon: const Icon(
                                                    FontAwesomeIcons.eye,
                                                    size: 18,
                                                    color: Colors.grey,
                                                  ),
                                                  onPressed: () {
                                                    _showComplaintDetails(
                                                        context, complaint);
                                                  },
                                                ),
                                              ),
                                              // Complaint From
                                              DataCell(
                                                Text(
                                                  complaint['complaint_from']
                                                          ?.toString() ??
                                                      'N/A',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ),
                                              // Complaint Against
                                              DataCell(
                                                Text(
                                                  complaint['complaint_against']
                                                          ?.toString() ??
                                                      'N/A',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ),
                                              // Complaint Title
                                              DataCell(
                                                Text(
                                                  complaint['complaint_title']
                                                          ?.toString() ??
                                                      'N/A',
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500),
                                                ),
                                              ),
                                              // Complaint Date
                                              DataCell(
                                                Text(
                                                  complaint['complaint_date']
                                                          ?.toString() ??
                                                      'N/A',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ),
                                              // Approval Status
                                              DataCell(
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: statusColor
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(4),
                                                    border: Border.all(
                                                      color: statusColor,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    approvalStatus,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: statusColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Details
                                              DataCell(
                                                SizedBox(
                                                  width: 200,
                                                  child: Text(
                                                    complaint['details']
                                                            ?.toString() ??
                                                        'N/A',
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                                Builder(
                                  builder: (context) {
                                    final filteredComplaints =
                                        _getFilteredComplaints(viewModel);
                                    final paginatedComplaints =
                                        _getPaginatedComplaints(viewModel);
                                    final totalPages = _getTotalPages(viewModel);

                                    return LayoutBuilder(
                                      builder: (context, constraints) {
                                        final isSmallScreen =
                                            constraints.maxWidth < 600;

                                        if (isSmallScreen) {
                                          // Stack vertically on small screens
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Entry summary
                                              Text(
                                                'Showing ${paginatedComplaints.isEmpty ? 0 : (_currentPage - 1) * _entriesPerPage + 1} to ${paginatedComplaints.isEmpty ? 0 : (_currentPage - 1) * _entriesPerPage + paginatedComplaints.length} of ${filteredComplaints.length} entries',
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                              const SizedBox(height: 12),
                                              // Pagination buttons
                                              Wrap(
                                                alignment: WrapAlignment.start,
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: [
                                                  // Previous button
                                                  TextButton(
                                                    onPressed: _currentPage > 1
                                                        ? () {
                                                            setState(() {
                                                              _currentPage--;
                                                            });
                                                          }
                                                        : null,
                                                    child: const Text('Previous'),
                                                  ),
                                                  // Page numbers
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
                                                              const Size(40, 40),
                                                          padding:
                                                              EdgeInsets.zero,
                                                        ),
                                                        child: Text(
                                                            pageNum.toString()),
                                                      );
                                                    },
                                                  ),
                                                  // Next button
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
                                          // Horizontal layout on larger screens
                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Entry summary
                                              Flexible(
                                    child: Text(
                                                  'Showing ${paginatedComplaints.isEmpty ? 0 : (_currentPage - 1) * _entriesPerPage + 1} to ${paginatedComplaints.isEmpty ? 0 : (_currentPage - 1) * _entriesPerPage + paginatedComplaints.length} of ${filteredComplaints.length} entries',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),

                                              // Pagination buttons
                                              Flexible(
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    // Previous button
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

                                                    // Page numbers - limit visible pages
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

                                                    // Next button
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
