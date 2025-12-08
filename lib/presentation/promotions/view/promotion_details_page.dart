import 'package:flutter/material.dart';
import 'package:bizzhrms_flutter_app/presentation/promotions/view_model/promotions_view_model.dart';

class PromotionDetailsPage extends StatefulWidget {
  const PromotionDetailsPage(
      {super.key, required this.promotionId, this.initialPromotion});

  final String promotionId;
  final Map<String, dynamic>? initialPromotion;

  @override
  State<PromotionDetailsPage> createState() => _PromotionDetailsPageState();
}

class _PromotionDetailsPageState extends State<PromotionDetailsPage> {
  Map<String, dynamic>? _promotion;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _promotion = widget.initialPromotion;
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    // If no promotionId was provided, just show the initial data (if any)
    if (widget.promotionId.isEmpty) {
      setState(() {
        _loading = false;
      });
      return;
    }

    final viewModel = PromotionsViewModel();
    try {
      final details = await viewModel.getPromotionDetails(widget.promotionId);
      setState(() {
        _promotion = details ?? _promotion;
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
        appBar: AppBar(title: const Text('Promotion Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Promotion Details')),
        body: Center(child: Text(_error!)),
      );
    }
    if (_promotion == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Promotion Details')),
        body: const Center(child: Text('No details found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Promotion Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Promotion Title Card
                _InfoCard(
                  icon: Icons.workspace_premium_rounded,
                  title: 'Promotion Title',
                  value: _promotion!['promotion_title']?.toString() ?? 'N/A',
                  theme: theme,
                ),

                // Employee Information Card
                _InfoCard(
                  icon: Icons.person_rounded,
                  title: 'Employee Information',
                  theme: theme,
                  children: [
                    _InfoItem(
                      label: 'Employee Name',
                      value: _promotion!['employee_name']?.toString() ?? 'N/A',
                      icon: Icons.badge_rounded,
                      theme: theme,
                    ),
                    const SizedBox(height: 12),
                    _InfoItem(
                      label: 'Employee ID',
                      value: _promotion!['employee_id']?.toString() ??
                          _promotion!['employee_primary_id']?.toString() ??
                          'N/A',
                      icon: Icons.numbers_rounded,
                      theme: theme,
                    ),
                  ],
                ),

                // Promotion Details Card
                _InfoCard(
                  icon: Icons.info_rounded,
                  title: 'Promotion Details',
                  theme: theme,
                  children: [
                    _InfoItem(
                      label: 'Promotion Date',
                      value: _promotion!['promotion_date']?.toString() ??
                          'N/A',
                      icon: Icons.calendar_month_rounded,
                      theme: theme,
                    ),
                    if (_promotion!['created_at'] != null) ...[
                      const SizedBox(height: 12),
                      _InfoItem(
                        label: 'Created At',
                        value:
                            _promotion!['created_at']?.toString() ?? 'N/A',
                        icon: Icons.access_time_rounded,
                        theme: theme,
                      ),
                    ],
                    if (_promotion!['promotion_id'] != null) ...[
                      const SizedBox(height: 12),
                      _InfoItem(
                        label: 'Promotion ID',
                        value:
                            _promotion!['promotion_id']?.toString() ?? 'N/A',
                        icon: Icons.tag_rounded,
                        theme: theme,
                      ),
                    ],
                  ],
                ),

                // Added By Card
                _InfoCard(
                  icon: Icons.person_add_rounded,
                  title: 'Added By',
                  theme: theme,
                  value: _promotion!['added_by']?.toString() ?? 'N/A',
                ),

                // Promotion Description Section
                if (_promotion!['promotion_description'] != null &&
                    _promotion!['promotion_description']
                        .toString()
                        .isNotEmpty)
                  _InfoCard(
                    icon: Icons.description_rounded,
                    title: 'Promotion Description',
                    theme: theme,
                    value: _promotion!['promotion_description']
                            ?.toString() ??
                        'N/A',
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

