import 'package:flutter/material.dart';
import 'package:bizzhrms_flutter_app/presentation/complaints/view_model/complaints_view_model.dart';

class ComplaintDetailsPage extends StatefulWidget {
  const ComplaintDetailsPage(
      {super.key, required this.complaintId, this.initialComplaint});

  final String complaintId;
  final Map<String, dynamic>? initialComplaint;

  @override
  State<ComplaintDetailsPage> createState() => _ComplaintDetailsPageState();
}

class _ComplaintDetailsPageState extends State<ComplaintDetailsPage> {
  Map<String, dynamic>? _complaint;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _complaint = widget.initialComplaint;
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final viewModel = ComplaintsViewModel();
    try {
      final details = await viewModel.getComplaintDetails(widget.complaintId);
      setState(() {
        // API returns data as array, get first item
        if (details != null && details is List && details.isNotEmpty) {
          final firstItem = details[0];
          if (firstItem is Map) {
            _complaint = Map<String, dynamic>.from(firstItem);
          } else {
            _complaint = widget.initialComplaint;
          }
        } else if (details != null && details is Map) {
          _complaint = Map<String, dynamic>.from(details);
        } else {
          _complaint = widget.initialComplaint;
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
        appBar: AppBar(title: const Text('Complaint Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Complaint Details')),
        body: Center(child: Text(_error!)),
      );
    }
    if (_complaint == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Complaint Details')),
        body: const Center(child: Text('No details found')),
      );
    }

    // Handle complaint_against as array
    String complaintAgainst = '';
    if (_complaint!['complaint_against'] != null) {
      if (_complaint!['complaint_against'] is List) {
        complaintAgainst = (_complaint!['complaint_against'] as List)
            .map((e) => e.toString())
            .join(', ');
      } else {
        complaintAgainst = _complaint!['complaint_against'].toString();
      }
    }

    // Get approval status color
    final approvalStatus = _complaint!['approval_status']?.toString() ?? 'N/A';
    Color statusColor;
    switch (approvalStatus.toLowerCase()) {
      case 'approved':
        statusColor = Colors.green;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Complaint Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Complaint Title Card
                _InfoCard(
                  icon: Icons.gavel_rounded,
                  title: 'Complaint Title',
                  value: _complaint!['complaint_title']?.toString() ?? 'N/A',
                  theme: theme,
                ),

                // Complaint Information Card
                _InfoCard(
                  icon: Icons.info_rounded,
                  title: 'Complaint Information',
                  theme: theme,
                  children: [
                    _InfoItem(
                      label: 'Complaint From',
                      value: _complaint!['complaint_from']?.toString() ?? 'N/A',
                      icon: Icons.person_rounded,
                      theme: theme,
                    ),
                    const SizedBox(height: 12),
                    _InfoItem(
                      label: 'Complaint Against',
                      value: complaintAgainst.isEmpty ? 'N/A' : complaintAgainst,
                      icon: Icons.person_off_rounded,
                      theme: theme,
                    ),
                    const SizedBox(height: 12),
                    _InfoItem(
                      label: 'Complaint Date',
                      value: _complaint!['complaint_date']?.toString() ?? 'N/A',
                      icon: Icons.calendar_month_rounded,
                      theme: theme,
                    ),
                    if (_complaint!['created_at'] != null) ...[
                      const SizedBox(height: 12),
                      _InfoItem(
                        label: 'Created At',
                        value: _complaint!['created_at']?.toString() ?? 'N/A',
                        icon: Icons.access_time_rounded,
                        theme: theme,
                      ),
                    ],
                    if (_complaint!['complaint_id'] != null) ...[
                      const SizedBox(height: 12),
                      _InfoItem(
                        label: 'Complaint ID',
                        value: _complaint!['complaint_id']?.toString() ?? 'N/A',
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
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: statusColor, width: 1),
                                ),
                                child: Text(
                                  approvalStatus,
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
                if (_complaint!['description'] != null &&
                    _complaint!['description'].toString().isNotEmpty)
                  _InfoCard(
                    icon: Icons.description_rounded,
                    title: 'Description',
                    theme: theme,
                    value: _complaint!['description']?.toString() ?? 'N/A',
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

