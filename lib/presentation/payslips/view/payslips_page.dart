import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../view_model/payslips_view_model.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/sidebar/sidebar_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/header/header_widget.dart';
import 'package:bizzhrms_flutter_app/core/constants/app_constants.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/loading_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/error_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/back_button_widget.dart';

class PayslipsPage extends StatefulWidget {
  const PayslipsPage({super.key});

  @override
  State<PayslipsPage> createState() => _PayslipsPageState();
}

class _PayslipsPageState extends State<PayslipsPage> {
  final TextEditingController _searchController = TextEditingController();
  int _entriesPerPage = 10;
  int _currentPage = 1;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredPayslips(PayslipsViewModel viewModel) {
    List<Map<String, dynamic>> payslips = viewModel.payslipsList;

    if (_searchQuery.isNotEmpty) {
      payslips = payslips.where((payslip) {
        final payslipId = payslip['payslip_id']?.toString().toLowerCase() ?? '';
        final employeeId =
            payslip['employee_id']?.toString().toLowerCase() ?? '';
        final monthPayment =
            payslip['month_payment']?.toString().toLowerCase() ?? '';
        final paymentMethod =
            payslip['payment_method']?.toString().toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        return payslipId.contains(query) ||
            employeeId.contains(query) ||
            monthPayment.contains(query) ||
            paymentMethod.contains(query);
      }).toList();
    }

    return payslips;
  }

  List<Map<String, dynamic>> _getPaginatedPayslips(
      PayslipsViewModel viewModel) {
    final filtered = _getFilteredPayslips(viewModel);
    final startIndex = (_currentPage - 1) * _entriesPerPage;
    final endIndex = startIndex + _entriesPerPage;
    if (endIndex > filtered.length) {
      return filtered.sublist(startIndex);
    }
    return filtered.sublist(startIndex, endIndex);
  }

  int _getTotalPages(PayslipsViewModel viewModel) {
    return (_getFilteredPayslips(viewModel).length / _entriesPerPage).ceil();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PayslipsViewModel()..loadPayslipsData(),
      builder: (context, child) {
        return Scaffold(
          drawer: const Drawer(
            child: SafeArea(
              child: SidebarWidget(currentRoute: AppConstants.routePayslips),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                const HeaderWidget(pageTitle: 'Payslips'),
                const BackButtonWidget(title: 'Payslips'),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Consumer<PayslipsViewModel>(
                      builder: (context, viewModel, child) {
                        if (viewModel.status == PayslipsStatus.loading) {
                          return const LoadingWidget(
                              message: 'Loading payslips...');
                        }

                        if (viewModel.status == PayslipsStatus.error) {
                          return ErrorDisplayWidget(
                            message: viewModel.errorMessage ??
                                'Failed to load payslips',
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
                                  'List All Payslips',
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
                                                Text('Payslip ID'),
                                                SizedBox(width: 4),
                                                Icon(Icons.swap_vert, size: 16),
                                              ],
                                            ),
                                          ),
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
                                                Text('Payment Amount'),
                                                SizedBox(width: 4),
                                                Icon(Icons.swap_vert, size: 16),
                                              ],
                                            ),
                                          ),
                                          DataColumn(
                                            label: Row(
                                              children: [
                                                Text('Month Payment'),
                                                SizedBox(width: 4),
                                                Icon(Icons.swap_vert, size: 16),
                                              ],
                                            ),
                                          ),
                                          DataColumn(
                                            label: Row(
                                              children: [
                                                Text('Created At'),
                                                SizedBox(width: 4),
                                                Icon(Icons.swap_vert, size: 16),
                                              ],
                                            ),
                                          ),
                                          DataColumn(
                                            label: Row(
                                              children: [
                                                Text('Payment Method'),
                                                SizedBox(width: 4),
                                                Icon(Icons.swap_vert, size: 16),
                                              ],
                                            ),
                                          ),
                                          DataColumn(
                                            label: Row(
                                              children: [
                                                Text('Payslips'),
                                                SizedBox(width: 4),
                                                Icon(Icons.swap_vert, size: 16),
                                              ],
                                            ),
                                          ),
                                        ],
                                        rows: _getPaginatedPayslips(viewModel)
                                            .map((payslip) {
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
                                                    Navigator.pushNamed(
                                                      context,
                                                      AppConstants
                                                          .routePayslipDetails,
                                                      arguments: {
                                                        'pay_id': payslip[
                                                                    'payslip_id']
                                                                ?.toString() ??
                                                            '',
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  payslip['payslip_id']
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
                                                  payslip['employee_id']
                                                          ?.toString() ??
                                                      'N/A',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  payslip['payment_amount'] !=
                                                              null &&
                                                          payslip['payment_amount']
                                                              .toString()
                                                              .isNotEmpty
                                                      ? '₹ ${payslip['payment_amount']}'
                                                      : 'N/A',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  payslip['month_payment']
                                                          ?.toString() ??
                                                      'N/A',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  payslip['created_at']
                                                          ?.toString() ??
                                                      'N/A',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  payslip['payment_method']
                                                          ?.toString() ??
                                                      'N/A',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ),
                                              DataCell(
                                                ElevatedButton.icon(
                                                  onPressed: () {
                                                    Navigator.pushNamed(
                                                      context,
                                                      AppConstants
                                                          .routeGeneratePayslips,
                                                      arguments: {
                                                        'payment_id': payslip[
                                                                    'payslip_id']
                                                                ?.toString() ??
                                                            '',
                                                      },
                                                    );
                                                  },
                                                  icon: const Icon(
                                                    Icons.add,
                                                    size: 16,
                                                  ),
                                                  label: const Text('Generate'),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.blue,
                                                    foregroundColor:
                                                        Colors.white,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 12,
                                                      vertical: 8,
                                                    ),
                                                    minimumSize:
                                                        const Size(0, 32),
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
                                    final filteredPayslips =
                                        _getFilteredPayslips(viewModel);
                                    final paginatedPayslips =
                                        _getPaginatedPayslips(viewModel);
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
                                                'Showing ${paginatedPayslips.isEmpty ? 0 : (_currentPage - 1) * _entriesPerPage + 1} to ${paginatedPayslips.isEmpty ? 0 : (_currentPage - 1) * _entriesPerPage + paginatedPayslips.length} of ${filteredPayslips.length} entries',
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
                                                  'Showing ${paginatedPayslips.isEmpty ? 0 : (_currentPage - 1) * _entriesPerPage + 1} to ${paginatedPayslips.isEmpty ? 0 : (_currentPage - 1) * _entriesPerPage + paginatedPayslips.length} of ${filteredPayslips.length} entries',
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
