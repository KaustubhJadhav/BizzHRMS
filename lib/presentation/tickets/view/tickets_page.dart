import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../view_model/tickets_view_model.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/sidebar/sidebar_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/header/header_widget.dart';
import 'package:bizzhrms_flutter_app/core/constants/app_constants.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/loading_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/error_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/back_button_widget.dart';

class TicketsPage extends StatefulWidget {
  const TicketsPage({super.key});

  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _entriesPerPage = 10;
  int _currentPage = 1;
  String _searchQuery = '';
  bool _showAddForm = false;
  int? _selectedPriority;

  @override
  void dispose() {
    _searchController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredTickets(TicketsViewModel viewModel) {
    List<Map<String, dynamic>> tickets = viewModel.ticketsList;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      tickets = tickets.where((ticket) {
        final ticketCode =
            ticket['ticket_code']?.toString().toLowerCase() ?? '';
        final subject = ticket['subject']?.toString().toLowerCase() ?? '';
        final employee = ticket['employee']?.toString().toLowerCase() ?? '';
        final status = ticket['status']?.toString().toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        return ticketCode.contains(query) ||
            subject.contains(query) ||
            employee.contains(query) ||
            status.contains(query);
      }).toList();
    }

    return tickets;
  }

  List<Map<String, dynamic>> _getPaginatedTickets(TicketsViewModel viewModel) {
    final filtered = _getFilteredTickets(viewModel);
    final startIndex = (_currentPage - 1) * _entriesPerPage;
    final endIndex = startIndex + _entriesPerPage;
    if (endIndex > filtered.length) {
      return filtered.sublist(startIndex);
    }
    return filtered.sublist(startIndex, endIndex);
  }

  int _getTotalPages(TicketsViewModel viewModel) {
    return (_getFilteredTickets(viewModel).length / _entriesPerPage).ceil();
  }

