import 'package:flutter/material.dart';
import 'package:bizzhrms_flutter_app/presentation/travels/view_model/travels_view_model.dart';

class TravelDetailsPage extends StatefulWidget {
  const TravelDetailsPage(
      {super.key, required this.travelId, this.initialTravel});

  final String travelId;
  final Map<String, dynamic>? initialTravel;

  @override
  State<TravelDetailsPage> createState() => _TravelDetailsPageState();
}

class _TravelDetailsPageState extends State<TravelDetailsPage> {
  Map<String, dynamic>? _travel;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _travel = widget.initialTravel;
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final viewModel = TravelsViewModel();
    try {
      final details = await viewModel.getTravelDetails(widget.travelId);
      setState(() {
        if (details != null && details is Map) {
          _travel = Map<String, dynamic>.from(details);
        } else {
          _travel = widget.initialTravel;
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
        appBar: AppBar(title: const Text('Travel Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Travel Details')),
        body: Center(child: Text(_error!)),
      );
    }
    if (_travel == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Travel Details')),
        body: const Center(child: Text('No details found')),
      );
    }

    // Get approval status color
    final status = _travel!['status']?.toString() ?? _travel!['approval_status']?.toString() ?? 'N/A';
    Color statusColor;
    switch (status.toLowerCase()) {
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
      appBar: AppBar(title: const Text('Travel Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Travel Purpose Card
                _InfoCard(
                  icon: Icons.flight_takeoff_rounded,
                  title: 'Visit Purpose',
                  value: _travel!['visit_purpose']?.toString() ?? 'N/A',
                  theme: theme,
                ),

                // Travel Information Card
                _InfoCard(
                  icon: Icons.info_rounded,
                  title: 'Travel Information',
                  theme: theme,
                  children: [
                    _InfoItem(
                      label: 'Visit Place',
                      value: _travel!['visit_place']?.toString() ?? 'N/A',
                      icon: Icons.location_on_rounded,
                      theme: theme,
                    ),
                    const SizedBox(height: 12),
                    _InfoItem(
                      label: 'Start Date',
                      value: _travel!['start_date']?.toString() ?? 'N/A',
                      icon: Icons.calendar_today_rounded,
                      theme: theme,
                    ),
                    const SizedBox(height: 12),
                    _InfoItem(
                      label: 'End Date',
                      value: _travel!['end_date']?.toString() ?? 'N/A',
                      icon: Icons.calendar_today_rounded,
                      theme: theme,
                    ),
                    const SizedBox(height: 12),
                    _InfoItem(
                      label: 'Travel Mode',
                      value: _travel!['travel_mode']?.toString() ?? 'N/A',
                      icon: Icons.directions_transit_rounded,
                      theme: theme,
                    ),
                    const SizedBox(height: 12),
                    _InfoItem(
                      label: 'Arrangement Type',
                      value: _travel!['arrangement_type']?.toString() ?? 'N/A',
                      icon: Icons.hotel_rounded,
                      theme: theme,
                    ),
                    if (_travel!['employee_id'] != null) ...[
                      const SizedBox(height: 12),
                      _InfoItem(
                        label: 'Employee ID',
                        value: _travel!['employee_id']?.toString() ?? 'N/A',
                        icon: Icons.badge_rounded,
                        theme: theme,
                      ),
                    ],
                    if (_travel!['travel_id'] != null) ...[
                      const SizedBox(height: 12),
                      _InfoItem(
                        label: 'Travel ID',
                        value: _travel!['travel_id']?.toString() ?? 'N/A',
                        icon: Icons.tag_rounded,
                        theme: theme,
                      ),
                    ],
                  ],
                ),

                // Budget Information Card
                _InfoCard(
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'Budget Information',
                  theme: theme,
                  children: [
                    _InfoItem(
                      label: 'Expected Budget',
                      value: _travel!['expected_budget']?.toString() ?? 'N/A',
                      icon: Icons.currency_rupee,
                      theme: theme,
                    ),
                    const SizedBox(height: 12),
                    _InfoItem(
                      label: 'Actual Budget',
                      value: _travel!['actual_budget']?.toString() ?? 'N/A',
                      icon: Icons.currency_rupee,
                      theme: theme,
                    ),
                  ],
                ),

                // Status Card
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
                if (_travel!['description'] != null &&
                    _travel!['description'].toString().isNotEmpty)
                  _InfoCard(
                    icon: Icons.description_rounded,
                    title: 'Description',
                    theme: theme,
                    value: _travel!['description']?.toString() ?? 'N/A',
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

