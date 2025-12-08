import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:bizzhrms_flutter_app/core/constants/app_constants.dart';
import 'package:bizzhrms_flutter_app/presentation/auth/view_model/auth_view_model.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';

class SidebarWidget extends StatefulWidget {
  final String? currentRoute;

  const SidebarWidget({
    super.key,
    this.currentRoute,
  });

  @override
  State<SidebarWidget> createState() => _SidebarWidgetState();
}

class _SidebarWidgetState extends State<SidebarWidget> {

  List<SidebarItem> get _menuItems {
    final allItems = [
      // Main Section
      SidebarItem(
        icon: FontAwesomeIcons.home,
        title: 'Home',
        route: AppConstants.routeHome,
        color: const Color(0xFF3498DB),
        section: 'Main',
      ),
      SidebarItem(
        icon: FontAwesomeIcons.house,
        title: 'Dashboard',
        route: AppConstants.routeDashboard,
        color: const Color(0xFF3498DB),
        section: 'Main',
      ),
      SidebarItem(
        icon: FontAwesomeIcons.clock,
        title: 'Attendance',
        route: AppConstants.routeAttendance,
        color: const Color(0xFF2ECC71),
        section: 'Main',
      ),
      SidebarItem(
        icon: FontAwesomeIcons.bed,
        title: 'Leave',
        route: AppConstants.routeLeaves,
        color: const Color(0xFFE74C3C),
        section: 'Main',
      ),
      // HR Section
      SidebarItem(
        icon: FontAwesomeIcons.trophy,
        title: 'Awards',
        route: AppConstants.routeAwards,
        color: const Color(0xFFFFD700),
        section: 'HR',
      ),
      SidebarItem(
        icon: FontAwesomeIcons.star,
        title: 'Promotions',
        route: AppConstants.routePromotions,
        color: const Color(0xFFF39C12),
        section: 'HR',
      ),
      SidebarItem(
        icon: FontAwesomeIcons.arrowsRotate,
        title: 'Transfers',
        route: AppConstants.routeTransfers,
        color: const Color(0xFF16A085),
        section: 'HR',
      ),
      SidebarItem(
        icon: FontAwesomeIcons.chartLine,
        title: 'Performance',
        route: AppConstants.routePerformance,
        color: const Color(0xFFE67E22),
        section: 'HR',
      ),
      // Work Section
      SidebarItem(
        icon: FontAwesomeIcons.listCheck,
        title: 'Work Report',
        route: AppConstants.routeWorkReport,
        color: const Color(0xFF9B59B6),
        section: 'Work',
      ),
      SidebarItem(
        icon: FontAwesomeIcons.archive,
        title: 'Projects',
        route: AppConstants.routeProjects,
        color: const Color(0xFFF39C12),
        section: 'Work',
      ),
      SidebarItem(
        icon: FontAwesomeIcons.graduationCap,
        title: 'Training',
        route: AppConstants.routeTraining,
        color: const Color(0xFF3498DB),
        section: 'Work',
      ),
      // Finance Section
      SidebarItem(
        icon: FontAwesomeIcons.calculator,
        title: 'Payroll',
        route: AppConstants.routePayroll,
        color: const Color(0xFF27AE60),
        section: 'Finance',
      ),
      // Support Section
      SidebarItem(
        icon: FontAwesomeIcons.ticket,
        title: 'Tickets',
        route: AppConstants.routeTickets,
        color: const Color(0xFF9B59B6),
        section: 'Support',
      ),
      SidebarItem(
        icon: FontAwesomeIcons.circleExclamation,
        title: 'Complaints',
        route: AppConstants.routeComplaints,
        color: const Color(0xFFE74C3C),
        section: 'Support',
      ),
      SidebarItem(
        icon: FontAwesomeIcons.triangleExclamation,
        title: 'Warnings',
        route: AppConstants.routeWarnings,
        color: const Color(0xFFFF6B6B),
        section: 'Support',
      ),
      // Travel & Schedule
      SidebarItem(
        icon: FontAwesomeIcons.plane,
        title: 'Travels',
        route: AppConstants.routeTravels,
        color: const Color(0xFF74B9FF),
        section: 'Travel',
      ),
      SidebarItem(
        icon: FontAwesomeIcons.clockRotateLeft,
        title: 'Office Shift',
        route: AppConstants.routeOfficeShift,
        color: const Color(0xFF6C5CE7),
        section: 'Schedule',
      ),
      // Career Section
      SidebarItem(
        icon: FontAwesomeIcons.newspaper,
        title: 'Job Applied',
        route: AppConstants.routeJobApplied,
        color: const Color(0xFF00B894),
        section: 'Career',
      ),
      SidebarItem(
        icon: FontAwesomeIcons.comments,
        title: 'Job Interview',
        route: AppConstants.routeJobInterview,
        color: const Color(0xFFA29BFE),
        section: 'Career',
      ),
      // Communication
      SidebarItem(
        icon: FontAwesomeIcons.stickyNote,
        title: 'Announcements',
        route: AppConstants.routeAnnouncements,
        color: const Color(0xFF1ABC9C),
        section: 'Communication',
      ),
      // Logout
      SidebarItem(
        icon: FontAwesomeIcons.arrowRightFromBracket,
        title: 'Logout',
        route: AppConstants.routeSignIn,
        color: const Color(0xFFE74C3C),
        isLogout: true,
        section: 'Account',
      ),
    ];

    // Filter out Home item if we're on the home page
    if (widget.currentRoute == AppConstants.routeHome) {
      return allItems.where((item) => item.route != AppConstants.routeHome).toList();
    }

    return allItems;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groupedItems = _groupItemsBySection(_menuItems);
    
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo Header
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/BizzHRMS-Orange.png',
                  height: 32,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Text(
                      'BizzHRMS',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Menu Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: groupedItems.length,
              itemBuilder: (context, index) {
                final section = groupedItems.keys.elementAt(index);
                final items = groupedItems[section]!;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Header
                    if (section != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          section.toUpperCase(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    // Section Items
                    ...items.map((item) {
                      final isActive = widget.currentRoute == item.route;
                      return _buildMenuItem(context, item, isActive);
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Map<String?, List<SidebarItem>> _groupItemsBySection(List<SidebarItem> items) {
    final Map<String?, List<SidebarItem>> grouped = {};
    for (var item in items) {
      final section = item.section ?? 'Other';
      grouped.putIfAbsent(section, () => []).add(item);
    }
    return grouped;
  }

  Widget _buildMenuItem(BuildContext context, SidebarItem item, bool isActive) {
    final theme = Theme.of(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (item.isLogout) {
            _handleLogout();
          } else {
            // Use pushNamed for smoother transitions instead of pushReplacementNamed
            Navigator.pushNamed(context, item.route);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isActive 
                ? item.color.withOpacity(0.1) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isActive
                ? Border.all(
                    color: item.color.withOpacity(0.3),
                    width: 1.5,
                  )
                : null,
          ),
          child: Row(
            children: [
              // Icon Container
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isActive
                      ? item.color.withOpacity(0.15)
                      : item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.icon,
                  color: isActive ? item.color : item.color.withOpacity(0.8),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              // Title
              Expanded(
                child: Text(
                  item.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isActive
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurface.withOpacity(0.8),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              // Active Indicator
              if (isActive)
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: item.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogout() async {
    try {
      // Create new AuthViewModel instance for logout
      final authViewModel = AuthViewModel();
      await authViewModel.logout();
      
      if (context.mounted) {
        // Navigate directly to sign in - this will clear all routes
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppConstants.routeSignIn,
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        // Clear preferences manually as fallback
        await PreferencesHelper.clearAll();
        // Navigate directly to sign in - this will clear all routes
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppConstants.routeSignIn,
          (route) => false,
        );
      }
    }
  }
}

class SidebarItem {
  final IconData icon;
  final String title;
  final String route;
  final Color color;
  final bool isLogout;
  final String? section;

  SidebarItem({
    required this.icon,
    required this.title,
    required this.route,
    required this.color,
    this.isLogout = false,
    this.section,
  });
}
