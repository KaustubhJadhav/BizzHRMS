// BizzHRMS Design System - Code Snippets
// Quick reference for common UI patterns

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ============================================
// 1. NAVIGATION CARD (Home Screen Grid)
// ============================================
Widget buildNavigationCard({
  required BuildContext context,
  required String title,
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
}) {
  final theme = Theme.of(context);
  
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ============================================
// 2. HERO/WELCOME CARD (Gradient Background)
// ============================================
Widget buildHeroCard({
  required BuildContext context,
  required String title,
  required String subtitle,
  required Widget child,
}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Theme.of(context).colorScheme.primary,
          Theme.of(context).colorScheme.primary.withOpacity(0.8),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    ),
  );
}

// ============================================
// 3. STANDARD CONTENT CARD
// ============================================
Widget buildContentCard({
  required BuildContext context,
  required String title,
  required Widget content,
}) {
  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    ),
  );
}

// ============================================
// 4. STAT CARD (With Icon Indicator)
// ============================================
Widget buildStatCard({
  required BuildContext context,
  required String label,
  required String value,
  required Color color,
  VoidCallback? onTap,
}) {
  final theme = Theme.of(context);
  
  Widget cardContent = Container(
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      border: Border.all(
        color: color.withOpacity(0.2),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.circle,
            size: 8,
            color: color,
          ),
        ),
        const SizedBox(height: 12),
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );

  if (onTap != null) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: cardContent,
      ),
    );
  }

  return cardContent;
}

// ============================================
// 5. SECTION TITLE
// ============================================
Widget buildSectionTitle({
  required BuildContext context,
  required String title,
  EdgeInsets? padding,
}) {
  return Padding(
    padding: padding ?? const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
    child: Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    ),
  );
}

// ============================================
// 6. ICON BADGE (For Hero Cards)
// ============================================
Widget buildIconBadge({
  required IconData icon,
  double size = 24,
}) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(
      icon,
      color: Colors.white,
      size: size,
    ),
  );
}

// ============================================
// 7. GRID LAYOUT (3 Columns)
// ============================================
Widget buildGridLayout({
  required List<Widget> children,
  int crossAxisCount = 3,
  double spacing = 12,
}) {
  return GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: crossAxisCount,
    crossAxisSpacing: spacing,
    mainAxisSpacing: spacing,
    childAspectRatio: 1.0,
    children: children,
  );
}

// ============================================
// 8. FILLED BUTTON (Primary Action)
// ============================================
Widget buildFilledButton({
  required BuildContext context,
  required String label,
  required IconData icon,
  required VoidCallback onPressed,
  required Color backgroundColor,
  Color? foregroundColor,
  bool isLoading = false,
}) {
  return FilledButton.icon(
    onPressed: isLoading ? null : onPressed,
    icon: Icon(icon, size: 18),
    label: Text(label),
    style: FilledButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor ?? Colors.white,
      disabledBackgroundColor: Colors.grey,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
    ),
  );
}

// ============================================
// 9. COLOR CONSTANTS (Quick Reference)
// ============================================
class AppColors {
  static const Color primary = Color(0xFF2C3E50);
  static const Color secondary = Color(0xFF3498DB);
  static const Color accent = Color(0xFFE74C3C);
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color background = Color(0xFFF5F6FA);
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
}

// ============================================
// 10. SPACING CONSTANTS
// ============================================
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
}

// ============================================
// 11. BORDER RADIUS CONSTANTS
// ============================================
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
}

// ============================================
// USAGE EXAMPLE
// ============================================
/*
Widget buildExampleScreen(BuildContext context) {
  return Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Card
            buildHeroCard(
              context: context,
              title: 'Welcome Back!',
              subtitle: 'Monday, January 15, 2024',
              child: YourContentHere(),
            ),
            
            const SizedBox(height: 24),
            
            // Section Title
            buildSectionTitle(context: context, title: 'Quick Access'),
            
            const SizedBox(height: 12),
            
            // Grid of Navigation Cards
            buildGridLayout(
              children: [
                buildNavigationCard(
                  context: context,
                  title: 'Dashboard',
                  icon: FontAwesomeIcons.house,
                  color: AppColors.secondary,
                  onTap: () {},
                ),
                // ... more cards
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
*/

