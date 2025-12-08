import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../view_model/transfers_view_model.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/sidebar/sidebar_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/header/header_widget.dart';
import 'package:bizzhrms_flutter_app/core/constants/app_constants.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/loading_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/error_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/back_button_widget.dart';

class TransfersPage extends StatefulWidget {
  const TransfersPage({super.key});

  @override
  State<TransfersPage> createState() => _TransfersPageState();
}

class _TransfersPageState extends State<TransfersPage> {
  final TextEditingController _searchController = TextEditingController();
  int _entriesPerPage = 10;
  int _currentPage = 1;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredTransfers(TransfersViewModel viewModel) {
    List<Map<String, dynamic>> transfers = viewModel.transfersList;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      transfers = transfers.where((item) {
        final employeeName = item['employee_name']?.toString().toLowerCase() ?? '';
        final department = item['transfer_to_department']?.toString().toLowerCase() ?? 
                          item['transfer_from']?.toString().toLowerCase() ?? '';
        final branch = item['transfer_to_branch']?.toString().toLowerCase() ?? 
                      item['transfer_to']?.toString().toLowerCase() ?? '';
        final status = item['status']?.toString().toLowerCase() ?? 
                      item['transfer_status']?.toString().toLowerCase() ?? '';
        final addedBy = item['added_by']?.toString().toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        return employeeName.contains(query) ||
            department.contains(query) ||
            branch.contains(query) ||
            status.contains(query) ||
            addedBy.contains(query);
      }).toList();
    }

