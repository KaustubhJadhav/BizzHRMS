import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../view_model/dashboard_view_model.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/sidebar/sidebar_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/header/header_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/loading_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/error_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/back_button_widget.dart';
import 'package:bizzhrms_flutter_app/core/constants/app_constants.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardViewModel()..loadDashboardData(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;

          if (isMobile) {
            // Mobile: Drawer instead of sidebar
            return Scaffold(
              drawer: Drawer(
                child: SafeArea(
                  child:
                      SidebarWidget(currentRoute: AppConstants.routeDashboard),
                ),
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    // Header with drawer button
                    const HeaderWidget(pageTitle: 'Dashboard'),
                    // Back Button with Title
                    const BackButtonWidget(title: 'Dashboard'),
                    // Content
                    Expanded(
                      child: _buildContent(context),
                    ),
                  ],
                ),
              ),
            );
          } else {
            // Desktop: Sidebar on left
            return Scaffold(
              body: SafeArea(
                child: Row(
                  children: [
                    // Sidebar
                    const SidebarWidget(
                        currentRoute: AppConstants.routeDashboard),
                    // Main Content
                    Expanded(
                      child: Column(
                        children: [
                          // Header
                          const HeaderWidget(pageTitle: 'Dashboard'),
                          // Back Button with Title
                          const BackButtonWidget(title: 'Dashboard'),
                          // Content
                          Expanded(
                            child: _buildContent(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.status == DashboardStatus.loading) {
          return const LoadingWidget(message: 'Loading dashboard...');
        }

        if (viewModel.status == DashboardStatus.error) {
          return ErrorDisplayWidget(
            message: viewModel.errorMessage ?? 'Failed to load dashboard',
            onRetry: () => viewModel.refresh(),
          );
        }

        final data = viewModel.dashboardData;
        if (data == null) {
          return const LoadingWidget(message: 'Loading dashboard...');
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Card
              _buildUserCard(data['userInfo'], data['attendance']),
              const SizedBox(height: 16),
              // Personal Details
              _buildPersonalDetails(data['userInfo']),
              const SizedBox(height: 16),
              // My Projects
              _buildProjectsCard('My Projects', data['projects']),
              const SizedBox(height: 16),
              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      '${data['attendance']['month']} Attendance',
                      '${data['attendance']['total']}/${data['attendance']['days']}',
                      FontAwesomeIcons.calendar,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Total Awards',
                      '${data['awards']['total']}',
                      FontAwesomeIcons.trophy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildProjectsCard('Announcements', data['announcements']),
              const SizedBox(height: 16),
              _buildProjectsCard('My Awards', data['myAwards']),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserCard(
      Map<String, dynamic>? userInfo, Map<String, dynamic>? attendance) {
    if (userInfo == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Avatar with status badge
            Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green, width: 3),
                    color: Colors.blue,
                  ),
                  child: userInfo['avatarUrl'] != null &&
                          userInfo['avatarUrl'].toString().isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            userInfo['avatarUrl'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                FontAwesomeIcons.user,
                                color: Colors.white,
                                size: 40,
                              );
                            },
                          ),
                        )
                      : const Icon(
                          FontAwesomeIcons.user,
                          color: Colors.white,
                          size: 40,
                        ),
                ),
                // Status indicator
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Name
            Text(
              userInfo['name'] ?? 'N/A',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Employee',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Last Login: ${userInfo['lastLogin'] ?? 'N/A'}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            // Clock Out Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Handle clock out
                },
                icon: const Icon(FontAwesomeIcons.arrowCircleLeft),
                label: const Text('Clock Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Today's Status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(FontAwesomeIcons.calendar, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    attendance != null && attendance['today'] != null
                        ? 'Today: ${attendance['today']}'
                        : 'Today: ${DateTime.now().weekday == DateTime.friday ? "Friday" : DateTime.now().weekday == DateTime.saturday ? "Saturday" : DateTime.now().weekday == DateTime.sunday ? "Sunday" : "Working Day"}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalDetails(Map<String, dynamic>? userInfo) {
    if (userInfo == null) return const SizedBox();

    final details = [
      {'label': 'Full Name', 'value': userInfo['name'] ?? 'N/A'},
      {'label': 'Employee ID', 'value': userInfo['employeeId'] ?? 'N/A'},
      {'label': 'Username', 'value': userInfo['username'] ?? 'N/A'},
      {'label': 'Email', 'value': userInfo['email'] ?? 'N/A'},
      {'label': 'Designation', 'value': userInfo['designation'] ?? 'N/A'},
      {'label': 'DOB', 'value': userInfo['dob'] ?? 'N/A'},
      {'label': 'Contact#', 'value': userInfo['contact'] ?? 'N/A'},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Personal Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to profile page for editing
                    Navigator.pushNamed(context, AppConstants.routeProfile);
                  },
                  icon: const Icon(FontAwesomeIcons.userPen, size: 16),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C3E50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...details.map((detail) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(
                          '${detail['label']}:',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(detail['value'].toString()),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsCard(String title, List items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(
                  child: Text('No projects available'),
                ),
              )
            else
              // Projects table would go here
              const Text('Projects table (to be implemented)'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(26.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF2C3E50), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