  void _showTicketDetails(BuildContext context, Map<String, dynamic> ticket,
      TicketsViewModel viewModel) {
    // Try to get ticket_id from the ticket object
    final ticketId = ticket['ticket_id']?.toString() ?? '';

    if (ticketId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ticket ID not available'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Navigate to ticket details page
    Navigator.pushNamed(
      context,
      AppConstants.routeTicketDetails,
      arguments: {
        'ticket_id': ticketId,
        'ticket': ticket,
      },
    );
  }

  Future<void> _handleAddTicket(TicketsViewModel viewModel) async {
    if (_formKey.currentState!.validate()) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        final result = await viewModel.addTicket(
          _subjectController.text.trim(),
          _descriptionController.text.trim(),
          _selectedPriority ?? 2, // Default to Medium if somehow null
        );

        // Hide loading indicator
        if (mounted) {
          Navigator.of(context).pop();
        }

        if (result != null && result['error'] == null) {
          // Success
          final ticketCode = result['ticket_code']?.toString() ?? '';
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  ticketCode.isNotEmpty
                      ? 'Ticket created successfully! Code: $ticketCode'
                      : 'Ticket created successfully!',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          }
          setState(() {
            _showAddForm = false;
            _subjectController.clear();
            _descriptionController.clear();
            _selectedPriority = null;
          });
        } else {
          // Error
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    result?['error']?.toString() ?? 'Failed to create ticket'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      } catch (e) {
        // Hide loading indicator
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Widget _buildAddTicketForm(TicketsViewModel viewModel) {
    if (!_showAddForm) return const SizedBox.shrink();

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
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
                    'Create New Ticket',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _showAddForm = false;
                        _subjectController.clear();
                        _descriptionController.clear();
                        _selectedPriority = null;
                      });
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Hide'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isSmallScreen = constraints.maxWidth < 600;

                  if (isSmallScreen) {
                    // Stack vertically on small screens
                    return Column(
                      children: [
                        TextFormField(
                          controller: _subjectController,
                          decoration: const InputDecoration(
                            labelText: 'Subject',
                            hintText: 'Enter ticket subject',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a subject';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: _selectedPriority,
                          decoration: const InputDecoration(
                            labelText: 'Priority',
                            hintText: 'Select Priority',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('Low')),
                            DropdownMenuItem(value: 2, child: Text('Medium')),
                            DropdownMenuItem(value: 3, child: Text('High')),
                            DropdownMenuItem(value: 4, child: Text('Critical')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedPriority = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a priority';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Ticket Description',
                            hintText: 'Enter ticket description',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 5,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                      ],
                    );
                  } else {
                    // Horizontal layout on larger screens
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _subjectController,
                                decoration: const InputDecoration(
                                  labelText: 'Subject',
                                  hintText: 'Enter ticket subject',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a subject';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<int>(
                                value: _selectedPriority,
                                decoration: const InputDecoration(
                                  labelText: 'Priority',
                                  hintText: 'Select Priority',
                                  border: OutlineInputBorder(),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                      value: 1, child: Text('Low')),
                                  DropdownMenuItem(
                                      value: 2, child: Text('Medium')),
                                  DropdownMenuItem(
                                      value: 3, child: Text('High')),
                                  DropdownMenuItem(
                                      value: 4, child: Text('Critical')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedPriority = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a priority';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Ticket Description',
                              hintText: 'Enter ticket description',
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                            ),
                            maxLines: 5,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a description';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _handleAddTicket(viewModel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C3E50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TicketsViewModel()..loadTicketsData(),
      builder: (context, child) {
        return Scaffold(
          drawer: const Drawer(
            child: SafeArea(
              child: SidebarWidget(currentRoute: AppConstants.routeTickets),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                const HeaderWidget(pageTitle: 'Tickets'),
                const BackButtonWidget(title: 'Tickets'),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Consumer<TicketsViewModel>(
                      builder: (context, viewModel, child) {
                        if (viewModel.status == TicketsStatus.loading) {
                          return const LoadingWidget(
                              message: 'Loading tickets...');
                        }

                        if (viewModel.status == TicketsStatus.error) {
                          return ErrorDisplayWidget(
                            message: viewModel.errorMessage ??
                                'Failed to load tickets',
                            onRetry: () => viewModel.refresh(),
                          );
                        }

                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Add Ticket Form
                              _buildAddTicketForm(viewModel),

                              // Tickets List Card
                              Card(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Title and Add New Button
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'List All Tickets',
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
                                            icon: Icon(_showAddForm
                                                ? Icons.remove
                                                : Icons.add),
                                            label: Text(_showAddForm
                                                ? 'Hide'
                                                : 'Add New'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF2C3E50),
                                              foregroundColor: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),

                                      // Controls: Entries per page and Search
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
                                                                child: Text(value
                                                                    .toString()),
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
                                                        controller:
                                                            _searchController,
                                                        decoration:
                                                            const InputDecoration(
                                                          border:
                                                              OutlineInputBorder(),
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          12,
                                                                      vertical:
                                                                          8),
                                                        ),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            _searchQuery =
                                                                value;
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                                                                child: Text(value
                                                                    .toString()),
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
                                                        controller:
                                                            _searchController,
                                                        decoration:
                                                            const InputDecoration(
                                                          border:
                                                              OutlineInputBorder(),
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          12,
                                                                      vertical:
                                                                          8),
                                                        ),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            _searchQuery =
                                                                value;
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
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: SingleChildScrollView(
                                          child: DataTable(
                                            columns: const [
                                              DataColumn(
                                                label: Row(
                                                  children: [
                                                    Text('Action'),
                                                    SizedBox(width: 4),
                                                    Icon(Icons.swap_vert,
                                                        size: 16),
                                                  ],
                                                ),
                                              ),
                                              DataColumn(
                                                label: Row(
                                                  children: [
                                                    Text('Ticket Code'),
                                                    SizedBox(width: 4),
                                                    Icon(Icons.swap_vert,
                                                        size: 16),
                                                  ],
                                                ),
                                              ),
                                              DataColumn(
                                                label: Row(
                                                  children: [
                                                    Text('Subject'),
                                                    SizedBox(width: 4),
                                                    Icon(Icons.swap_vert,
                                                        size: 16),
                                                  ],
                                                ),
                                              ),
                                              DataColumn(
                                                label: Row(
                                                  children: [
                                                    Text('Employee'),
                                                    SizedBox(width: 4),
                                                    Icon(Icons.swap_vert,
                                                        size: 16),
                                                  ],
                                                ),
                                              ),
                                              DataColumn(
                                                label: Row(
                                                  children: [
                                                    Text('Priority'),
                                                    SizedBox(width: 4),
                                                    Icon(Icons.swap_vert,
                                                        size: 16),
                                                  ],
                                                ),
                                              ),
                                              DataColumn(
                                                label: Row(
                                                  children: [
                                                    Text('Status'),
                                                    SizedBox(width: 4),
                                                    Icon(Icons.swap_vert,
                                                        size: 16),
                                                  ],
                                                ),
                                              ),
                                              DataColumn(
                                                label: Row(
                                                  children: [
                                                    Text('Date'),
                                                    SizedBox(width: 4),
                                                    Icon(Icons.swap_vert,
                                                        size: 16),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            rows:
                                                _getPaginatedTickets(viewModel)
                                                    .map((ticket) {
                                              final priority =
                                                  ticket['priority'] ?? 0;
                                              final priorityColor = viewModel
                                                  .getPriorityColor(priority);
                                              final status = ticket['status']
                                                      ?.toString() ??
                                                  'N/A';

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
                                                        _showTicketDetails(
                                                            context,
                                                            ticket,
                                                            viewModel);
                                                      },
                                                    ),
                                                  ),
                                                  // Ticket Code
                                                  DataCell(
                                                    Text(
                                                      ticket['ticket_code']
                                                              ?.toString() ??
                                                          'N/A',
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ),
                                                  // Subject
                                                  DataCell(
                                                    Text(
                                                      ticket['subject']
                                                              ?.toString() ??
                                                          'N/A',
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ),
                                                  // Employee
                                                  DataCell(
                                                    Text(
                                                      ticket['employee']
                                                              ?.toString() ??
                                                          'N/A',
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ),
                                                  // Priority
                                                  DataCell(
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: priorityColor
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                        border: Border.all(
                                                          color: priorityColor,
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        viewModel
                                                            .getPriorityText(
                                                                priority),
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: priorityColor,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  // Status
                                                  DataCell(
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: _getStatusColor(
                                                                status)
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                        border: Border.all(
                                                          color:
                                                              _getStatusColor(
                                                                  status),
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        status,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              _getStatusColor(
                                                                  status),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  // Date
                                                  DataCell(
                                                    Text(
                                                      ticket['date']
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

                                      const SizedBox(height: 16),

                                      // Pagination
                                      Builder(
                                        builder: (context) {
                                          final filteredTickets =
                                              _getFilteredTickets(viewModel);
                                          final paginatedTickets =
                                              _getPaginatedTickets(viewModel);
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
                                                      'Showing ${paginatedTickets.isEmpty ? 0 : (_currentPage - 1) * _entriesPerPage + 1} to ${paginatedTickets.isEmpty ? 0 : (_currentPage - 1) * _entriesPerPage + paginatedTickets.length} of ${filteredTickets.length} entries',
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                    const SizedBox(height: 12),
                                                    Wrap(
                                                      alignment:
                                                          WrapAlignment.start,
                                                      spacing: 8,
                                                      runSpacing: 8,
                                                      children: [
                                                        TextButton(
                                                          onPressed:
                                                              _currentPage > 1
                                                                  ? () {
                                                                      setState(
                                                                          () {
                                                                        _currentPage--;
                                                                      });
                                                                    }
                                                                  : null,
                                                          child: const Text(
                                                              'Previous'),
                                                        ),
                                                        ...List.generate(
                                                          totalPages,
                                                          (index) {
                                                            final pageNum =
                                                                index + 1;
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
                                                            );
                                                          },
                                                        ),
                                                        TextButton(
                                                          onPressed:
                                                              _currentPage <
                                                                      totalPages
                                                                  ? () {
                                                                      setState(
                                                                          () {
                                                                        _currentPage++;
                                                                      });
                                                                    }
                                                                  : null,
                                                          child: const Text(
                                                              'Next'),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                );
                                              } else {
                                                return Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        'Showing ${paginatedTickets.isEmpty ? 0 : (_currentPage - 1) * _entriesPerPage + 1} to ${paginatedTickets.isEmpty ? 0 : (_currentPage - 1) * _entriesPerPage + paginatedTickets.length} of ${filteredTickets.length} entries',
                                                        style: const TextStyle(
                                                            fontSize: 14),
                                                        overflow: TextOverflow
                                                            .ellipsis,
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
                                                                        setState(
                                                                            () {
                                                                          _currentPage--;
                                                                        });
                                                                      }
                                                                    : null,
                                                            child: const Text(
                                                                'Previous'),
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          ...List.generate(
                                                            totalPages > 10
                                                                ? 10
                                                                : totalPages,
                                                            (index) {
                                                              final pageNum =
                                                                  index + 1;
                                                              return Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        4),
                                                                child:
                                                                    TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      _currentPage =
                                                                          pageNum;
                                                                    });
                                                                  },
                                                                  style: TextButton
                                                                      .styleFrom(
                                                                    backgroundColor: _currentPage ==
                                                                            pageNum
                                                                        ? Colors
                                                                            .blue
                                                                        : null,
                                                                    foregroundColor: _currentPage ==
                                                                            pageNum
                                                                        ? Colors
                                                                            .white
                                                                        : null,
                                                                    minimumSize:
                                                                        const Size(
                                                                            40,
                                                                            40),
                                                                    padding:
                                                                        EdgeInsets
                                                                            .zero,
                                                                  ),
                                                                  child: Text(
                                                                      pageNum
                                                                          .toString()),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          TextButton(
                                                            onPressed:
                                                                _currentPage <
                                                                        totalPages
                                                                    ? () {
                                                                        setState(
                                                                            () {
                                                                          _currentPage++;
                                                                        });
                                                                      }
                                                                    : null,
                                                            child: const Text(
                                                                'Next'),
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
                              ),
                            ],
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.blue;
      case 'in progress':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
