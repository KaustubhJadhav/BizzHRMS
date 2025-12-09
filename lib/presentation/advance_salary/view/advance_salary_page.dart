import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../view_model/advance_salary_view_model.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/sidebar/sidebar_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/header/header_widget.dart';
import 'package:bizzhrms_flutter_app/core/constants/app_constants.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/loading_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/error_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/back_button_widget.dart';

class AdvanceSalaryPage extends StatefulWidget {
  const AdvanceSalaryPage({super.key});

  @override
  State<AdvanceSalaryPage> createState() => _AdvanceSalaryPageState();
}

class _AdvanceSalaryPageState extends State<AdvanceSalaryPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _monthYearController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _emiController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _entriesPerPage = 10;
  int _currentPage = 1;
  String _searchQuery = '';
  bool _showAddForm = false;
  String? _selectedOneTimeDeduct;

  @override
  void dispose() {
    _searchController.dispose();
    _monthYearController.dispose();
    _amountController.dispose();
    _emiController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredAdvanceSalary(AdvanceSalaryViewModel viewModel) {
    List<Map<String, dynamic>> advanceSalaries = viewModel.advanceSalaryList;

    if (_searchQuery.isNotEmpty) {
      advanceSalaries = advanceSalaries.where((item) {
        final employeeName = item['employee_name']?.toString().toLowerCase() ?? '';
        final monthYear = item['month_year']?.toString().toLowerCase() ?? '';
        final status = item['status']?.toString().toLowerCase() ?? '';
        final reason = item['reason']?.toString().toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        return employeeName.contains(query) ||
            monthYear.contains(query) ||
            status.contains(query) ||
            reason.contains(query);
      }).toList();
    }

    return advanceSalaries;
  }

  List<Map<String, dynamic>> _getPaginatedAdvanceSalary(AdvanceSalaryViewModel viewModel) {
    final filtered = _getFilteredAdvanceSalary(viewModel);
    final startIndex = (_currentPage - 1) * _entriesPerPage;
    final endIndex = startIndex + _entriesPerPage;
    if (endIndex > filtered.length) {
      return filtered.sublist(startIndex);
    }
    return filtered.sublist(startIndex, endIndex);
  }

  int _getTotalPages(AdvanceSalaryViewModel viewModel) {
    return (_getFilteredAdvanceSalary(viewModel).length / _entriesPerPage).ceil();
  }

  void _showAdvanceSalaryDetails(BuildContext context, Map<String, dynamic> advanceSalary) {
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
                        'View Advance Salary Details',
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
                          'Employee',
                          advanceSalary['employee_name']?.toString() ?? 'N/A',
                        ),
                        if (advanceSalary['reason'] != null && advanceSalary['reason'].toString().isNotEmpty)
                          _buildDetailRow(
                            'Reason',
                            advanceSalary['reason'].toString(),
                          ),
                        _buildDetailRow(
                          'Amount',
                          advanceSalary['advance_amount'] != null && advanceSalary['advance_amount'].toString().isNotEmpty
                              ? '₹ ${advanceSalary['advance_amount']}'
                              : 'N/A',
                        ),
                        _buildDetailRow(
                          'Month & Year',
                          advanceSalary['month_year']?.toString() ?? 'N/A',
                        ),
                        _buildDetailRow(
                          'One Time Deduct',
                          advanceSalary['one_time_deduct']?.toString() ?? 'N/A',
                        ),
                        _buildDetailRow(
                          'Monthly Installment',
                          advanceSalary['monthly_installment'] != null && advanceSalary['monthly_installment'].toString().isNotEmpty
                              ? advanceSalary['monthly_installment'] == '0'
                                  ? 'N/A'
                                  : '₹ ${advanceSalary['monthly_installment']}'
                              : 'N/A',
                        ),
                        _buildDetailRow(
                          'Created At',
                          advanceSalary['created_at']?.toString() ?? 'N/A',
                        ),
                        _buildDetailRow(
                          'Status',
                          advanceSalary['status']?.toString() ?? 'N/A',
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

  Future<void> _handleAddAdvanceSalary(AdvanceSalaryViewModel viewModel) async {
    if (_formKey.currentState!.validate()) {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        // Convert one_time_deduct to '0' or '1' based on selection
        final oneTimeDeduct = _selectedOneTimeDeduct == 'Yes' ? '1' : '0';
        
        // Get monthly installment, default to '0' if one-time deduct is Yes
        final monthlyInstallment = _selectedOneTimeDeduct == 'Yes' 
            ? '0' 
            : (_emiController.text.trim().isEmpty ? '0' : _emiController.text.trim());

        final success = await viewModel.addAdvanceSalary(
          monthYear: _monthYearController.text.trim(),
          amount: _amountController.text.trim(),
          reason: _reasonController.text.trim(),
          oneTimeDeduct: oneTimeDeduct,
          monthlyInstallment: monthlyInstallment,
        );

        // Close loading dialog
        if (mounted) {
          Navigator.of(context).pop();
        }

        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Advance salary request created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
          setState(() {
            _showAddForm = false;
            _monthYearController.clear();
            _amountController.clear();
            _emiController.clear();
            _reasonController.clear();
            _selectedOneTimeDeduct = null;
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(viewModel.errorMessage ?? 'Failed to create advance salary request'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        // Close loading dialog
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildAddAdvanceSalaryForm(AdvanceSalaryViewModel viewModel) {
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
                    'Request Advance Salary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _showAddForm = false;
                        _monthYearController.clear();
                        _amountController.clear();
                        _emiController.clear();
                        _reasonController.clear();
                        _selectedOneTimeDeduct = null;
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
                    return Column(
                      children: [
                        TextFormField(
                          controller: _monthYearController,
                          decoration: const InputDecoration(
                            labelText: 'Month & Year',
                            hintText: 'Select Month & Year',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                _monthYearController.text =
                                    '${picked.year}-${picked.month.toString().padLeft(2, '0')}';
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select month & year';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _amountController,
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            hintText: 'Enter amount',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter amount';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedOneTimeDeduct,
                          decoration: const InputDecoration(
                            labelText: 'One Time Deduct',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Yes', child: Text('Yes')),
                            DropdownMenuItem(value: 'No', child: Text('No')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedOneTimeDeduct = value;
                              if (value == 'Yes') {
                                _emiController.text = '0.00';
                              }
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select one time deduct';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emiController,
                          decoration: const InputDecoration(
                            labelText: 'EMI',
                            hintText: 'Employee Monthly Installment',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          enabled: _selectedOneTimeDeduct == 'No',
                          validator: (value) {
                            if (_selectedOneTimeDeduct == 'No' &&
                                (value == null || value.isEmpty)) {
                              return 'Please enter EMI';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _reasonController,
                          decoration: const InputDecoration(
                            labelText: 'Reason',
                            hintText: 'Enter reason',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 5,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter reason';
                            }
                            return null;
                          },
                        ),
                      ],
                    );
                  } else {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _monthYearController,
                                decoration: const InputDecoration(
                                  labelText: 'Month & Year',
                                  hintText: 'Select Month & Year',
                                  border: OutlineInputBorder(),
                                ),
                                readOnly: true,
                                onTap: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _monthYearController.text =
                                          '${picked.month.toString().padLeft(2, '0')}-${picked.year}';
                                    });
                                  }
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select month & year';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _amountController,
                                decoration: const InputDecoration(
                                  labelText: 'Amount',
                                  hintText: 'Enter amount',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter amount';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedOneTimeDeduct,
                                      decoration: const InputDecoration(
                                        labelText: 'One Time Deduct',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'Yes', child: Text('Yes')),
                                        DropdownMenuItem(
                                            value: 'No', child: Text('No')),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedOneTimeDeduct = value;
                                          if (value == 'Yes') {
                                            _emiController.text = '0.00';
                                          }
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null) {
                                          return 'Please select';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _emiController,
                                      decoration: const InputDecoration(
                                        labelText: 'EMI',
                                        hintText: 'Monthly Installment',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      enabled: _selectedOneTimeDeduct == 'No',
                                      validator: (value) {
                                        if (_selectedOneTimeDeduct == 'No' &&
                                            (value == null || value.isEmpty)) {
                                          return 'Please enter EMI';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _reasonController,
                            decoration: const InputDecoration(
                              labelText: 'Reason',
                              hintText: 'Enter reason',
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                            ),
                            maxLines: 5,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter reason';
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
              Consumer<AdvanceSalaryViewModel>(
                builder: (context, viewModel, child) {
                  return ElevatedButton(
                    onPressed: () => _handleAddAdvanceSalary(viewModel),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C3E50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Save'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'accepted':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdvanceSalaryViewModel()..loadAdvanceSalaryData(),
      builder: (context, child) {
        return Scaffold(
          drawer: const Drawer(
            child: SafeArea(
              child: SidebarWidget(
                  currentRoute: AppConstants.routeAdvanceSalary),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                const HeaderWidget(pageTitle: 'Advance Salary'),
                const BackButtonWidget(title: 'Advance Salary'),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Consumer<AdvanceSalaryViewModel>(
                      builder: (context, viewModel, child) {
                        if (viewModel.status == AdvanceSalaryStatus.loading) {
                          return const LoadingWidget(
                              message: 'Loading advance salaries...');
                        }

                        if (viewModel.status == AdvanceSalaryStatus.error) {
                          return ErrorDisplayWidget(
                            message: viewModel.errorMessage ??
                                'Failed to load advance salaries',
                            onRetry: () => viewModel.refresh(),
                          );
                        }

                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildAddAdvanceSalaryForm(viewModel),
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
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          final isSmallScreen =
                                              constraints.maxWidth < 600;
                                          
                                          if (isSmallScreen) {
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'List All Advance Salaries',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: ElevatedButton.icon(
                                                    onPressed: () {
                                                      setState(() {
                                                        _showAddForm =
                                                            !_showAddForm;
                                                      });
                                                    },
                                                    icon: Icon(_showAddForm
                                                        ? Icons.remove
                                                        : Icons.add),
                                                    label: Text(_showAddForm
                                                        ? 'Hide'
                                                        : 'Add New'),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          const Color(0xFF2C3E50),
                                                      foregroundColor:
                                                          Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          } else {
                                            return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Flexible(
                                                  child: Text(
                                                    'List All Advance Salaries',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                ElevatedButton.icon(
                                                  onPressed: () {
                                                    setState(() {
                                                      _showAddForm =
                                                          !_showAddForm;
                                                    });
                                                  },
                                                  icon: Icon(_showAddForm
                                                      ? Icons.remove
                                                      : Icons.add),
                                                  label: Text(_showAddForm
                                                      ? 'Hide'
                                                      : 'Add New'),
                                                  style: ElevatedButton
                                                      .styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFF2C3E50),
                                                    foregroundColor:
                                                        Colors.white,
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                        },
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
                                                              EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      12,
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
                                                              EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      12,
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
                                                    Text('Amount'),
                                                    SizedBox(width: 4),
                                                    Icon(Icons.swap_vert,
                                                        size: 16),
                                                  ],
                                                ),
                                              ),
                                              DataColumn(
                                                label: Row(
                                                  children: [
                                                    Text('Month & Year'),
                                                    SizedBox(width: 4),
                                                    Icon(Icons.swap_vert,
                                                        size: 16),
                                                  ],
                                                ),
                                              ),
                                              DataColumn(
                                                label: Row(
                                                  children: [
                                                    Text('One Time Deduct'),
                                                    SizedBox(width: 4),
                                                    Icon(Icons.swap_vert,
                                                        size: 16),
                                                  ],
                                                ),
                                              ),
                                              DataColumn(
                                                label: Row(
                                                  children: [
                                                    Text('Monthly Installment'),
                                                    SizedBox(width: 4),
                                                    Icon(Icons.swap_vert,
                                                        size: 16),
                                                  ],
                                                ),
                                              ),
                                              DataColumn(
                                                label: Row(
                                                  children: [
                                                    Text('Created At'),
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
                                            ],
                                            rows: _getPaginatedAdvanceSalary(
                                                    viewModel)
                                                .map((item) {
                                              final status =
                                                  item['status']?.toString() ??
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
                                                        _showAdvanceSalaryDetails(
                                                            context, item);
                                                      },
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      item['employee_name']
                                                              ?.toString() ??
                                                          'N/A',
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      item['advance_amount'] != null && item['advance_amount'].toString().isNotEmpty
                                                          ? '₹ ${item['advance_amount']}'
                                                          : 'N/A',
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      item['month_year']
                                                              ?.toString() ??
                                                          'N/A',
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      item['one_time_deduct']
                                                              ?.toString() ??
                                                          'N/A',
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      item['monthly_installment'] != null && item['monthly_installment'].toString().isNotEmpty
                                                          ? item['monthly_installment'] == '0'
                                                              ? 'N/A'
                                                              : '₹ ${item['monthly_installment']}'
                                                          : 'N/A',
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      item['created_at']
                                                              ?.toString() ??
                                                          'N/A',
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Container(
                                                      padding:
                                                          const EdgeInsets
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
                                      const SizedBox(height: 16),
                                      Builder(
                                        builder: (context) {
                                          final filteredAdvanceSalaries =
                                              _getFilteredAdvanceSalary(
                                                  viewModel);
                                          final paginatedAdvanceSalaries =
                                              _getPaginatedAdvanceSalary(
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
                                                      'Showing ${paginatedAdvanceSalaries.isEmpty ? 0 : (_currentPage - 1) * _entriesPerPage + 1} to ${paginatedAdvanceSalaries.isEmpty ? 0 : (_currentPage - 1) * _entriesPerPage + paginatedAdvanceSalaries.length} of ${filteredAdvanceSalaries.length} entries',
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
                                                              child: Text(
                                                                  pageNum
                                                                      .toString()),
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
                                                        'Showing ${paginatedAdvanceSalaries.isEmpty ? 0 : (_currentPage - 1) * _entriesPerPage + 1} to ${paginatedAdvanceSalaries.isEmpty ? 0 : (_currentPage - 1) * _entriesPerPage + paginatedAdvanceSalaries.length} of ${filteredAdvanceSalaries.length} entries',
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
                                                            onPressed: _currentPage <
                                                                    totalPages
                                                                ? () {
                                                                    setState(() {
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
}

