import 'package:flutter/material.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/sidebar/sidebar_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/header/header_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/back_button_widget.dart';
import 'package:bizzhrms_flutter_app/core/constants/app_constants.dart';

class PayrollPage extends StatelessWidget {
  const PayrollPage({super.key});

  Widget _buildNavigationCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String route,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: SidebarWidget(currentRoute: AppConstants.routePayroll),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const HeaderWidget(pageTitle: 'Payroll'),
            const BackButtonWidget(title: 'Payroll'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 600 ? 3 : 1;
                    final childAspectRatio = constraints.maxWidth > 600 ? 1.0 : 2.5;

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: childAspectRatio,
                      children: [
                        _buildNavigationCard(
                          context,
                          title: 'Payslips',
                          icon: Icons.receipt,
                          route: AppConstants.routePayslips,
                          color: Colors.blue,
                        ),
                        _buildNavigationCard(
                          context,
                          title: 'Advance Salary',
                          icon: Icons.account_balance_wallet,
                          route: AppConstants.routeAdvanceSalary,
                          color: Colors.green,
                        ),
                        _buildNavigationCard(
                          context,
                          title: 'Advance Salary Report',
                          icon: Icons.assessment,
                          route: AppConstants.routeAdvanceSalaryReport,
                          color: Colors.orange,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