    return transfers;
  }

  List<Map<String, dynamic>> _getPaginatedTransfers(TransfersViewModel viewModel) {
    final filtered = _getFilteredTransfers(viewModel);
    final startIndex = (_currentPage - 1) * _entriesPerPage;
    final endIndex = startIndex + _entriesPerPage;
    if (endIndex > filtered.length) {
      return filtered.sublist(startIndex);
    }
    return filtered.sublist(startIndex, endIndex);
  }

  int _getTotalPages(TransfersViewModel viewModel) {
    return (_getFilteredTransfers(viewModel).length / _entriesPerPage).ceil();
  }

  void _showTransferDetails(BuildContext context, Map<String, dynamic> transfer, TransfersViewModel viewModel) {
    final transferId = transfer['transfer_id']?.toString() ?? '';
    
    if (transferId.isEmpty) {
      // If no transfer_id, show basic details from list
      _showTransferDetailsDialog(context, transfer, viewModel);
      return;
    }

    // Show loading dialog first
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Fetch full transfer details
    viewModel.getTransferDetails(transferId).then((transferDetails) {
      Navigator.of(context).pop(); // Close loading dialog
      
      if (transferDetails != null) {
        _showTransferDetailsDialog(context, transferDetails, viewModel);
      } else {
        // If API fails, show basic details from list
        _showTransferDetailsDialog(context, transfer, viewModel);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load full transfer details. Showing basic information.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _showTransferDetailsDialog(BuildContext context, Map<String, dynamic> transfer, TransfersViewModel viewModel) {
    final theme = Theme.of(context);
    final statusColor = viewModel.getStatusColor(transfer['status']?.toString() ?? transfer['transfer_status']?.toString() ?? '');
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: (MediaQuery.of(context).size.width * 0.99).clamp(1000.0, 1600.0),
            maxHeight: MediaQuery.of(context).size.height * 0.97,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Material 3 Header
              Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.swap_horiz_rounded,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Transfer Details',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Employee Information Card
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_rounded,
                                    size: 20,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Employee Information',
                                      style: theme.textTheme.labelLarge?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildInfoItem(
                                context,
                                'Employee Name',
                                transfer['employee_name']?.toString() ?? 'N/A',
                                Icons.badge_rounded,
                              ),
                              const SizedBox(height: 12),
                              _buildInfoItem(
                                context,
                                'Employee ID',
                                transfer['employee_id']?.toString() ?? 'N/A',
                                Icons.numbers_rounded,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Transfer Details Card
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_rounded,
                                    size: 20,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Transfer Details',
                                      style: theme.textTheme.labelLarge?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildInfoItem(
                                context,
                                'Transfer Date',
                                transfer['transfer_date']?.toString() ?? 'N/A',
                                Icons.calendar_month_rounded,
                              ),
                              const SizedBox(height: 12),
                              _buildInfoItem(
                                context,
                                'Transfer From',
                                transfer['transfer_from']?.toString() ?? transfer['transfer_to_department']?.toString() ?? 'N/A',
                                Icons.arrow_back_rounded,
                              ),
                              const SizedBox(height: 12),
                              _buildInfoItem(
                                context,
                                'Transfer To',
                                transfer['transfer_to']?.toString() ?? transfer['transfer_to_branch']?.toString() ?? 'N/A',
                                Icons.arrow_forward_rounded,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.flag_rounded,
                                    size: 18,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Status',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: statusColor, width: 1),
                                          ),
                                          child: Text(
                                            transfer['status']?.toString() ?? transfer['transfer_status']?.toString() ?? 'N/A',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: statusColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (transfer['created_at'] != null) ...[
                                const SizedBox(height: 12),
                                _buildInfoItem(
                                  context,
                                  'Created At',
                                  transfer['created_at']?.toString() ?? 'N/A',
                                  Icons.access_time_rounded,
                                ),
                              ],
                              if (transfer['transfer_id'] != null) ...[
                                const SizedBox(height: 12),
                                _buildInfoItem(
                                  context,
                                  'Transfer ID',
                                  transfer['transfer_id']?.toString() ?? 'N/A',
                                  Icons.tag_rounded,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      
                      // Added By Card
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_add_rounded,
                                    size: 20,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Added By',
                                      style: theme.textTheme.labelLarge?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                transfer['added_by']?.toString() ?? 'N/A',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Transfer Description Section
                      if (transfer['transfer_description'] != null && transfer['transfer_description'].toString().isNotEmpty)
                        Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.description_rounded,
                                      size: 20,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Transfer Description',
                                        style: theme.textTheme.labelLarge?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  transfer['transfer_description']?.toString() ?? 'N/A',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Footer
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Close'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
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

  Widget _buildInfoItem(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransfersViewModel()..loadTransfersData(),
      builder: (context, child) {
    return Scaffold(
          drawer: const Drawer(
        child: SafeArea(
          child: SidebarWidget(currentRoute: AppConstants.routeTransfers),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const HeaderWidget(pageTitle: 'Transfers'),
            const BackButtonWidget(title: 'Transfers'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                    child: Consumer<TransfersViewModel>(
                      builder: (context, viewModel, child) {
                        if (viewModel.status == TransfersStatus.loading) {
                          return const LoadingWidget(
                              message: 'Loading transfers...');
                        }

                        if (viewModel.status == TransfersStatus.error) {
                          return ErrorDisplayWidget(
                            message: viewModel.errorMessage ??
                                'Failed to load transfers',
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
                                  'List All Transfers',
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
                                                Text('Employee Name'),
                                                SizedBox(width: 4),
                                                Icon(Icons.swap_vert, size: 16),
                                              ],
                                            ),
                                          ),
                                          DataColumn(
                                            label: Row(
                                              children: [
                                                Text('Transfer Date'),
                                                SizedBox(width: 4),
                                                Icon(Icons.swap_vert, size: 16),
                                              ],
                                            ),
                                          ),
                                          DataColumn(
                                            label: Row(
                                              children: [
                                                Text('Transfer To (Department)'),
                                                SizedBox(width: 4),
                                                Icon(Icons.swap_vert, size: 16),
                                              ],
                                            ),
                                          ),
                                          DataColumn(
                                            label: Row(
                                              children: [
                                                Text('Transfer To (Branch)'),
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
                                          DataColumn(
                                            label: Row(
                                              children: [
                                                Text('Added By'),
                                                SizedBox(width: 4),
                                                Icon(Icons.swap_vert, size: 16),
                                              ],
                                            ),
                                          ),
                                        ],
                                        rows: _getPaginatedTransfers(viewModel)
                                            .map((transfer) {
                                          final status = transfer['status']?.toString() ?? 'N/A';
                                          final statusColor = viewModel.getStatusColor(status);
                                          
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
                                                    _showTransferDetails(
                                                        context, transfer, viewModel);
                                                  },
                                                ),
                                              ),
                                              // Employee Name
                                              DataCell(
                                                Text(
                                                  transfer['employee_name']
                                                          ?.toString() ??
                                                      'N/A',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ),
                                              // Transfer Date
                                              DataCell(
                                                Text(
                                                  transfer['transfer_date']
                                                          ?.toString() ??
                                                      'N/A',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ),
                                              // Transfer To (Department)
                                              DataCell(
                                                Text(
                                                  transfer['transfer_to_department']
                                                          ?.toString() ??
                                                      'N/A',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ),
                                              // Transfer To (Branch)
                                              DataCell(
                                                Text(
                                                  transfer['transfer_to_branch']
                                                          ?.toString() ??
                                                      'N/A',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ),
                                              // Status
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
                                                    status,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: statusColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Added By
                                              DataCell(
                                                Text(
                                                  transfer['added_by']
                                                          ?.toString() ??
                                                      'N/A',
                                                  style: const TextStyle(
                                                      fontSize: 14),
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
                                    final filteredTransfers =
                                        _getFilteredTransfers(viewModel);
                                    final paginatedTransfers =
                                        _getPaginatedTransfers(viewModel);
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
                                                'Showing ${paginatedTransfers.isEmpty ? 0 : (_currentPage - 1) * _entriesPerPage + 1} to ${paginatedTransfers.isEmpty ? 0 : (_currentPage - 1) * _entriesPerPage + paginatedTransfers.length} of ${filteredTransfers.length} entries',
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
                                                  'Showing ${paginatedTransfers.isEmpty ? 0 : (_currentPage - 1) * _entriesPerPage + 1} to ${paginatedTransfers.isEmpty ? 0 : (_currentPage - 1) * _entriesPerPage + paginatedTransfers.length} of ${filteredTransfers.length} entries',
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
