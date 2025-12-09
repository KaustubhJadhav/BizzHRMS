import 'package:flutter/material.dart';
import 'package:bizzhrms_flutter_app/presentation/performance/view_model/performance_view_model.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/sidebar/sidebar_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/header/header_widget.dart';
import 'package:bizzhrms_flutter_app/core/constants/app_constants.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/back_button_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/loading_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/error_widget.dart';

class PerformanceDetailsPage extends StatefulWidget {
  const PerformanceDetailsPage(
      {super.key, required this.performanceAppraisalId, this.initialPerformance});

  final String performanceAppraisalId;
  final Map<String, dynamic>? initialPerformance;

  @override
  State<PerformanceDetailsPage> createState() => _PerformanceDetailsPageState();
}

class _PerformanceDetailsPageState extends State<PerformanceDetailsPage> {
  Map<String, dynamic>? _performance;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _performance = widget.initialPerformance;
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final viewModel = PerformanceViewModel();
    try {
      final details = await viewModel.getPerformanceDetails(widget.performanceAppraisalId);
      setState(() {
        if (details != null) {
          _performance = Map<String, dynamic>.from(details);
        } else {
          _performance = widget.initialPerformance;
        }
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const Drawer(
        child: SafeArea(
          child: SidebarWidget(currentRoute: AppConstants.routePerformance),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const HeaderWidget(pageTitle: 'Performance Details'),
            const BackButtonWidget(title: 'Performance Details'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildContent(theme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_loading) {
      return const LoadingWidget(message: 'Loading performance details...');
    }

    if (_error != null) {
      return ErrorDisplayWidget(
        message: _error!,
        onRetry: _fetchDetails,
      );
    }

    if (_performance == null) {
      return const Center(child: Text('No details found'));
    }

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Employee Information Card
              _InfoCard(
                icon: Icons.person_rounded,
                title: 'Employee Information',
                theme: theme,
                children: [
                  _InfoItem(
                    label: 'Employee ID',
                    value: _performance!['employee_id']?.toString() ?? 'N/A',
                    icon: Icons.badge_rounded,
                    theme: theme,
                  ),
                  const SizedBox(height: 12),
                  _InfoItem(
                    label: 'Employee Name',
                    value: _performance!['employee_name']?.toString() ?? 'N/A',
                    icon: Icons.person_outline_rounded,
                    theme: theme,
                  ),
                  const SizedBox(height: 12),
                  _InfoItem(
                    label: 'Employee Primary ID',
                    value: _performance!['employee_primary_id']?.toString() ?? 'N/A',
                    icon: Icons.credit_card_rounded,
                    theme: theme,
                  ),
                  const SizedBox(height: 12),
                  _InfoItem(
                    label: 'Appraisal Year & Month',
                    value: _performance!['appraisal_year_month']?.toString() ?? 'N/A',
                    icon: Icons.calendar_today_rounded,
                    theme: theme,
                  ),
                ],
              ),

              // Technical Competencies Card
              if (_performance!['technical_competencies'] != null &&
                  _performance!['technical_competencies'] is List &&
                  (_performance!['technical_competencies'] as List).isNotEmpty)
                _InfoCard(
                  icon: Icons.engineering_rounded,
                  title: 'Technical Competencies',
                  theme: theme,
                  children: [
                    ...((_performance!['technical_competencies'] as List).map((competency) {
                      final comp = competency as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: theme.colorScheme.outline.withOpacity(0.2),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comp['indicator']?.toString() ?? 'N/A',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _InfoItem(
                                        label: 'Expected Value',
                                        value: comp['expected_value']?.toString() ?? 'N/A',
                                        icon: Icons.trending_up_rounded,
                                        theme: theme,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _InfoItem(
                                        label: 'Selected Value',
                                        value: comp['selected_value']?.toString() ?? 'N/A',
                                        icon: Icons.check_circle_outline_rounded,
                                        theme: theme,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList()),
                  ],
                ),

              // Behavioral Competencies Card
              if (_performance!['behavioral_competencies'] != null &&
                  _performance!['behavioral_competencies'] is List &&
                  (_performance!['behavioral_competencies'] as List).isNotEmpty)
                _InfoCard(
                  icon: Icons.psychology_rounded,
                  title: 'Behavioral Competencies',
                  theme: theme,
                  children: [
                    ...((_performance!['behavioral_competencies'] as List).map((competency) {
                      final comp = competency as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: theme.colorScheme.outline.withOpacity(0.2),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comp['indicator']?.toString() ?? 'N/A',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _InfoItem(
                                        label: 'Expected Value',
                                        value: comp['expected_value']?.toString() ?? 'N/A',
                                        icon: Icons.trending_up_rounded,
                                        theme: theme,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _InfoItem(
                                        label: 'Selected Value',
                                        value: comp['selected_value']?.toString() ?? 'N/A',
                                        icon: Icons.check_circle_outline_rounded,
                                        theme: theme,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList()),
                  ],
                ),

              // Remarks Card
              if (_performance!['remarks'] != null &&
                  _performance!['remarks'].toString().isNotEmpty)
                _InfoCard(
                  icon: Icons.note_rounded,
                  title: 'Remarks',
                  value: _performance!['remarks']?.toString() ?? 'N/A',
                  theme: theme,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.theme,
    this.value,
    this.children,
  });

  final IconData icon;
  final String title;
  final ThemeData theme;
  final String? value;
  final List<Widget>? children;

  @override
  Widget build(BuildContext context) {
    return Card(
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
                  icon,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            if (value != null) ...[
              const SizedBox(height: 8),
              Text(
                value!,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
            if (children != null) ...[
              const SizedBox(height: 16),
              ...children!,
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.theme,
  });

  final String label;
  final String value;
  final IconData icon;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
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
}

