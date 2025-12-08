import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:bizzhrms_flutter_app/core/constants/app_constants.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/header/header_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/auth/view_model/auth_view_model.dart';
import 'package:bizzhrms_flutter_app/presentation/home/view_model/home_view_model.dart';
import 'package:bizzhrms_flutter_app/presentation/home/view_model/admin_attendance_view_model.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  Timer? _timer;
  bool _isRefreshing = false;
  DateTime? _lastRefreshTime;
  static const _refreshDebounceDuration = Duration(seconds: 1);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Start timer to update time every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      _lastRefreshTime = null; // Reset to allow refresh
      _refreshData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This will be called when route becomes active
    _checkAndRefresh();
  }

  void _checkAndRefresh() {
    if (!mounted) return;

    // Check if route is currently active
    final route = ModalRoute.of(context);
    if (route?.isCurrent == true) {
      // Debounce: Only refresh if enough time has passed since last refresh
      final now = DateTime.now();
      if (_lastRefreshTime == null ||
          now.difference(_lastRefreshTime!) > _refreshDebounceDuration) {
        _lastRefreshTime = now;
        // Use a small delay to ensure the widget tree is fully built
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _refreshData();
          }
        });
      }
    }
  }

  void _refreshData() {
    // Use a small delay to ensure the widget tree and providers are ready
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;

      if (PreferencesHelper.isAdmin()) {
        // Refresh admin dashboard
        try {
          final viewModel = context.read<AdminAttendanceViewModel>();
          if (!viewModel.isLoading) {
            viewModel.loadDashboard();
          }
        } catch (e) {
          // Provider might not be available yet, try again after a delay
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              try {
                final viewModel = context.read<AdminAttendanceViewModel>();
                if (!viewModel.isLoading) {
                  viewModel.loadDashboard();
                }
              } catch (e2) {
                // Ignore if still not available
              }
            }
          });
        }
      } else {
        // Refresh user dashboard (clock state and permission)
        try {
          final viewModel = context.read<HomeViewModel>();
          viewModel.refresh();
        } catch (e) {
          // Provider might not be available yet, try again after a delay
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              try {
                final viewModel = context.read<HomeViewModel>();
                viewModel.refresh();
              } catch (e2) {
                // Ignore if still not available
              }
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if route is active and refresh when returning to this page
    // This ensures refresh happens every time the build method is called
    // (which happens when navigating back to this page)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final route = ModalRoute.of(context);
        if (route?.isCurrent == true) {
          // Always refresh when route becomes active (when navigating back)
          // Reset last refresh time to allow immediate refresh
          final now = DateTime.now();
          if (_lastRefreshTime == null ||
              now.difference(_lastRefreshTime!) > _refreshDebounceDuration) {
            _lastRefreshTime = now;
            // Use a delay to ensure providers are ready
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                _refreshData();
              }
            });
          }
        }
      }
    });

    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = HomeViewModel();
        // Load current clock state and employee permission when view model is created
        viewModel.loadCurrentClockState();
        viewModel.loadEmployeePermission();

        // Also refresh when returning to this page
        // Use a delay to ensure the widget tree is built
        Future.delayed(const Duration(milliseconds: 500), () {
          // This will be called when navigating back to the page
          // The view model will refresh its data
          viewModel.refresh();
        });

        return viewModel;
      },
      child: WillPopScope(
        onWillPop: () async {
          // Show confirmation dialog when back button is pressed
          final shouldPop = await _showExitConfirmationDialog(context);
          if (shouldPop == true) {
            // Exit the app
            return true;
          }
          // Don't exit if user cancels
          return false;
        },
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Header (no burger menu on home screen)
                const HeaderWidget(pageTitle: 'Home', showMenu: false),
                // Content
                Expanded(
                  child: _buildContent(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showExitConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C),
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    // Check if user is admin
    final isAdmin = PreferencesHelper.isAdmin();

    if (isAdmin) {
      // Show admin UI - today's attendance for all employees
      return _buildAdminContent(context);
    } else {
      // Show regular user UI
      return Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          // Refresh when this widget is built (happens when navigating back)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              final route = ModalRoute.of(context);
              if (route?.isCurrent == true) {
                // Refresh data when returning to this page
                final now = DateTime.now();
                if (_lastRefreshTime == null ||
                    now.difference(_lastRefreshTime!) >
                        _refreshDebounceDuration) {
                  _lastRefreshTime = now;
                  viewModel.refresh();
                }
              }
            }
          });

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _isRefreshing = true;
              });
              await viewModel.refresh();
              // Add a small delay for bounce effect
              await Future.delayed(const Duration(milliseconds: 300));
              if (mounted) {
                setState(() {
                  _isRefreshing = false;
                });
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card with Clock In
                  _BounceableCard(
                    isAnimating: _isRefreshing,
                    child: _buildWelcomeCard(context),
                  ),
                  const SizedBox(height: 20),
                  // Section Title
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4.0, vertical: 8.0),
                    child: Text(
                      'Quick Access',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Navigation Cards Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth < 600 ? 3 : 4;
                      final childAspectRatio =
                          constraints.maxWidth < 600 ? 0.85 : 0.9;
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: childAspectRatio,
                        children: [
                          _buildNavigationCard(
                            context,
                            title: 'Dashboard',
                            icon: FontAwesomeIcons.house,
                            route: AppConstants.routeDashboard,
                            color: const Color(0xFF3498DB),
                          ),
                          _buildNavigationCard(
                            context,
                            title: 'Attendance',
                            icon: FontAwesomeIcons.clock,
                            route: AppConstants.routeAttendance,
                            color: const Color(0xFF2ECC71),
                          ),
                          _buildNavigationCard(
                            context,
                            title: 'Leave',
                            icon: FontAwesomeIcons.bed,
                            route: AppConstants.routeLeaves,
                            color: const Color(0xFFE74C3C),
                          ),
                          _buildNavigationCard(
                            context,
                            title: 'Awards',
                            icon: FontAwesomeIcons.trophy,
                            route: AppConstants.routeAwards,
                            color: const Color(0xFFFFD700),
                          ),
                          _buildNavigationCard(
                            context,
                            title: 'Tickets',
                            icon: FontAwesomeIcons.ticket,
                            route: AppConstants.routeTickets,
                            color: const Color(0xFF9B59B6),
                          ),
                          _buildNavigationCard(
                            context,
                            title: 'Payroll',
                            icon: FontAwesomeIcons.calculator,
                            route: AppConstants.routePayroll,
                            color: const Color(0xFF27AE60),
                          ),
                          _buildNavigationCard(
                            context,
                            title: 'Training',
                            icon: FontAwesomeIcons.graduationCap,
                            route: AppConstants.routeTraining,
                            color: const Color(0xFF3498DB),
                          ),
                          _buildNavigationCard(
                            context,
                            title: 'Performance',
                            icon: FontAwesomeIcons.chartLine,
                            route: AppConstants.routePerformance,
                            color: const Color(0xFFE67E22),
                          ),
                          _buildNavigationCard(
                            context,
                            title: 'Transfers',
                            icon: FontAwesomeIcons.arrowsRotate,
                            route: AppConstants.routeTransfers,
                            color: const Color(0xFF16A085),
                          ),
                          _buildNavigationCard(
                            context,
                            title: 'Promotions',
                            icon: FontAwesomeIcons.star,
                            route: AppConstants.routePromotions,
                            color: const Color(0xFFF39C12),
                          ),
                          _buildNavigationCard(
                            context,
                            title: 'Complaints',
                            icon: FontAwesomeIcons.circleExclamation,
                            route: AppConstants.routeComplaints,
                            color: const Color(0xFFE74C3C),
                          ),
                          _buildNavigationCard(
                            context,
                            title: 'Warnings',
                            icon: FontAwesomeIcons.triangleExclamation,
                            route: AppConstants.routeWarnings,
                            color: const Color(0xFFFF6B6B),
                          ),
                          _buildNavigationCard(
                            context,
                            title: 'Travels',
                            icon: FontAwesomeIcons.plane,
                            route: AppConstants.routeTravels,
                            color: const Color(0xFF74B9FF),
                          ),
                          _buildNavigationCard(
                            context,
                            title: 'Office Shift',
                            icon: FontAwesomeIcons.clockRotateLeft,
                            route: AppConstants.routeOfficeShift,
                            color: const Color(0xFF6C5CE7),
                          ),
                          _buildNavigationCard(
                            context,
                            title: 'Job Applied',
                            icon: FontAwesomeIcons.newspaper,
                            route: AppConstants.routeJobApplied,
                            color: const Color(0xFF00B894),
                          ),
                          _buildNavigationCard(
                            context,
                            title: 'Job Interview',
                            icon: FontAwesomeIcons.comments,
                            route: AppConstants.routeJobInterview,
                            color: const Color(0xFFA29BFE),
                          ),
                          _buildNavigationCard(
                            context,
                            title: 'Work Report',
                            icon: FontAwesomeIcons.listCheck,
                            route: AppConstants.routeWorkReport,
                            color: const Color(0xFF9B59B6),
                          ),
                          _buildNavigationCard(
                            context,
                            title: 'Projects',
                            icon: FontAwesomeIcons.archive,
                            route: AppConstants.routeProjects,
                            color: const Color(0xFFF39C12),
                          ),
                          _buildNavigationCard(
                            context,
                            title: 'Announcements',
                            icon: FontAwesomeIcons.stickyNote,
                            route: AppConstants.routeAnnouncements,
                            color: const Color(0xFF1ABC9C),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildAdminContent(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = AdminAttendanceViewModel();
        viewModel.loadDashboard();
        return viewModel;
      },
      child: Consumer<AdminAttendanceViewModel>(
        builder: (context, viewModel, child) {
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _isRefreshing = true;
              });
              await viewModel.loadDashboard();
              // Add a small delay for bounce effect
              await Future.delayed(const Duration(milliseconds: 300));
              if (mounted) {
                setState(() {
                  _isRefreshing = false;
                });
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Branch Selector
                  // Card(
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(16.0),
                  //     child: Row(
                  //       children: [
                  //         const Text(
                  //           'Branch:',
                  //           style: TextStyle(
                  //             fontWeight: FontWeight.bold,
                  //             fontSize: 16,
                  //           ),
                  //         ),
                  //         const SizedBox(width: 12),
                  //         Expanded(
                  //           child: DropdownButton<String>(
                  //             value: 'Main',
                  //             isExpanded: true,
                  //             items: const [
                  //               DropdownMenuItem(
                  //                 value: 'Main',
                  //                 child: Text('Main'),
                  //               ),
                  //             ],
                  //             onChanged: (value) {
                  //               // TODO: Handle branch change when API is available
                  //             },
                  //             style: const TextStyle(fontSize: 16),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 16),
                  // Loading or Error State
                  if (viewModel.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (viewModel.errorMessage != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                viewModel.errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    // Attendance Report Center and Admin Options as separate containers
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildAttendanceReportCenter(context, viewModel),
                        const SizedBox(height: 24),
                        _buildAdminOptions(context),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAttendanceReportCenter(
      BuildContext context, AdminAttendanceViewModel viewModel) {
    // Get attendance stats from view model
    final attendanceStats = viewModel.getAttendanceStats();

    // Get selected date from view model or use current date - this will be reactive
    DateTime getSelectedDate() {
      if (viewModel.selectedDate != null &&
          viewModel.selectedDate!.isNotEmpty) {
        try {
          return DateTime.parse(viewModel.selectedDate!);
        } catch (e) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    final selectedDate = getSelectedDate();

    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  // Stack vertically on small screens
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attendance Report Center',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Date Picker
                      _buildDatePicker(
                          context, selectedDate, viewModel, getSelectedDate),
                    ],
                  );
                } else {
                  // Side by side on larger screens
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Attendance Report Center',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildDatePicker(
                          context, selectedDate, viewModel, getSelectedDate),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            // Statistics Grid
            _BounceableCard(
              isAnimating: _isRefreshing,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // 3x2 layout: 3 columns, 2 rows
                  final crossAxisCount = 3;
                  final childAspectRatio = 0.75;

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: childAspectRatio,
                    children: [
                      _buildStatCard(
                        'Total',
                        attendanceStats['total']!.toString(),
                        const Color(0xFF8A2BE2),
                        onTap: () {
                          Navigator.pushNamed(
                              context, AppConstants.routeAdminEmployees);
                        },
                      ),
                      _buildStatCard(
                        'Present',
                        attendanceStats['present']!.toString(),
                        Colors.green,
                        onTap: () {
                          // Get selected date from view model or use today's date
                          final selectedDate = viewModel.selectedDate ??
                              DateFormat('yyyy-MM-dd').format(DateTime.now());
                          Navigator.pushNamed(
                            context,
                            AppConstants.routeAdminAttendanceFiltered,
                            arguments: {
                              'statusTime': 'Present',
                              'date': selectedDate,
                            },
                          );
                        },
                      ),
                      _buildStatCard(
                        'Absent',
                        attendanceStats['absent']!.toString(),
                        Colors.red,
                        onTap: () {
                          // Get selected date from view model or use today's date
                          final selectedDate = viewModel.selectedDate ??
                              DateFormat('yyyy-MM-dd').format(DateTime.now());
                          Navigator.pushNamed(
                            context,
                            AppConstants.routeAdminAttendanceFiltered,
                            arguments: {
                              'statusTime': 'Absent',
                              'date': selectedDate,
                            },
                          );
                        },
                      ),
                      // _buildStatCard(
                      //   'Half Day',
                      //   attendanceStats['halfDay']!.toString(),
                      //   Colors.orange,
                      // ),
                      // _buildStatCard(
                      //   'Weekly Off',
                      //   attendanceStats['weeklyOff']!.toString(),
                      //   const Color(0xFF8A2BE2),
                      // ),
                      _buildStatCard(
                        'Holiday',
                        attendanceStats['holiday']!.toString(),
                        Colors.blue,
                        onTap: () {
                          // Get selected date from view model or use today's date
                          final selectedDate = viewModel.selectedDate ??
                              DateFormat('yyyy-MM-dd').format(DateTime.now());
                          Navigator.pushNamed(
                            context,
                            AppConstants.routeAdminAttendanceFiltered,
                            arguments: {
                              'statusTime': 'Holiday',
                              'date': selectedDate,
                            },
                          );
                        },
                      ),
                      _buildStatCard(
                        'On Break',
                        attendanceStats['onBreak']!.toString(),
                        const Color(0xFF00BCD4),
                      ),
                      _buildStatCard(
                        'On Leave',
                        attendanceStats['onLeave']!.toString(),
                        const Color(0xFFFFC107),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // Leave Management Section
            _BounceableCard(
              isAnimating: _isRefreshing,
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                          context, AppConstants.routeAdminLeaveManagement);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              FontAwesomeIcons.calendarDays,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Leave Management',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Manage employee leaves - Add, Edit, Delete',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.6),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.4),
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminOptions(BuildContext context) {
    return _BounceableCard(
      isAnimating: _isRefreshing,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Options',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  // Adjust grid columns based on screen size
                  final crossAxisCount = constraints.maxWidth < 600 ? 3 : 4;
                  final childAspectRatio =
                      constraints.maxWidth < 600 ? 0.75 : 0.8;

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: childAspectRatio,
                    children: [
                      _buildNavigationCard(
                        context,
                        title: 'Employees',
                        icon: FontAwesomeIcons.users,
                        route: AppConstants.routeAdminEmployees,
                        color: const Color(0xFF3498DB),
                      ),
                      _buildNavigationCard(
                        context,
                        title: 'Set Roles',
                        icon: FontAwesomeIcons.userShield,
                        route: AppConstants.routeAdminSetRoles,
                        color: const Color(0xFF2ECC71),
                      ),
                      _buildNavigationCard(
                        context,
                        title: 'Awards',
                        icon: FontAwesomeIcons.trophy,
                        route: AppConstants.routeAwards,
                        color: const Color(0xFFFFD700),
                      ),
                      _buildNavigationCard(
                        context,
                        title: 'Transfers',
                        icon: FontAwesomeIcons.arrowsRotate,
                        route: AppConstants.routeTransfers,
                        color: const Color(0xFF16A085),
                      ),
                      _buildNavigationCard(
                        context,
                        title: 'Resignations',
                        icon: FontAwesomeIcons.fileContract,
                        route: AppConstants.routeAdminResignations,
                        color: const Color(0xFFE74C3C),
                      ),
                      _buildNavigationCard(
                        context,
                        title: 'Travels',
                        icon: FontAwesomeIcons.plane,
                        route: AppConstants.routeTravels,
                        color: const Color(0xFF74B9FF),
                      ),
                      _buildNavigationCard(
                        context,
                        title: 'Promotions',
                        icon: FontAwesomeIcons.star,
                        route: AppConstants.routePromotions,
                        color: const Color(0xFFF39C12),
                      ),
                      _buildNavigationCard(
                        context,
                        title: 'Complaints',
                        icon: FontAwesomeIcons.circleExclamation,
                        route: AppConstants.routeComplaints,
                        color: const Color(0xFFE74C3C),
                      ),
                      _buildNavigationCard(
                        context,
                        title: 'Warnings',
                        icon: FontAwesomeIcons.triangleExclamation,
                        route: AppConstants.routeWarnings,
                        color: const Color(0xFFFF6B6B),
                      ),
                      _buildNavigationCard(
                        context,
                        title: 'Terminations',
                        icon: FontAwesomeIcons.userXmark,
                        route: AppConstants.routeAdminTerminations,
                        color: const Color(0xFFC0392B),
                      ),
                      _buildNavigationCard(
                        context,
                        title: 'Company',
                        icon: FontAwesomeIcons.building,
                        route: AppConstants.routeAdminCompany,
                        color: const Color(0xFF34495E),
                      ),
                      _buildNavigationCard(
                        context,
                        title: 'Branch',
                        icon: FontAwesomeIcons.sitemap,
                        route: AppConstants.routeAdminBranch,
                        color: const Color(0xFF7F8C8D),
                      ),
                      _buildNavigationCard(
                        context,
                        title: 'Department',
                        icon: FontAwesomeIcons.briefcase,
                        route: AppConstants.routeAdminDepartment,
                        color: const Color(0xFF95A5A6),
                      ),
                      _buildNavigationCard(
                        context,
                        title: 'Designation',
                        icon: FontAwesomeIcons.idCard,
                        route: AppConstants.routeAdminDesignation,
                        color: const Color(0xFFBDC3C7),
                      ),
                      _buildNavigationCard(
                        context,
                        title: 'Announcements',
                        icon: FontAwesomeIcons.stickyNote,
                        route: AppConstants.routeAnnouncements,
                        color: const Color(0xFF1ABC9C),
                      ),
                      _buildNavigationCard(
                        context,
                        title: 'Policies',
                        icon: FontAwesomeIcons.fileLines,
                        route: AppConstants.routeAdminPolicies,
                        color: const Color(0xFF3498DB),
                      ),
                      _buildNavigationCard(
                        context,
                        title: 'Expense',
                        icon: FontAwesomeIcons.moneyBill,
                        route: AppConstants.routeAdminExpense,
                        color: const Color(0xFF27AE60),
                      ),
                      _buildNavigationCard(
                        context,
                        title: 'Performance',
                        icon: FontAwesomeIcons.chartLine,
                        route: AppConstants.routeAdminPerformanceIndicator,
                        color: const Color(0xFFE67E22),
                      ),
                      _buildNavigationCard(
                        context,
                        title: 'Payroll',
                        icon: FontAwesomeIcons.calculator,
                        route: AppConstants.routeAdminPayrollTemplates,
                        color: const Color(0xFF27AE60),
                      ),
                      _buildNavigationCard(
                        context,
                        title: 'Projects',
                        icon: FontAwesomeIcons.archive,
                        route: AppConstants.routeProjects,
                        color: const Color(0xFFF39C12),
                      ),
                      _buildNavigationCard(
                        context,
                        title: 'Work Report',
                        icon: FontAwesomeIcons.listCheck,
                        route: AppConstants.routeWorkReport,
                        color: const Color(0xFF9B59B6),
                      ),
                      _buildNavigationCard(
                        context,
                        title: 'Tickets',
                        icon: FontAwesomeIcons.ticket,
                        route: AppConstants.routeTickets,
                        color: const Color(0xFF9B59B6),
                      ),
                      _buildNavigationCard(
                        context,
                        title: 'Job Posts',
                        icon: FontAwesomeIcons.briefcase,
                        route: AppConstants.routeAdminJobPosts,
                        color: const Color(0xFF3498DB),
                      ),
                      _buildNavigationCard(
                        context,
                        title: 'Job Candidates',
                        icon: FontAwesomeIcons.userTie,
                        route: AppConstants.routeAdminJobCandidates,
                        color: const Color(0xFF2ECC71),
                      ),
                      _buildNavigationCard(
                        context,
                        title: 'Job Interviews',
                        icon: FontAwesomeIcons.comments,
                        route: AppConstants.routeJobInterview,
                        color: const Color(0xFFA29BFE),
                      ),
                      _buildNavigationCard(
                        context,
                        title: 'Training',
                        icon: FontAwesomeIcons.graduationCap,
                        route: AppConstants.routeTraining,
                        color: const Color(0xFF3498DB),
                      ),
                      _buildNavigationCard(
                        context,
                        title: 'Files Manager',
                        icon: FontAwesomeIcons.folder,
                        route: AppConstants.routeAdminFilesManager,
                        color: const Color(0xFF95A5A6),
                      ),
                      _buildNavigationCard(
                        context,
                        title: 'Employees Directory',
                        icon: FontAwesomeIcons.addressBook,
                        route: AppConstants.routeAdminEmployeesDirectory,
                        color: const Color(0xFF34495E),
                      ),
                      _buildNavigationCard(
                        context,
                        title: 'Accounts',
                        icon: FontAwesomeIcons.buildingColumns,
                        route: AppConstants.routeAdminAccounts,
                        color: const Color(0xFF8E44AD),
                      ),
                      _buildNavigationCard(
                        context,
                        title: 'Transactions',
                        icon: FontAwesomeIcons.exchange,
                        route: AppConstants.routeAdminTransactions,
                        color: const Color(0xFF16A085),
                      ),
                      _buildNavigationCard(
                        context,
                        title: 'Reports',
                        icon: FontAwesomeIcons.chartBar,
                        route: AppConstants.routeAdminReports,
                        color: const Color(0xFFE74C3C),
                      ),
                      _buildNavigationCard(
                        context,
                        title: 'Settings',
                        icon: FontAwesomeIcons.gear,
                        route: AppConstants.routeAdminSettings,
                        color: const Color(0xFF7F8C8D),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(
    BuildContext context,
    DateTime selectedDate,
    AdminAttendanceViewModel viewModel,
    DateTime Function() getSelectedDate,
  ) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final pickedDate = await showDatePicker(
            context: context,
            initialDate: selectedDate,
            firstDate: DateTime(2020),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (pickedDate != null) {
            final dateString = DateFormat('yyyy-MM-dd').format(pickedDate);
            await viewModel.loadDashboard(date: dateString);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Builder(
                builder: (context) {
                  final displayDate = getSelectedDate();
                  return Text(
                    DateFormat('yyyy-MM-dd').format(displayDate),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.calendar_today,
                size: 18,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color,
      {VoidCallback? onTap}) {
    final theme = Theme.of(context);

    Widget cardContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
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
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 10),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
                fontSize: 14,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 24,
                height: 1.0,
              ),
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

  Widget _buildWelcomeCard(BuildContext context) {
    final now = DateTime.now();
    final timeString = DateFormat('hh:mm:ss a').format(now);
    final dateString = DateFormat('EEEE, MMMM dd, yyyy').format(now);

    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        final isLoading = viewModel.clockingStatus == ClockingStatus.loading;
        final currentState = viewModel.currentClockState;
        final isClockedIn = currentState == 'in';
        final allowMobileClock = viewModel.allowMobileClock;

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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Back!',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateString,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        FontAwesomeIcons.clock,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Time',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            timeString,
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (allowMobileClock)
                      FilledButton.icon(
                        onPressed: isLoading
                            ? null
                            : () => isClockedIn
                                ? _handleClockOut(
                                    context, viewModel, timeString)
                                : _handleClockIn(
                                    context, viewModel, timeString),
                        icon: Icon(
                          isClockedIn
                              ? FontAwesomeIcons.clockRotateLeft
                              : FontAwesomeIcons.clock,
                          size: 18,
                        ),
                        label: Text(isClockedIn ? 'Clock Out' : 'Clock In'),
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              isClockedIn ? Colors.red.shade400 : Colors.white,
                          foregroundColor: isClockedIn
                              ? Colors.white
                              : Theme.of(context).colorScheme.primary,
                          disabledBackgroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleClockIn(
    BuildContext context,
    HomeViewModel viewModel,
    String timeString,
  ) async {
    final success = await viewModel.clockIn();
    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Clocked in at $timeString'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage ?? 'Failed to clock in'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleClockOut(
    BuildContext context,
    HomeViewModel viewModel,
    String timeString,
  ) async {
    final success = await viewModel.clockOut();
    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Clocked out at $timeString'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage ?? 'Failed to clock out'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildNavigationCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String route,
    required Color color,
    bool isLogout = false,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isLogout) {
            _handleLogout(context);
          } else {
            Navigator.pushNamed(context, route);
          }
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.05),
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
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: color,
                ),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                      fontSize: 12,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
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

// Bounceable Card Widget for bounce effect on refresh
class _BounceableCard extends StatefulWidget {
  final Widget child;
  final bool isAnimating;

  const _BounceableCard({
    required this.child,
    required this.isAnimating,
  });

  @override
  State<_BounceableCard> createState() => _BounceableCardState();
}

class _BounceableCardState extends State<_BounceableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void didUpdateWidget(_BounceableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating && !oldWidget.isAnimating) {
      // Trigger bounce animation when refresh starts
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        final scale = 0.95 + (_bounceAnimation.value * 0.05);
        return Transform.scale(
          scale: scale,
          child: widget.child,
        );
      },
    );
  }
}

// Elastic Card Widget for bounce/stretch animation on drag and auto-bounce
class ElasticCard extends StatefulWidget {
  final Widget child;
  final bool autoBounce; // NEW

  const ElasticCard({
    super.key,
    required this.child,
    this.autoBounce = false, // default: no auto bounce
  });

  @override
  State<ElasticCard> createState() => _ElasticCardState();
}

class _ElasticCardState extends State<ElasticCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Trigger bounce on screen load
    if (widget.autoBounce) {
      Future.delayed(const Duration(milliseconds: 180), () {
        _startAutoBounce();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startAutoBounce() {
    if (!mounted) return;
    setState(() => _dragOffset = 40); // push downward a bit

    _controller.reset();
    _controller.addListener(() {
      if (mounted) {
        setState(() {
          _dragOffset = _dragOffset * (1 - _controller.value);
        });
      }
    });

    _controller.forward();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!mounted) return;
    setState(() {
      _dragOffset += details.delta.dy * 0.4;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (!mounted) return;
    _controller.reset();
    _controller.addListener(() {
      if (mounted) {
        setState(() {
          _dragOffset = _dragOffset * (1 - _controller.value);
        });
      }
    });
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final stretch = (_dragOffset / 250).clamp(-0.25, 0.25);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragUpdate: _onDragUpdate,
      onVerticalDragEnd: _onDragEnd,
      child: Transform.scale(
        scaleY: 1 + stretch,
        child: widget.child,
      ),
    );
  }
}
