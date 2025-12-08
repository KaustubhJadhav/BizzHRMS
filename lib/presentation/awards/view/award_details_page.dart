import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bizzhrms_flutter_app/presentation/awards/view_model/awards_view_model.dart';

class AwardDetailsPage extends StatefulWidget {
  const AwardDetailsPage({super.key, required this.awardId, this.initialAward});

  final String awardId;
  final Map<String, dynamic>? initialAward;

  @override
  State<AwardDetailsPage> createState() => _AwardDetailsPageState();
}

class _AwardDetailsPageState extends State<AwardDetailsPage> {
  Map<String, dynamic>? _award;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _award = widget.initialAward;
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final viewModel = AwardsViewModel();
    try {
      final details = await viewModel.getAwardDetails(widget.awardId);
      setState(() {
        _award = details ?? _award;
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
        appBar: AppBar(title: const Text('Award Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Award Details')),
        body: Center(
          child: Text(_error!),
        ),
      );
    }
    if (_award == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Award Details')),
        body: const Center(child: Text('No details found')),
      );
    }

    final awardPhoto = _award!['award_photo']?.toString();

    return Scaffold(
      appBar: AppBar(title: const Text('Award Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Award Photo
                if (awardPhoto != null && awardPhoto.isNotEmpty)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final availableWidth = constraints.maxWidth;
                          final imageHeight =
                              (availableWidth * 0.5).clamp(300.0, 500.0);
                          return Image.network(
                            awardPhoto,
                            width: double.infinity,
                            height: imageHeight,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) => Container(
                              height: imageHeight,
                              color: theme.colorScheme.surfaceVariant,
                              alignment: Alignment.center,
                              child: Icon(Icons.image_not_supported_rounded,
                                  size: 64,
                                  color: theme.colorScheme.onSurfaceVariant),
                            ),
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                height: imageHeight,
                                color: theme.colorScheme.surfaceVariant,
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(
                                  value: progress.expectedTotalBytes != null
                                      ? progress.cumulativeBytesLoaded /
                                          progress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),

                // Award Name
                _InfoCard(
                  icon: Icons.workspace_premium_rounded,
                  title: 'Award Name',
                  value: _award!['award_name']?.toString() ?? 'N/A',
                  theme: theme,
                ),

                // Employee Info
                _InfoCard(
                  icon: Icons.person_rounded,
                  title: 'Employee Information',
                  theme: theme,
                  children: [
                    _InfoItem(
                      label: 'Employee Name',
                      value: _award!['employee_name']?.toString() ?? 'N/A',
                      icon: Icons.badge_rounded,
                      theme: theme,
                    ),
                    const SizedBox(height: 12),
                    _InfoItem(
                      label: 'Employee ID',
                      value: _award!['employee_id']?.toString() ??
                          _award!['employee_primary_id']?.toString() ??
                          'N/A',
                      icon: Icons.numbers_rounded,
                      theme: theme,
                    ),
                  ],
                ),

                // Award Details
                _InfoCard(
                  icon: Icons.info_rounded,
                  title: 'Award Details',
                  theme: theme,
                  children: [
                    _InfoItem(
                      label: 'Gift',
                      value: _award!['gift']?.toString() ??
                          _award!['award_gift']?.toString() ??
                          'N/A',
                      icon: Icons.card_giftcard_rounded,
                      theme: theme,
                    ),
                    const SizedBox(height: 12),
                    _InfoItem(
                      label: 'Cash Price',
                      value: _award!['cash_price'] != null ||
                              _award!['award_cash_price'] != null
                          ? '₹ ${_award!['cash_price'] ?? _award!['award_cash_price']}'
                          : 'N/A',
                      icon: Icons.currency_rupee_rounded,
                      theme: theme,
                    ),
                    const SizedBox(height: 12),
                    _InfoItem(
                      label: 'Month & Year',
                      value: _award!['award_month_year']?.toString() ?? 'N/A',
                      icon: Icons.calendar_month_rounded,
                      theme: theme,
                    ),
                    if (_award!['award_date'] != null) ...[
                      const SizedBox(height: 12),
                      _InfoItem(
                        label: 'Award Date',
                        value: _award!['award_date']?.toString() ?? 'N/A',
                        icon: Icons.event_rounded,
                        theme: theme,
                      ),
                    ],
                    if (_award!['award_id'] != null) ...[
                      const SizedBox(height: 12),
                      _InfoItem(
                        label: 'Award ID',
                        value: _award!['award_id']?.toString() ?? 'N/A',
                        icon: Icons.tag_rounded,
                        theme: theme,
                      ),
                    ],
                  ],
                ),

                // Added By
                _InfoCard(
                  icon: Icons.person_add_rounded,
                  title: 'Added By',
                  theme: theme,
                  value: _award!['added_by']?.toString() ?? 'N/A',
                ),

                // Award Information / Description
                if (_award!['award_information'] != null &&
                    _award!['award_information'].toString().isNotEmpty)
                  _InfoCard(
                    icon: Icons.description_rounded,
                    title: 'Award Information',
                    theme: theme,
                    value: _award!['award_information']?.toString() ?? 'N/A',
                  ),
                if (_award!['award_description'] != null &&
                    _award!['award_description'].toString().isNotEmpty)
                  _InfoCard(
                    icon: Icons.article_rounded,
                    title: 'Award Description',
                    theme: theme,
                    value: _award!['award_description']?.toString() ?? 'N/A',
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

