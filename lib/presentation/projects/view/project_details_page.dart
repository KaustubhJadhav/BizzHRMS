import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../view_model/project_details_view_model.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/sidebar/sidebar_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/header/header_widget.dart';
import 'package:bizzhrms_flutter_app/core/constants/app_constants.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/loading_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/error_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/back_button_widget.dart';

class ProjectDetailsPage extends StatefulWidget {
  final Map<String, dynamic> project;

  const ProjectDetailsPage({
    super.key,
    required this.project,
  });

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging ||
        _tabController.index != _selectedTabIndex) {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == 'null') {
      return 'N/A';
    }
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}-${_getMonthName(date.month)}-${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'highest':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'normal':
        return Colors.blue;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(int? status) {
    switch (status) {
      case 0:
        return 'Not Started';
      case 1:
        return 'In Progress';
      case 2:
        return 'Completed';
      case 3:
        return 'Deferred';
      default:
        return 'Not Started';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          ProjectDetailsViewModel()..setProjectDetails(widget.project),
      builder: (context, child) {
        return Scaffold(
          drawer: Drawer(
            child: SafeArea(
              child: SidebarWidget(currentRoute: AppConstants.routeProjects),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                const HeaderWidget(pageTitle: 'Project Details'),
                const BackButtonWidget(title: 'Project Details'),
                Expanded(
                  child: Consumer<ProjectDetailsViewModel>(
                    builder: (context, viewModel, child) {
                      if (viewModel.status == ProjectDetailsStatus.loading) {
                        return const LoadingWidget(
                            message: 'Loading project details...');
                      }

                      if (viewModel.status == ProjectDetailsStatus.error) {
                        return ErrorDisplayWidget(
                          message: viewModel.errorMessage ??
                              'Failed to load project details',
                          onRetry: () => viewModel.refresh(),
                        );
                      }

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final isSmallScreen = constraints.maxWidth < 800;

                          if (isSmallScreen) {
                            // Mobile layout: Use bottom navigation or tabs
                            return Column(
                              children: [
                                // Tab bar at top
                                Container(
                                  color: Colors.white,
                                  child: TabBar(
                                    controller: _tabController,
                                    isScrollable: true,
                                    labelPadding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    tabAlignment: TabAlignment.start,
                                    tabs: const [
                                      Tab(
                                          icon: Icon(Icons.home),
                                          text: 'Overview'),
                                      Tab(
                                          icon: Icon(Icons.people),
                                          text: 'Assigned'),
                                      Tab(
                                          icon: Icon(Icons.trending_up),
                                          text: 'Progress'),
                                      Tab(
                                          icon: Icon(Icons.chat),
                                          text: 'Discussion'),
                                      Tab(
                                          icon: Icon(Icons.bug_report),
                                          text: 'Bugs'),
                                      Tab(
                                          icon: Icon(Icons.folder),
                                          text: 'Files'),
                                      Tab(icon: Icon(Icons.note), text: 'Note'),
                                    ],
                                  ),
                                ),
                                // Content
                                Expanded(
                                  child: TabBarView(
                                    controller: _tabController,
                                    children: [
                                      _buildOverviewTab(viewModel),
                                      _buildAssignedToTab(viewModel),
                                      _buildProgressTab(viewModel),
                                      _buildDiscussionTab(viewModel),
                                      _buildBugsTab(viewModel),
                                      _buildFilesTab(viewModel),
                                      _buildNoteTab(viewModel),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }

                          // Desktop layout: Sidebar + Content
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Sidebar Navigation
                              RepaintBoundary(
                                child: Container(
                                  width: 250,
                                  color: Colors.white,
                                  child: Column(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            16.0, 16.0, 16.0, 12.0),
                                        child: Text(
                                          'Project Details',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      _buildNavItem(
                                        icon: Icons.home,
                                        title: 'Overview',
                                        index: 0,
                                        onTap: () {
                                          _tabController.animateTo(0);
                                        },
                                      ),
                                      _buildNavItem(
                                        icon: Icons.people,
                                        title: 'Assigned To',
                                        index: 1,
                                        onTap: () {
                                          _tabController.animateTo(1);
                                        },
                                      ),
                                      _buildNavItem(
                                        icon: Icons.trending_up,
                                        title: 'Progress',
                                        index: 2,
                                        onTap: () {
                                          _tabController.animateTo(2);
                                        },
                                      ),
                                      _buildNavItem(
                                        icon: Icons.chat,
                                        title: 'Discussion',
                                        index: 3,
                                        onTap: () {
                                          _tabController.animateTo(3);
                                        },
                                      ),
                                      _buildNavItem(
                                        icon: Icons.bug_report,
                                        title: 'Bugs/Issues',
                                        index: 4,
                                        onTap: () {
                                          _tabController.animateTo(4);
                                        },
                                      ),
                                      _buildNavItem(
                                        icon: Icons.folder,
                                        title: 'Files',
                                        index: 5,
                                        onTap: () {
                                          _tabController.animateTo(5);
                                        },
                                      ),
                                      _buildNavItem(
                                        icon: Icons.note,
                                        title: 'Note',
                                        index: 6,
                                        onTap: () {
                                          _tabController.animateTo(6);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Content Area
                              Expanded(
                                child: Container(
                                  color: Colors.grey.shade100,
                                  child: TabBarView(
                                    controller: _tabController,
                                    children: [
                                      _buildOverviewTab(viewModel),
                                      _buildAssignedToTab(viewModel),
                                      _buildProgressTab(viewModel),
                                      _buildDiscussionTab(viewModel),
                                      _buildBugsTab(viewModel),
                                      _buildFilesTab(viewModel),
                                      _buildNoteTab(viewModel),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required int index,
    required VoidCallback onTap,
  }) {
    final isActive = _selectedTabIndex == index;
    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.blue.withOpacity(0.1),
          highlightColor: Colors.blue.withOpacity(0.05),
          hoverColor: Colors.grey.withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isActive ? Colors.blue.shade50 : Colors.transparent,
              border: isActive
                  ? const Border(
                      left: BorderSide(color: Colors.blue, width: 3),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isActive ? Colors.blue : Colors.grey.shade700,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
                      color: isActive ? Colors.blue : Colors.grey.shade700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(ProjectDetailsViewModel viewModel) {
    final project = viewModel.projectDetails ?? widget.project;
    final totalTasks = project['total_tasks'] ?? 0;
    final totalBugs = project['total_bugs'] ?? 0;
    final totalMembers = project['assigned_to'] is List
        ? (project['assigned_to'] as List).length
        : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 600;

              if (isSmallScreen) {
                // Stack vertically on small screens
                return Column(
                  children: [
                    _buildStatCard(
                      icon: Icons.assignment,
                      iconColor: Colors.blue,
                      title: 'Total Tasks',
                      value: totalTasks.toString(),
                    ),
                    const SizedBox(height: 12),
                    _buildStatCard(
                      icon: Icons.bug_report,
                      iconColor: Colors.red,
                      title: 'Bugs/Issues',
                      value: totalBugs.toString(),
                    ),
                    const SizedBox(height: 12),
                    _buildStatCard(
                      icon: Icons.people,
                      iconColor: Colors.green,
                      title: 'Total Members',
                      value: totalMembers.toString(),
                    ),
                  ],
                );
              }

              // Horizontal layout on larger screens
              return Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.assignment,
                      iconColor: Colors.blue,
                      title: 'Total Tasks',
                      value: totalTasks.toString(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.bug_report,
                      iconColor: Colors.red,
                      title: 'Bugs/Issues',
                      value: totalBugs.toString(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.people,
                      iconColor: Colors.green,
                      title: 'Total Members',
                      value: totalMembers.toString(),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          // Project Overview
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Project Overview - ${project['title']?.toString() ?? 'N/A'}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  // Description
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      project['summary']?.toString() ??
                          project['description']?.toString() ??
                          'No description available',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const Divider(height: 32),
                  // Project Info
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isSmallScreen = constraints.maxWidth < 800;

                      if (isSmallScreen) {
                        // Stack vertically on small screens
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status: ${_getStatusText(project['status'] is int ? project['status'] : int.tryParse(project['status']?.toString() ?? '0'))}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  FontAwesomeIcons.calendar,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Start Date: ${_formatDate(project['start_date']?.toString())}',
                                    style: const TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  FontAwesomeIcons.calendar,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'End Date: ${_formatDate(project['end_date']?.toString())}',
                                    style: const TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Text('Priority: '),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getPriorityColor(
                                      project['priority']?.toString(),
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    project['priority']?.toString() ?? 'Normal',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }

                      // Horizontal layout on larger screens
                      return Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Status: ${_getStatusText(project['status'] is int ? project['status'] : int.tryParse(project['status']?.toString() ?? '0'))}',
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  FontAwesomeIcons.calendar,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Start: ${_formatDate(project['start_date']?.toString())}',
                                    style: const TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  FontAwesomeIcons.calendar,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'End: ${_formatDate(project['end_date']?.toString())}',
                                    style: const TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Priority: '),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getPriorityColor(
                                        project['priority']?.toString(),
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      project['priority']?.toString() ??
                                          'Normal',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignedToTab(ProjectDetailsViewModel viewModel) {
    final project = viewModel.projectDetails ?? widget.project;
    final assignedTo = project['assigned_to'] as List?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Assigned Users',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (assignedTo != null && assignedTo.isNotEmpty)
                ...assignedTo.map((user) {
                  final userName = user is Map
                      ? (user['name'] ?? user['username'] ?? 'Unknown')
                      : user.toString();
                  final userRole = user is Map
                      ? (user['role'] ?? user['designation'] ?? 'Other')
                      : 'Other';
                  final avatarUrl =
                      user is Map ? user['avatar']?.toString() : null;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage:
                              avatarUrl != null && avatarUrl.isNotEmpty
                                  ? NetworkImage(avatarUrl)
                                  : null,
                          child: avatarUrl == null || avatarUrl.isEmpty
                              ? Text(
                                  userName.length > 0
                                      ? userName.substring(0, 1).toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                          backgroundColor: Colors.blue.shade300,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                userRole,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right,
                            color: Colors.grey, size: 20),
                      ],
                    ),
                  );
                }).toList()
              else
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      'No assigned users',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressTab(ProjectDetailsViewModel viewModel) {
    final project = viewModel.projectDetails ?? widget.project;
    // Try multiple possible field names for project ID
    final projectId = (project['project_id'] ??
            project['id'] ??
            project['ID'] ??
            project['projectId'] ??
            '')
        .toString();

    // Debug: Print project data to see available fields
    print('=== PROJECT DATA DEBUG (Progress Tab) ===');
    print('Project keys: ${project.keys.toList()}');
    print('project_id: ${project['project_id']}');
    print('id: ${project['id']}');
    print('Final projectId: $projectId');
    print('==========================================');

    // Use state variables for form controls
    final initialProgress = project['progress'] is int
        ? project['progress']
        : int.tryParse(project['progress']?.toString() ?? '0') ?? 0;
    final initialStatus = project['status'] is int
        ? project['status']
        : int.tryParse(project['status']?.toString() ?? '0') ?? 0;
    final initialPriorityStr = project['priority']?.toString() ?? 'Normal';

    // Convert priority string to int (Highest=1, High=2, Normal=3, Low=4)
    int getPriorityValue(String priorityStr) {
      switch (priorityStr.toLowerCase()) {
        case 'highest':
          return 1;
        case 'high':
          return 2;
        case 'normal':
          return 3;
        case 'low':
          return 4;
        default:
          return 3;
      }
    }

    return _ProgressTabStateful(
      viewModel: viewModel,
      projectId: projectId,
      initialProgress: initialProgress,
      initialStatus: initialStatus,
      initialPriority: getPriorityValue(initialPriorityStr),
    );
  }

  Widget _buildDiscussionTab(ProjectDetailsViewModel viewModel) {
    final project = viewModel.projectDetails ?? widget.project;
    // Try multiple possible field names for project ID
    final projectId =
        (project['project_id'] ?? project['projectId'] ?? project['id'] ?? '')
            .toString();

    print('=== DISCUSSION TAB ===');
    print('project_id: ${project['project_id']}');
    print('projectId: ${project['projectId']}');
    print('id: ${project['id']}');
    print('Final projectId: $projectId');
    print('');

    return _DiscussionTabContent(
      viewModel: viewModel,
      projectId: projectId,
    );
  }

  Widget _buildBugsTab(ProjectDetailsViewModel viewModel) {
    final project = viewModel.projectDetails ?? widget.project;
    // Try multiple possible field names for project ID
    final projectId =
        (project['project_id'] ?? project['projectId'] ?? project['id'] ?? '')
            .toString();

    return _BugsTabContent(
      viewModel: viewModel,
      projectId: projectId,
    );
  }

  Widget _buildFilesTab(ProjectDetailsViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Project Files',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Add File Form
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        // TODO: File picker
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'File upload functionality will be implemented with API'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Browse'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Add file via API
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Add file functionality will be implemented with API'),
                              ),
                            );
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Attachment List',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              // Files List (placeholder)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    'No files uploaded yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteTab(ProjectDetailsViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Project Note',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                maxLines: 15,
                decoration: const InputDecoration(
                  hintText: 'Project Note',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(
                  text: viewModel.projectDetails?['note']?.toString() ?? '',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // TODO: Save note via API
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Save note functionality will be implemented with API'),
                    ),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiscussionTabContent extends StatefulWidget {
  final ProjectDetailsViewModel viewModel;
  final String projectId;

  const _DiscussionTabContent({
    required this.viewModel,
    required this.projectId,
  });

  @override
  State<_DiscussionTabContent> createState() => _DiscussionTabContentState();
}

class _DiscussionTabContentState extends State<_DiscussionTabContent> {
  final TextEditingController _messageController = TextEditingController();
  File? _selectedFile;
  String? _selectedFileName = null;

  @override
  void initState() {
    super.initState();
    // Load discussions when tab is first opened
    if (widget.projectId.isNotEmpty &&
        widget.viewModel.discussions.isEmpty &&
        !widget.viewModel.isLoadingDiscussions) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.viewModel.loadDiscussions(widget.projectId);
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Project Discussion',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Add Discussion Form
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Message',
                        border: OutlineInputBorder(),
                      ),
                      controller: _messageController,
                    ),
                    const SizedBox(height: 12),
                    // File attachment
                    if (_selectedFile != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.attach_file, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedFileName ?? 'Selected file',
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                setState(() {
                                  _selectedFile = null;
                                  _selectedFileName = null;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () async {
                        // For now, we'll use a simple approach
                        // In a real app, you'd use file_picker package
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'File picker will be implemented. For now, you can add discussions without attachments.'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.attach_file, size: 16),
                      label: const Text('Attachment'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (widget.viewModel.isAddingDiscussion)
                          const Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ElevatedButton(
                          onPressed: widget.viewModel.isAddingDiscussion
                              ? null
                              : () async {
                                  if (_messageController.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please enter a message'),
                                      ),
                                    );
                                    return;
                                  }

                                  // Validate project ID
                                  if (widget.projectId.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Project ID is missing. Please try again.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  print('=== ADDING DISCUSSION ===');
                                  print('Project ID: ${widget.projectId}');
                                  print(
                                      'Message: ${_messageController.text.trim()}');
                                  print('Has file: ${_selectedFile != null}');
                                  print('');

                                  final success =
                                      await widget.viewModel.addDiscussion(
                                    projectId: widget.projectId,
                                    message: _messageController.text.trim(),
                                    attachmentFile: _selectedFile,
                                  );

                                  if (success) {
                                    _messageController.clear();
                                    setState(() {
                                      _selectedFile = null;
                                      _selectedFileName = null;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Discussion added successfully'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          widget.viewModel.errorMessage ??
                                              'Failed to add discussion',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'All Discussions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              // Discussions List
              if (widget.viewModel.isLoadingDiscussions)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (widget.viewModel.discussions.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      'No discussions yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...widget.viewModel.discussions.map((discussion) {
                  final message = discussion['xin_message']?.toString() ?? '';
                  final userName = discussion['employee_name']?.toString() ??
                      discussion['user_name']?.toString() ??
                      'Unknown User';
                  final dateTime = discussion['created_at']?.toString() ??
                      discussion['date']?.toString() ??
                      '';
                  final attachment = discussion['attachment_file']?.toString();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.blue.shade300,
                              child: Text(
                                userName.length > 0
                                    ? userName.substring(0, 1).toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (dateTime.isNotEmpty)
                                    Text(
                                      _formatDateTime(dateTime),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          message,
                          style: const TextStyle(fontSize: 14),
                        ),
                        if (attachment != null && attachment.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.attach_file,
                                    size: 16, color: Colors.blue),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    attachment,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty || dateTimeStr == 'null') {
      return '';
    }
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.day.toString().padLeft(2, '0')}-${_getMonthName(dateTime.month)}-${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}

// Separate stateful widget for Progress tab to manage form state
class _ProgressTabStateful extends StatefulWidget {
  final ProjectDetailsViewModel viewModel;
  final String projectId;
  final int initialProgress;
  final int initialStatus;
  final int initialPriority;

  const _ProgressTabStateful({
    required this.viewModel,
    required this.projectId,
    required this.initialProgress,
    required this.initialStatus,
    required this.initialPriority,
  });

  @override
  State<_ProgressTabStateful> createState() => _ProgressTabStatefulState();
}

class _ProgressTabStatefulState extends State<_ProgressTabStateful> {
  late int _progress;
  late int _status;
  late int _priority;

  @override
  void initState() {
    super.initState();
    _progress = widget.initialProgress;
    _status = widget.initialStatus;
    _priority = widget.initialPriority;
  }

  Future<void> _handleSave() async {
    if (widget.projectId.isEmpty || widget.projectId == 'null') {
      // Debug: Print project data to help identify the issue
      final project = widget.viewModel.projectDetails;
      print('=== PROJECT ID DEBUG ===');
      print('Project ID from widget: ${widget.projectId}');
      print('Project keys: ${project?.keys.toList() ?? 'null'}');
      print('project_id: ${project?['project_id']}');
      print('id: ${project?['id']}');
      print('=======================');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Project ID is missing. Available fields: ${project?.keys.join(', ') ?? 'none'}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

    final success = await widget.viewModel.updateProjectStatus(
      projectId: widget.projectId,
      priority: _priority,
      progressValue: _progress,
      status: _status,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project status updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.viewModel.errorMessage ??
                  'Failed to update project status',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUpdating = widget.viewModel.isUpdating;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Project Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              // Progress Slider
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '$_progress%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _progress.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: '$_progress%',
                    onChanged: isUpdating
                        ? null
                        : (value) {
                            setState(() {
                              _progress = value.round();
                            });
                          },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Status Dropdown
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                value: _status,
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Not Started')),
                  DropdownMenuItem(value: 1, child: Text('In Progress')),
                  DropdownMenuItem(value: 2, child: Text('Completed')),
                  DropdownMenuItem(value: 3, child: Text('Deferred')),
                ],
                onChanged: isUpdating
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            _status = value;
                          });
                        }
                      },
              ),
              const SizedBox(height: 16),
              // Priority Dropdown
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                value: _priority,
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Highest')),
                  DropdownMenuItem(value: 2, child: Text('High')),
                  DropdownMenuItem(value: 3, child: Text('Normal')),
                  DropdownMenuItem(value: 4, child: Text('Low')),
                ],
                onChanged: isUpdating
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            _priority = value;
                          });
                        }
                      },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isUpdating ? null : _handleSave,
                child: isUpdating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BugsTabContent extends StatefulWidget {
  final ProjectDetailsViewModel viewModel;
  final String projectId;

  const _BugsTabContent({
    required this.viewModel,
    required this.projectId,
  });

  @override
  State<_BugsTabContent> createState() => _BugsTabContentState();
}

class _BugsTabContentState extends State<_BugsTabContent> {
  @override
  void initState() {
    super.initState();
    // Load bugs when tab is first opened
    if (widget.projectId.isNotEmpty &&
        widget.viewModel.bugs.isEmpty &&
        !widget.viewModel.isLoadingBugs) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.viewModel.loadBugs(widget.projectId);
      });
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == 'null') {
      return 'N/A';
    }
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}-${_getMonthName(date.month)}-${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  Color _getStatusColor(int? status) {
    switch (status) {
      case 0:
        return Colors.orange; // Pending
      case 1:
        return Colors.blue; // In Progress
      case 2:
        return Colors.green; // Resolved
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(int? status, String? statusLabel) {
    if (statusLabel != null && statusLabel.isNotEmpty) {
      return statusLabel;
    }
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'In Progress';
      case 2:
        return 'Resolved';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Project Bugs/Issues',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'All Bugs/Issues',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              // Bugs List
              if (widget.viewModel.isLoadingBugs)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (widget.viewModel.bugs.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      'No bugs/issues yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...widget.viewModel.bugs.map((bug) {
                  final title = bug['title']?.toString() ?? 'Untitled';
                  final message = bug['message']?.toString() ?? '';
                  final status = bug['status'] is int
                      ? bug['status']
                      : int.tryParse(bug['status']?.toString() ?? '0') ?? 0;
                  final statusLabel = bug['status_label']?.toString();
                  final employeeName =
                      bug['employee_name']?.toString() ?? 'Unknown';
                  final designation = bug['designation']?.toString() ?? '';
                  final profileImage = bug['profile_image']?.toString();
                  final attachment = bug['attachment']?.toString();
                  final date = bug['date']?.toString() ?? '';
                  final time = bug['time']?.toString() ?? '';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Employee info and status
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile image
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: profileImage != null &&
                                      profileImage.isNotEmpty
                                  ? NetworkImage(profileImage)
                                  : null,
                              child:
                                  profileImage == null || profileImage.isEmpty
                                      ? Text(
                                          employeeName.length > 0
                                              ? employeeName
                                                  .substring(0, 1)
                                                  .toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : null,
                              backgroundColor: Colors.blue.shade300,
                            ),
                            const SizedBox(width: 12),
                            // Employee name and designation
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    employeeName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (designation.isNotEmpty)
                                    Text(
                                      designation,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  if (date.isNotEmpty || time.isNotEmpty)
                                    Text(
                                      '${_formatDate(date)} ${time.isNotEmpty ? "at $time" : ""}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Status badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getStatusColor(status),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _getStatusText(status, statusLabel),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(status),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Title
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Message
                        if (message.isNotEmpty)
                          Text(
                            message,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        // Attachment
                        if (attachment != null && attachment.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: InkWell(
                              onTap: () {
                                // TODO: Open attachment URL
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Opening attachment: $attachment'),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.attach_file,
                                      size: 20,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Attachment',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
