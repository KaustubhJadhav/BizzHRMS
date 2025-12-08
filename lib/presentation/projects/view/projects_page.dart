import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../view_model/projects_view_model.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/sidebar/sidebar_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/header/header_widget.dart';
import 'package:bizzhrms_flutter_app/core/constants/app_constants.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/loading_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/error_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/back_button_widget.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  final TextEditingController _searchController = TextEditingController();
  int _entriesPerPage = 10;
  int _currentPage = 1;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredProjects(ProjectsViewModel viewModel) {
    List<Map<String, dynamic>> projects = viewModel.projectsList;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      projects = projects.where((project) {
        final title = project['title']?.toString().toLowerCase() ?? '';
        final summary = project['summary']?.toString().toLowerCase() ?? '';
        final priority = project['priority']?.toString().toLowerCase() ?? '';
        final createdBy = project['created_by']?.toString().toLowerCase() ?? '';
        final assignedTo = (project['assigned_to'] as List?)
                ?.map((e) => e.toString().toLowerCase())
                .join(' ') ??
            '';
        final query = _searchQuery.toLowerCase();
        return title.contains(query) ||
            summary.contains(query) ||
            priority.contains(query) ||
            createdBy.contains(query) ||
            assignedTo.contains(query);
      }).toList();
    }

    return projects;
  }

  List<Map<String, dynamic>> _getPaginatedProjects(
      ProjectsViewModel viewModel) {
    final filtered = _getFilteredProjects(viewModel);
    final startIndex = (_currentPage - 1) * _entriesPerPage;
    final endIndex = startIndex + _entriesPerPage;
    if (endIndex > filtered.length) {
      return filtered.sublist(startIndex);
    }
    return filtered.sublist(startIndex, endIndex);
  }

  int _getTotalPages(ProjectsViewModel viewModel) {
    return (_getFilteredProjects(viewModel).length / _entriesPerPage).ceil();
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'normal':
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProjectsViewModel()..loadProjectsData(),
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
                const HeaderWidget(pageTitle: 'Projects'),
                const BackButtonWidget(title: 'Projects'),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Consumer<ProjectsViewModel>(
                      builder: (context, viewModel, child) {
                        if (viewModel.status == ProjectsStatus.loading) {
                          return const LoadingWidget(
                              message: 'Loading projects...');
                        }

                        if (viewModel.status == ProjectsStatus.error) {
                          return ErrorDisplayWidget(
                            message: viewModel.errorMessage ??
                                'Failed to load projects',
                            onRetry: () => viewModel.refresh(),
                          );
                        }

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                const Text(
                                  'List All Projects',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Controls: Entries per page and Search
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final isSmallScreen =
                                        constraints.maxWidth < 600;

                                    if (isSmallScreen) {
                                      // Stack vertically on small screens
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Entries per page
                                          Row(
                                            children: [
                                              const Text('Show'),
                                              const SizedBox(width: 8),
                                              DropdownButton<int>(
                                                value: _entriesPerPage,
                                                items: [10, 25, 50, 100]
                                                    .map((value) =>
                                                        DropdownMenuItem(
                                                          value: value,
                                                          child: Text(
                                                              value.toString()),
                                                        ))
                                                    .toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    _entriesPerPage =
                                                        value ?? 10;
                                                    _currentPage = 1;
                                                  });
                                                },
                                              ),
                                              const SizedBox(width: 8),
                                              const Text('entries'),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          // Search
                                          Row(
                                            children: [
                                              const Text('Search:'),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: TextField(
                                                  controller: _searchController,
                                                  decoration:
                                                      const InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 8),
                                                  ),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _searchQuery = value;
                                                      _currentPage = 1;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    } else {
                                      // Horizontal layout on larger screens
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Entries per page
                                          Row(
                                            children: [
                                              const Text('Show'),
                                              const SizedBox(width: 8),
                                              DropdownButton<int>(
                                                value: _entriesPerPage,
                                                items: [10, 25, 50, 100]
                                                    .map((value) =>
                                                        DropdownMenuItem(
                                                          value: value,
                                                          child: Text(
                                                              value.toString()),
                                                        ))
                                                    .toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    _entriesPerPage =
                                                        value ?? 10;
                                                    _currentPage = 1;
                                                  });
                                                },
                                              ),
                                              const SizedBox(width: 8),
                                              const Text('entries'),
                                            ],
                                          ),

                                          // Search
                                          Row(
                                            children: [
                                              const Text('Search:'),
                                              const SizedBox(width: 8),
                                              SizedBox(
                                                width: 200,
                                                child: TextField(
                                                  controller: _searchController,
                                                  decoration:
                                                      const InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 8),
                                                  ),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _searchQuery = value;
                                                      _currentPage = 1;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Table
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SingleChildScrollView(
                                      child: DataTable(
                                        columns: const [
                                          DataColumn(
                                            label: Row(
                                              children: [
                                                Text('Action'),
                                                SizedBox(width: 4),
                                                Icon(Icons.swap_vert, size: 16),
                                              ],
                                            ),
                                          ),
                                          DataColumn(
                                            label: Row(
                                              children: [
                                                Text('Project Summary'),
                                                SizedBox(width: 4),
                                                Icon(Icons.swap_vert, size: 16),
                                              ],
                                            ),
                                          ),
                                          DataColumn(
                                            label: Row(
                                              children: [
                                                Text('Priority'),
                                                SizedBox(width: 4),
                                                Icon(Icons.swap_vert, size: 16),
                                              ],
                                            ),
                                          ),
                                          DataColumn(
                                            label: Row(
                                              children: [
                                                Text('End Date'),
                                                SizedBox(width: 4),
                                                Icon(Icons.swap_vert, size: 16),
                                              ],
                                            ),
                                          ),
                                          DataColumn(
                                            label: Row(
                                              children: [
                                                Text('Progress'),
                                                SizedBox(width: 4),
                                                Icon(Icons.swap_vert, size: 16),
                                              ],
                                            ),
                                          ),
                                          DataColumn(
                                            label: Row(
                                              children: [
                                                Text('Assigned users'),
                                                SizedBox(width: 4),
                                                Icon(Icons.swap_vert, size: 16),
                                              ],
                                            ),
                                          ),
                                        ],
                                        rows: _getPaginatedProjects(viewModel)
                                            .map((project) {
                                          final progress =
                                              project['progress'] ?? 0;
                                          final progressInt = progress is int
                                              ? progress
                                              : int.tryParse(
                                                      progress.toString()) ??
                                                  0;
                                          final priority =
                                              project['priority']?.toString() ??
                                                  'Normal';
                                          final assignedTo =
                                              project['assigned_to'] as List?;

                                          return DataRow(
                                            cells: [
                                              // Action
                                              DataCell(
                                                IconButton(
                                                  icon: const Icon(
                                                    FontAwesomeIcons.arrowRight,
                                                    size: 16,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pushNamed(
                                                      context,
                                                      AppConstants
                                                          .routeProjectDetails,
                                                      arguments: project,
                                                    );
                                                  },
                                                ),
                                              ),
                                              // Project Summary
                                              DataCell(
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.pushNamed(
                                                          context,
                                                          AppConstants
                                                              .routeProjectDetails,
                                                          arguments: project,
                                                        );
                                                      },
                                                      child: Text(
                                                        project['title']
                                                                ?.toString() ??
                                                            'N/A',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.blue,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      project['summary']
                                                              ?.toString() ??
                                                          '',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors
                                                            .grey.shade600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Priority
                                              DataCell(
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _getPriorityColor(
                                                        priority),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: Text(
                                                    priority,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // End Date
                                              DataCell(
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      FontAwesomeIcons.calendar,
                                                      size: 14,
                                                      color: Colors.grey,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      project['end_date']
                                                              ?.toString() ??
                                                          'N/A',
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Progress
                                              DataCell(
                                                Text(
                                                  'Completed $progressInt%',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ),
                                              // Assigned users
                                              DataCell(
                                                assignedTo != null &&
                                                        assignedTo.isNotEmpty
                                                    ? Row(
                                                        children: List.generate(
                                                          assignedTo.length > 3
                                                              ? 3
                                                              : assignedTo
                                                                  .length,
                                                          (index) {
                                                            return Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      right: 4),
                                                              width: 32,
                                                              height: 32,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .blue
                                                                    .shade300,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              child: Center(
                                                                child: Text(
                                                                  assignedTo[index]
                                                                          ?.toString()
                                                                          .substring(
                                                                              0,
                                                                              1)
                                                                          .toUpperCase() ??
                                                                      '?',
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      )
                                                    : const Text('N/A'),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Pagination
                                Builder(
                                  builder: (context) {
                                    final filteredProjects =
                                        _getFilteredProjects(viewModel);
                                    final paginatedProjects =
                                        _getPaginatedProjects(viewModel);
                                    final totalPages =
                                        _getTotalPages(viewModel);

                                    return LayoutBuilder(
                                      builder: (context, constraints) {
                                        final isSmallScreen =
                                            constraints.maxWidth < 600;

                                        if (isSmallScreen) {
                                          // Stack vertically on small screens
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Entry summary
                                              Text(
                                                'Showing ${paginatedProjects.isEmpty ? 0 : (_currentPage - 1) * _entriesPerPage + 1} to ${paginatedProjects.isEmpty ? 0 : (_currentPage - 1) * _entriesPerPage + paginatedProjects.length} of ${filteredProjects.length} entries',
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                              const SizedBox(height: 12),
                                              // Pagination buttons - wrap if needed
                                              Wrap(
                                                alignment: WrapAlignment.start,
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: [
                                                  // Previous button
                                                  TextButton(
                                                    onPressed: _currentPage > 1
                                                        ? () {
                                                            setState(() {
                                                              _currentPage--;
                                                            });
                                                          }
                                                        : null,
                                                    child:
                                                        const Text('Previous'),
                                                  ),
                                                  // Page numbers
                                                  ...List.generate(
                                                    totalPages,
                                                    (index) {
                                                      final pageNum = index + 1;
                                                      return TextButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            _currentPage =
                                                                pageNum;
                                                          });
                                                        },
                                                        style: TextButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              _currentPage ==
                                                                      pageNum
                                                                  ? Colors.blue
                                                                  : null,
                                                          foregroundColor:
                                                              _currentPage ==
                                                                      pageNum
                                                                  ? Colors.white
                                                                  : null,
                                                          minimumSize:
                                                              const Size(
                                                                  40, 40),
                                                          padding:
                                                              EdgeInsets.zero,
                                                        ),
                                                        child: Text(
                                                            pageNum.toString()),
                                                      );
                                                    },
                                                  ),
                                                  // Next button
                                                  TextButton(
                                                    onPressed: _currentPage <
                                                            totalPages
                                                        ? () {
                                                            setState(() {
                                                              _currentPage++;
                                                            });
                                                          }
                                                        : null,
                                                    child: const Text('Next'),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        } else {
                                          // Horizontal layout on larger screens
                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Entry summary
                                              Flexible(
                                                child: Text(
                                                  'Showing ${paginatedProjects.isEmpty ? 0 : (_currentPage - 1) * _entriesPerPage + 1} to ${paginatedProjects.isEmpty ? 0 : (_currentPage - 1) * _entriesPerPage + paginatedProjects.length} of ${filteredProjects.length} entries',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),

                                              // Pagination buttons
                                              Flexible(
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    // Previous button
                                                    TextButton(
                                                      onPressed:
                                                          _currentPage > 1
                                                              ? () {
                                                                  setState(() {
                                                                    _currentPage--;
                                                                  });
                                                                }
                                                              : null,
                                                      child: const Text(
                                                          'Previous'),
                                                    ),
                                                    const SizedBox(width: 8),

                                                    // Page numbers - limit visible pages on very small screens
                                                    ...List.generate(
                                                      totalPages > 10
                                                          ? 10
                                                          : totalPages,
                                                      (index) {
                                                        final pageNum =
                                                            index + 1;
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      4),
                                                          child: TextButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                _currentPage =
                                                                    pageNum;
                                                              });
                                                            },
                                                            style: TextButton
                                                                .styleFrom(
                                                              backgroundColor:
                                                                  _currentPage ==
                                                                          pageNum
                                                                      ? Colors
                                                                          .blue
                                                                      : null,
                                                              foregroundColor:
                                                                  _currentPage ==
                                                                          pageNum
                                                                      ? Colors
                                                                          .white
                                                                      : null,
                                                              minimumSize:
                                                                  const Size(
                                                                      40, 40),
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                            ),
                                                            child: Text(pageNum
                                                                .toString()),
                                                          ),
                                                        );
                                                      },
                                                    ),

                                                    const SizedBox(width: 8),

                                                    // Next button
                                                    TextButton(
                                                      onPressed: _currentPage <
                                                              totalPages
                                                          ? () {
                                                              setState(() {
                                                                _currentPage++;
                                                              });
                                                            }
                                                          : null,
                                                      child: const Text('Next'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
