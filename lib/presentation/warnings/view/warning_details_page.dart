import 'package:flutter/material.dart';
import 'package:bizzhrms_flutter_app/presentation/warnings/view_model/warnings_view_model.dart';

class WarningDetailsPage extends StatefulWidget {
  const WarningDetailsPage(
      {super.key, required this.warningId, this.initialWarning});

  final String warningId;
  final Map<String, dynamic>? initialWarning;

  @override
  State<WarningDetailsPage> createState() => _WarningDetailsPageState();
}

class _WarningDetailsPageState extends State<WarningDetailsPage> {
  Map<String, dynamic>? _warning;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _warning = widget.initialWarning;
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final viewModel = WarningsViewModel();
    try {
      final details = await viewModel.getWarningDetails(widget.warningId);
      setState(() {
        // API returns data as array, get first item
        if (details != null && details is List && details.isNotEmpty) {
          final firstItem = details[0];
          if (firstItem is Map) {
            _warning = Map<String, dynamic>.from(firstItem);
          } else {
            _warning = widget.initialWarning;
          }
        } else if (details != null && details is Map) {
          _warning = Map<String, dynamic>.from(details);
        } else {
          _warning = widget.initialWarning;
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
        appBar: AppBar(title: const Text('Warning Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Warning Details')),
        body: Center(child: Text(_error!)),
      );
    }
    if (_warning == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Warning Details')),
        body: const Center(child: Text('No details found')),
      );
    }

    // Get approval status color
    final approvalStatus = _warning!['approval_status']?.toString() ?? 'N/A';
    Color approvalStatusColor;
    switch (approvalStatus.toLowerCase()) {
      case 'approved':
        approvalStatusColor = Colors.green;
        break;
      case 'pending':
        approvalStatusColor = Colors.orange;
        break;
      case 'rejected':
        approvalStatusColor = Colors.red;
        break;
      default:
        approvalStatusColor = Colors.grey;
    }

    // Get warning type color
    final warningType = _warning!['warning_type']?.toString() ?? 'N/A';
    final viewModel = WarningsViewModel();
    final warningTypeColor = viewModel.getWarningTypeColor(warningType);

    return Scaffold(
      appBar: AppBar(title: const Text('Warning Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Warning Subject Card
                _InfoCard(
                  icon: Icons.warning_rounded,
                  title: 'Warning Subject',
                  value: _warning!['subject']?.toString() ?? 'N/A',
                  theme: theme,
                ),

                // Warning Information Card
                _InfoCard(
                  icon: Icons.info_rounded,
                  title: 'Warning Information',
                  theme: theme,
                  children: [
                    _InfoItem(
                      label: 'Warning Date',
                      value: _warning!['warning_date']?.toString() ?? 'N/A',
                      icon: Icons.calendar_month_rounded,
                      theme: theme,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.category_rounded,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Warning Type',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: warningTypeColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: warningTypeColor, width: 1),
                                ),
                                child: Text(
                                  warningType,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: warningTypeColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _InfoItem(
                      label: 'Warning By',
                      value: _warning!['warning_by']?.toString() ?? 'N/A',
                      icon: Icons.person_rounded,
                      theme: theme,
                    ),
                    if (_warning!['created_at'] != null) ...[
                      const SizedBox(height: 12),
                      _InfoItem(
                        label: 'Created At',
                        value: _warning!['created_at']?.toString() ?? 'N/A',
                        icon: Icons.access_time_rounded,
                        theme: theme,
                      ),
                    ],
                    if (_warning!['warning_id'] != null) ...[
                      const SizedBox(height: 12),
                      _InfoItem(
                        label: 'Warning ID',
                        value: _warning!['warning_id']?.toString() ?? 'N/A',
                        icon: Icons.tag_rounded,
                        theme: theme,
                      ),
                    ],
                  ],
                ),

                // Approval Status Card
                _InfoCard(
                  icon: Icons.verified_rounded,
                  title: 'Approval Status',
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
                                  color: approvalStatusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: approvalStatusColor, width: 1),
                                ),
                                child: Text(
                                  approvalStatus,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: approvalStatusColor,
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
                if (_warning!['description'] != null &&
                    _warning!['description'].toString().isNotEmpty)
                  _InfoCard(
                    icon: Icons.description_rounded,
                    title: 'Description',
                    theme: theme,
                    value: _warning!['description']?.toString() ?? 'N/A',
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

