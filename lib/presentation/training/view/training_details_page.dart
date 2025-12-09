import 'package:flutter/material.dart';
import 'package:bizzhrms_flutter_app/presentation/training/view_model/training_view_model.dart';

class TrainingDetailsPage extends StatefulWidget {
  const TrainingDetailsPage(
      {super.key, required this.trainingId, this.initialTraining});

  final String trainingId;
  final Map<String, dynamic>? initialTraining;

  @override
  State<TrainingDetailsPage> createState() => _TrainingDetailsPageState();
}

class _TrainingDetailsPageState extends State<TrainingDetailsPage> {
  Map<String, dynamic>? _training;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _training = widget.initialTraining;
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final viewModel = TrainingViewModel();
    try {
      final details = await viewModel.getTrainingDetails(widget.trainingId);
      setState(() {
        if (details != null && details is Map) {
          _training = Map<String, dynamic>.from(details);
        } else {
          _training = widget.initialTraining;
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

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Training Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Training Details')),
        body: Center(child: Text(_error!)),
      );
    }
    if (_training == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Training Details')),
        body: const Center(child: Text('No details found')),
      );
    }

    // Get training status color
    final status = _training!['training_status']?.toString() ?? _training!['status']?.toString() ?? 'N/A';
    final viewModel = TrainingViewModel();
    final statusColor = viewModel.getStatusColor(status);

    // Extract employee names from employees array
    String employeeNames = 'N/A';
    if (_training!['employees'] != null && _training!['employees'] is List) {
      final employees = _training!['employees'] as List;
      employeeNames = employees
          .map((emp) {
            if (emp is Map) {
              return emp['name']?.toString() ?? '';
            }
            return '';
          })
          .where((name) => name.isNotEmpty)
          .join(', ');
      if (employeeNames.isEmpty) {
        employeeNames = 'N/A';
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Training Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Training Type Card
                _InfoCard(
                  icon: Icons.school_rounded,
                  title: 'Training Type',
                  value: _training!['training_type_id']?.toString() ?? 'N/A',
                  theme: theme,
                ),

                // Training Information Card
                _InfoCard(
                  icon: Icons.info_rounded,
                  title: 'Training Information',
                  theme: theme,
                  children: [
                    _InfoItem(
                      label: 'Trainer Name',
                      value: _training!['trainer_name']?.toString() ?? 'N/A',
                      icon: Icons.person_rounded,
                      theme: theme,
                    ),
                    const SizedBox(height: 12),
                    _InfoItem(
                      label: 'Start Date',
                      value: _training!['start_date']?.toString() ?? 'N/A',
                      icon: Icons.calendar_today_rounded,
                      theme: theme,
                    ),
                    const SizedBox(height: 12),
                    _InfoItem(
                      label: 'Finish Date',
                      value: _training!['finish_date']?.toString() ?? 'N/A',
                      icon: Icons.event_rounded,
                      theme: theme,
                    ),
                    const SizedBox(height: 12),
                    _InfoItem(
                      label: 'Created Date',
                      value: _training!['created_date']?.toString() ?? 'N/A',
                      icon: Icons.access_time_rounded,
                      theme: theme,
                    ),
                    if (_training!['training_id'] != null) ...[
                      const SizedBox(height: 12),
                      _InfoItem(
                        label: 'Training ID',
                        value: _training!['training_id']?.toString() ?? 'N/A',
                        icon: Icons.tag_rounded,
                        theme: theme,
                      ),
                    ],
                    if (_training!['employee_id'] != null) ...[
                      const SizedBox(height: 12),
                      _InfoItem(
                        label: 'Employee ID',
                        value: _training!['employee_id']?.toString() ?? 'N/A',
                        icon: Icons.badge_rounded,
                        theme: theme,
                      ),
                    ],
                  ],
                ),

                // Employees Card
                _InfoCard(
                  icon: Icons.people_rounded,
                  title: 'Employees',
                  value: employeeNames,
                  theme: theme,
                ),

                // Cost Information Card
                _InfoCard(
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'Training Cost',
                  theme: theme,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.currency_rupee,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cost',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _training!['training_cost']?.toString() ?? 'N/A',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Status Card
                _InfoCard(
                  icon: Icons.verified_rounded,
                  title: 'Training Status',
                  theme: theme,
                  children: [
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: statusColor, width: 1),
                                ),
                                child: Text(
                                  status,
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
                  ],
                ),

                // Description Section
                if (_training!['description'] != null &&
                    _training!['description'].toString().isNotEmpty)
                  _InfoCard(
                    icon: Icons.description_rounded,
                    title: 'Description',
                    theme: theme,
                    value: _training!['description']?.toString() ?? 'N/A',
                  ),

                // Performance Section
                if (_training!['performance'] != null &&
                    _training!['performance'].toString().isNotEmpty)
                  _InfoCard(
                    icon: Icons.trending_up_rounded,
                    title: 'Performance',
                    theme: theme,
                    value: _training!['performance']?.toString() ?? 'N/A',
                  ),

                // Remarks Section
                if (_training!['remarks'] != null &&
                    _training!['remarks'].toString().isNotEmpty)
                  _InfoCard(
                    icon: Icons.note_rounded,
                    title: 'Remarks',
                    theme: theme,
                    value: _training!['remarks']?.toString() ?? 'N/A',
                  ),
              ],
            ),
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

