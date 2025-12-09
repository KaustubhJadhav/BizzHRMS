import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../view_model/generate_payslips_view_model.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/sidebar/sidebar_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/header/header_widget.dart';
import 'package:bizzhrms_flutter_app/core/constants/app_constants.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/back_button_widget.dart';

class GeneratePayslipsPage extends StatefulWidget {
  const GeneratePayslipsPage({super.key, this.paymentId});

  final String? paymentId;

  @override
  State<GeneratePayslipsPage> createState() => _GeneratePayslipsPageState();
}

class _GeneratePayslipsPageState extends State<GeneratePayslipsPage> {
  final _formKey = GlobalKey<FormState>();
  final _paymentIdController = TextEditingController();
  late final GeneratePayslipsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = GeneratePayslipsViewModel();
    if (widget.paymentId != null && widget.paymentId!.isNotEmpty) {
      _paymentIdController.text = widget.paymentId!;
      // Auto-generate payslip if paymentId is provided
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _viewModel.generatePayslip(paymentId: widget.paymentId!);
      });
    }
  }

  @override
  void dispose() {
    _paymentIdController.dispose();
    super.dispose();
  }

  Future<void> _downloadPayslip(String url) async {
    try {
      final uri = Uri.parse(url);
      // Try to launch URL directly without checking first
      // This avoids the platform channel error with canLaunchUrl
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open PDF link')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening PDF: ${e.toString()}'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
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
    return ChangeNotifierProvider(
      create: (_) => _viewModel,
      child: Scaffold(
        drawer: const Drawer(
          child: SafeArea(
            child:
                SidebarWidget(currentRoute: AppConstants.routeGeneratePayslips),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              const HeaderWidget(pageTitle: 'Generate Payslips'),
              const BackButtonWidget(title: 'Generate Payslips'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Consumer<GeneratePayslipsViewModel>(
                        builder: (context, viewModel, child) {
                          if (viewModel.status ==
                              GeneratePayslipsStatus.loading) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (viewModel.status ==
                              GeneratePayslipsStatus.error) {
                            return Card(
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
                                      viewModel.errorMessage ??
                                          'Failed to generate payslip',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF2C3E50),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                      onPressed: () {
                                        viewModel.reset();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF2C3E50),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                      ),
                                      child: const Text('Try Again'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          if (viewModel.status ==
                                  GeneratePayslipsStatus.success &&
                              viewModel.payslipData != null) {
                            final data = viewModel.payslipData!;
                            final employee =
                                data['employee'] as Map<String, dynamic>?;
                            final payslip =
                                data['payslip'] as Map<String, dynamic>?;
                            final downloadLink =
                                data['payslip_download_link']?.toString();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Download Button
                                if (downloadLink != null &&
                                    downloadLink.isNotEmpty)
                                  Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Payslip PDF',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF2C3E50),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Click the button below to download your payslip',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          ElevatedButton.icon(
                                            onPressed: () =>
                                                _downloadPayslip(downloadLink),
                                            icon: const Icon(Icons.download),
                                            label: const Text('Download PDF'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 24,
                                                vertical: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                // Employee Information
                                if (employee != null)
                                  _buildInfoCard(
                                    title: 'Employee Information',
                                    children: [
                                      _buildInfoItem(
                                        label: 'Employee ID',
                                        value: employee['employee_id']
                                                ?.toString() ??
                                            'N/A',
                                      ),
                                      _buildInfoItem(
                                        label: 'Name',
                                        value: '${employee['first_name'] ?? ''} ${employee['last_name'] ?? ''}'
                                                .trim()
                                                .isEmpty
                                            ? 'N/A'
                                            : '${employee['first_name'] ?? ''} ${employee['last_name'] ?? ''}'
                                                .trim(),
                                      ),
                                      _buildInfoItem(
                                        label: 'Contact No',
                                        value: employee['contact_no']
                                                ?.toString() ??
                                            'N/A',
                                      ),
                                      _buildInfoItem(
                                        label: 'Date of Joining',
                                        value: employee['date_of_joining']
                                                ?.toString() ??
                                            'N/A',
                                      ),
                                      _buildInfoItem(
                                        label: 'Department',
                                        value: employee['department_name']
                                                ?.toString() ??
                                            'N/A',
                                      ),
                                      _buildInfoItem(
                                        label: 'Designation',
                                        value: employee['designation_name']
                                                ?.toString() ??
                                            'N/A',
                                      ),
                                    ],
                                  ),

                                // Payslip Details
                                if (payslip != null)
                                  _buildInfoCard(
                                    title: 'Payslip Details',
                                    children: [
                                      _buildInfoItem(
                                        label: 'Payment ID',
                                        value: payslip['make_payment_id']
                                                ?.toString() ??
                                            'N/A',
                                      ),
                                      _buildInfoItem(
                                        label: 'Payment Date',
                                        value: payslip['payment_date']
                                                ?.toString() ??
                                            'N/A',
                                      ),
                                      _buildInfoItem(
                                        label: 'Payment Method',
                                        value: payslip['payment_method']
                                                ?.toString() ??
                                            'N/A',
                                      ),
                                      const Divider(height: 32),
                                      const Text(
                                        'Salary Breakdown',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2C3E50),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      _buildInfoItem(
                                        label: 'Basic Salary',
                                        value:
                                            payslip['basic_salary'] != null &&
                                                    payslip['basic_salary']
                                                        .toString()
                                                        .isNotEmpty
                                                ? '₹ ${payslip['basic_salary']}'
                                                : 'N/A',
                                      ),
                                      _buildInfoItem(
                                        label: 'House Rent Allowance',
                                        value: payslip['house_rent_allowance'] !=
                                                    null &&
                                                payslip['house_rent_allowance']
                                                    .toString()
                                                    .isNotEmpty
                                            ? '₹ ${payslip['house_rent_allowance']}'
                                            : '₹ 0',
                                      ),
                                      _buildInfoItem(
                                        label: 'Medical Allowance',
                                        value: payslip['medical_allowance'] !=
                                                    null &&
                                                payslip['medical_allowance']
                                                    .toString()
                                                    .isNotEmpty
                                            ? '₹ ${payslip['medical_allowance']}'
                                            : '₹ 0',
                                      ),
                                      _buildInfoItem(
                                        label: 'Travelling Allowance',
                                        value: payslip['travelling_allowance'] !=
                                                    null &&
                                                payslip['travelling_allowance']
                                                    .toString()
                                                    .isNotEmpty
                                            ? '₹ ${payslip['travelling_allowance']}'
                                            : '₹ 0',
                                      ),
                                      _buildInfoItem(
                                        label: 'Dearness Allowance',
                                        value: payslip['dearness_allowance'] !=
                                                    null &&
                                                payslip['dearness_allowance']
                                                    .toString()
                                                    .isNotEmpty
                                            ? '₹ ${payslip['dearness_allowance']}'
                                            : '₹ 0',
                                      ),
                                      _buildInfoItem(
                                        label: 'Conveyance Allowance',
                                        value: payslip['conveyance_allowance'] !=
                                                    null &&
                                                payslip['conveyance_allowance']
                                                    .toString()
                                                    .isNotEmpty
                                            ? '₹ ${payslip['conveyance_allowance']}'
                                            : '₹ 0',
                                      ),
                                      _buildInfoItem(
                                        label: 'Education Allowance',
                                        value: payslip['education_allowance'] !=
                                                    null &&
                                                payslip['education_allowance']
                                                    .toString()
                                                    .isNotEmpty
                                            ? '₹ ${payslip['education_allowance']}'
                                            : '₹ 0',
                                      ),
                                      if (payslip['telephone_allowance'] !=
                                          null)
                                        _buildInfoItem(
                                          label: 'Telephone Allowance',
                                          value: payslip['telephone_allowance']
                                                  .toString()
                                                  .isNotEmpty
                                              ? '₹ ${payslip['telephone_allowance']}'
                                              : '₹ 0',
                                        ),
                                      if (payslip['other_allowance'] != null)
                                        _buildInfoItem(
                                          label: 'Other Allowance',
                                          value: payslip['other_allowance']
                                                  .toString()
                                                  .isNotEmpty
                                              ? '₹ ${payslip['other_allowance']}'
                                              : '₹ 0',
                                        ),
                                      if (payslip['special_allowance'] !=
                                              null &&
                                          payslip['special_allowance']
                                              .toString()
                                              .isNotEmpty)
                                        _buildInfoItem(
                                          label: 'Special Allowance',
                                          value:
                                              '₹ ${payslip['special_allowance']}',
                                        ),
                                      const Divider(height: 32),
                                      const Text(
                                        'Deductions',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2C3E50),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      _buildInfoItem(
                                        label: 'Provident Fund',
                                        value: payslip['provident_fund'] !=
                                                    null &&
                                                payslip['provident_fund']
                                                    .toString()
                                                    .isNotEmpty
                                            ? '₹ ${payslip['provident_fund']}'
                                            : '₹ 0',
                                      ),
                                      _buildInfoItem(
                                        label: 'ESIC Deduction',
                                        value: payslip['esic_deduction'] !=
                                                    null &&
                                                payslip['esic_deduction']
                                                    .toString()
                                                    .isNotEmpty
                                            ? '₹ ${payslip['esic_deduction']}'
                                            : '₹ 0',
                                      ),
                                      _buildInfoItem(
                                        label: 'Security Deposit',
                                        value: payslip['security_deposit'] !=
                                                    null &&
                                                payslip['security_deposit']
                                                    .toString()
                                                    .isNotEmpty
                                            ? '₹ ${payslip['security_deposit']}'
                                            : '₹ 0',
                                      ),
                                      _buildInfoItem(
                                        label: 'LWF Deduction',
                                        value: payslip['lwf_deduction'] !=
                                                    null &&
                                                payslip['lwf_deduction']
                                                    .toString()
                                                    .isNotEmpty
                                            ? '₹ ${payslip['lwf_deduction']}'
                                            : '₹ 0',
                                      ),
                                      _buildInfoItem(
                                        label: 'Tax Deduction',
                                        value: payslip['tax_deduction'] !=
                                                    null &&
                                                payslip['tax_deduction']
                                                    .toString()
                                                    .isNotEmpty
                                            ? '₹ ${payslip['tax_deduction']}'
                                            : '₹ 0',
                                      ),
                                      if (payslip['advance_salary_amount'] !=
                                              null &&
                                          payslip['advance_salary_amount']
                                                  .toString() !=
                                              '0')
                                        _buildInfoItem(
                                          label: 'Advance Salary',
                                          value:
                                              '₹ ${payslip['advance_salary_amount']}',
                                        ),
                                      const Divider(height: 32),
                                      _buildInfoItem(
                                        label: 'Total Allowances',
                                        value: payslip['total_allowances'] !=
                                                    null &&
                                                payslip['total_allowances']
                                                    .toString()
                                                    .isNotEmpty
                                            ? '₹ ${payslip['total_allowances']}'
                                            : '₹ 0',
                                      ),
                                      _buildInfoItem(
                                        label: 'Total Deductions',
                                        value: payslip['total_deductions'] !=
                                                    null &&
                                                payslip['total_deductions']
                                                    .toString()
                                                    .isNotEmpty
                                            ? '₹ ${payslip['total_deductions']}'
                                            : '₹ 0',
                                      ),
                                      _buildInfoItem(
                                        label: 'Gross Salary',
                                        value:
                                            payslip['gross_salary'] != null &&
                                                    payslip['gross_salary']
                                                        .toString()
                                                        .isNotEmpty
                                                ? '₹ ${payslip['gross_salary']}'
                                                : 'N/A',
                                      ),
                                      const Divider(height: 16),
                                      _buildInfoItem(
                                        label: 'Net Salary',
                                        value: payslip['net_salary'] != null &&
                                                payslip['net_salary']
                                                    .toString()
                                                    .isNotEmpty
                                            ? '₹ ${payslip['net_salary']}'
                                            : 'N/A',
                                      ),
                                      if (payslip['comments'] != null &&
                                          payslip['comments']
                                              .toString()
                                              .isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                                payslip['comments'].toString(),
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

                                // Generate New Button
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 16, bottom: 32),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      viewModel.reset();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2C3E50),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                    ),
                                    child: const Text('Generate New Payslip'),
                                  ),
                                ),
                              ],
                            );
                          }

                          // Initial form state - only show if paymentId is not provided
                          if (widget.paymentId != null &&
                              widget.paymentId!.isNotEmpty) {
                            // If paymentId is provided, show loading while generating
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          // Show form only when no paymentId is provided
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Generate Payslip',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2C3E50),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Enter the Payment ID to generate payslip',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    TextFormField(
                                      controller: _paymentIdController,
                                      decoration: const InputDecoration(
                                        labelText: 'Payment ID',
                                        hintText: 'Enter payment ID',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.payment),
                                      ),
                                      keyboardType: TextInputType.text,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter payment ID';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            viewModel.generatePayslip(
                                              paymentId: _paymentIdController
                                                  .text
                                                  .trim(),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF2C3E50),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 16,
                                          ),
                                        ),
                                        child: const Text(
                                          'Generate Payslip',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
