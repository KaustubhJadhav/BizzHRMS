import 'package:flutter/material.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';
import 'package:bizzhrms_flutter_app/data/data_sources/remote_data_source.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/sidebar/sidebar_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/header/header_widget.dart';
import 'package:bizzhrms_flutter_app/core/constants/app_constants.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/back_button_widget.dart';

class PayslipDetailsPage extends StatefulWidget {
  const PayslipDetailsPage({super.key, required this.payId});

  final String payId;

  @override
  State<PayslipDetailsPage> createState() => _PayslipDetailsPageState();
}

class _PayslipDetailsPageState extends State<PayslipDetailsPage> {
  Map<String, dynamic>? _payslipData;
  bool _loading = true;
  String? _error;
  final RemoteDataSource _remoteDataSource = RemoteDataSource();

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final token = PreferencesHelper.getUserToken();
      if (token == null || token.isEmpty) {
        setState(() {
          _loading = false;
          _error = 'User not authenticated';
        });
        return;
      }

      final response = await _remoteDataSource.getPayslipDetails(
        token,
        null, // Cookie is optional
        widget.payId,
      );

      if (response['status'] == true && response['data'] != null) {
        setState(() {
          _payslipData = response['data'] as Map<String, dynamic>;
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
          _error = response['message']?.toString() ?? 'Failed to fetch payslip details';
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        drawer: const Drawer(
          child: SafeArea(
            child: SidebarWidget(currentRoute: AppConstants.routePayslips),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              const HeaderWidget(pageTitle: 'Payslip Details'),
              const BackButtonWidget(title: 'Payslip Details'),
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        drawer: const Drawer(
          child: SafeArea(
            child: SidebarWidget(currentRoute: AppConstants.routePayslips),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              const HeaderWidget(pageTitle: 'Payslip Details'),
              const BackButtonWidget(title: 'Payslip Details'),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _error!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF2C3E50),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _loading = true;
                                  _error = null;
                                });
                                _fetchDetails();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2C3E50),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_payslipData == null) {
      return Scaffold(
        drawer: const Drawer(
          child: SafeArea(
            child: SidebarWidget(currentRoute: AppConstants.routePayslips),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              const HeaderWidget(pageTitle: 'Payslip Details'),
              const BackButtonWidget(title: 'Payslip Details'),
              const Expanded(
                child: Center(child: Text('No details found')),
              ),
            ],
          ),
        ),
      );
    }

    final employee = _payslipData!['employee'] as Map<String, dynamic>?;
    final salary = _payslipData!['salary'] as Map<String, dynamic>?;
    final allowances = _payslipData!['allowances'] as Map<String, dynamic>?;
    final deductions = _payslipData!['deductions'] as Map<String, dynamic>?;
    final totalSalaryDetails = _payslipData!['total_salary_details'] as Map<String, dynamic>?;

    return Scaffold(
      drawer: const Drawer(
        child: SafeArea(
          child: SidebarWidget(currentRoute: AppConstants.routePayslips),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const HeaderWidget(pageTitle: 'Payslip Details'),
            const BackButtonWidget(title: 'Payslip Details'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Employee Information
                        if (employee != null)
                          _buildInfoCard(
                            title: 'Employee Information',
                            children: [
                              _buildInfoItem(
                                label: 'Employee ID',
                                value: employee['employee_id']?.toString() ?? 'N/A',
                              ),
                              _buildInfoItem(
                                label: 'Name',
                                value: employee['name']?.toString() ?? 'N/A',
                              ),
                              _buildInfoItem(
                                label: 'Department',
                                value: employee['department']?.toString() ?? 'N/A',
                              ),
                              _buildInfoItem(
                                label: 'Designation',
                                value: employee['designation']?.toString() ?? 'N/A',
                              ),
                              _buildInfoItem(
                                label: 'Date of Joining',
                                value: employee['date_of_joining']?.toString() ?? 'N/A',
                              ),
                            ],
                          ),

                        // Salary Information
                        if (salary != null)
                          _buildInfoCard(
                            title: 'Salary Information',
                            children: [
                              if (salary['month'] != null && salary['month'].toString().isNotEmpty)
                                _buildInfoItem(
                                  label: 'Month',
                                  value: salary['month'].toString(),
                                ),
                              _buildInfoItem(
                                label: 'Payment Status',
                                value: salary['payment_status']?.toString() ?? 'N/A',
                              ),
                              _buildInfoItem(
                                label: 'Payment Method',
                                value: salary['payment_method']?.toString() ?? 'N/A',
                              ),
                              if (salary['hourly_rate'] != null && salary['hourly_rate'].toString().isNotEmpty)
                                _buildInfoItem(
                                  label: 'Hourly Rate',
                                  value: '₹ ${salary['hourly_rate']}',
                                ),
                              if (salary['overtime_rate'] != null && salary['overtime_rate'].toString().isNotEmpty)
                                _buildInfoItem(
                                  label: 'Overtime Rate',
                                  value: '₹ ${salary['overtime_rate']}',
                                ),
                              if (salary['total_hours_work'] != null && salary['total_hours_work'].toString().isNotEmpty)
                                _buildInfoItem(
                                  label: 'Total Hours Work',
                                  value: salary['total_hours_work'].toString(),
                                ),
                              if (salary['comments'] != null && salary['comments'].toString().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Comments',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        salary['comments'].toString(),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF2C3E50),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),

                        // Allowances
                        if (allowances != null)
                          _buildInfoCard(
                            title: 'Allowances',
                            children: [
                              _buildInfoItem(
                                label: 'House Rent Allowance',
                                value: allowances['house_rent_allowance'] != null && allowances['house_rent_allowance'].toString().isNotEmpty
                                    ? '₹ ${allowances['house_rent_allowance']}'
                                    : '₹ 0',
                              ),
                              _buildInfoItem(
                                label: 'Medical Allowance',
                                value: allowances['medical_allowance'] != null && allowances['medical_allowance'].toString().isNotEmpty
                                    ? '₹ ${allowances['medical_allowance']}'
                                    : '₹ 0',
                              ),
                              _buildInfoItem(
                                label: 'Travelling Allowance',
                                value: allowances['travelling_allowance'] != null && allowances['travelling_allowance'].toString().isNotEmpty
                                    ? '₹ ${allowances['travelling_allowance']}'
                                    : '₹ 0',
                              ),
                              _buildInfoItem(
                                label: 'Dearness Allowance',
                                value: allowances['dearness_allowance'] != null && allowances['dearness_allowance'].toString().isNotEmpty
                                    ? '₹ ${allowances['dearness_allowance']}'
                                    : '₹ 0',
                              ),
                              if (allowances['special_allowance'] != null && allowances['special_allowance'].toString().isNotEmpty)
                                _buildInfoItem(
                                  label: 'Special Allowance',
                                  value: '₹ ${allowances['special_allowance']}',
                                ),
                            ],
                          ),

                        // Deductions
                        if (deductions != null)
                          _buildInfoCard(
                            title: 'Deductions',
                            children: [
                              if (deductions['provident_fund'] != null && deductions['provident_fund'].toString().isNotEmpty)
                                _buildInfoItem(
                                  label: 'Provident Fund',
                                  value: '₹ ${deductions['provident_fund']}',
                                ),
                              _buildInfoItem(
                                label: 'ESIC Deduction',
                                value: deductions['esic_deduction'] != null && deductions['esic_deduction'].toString().isNotEmpty
                                    ? '₹ ${deductions['esic_deduction']}'
                                    : '₹ 0',
                              ),
                              _buildInfoItem(
                                label: 'Tax Deduction',
                                value: deductions['tax_deduction'] != null && deductions['tax_deduction'].toString().isNotEmpty
                                    ? '₹ ${deductions['tax_deduction']}'
                                    : '₹ 0',
                              ),
                              _buildInfoItem(
                                label: 'Security Deposit',
                                value: deductions['security_deposit'] != null && deductions['security_deposit'].toString().isNotEmpty
                                    ? '₹ ${deductions['security_deposit']}'
                                    : '₹ 0',
                              ),
                              _buildInfoItem(
                                label: 'LWF Deduction',
                                value: deductions['lwf_deduction'] != null && deductions['lwf_deduction'].toString().isNotEmpty
                                    ? '₹ ${deductions['lwf_deduction']}'
                                    : '₹ 0',
                              ),
                            ],
                          ),

                        // Total Salary Details
                        if (totalSalaryDetails != null)
                          _buildInfoCard(
                            title: 'Total Salary Details',
                            children: [
                              _buildInfoItem(
                                label: 'Gross Salary',
                                value: totalSalaryDetails['gross_salary'] != null && totalSalaryDetails['gross_salary'].toString().isNotEmpty
                                    ? '₹ ${totalSalaryDetails['gross_salary']}'
                                    : 'N/A',
                              ),
                              _buildInfoItem(
                                label: 'Total Allowances',
                                value: totalSalaryDetails['total_allowances'] != null && totalSalaryDetails['total_allowances'].toString().isNotEmpty
                                    ? '₹ ${totalSalaryDetails['total_allowances']}'
                                    : '₹ 0',
                              ),
                              _buildInfoItem(
                                label: 'Total Deductions',
                                value: totalSalaryDetails['total_deductions'] != null && totalSalaryDetails['total_deductions'].toString().isNotEmpty
                                    ? '₹ ${totalSalaryDetails['total_deductions']}'
                                    : '₹ 0',
                              ),
                              if (totalSalaryDetails['advance_salary_deducted'] != null)
                                _buildInfoItem(
                                  label: 'Advance Salary Deducted',
                                  value: '₹ ${totalSalaryDetails['advance_salary_deducted']}',
                                ),
                              const Divider(height: 32),
                              _buildInfoItem(
                                label: 'Net Salary',
                                value: totalSalaryDetails['net_salary'] != null && totalSalaryDetails['net_salary'].toString().isNotEmpty
                                    ? '₹ ${totalSalaryDetails['net_salary']}'
                                    : 'N/A',
                              ),
                              _buildInfoItem(
                                label: 'Paid Amount',
                                value: totalSalaryDetails['paid_amount'] != null && totalSalaryDetails['paid_amount'].toString().isNotEmpty
                                    ? '₹ ${totalSalaryDetails['paid_amount']}'
                                    : 'N/A',
                              ),
                              if (totalSalaryDetails['hourly_salary_total'] != null && totalSalaryDetails['hourly_salary_total'] != 0)
                                _buildInfoItem(
                                  label: 'Hourly Salary Total',
                                  value: '₹ ${totalSalaryDetails['hourly_salary_total']}',
                                ),
                              if (totalSalaryDetails['payment_method'] != null && totalSalaryDetails['payment_method'].toString().isNotEmpty)
                                _buildInfoItem(
                                  label: 'Payment Method',
                                  value: totalSalaryDetails['payment_method'].toString(),
                                ),
                              if (totalSalaryDetails['comments'] != null && totalSalaryDetails['comments'].toString().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Comments',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        totalSalaryDetails['comments'].toString(),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF2C3E50),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

