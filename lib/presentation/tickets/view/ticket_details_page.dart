import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:bizzhrms_flutter_app/presentation/tickets/view_model/tickets_view_model.dart';

class TicketDetailsPage extends StatefulWidget {
  const TicketDetailsPage(
      {super.key, required this.ticketId, this.initialTicket});

  final String ticketId;
  final Map<String, dynamic>? initialTicket;

  @override
  State<TicketDetailsPage> createState() => _TicketDetailsPageState();
}

class _TicketDetailsPageState extends State<TicketDetailsPage> {
  Map<String, dynamic>? _ticket;
  bool _loading = true;
  String? _error;
  final TicketsViewModel _viewModel = TicketsViewModel();

  @override
  void initState() {
    super.initState();
    _ticket = widget.initialTicket;
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final details = await _viewModel.getTicketDetails(widget.ticketId);
      setState(() {
        if (details != null && details is Map) {
          _ticket = Map<String, dynamic>.from(details);
        } else {
          _ticket = widget.initialTicket;
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

  Future<void> _refreshDetails() async {
    setState(() {
      _loading = true;
    });
    await _fetchDetails();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.blue;
      case 'in progress':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusValue(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return '0';
      case 'in progress':
        return '1';
      case 'resolved':
        return '2';
      case 'closed':
        return '3';
      default:
        return '0';
    }
  }

  void _showEditDialog() {
    final remarksController = TextEditingController(
      text: _ticket!['ticket_remarks']?.toString() ?? '',
    );
    final noteController = TextEditingController(
      text: _ticket!['ticket_note']?.toString() ?? '',
    );
    String selectedStatus = _getStatusValue(_ticket!['status']?.toString() ?? 'Open');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Ticket'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Dropdown
                const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: '0', child: Text('Open')),
                    DropdownMenuItem(value: '1', child: Text('In Progress')),
                    DropdownMenuItem(value: '2', child: Text('Resolved')),
                    DropdownMenuItem(value: '3', child: Text('Closed')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedStatus = value ?? '0';
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Remarks Field
                const Text('Remarks', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: remarksController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter remarks',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                // Note Field
                const Text('Note', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter note',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Show loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                try {
                  final result = await _viewModel.editTicket(
                    widget.ticketId,
                    selectedStatus,
                    remarksController.text.trim(),
                    noteController.text.trim(),
                  );

                  // Hide loading
                  if (mounted) {
                    Navigator.of(context).pop(); // Close loading
                    Navigator.of(context).pop(); // Close edit dialog
                  }

                  if (result != null && result['error'] == null) {
                    // Refresh details
                    await _refreshDetails();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ticket updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result?['error']?.toString() ?? 'Failed to update ticket'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.of(context).pop(); // Close loading
                    Navigator.of(context).pop(); // Close edit dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCommentDialog() {
    final commentController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Comment'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: commentController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter your comment',
              labelText: 'Comment',
            ),
            maxLines: 4,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a comment';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                // Show loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                try {
                  final result = await _viewModel.addTicketComment(
                    widget.ticketId,
                    commentController.text.trim(),
                  );

                  // Hide loading
                  if (mounted) {
                    Navigator.of(context).pop(); // Close loading
                    Navigator.of(context).pop(); // Close comment dialog
                  }

                  if (result != null && result['error'] == null) {
                    // Refresh details to show new comment
                    await _refreshDetails();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Comment added successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result?['error']?.toString() ?? 'Failed to add comment'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.of(context).pop(); // Close loading
                    Navigator.of(context).pop(); // Close comment dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddAttachmentDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    List<File> selectedFiles = [];

    // Allowed file types: gif, png, jpg, jpeg, txt, doc, docx, xls, xlsx
    const allowedExtensions = ['gif', 'png', 'jpg', 'jpeg', 'txt', 'doc', 'docx', 'xls', 'xlsx'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Attachment'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // File Title
                  const Text('File Title', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter file title',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a file title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // File Description
                  const Text('File Description', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter file description',
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a file description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // File Selection
                  const Text('Select Files', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    'Allowed types: gif, png, jpg, jpeg, txt, doc, docx, xls, xlsx',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        FilePickerResult? result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: allowedExtensions,
                          allowMultiple: true,
                        );

                        if (result != null && result.files.isNotEmpty) {
                          setDialogState(() {
                            // Add new files to existing list (don't replace)
                            final newFiles = result.files
                                .where((file) => file.path != null)
                                .map((file) => File(file.path!))
                                .toList();
                            selectedFiles.addAll(newFiles);
                          });
                        }
                      } catch (e) {
                        if (mounted) {
                          String errorMessage = 'Error picking files: $e';
                          // Provide helpful message for MissingPluginException
                          if (e.toString().contains('MissingPluginException')) {
                            errorMessage = 'File picker plugin not initialized. Please restart the app completely (not just hot reload).';
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 5),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.attach_file, size: 18),
                    label: const Text('Pick Files'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  if (selectedFiles.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Selected: ${selectedFiles.length} file(s)',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...selectedFiles.map((file) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.insert_drive_file,
                            size: 16,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              file.path.split(Platform.pathSeparator).last,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              setDialogState(() {
                                selectedFiles.remove(file);
                              });
                            },
                          ),
                        ],
                      ),
                    )),
                  ],
                  if (selectedFiles.isEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'No files selected',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  if (selectedFiles.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select at least one file'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  // Show loading
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  try {
                    final result = await _viewModel.addTicketAttachment(
                      widget.ticketId,
                      selectedFiles,
                      titleController.text.trim(),
                      descriptionController.text.trim(),
                    );

                    // Hide loading
                    if (mounted) {
                      Navigator.of(context).pop(); // Close loading
                      Navigator.of(context).pop(); // Close attachment dialog
                    }

                    if (result != null && result['error'] == null) {
                      // Refresh details to show new attachment
                      await _refreshDetails();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Attachment added successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result?['error']?.toString() ?? 'Failed to add attachment'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.of(context).pop(); // Close loading
                      Navigator.of(context).pop(); // Close attachment dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleDeleteComment(String commentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                final result = await _viewModel.deleteTicketComment(commentId);

                // Hide loading
                if (mounted) {
                  Navigator.of(context).pop(); // Close loading
                  Navigator.of(context).pop(); // Close delete confirmation dialog
                }

                if (result != null && result['error'] == null) {
                  // Refresh details to remove deleted comment
                  await _refreshDetails();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Comment deleted successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result?['error']?.toString() ?? 'Failed to delete comment'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop(); // Close loading
                  Navigator.of(context).pop(); // Close delete confirmation dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _handleDeleteAttachment(String attachmentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Attachment'),
        content: const Text('Are you sure you want to delete this attachment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                final result = await _viewModel.deleteTicketAttachment(attachmentId);

                // Hide loading
                if (mounted) {
                  Navigator.of(context).pop(); // Close loading
                  Navigator.of(context).pop(); // Close delete confirmation dialog
                }

                if (result != null && result['error'] == null) {
                  // Refresh details to remove deleted attachment
                  await _refreshDetails();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Attachment deleted successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result?['error']?.toString() ?? 'Failed to delete attachment'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop(); // Close loading
                  Navigator.of(context).pop(); // Close delete confirmation dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ticket Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ticket Details')),
        body: Center(child: Text(_error!)),
      );
    }
    if (_ticket == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ticket Details')),
        body: const Center(child: Text('No details found')),
      );
    }

    // Get priority and status colors
    final priorityString = _ticket!['priority']?.toString() ?? 'N/A';
    final priorityColor = _viewModel.getPriorityColorFromString(priorityString);
    
    final status = _ticket!['status']?.toString() ?? 'N/A';
    final statusColor = _getStatusColor(status);

    // Get comments and attachments
    final comments = _ticket!['comments'] != null && _ticket!['comments'] is List
        ? _ticket!['comments'] as List
        : <dynamic>[];
    
    final attachments = _ticket!['attachments'] != null && _ticket!['attachments'] is List
        ? _ticket!['attachments'] as List
        : <dynamic>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditDialog,
            tooltip: 'Edit Ticket',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ticket Subject Card
                _InfoCard(
                  icon: Icons.subject_rounded,
                  title: 'Subject',
                  value: _ticket!['subject']?.toString() ?? 'N/A',
                  theme: theme,
                ),

                // Ticket Information Card
                _InfoCard(
                  icon: Icons.info_rounded,
                  title: 'Ticket Information',
                  theme: theme,
                  children: [
                    _InfoItem(
                      label: 'Ticket Code',
                      value: _ticket!['ticket_code']?.toString() ?? 'N/A',
                      icon: Icons.tag_rounded,
                      theme: theme,
                    ),
                    const SizedBox(height: 12),
                    _InfoItem(
                      label: 'Employee Name',
                      value: _ticket!['employee_name']?.toString() ?? 'N/A',
                      icon: Icons.person_rounded,
                      theme: theme,
                    ),
                    const SizedBox(height: 12),
                    _InfoItem(
                      label: 'Created At',
                      value: _ticket!['created_at']?.toString() ?? 'N/A',
                      icon: Icons.calendar_today_rounded,
                      theme: theme,
                    ),
                    if (_ticket!['ticket_id'] != null) ...[
                      const SizedBox(height: 12),
                      _InfoItem(
                        label: 'Ticket ID',
                        value: _ticket!['ticket_id']?.toString() ?? 'N/A',
                        icon: Icons.numbers_rounded,
                        theme: theme,
                      ),
                    ],
                    if (_ticket!['employee_id'] != null) ...[
                      const SizedBox(height: 12),
                      _InfoItem(
                        label: 'Employee ID',
                        value: _ticket!['employee_id']?.toString() ?? 'N/A',
                        icon: Icons.badge_rounded,
                        theme: theme,
                      ),
                    ],
                  ],
                ),

                // Priority and Status Card
                _InfoCard(
                  icon: Icons.flag_rounded,
                  title: 'Priority & Status',
                  theme: theme,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.priority_high_rounded,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Priority',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: priorityColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: priorityColor, width: 1),
                                ),
                                child: Text(
                                  priorityString,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: priorityColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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

                // Ticket Remarks Section
                _InfoCard(
                  icon: Icons.note_rounded,
                  title: 'Remarks',
                  theme: theme,
                  value: _ticket!['ticket_remarks']?.toString() ?? 'No remarks',
                ),

                // Ticket Note Section
                _InfoCard(
                  icon: Icons.sticky_note_2_rounded,
                  title: 'Note',
                  theme: theme,
                  value: _ticket!['ticket_note']?.toString() ?? 'No note',
                ),

                // Message Section
                if (_ticket!['message'] != null &&
                    _ticket!['message'].toString().isNotEmpty)
                  _InfoCard(
                    icon: Icons.message_rounded,
                    title: 'Message',
                    theme: theme,
                    value: _ticket!['message']?.toString() ?? 'N/A',
                  ),

                // Comments Section - Always show with Add button
                _InfoCard(
                  icon: Icons.comment_rounded,
                  title: 'Comments',
                  theme: theme,
                  children: [
                    // Add Comment Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: _showAddCommentDialog,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Comment'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Comments List
                    if (comments.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'No comments yet',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                    else
                      ...comments.asMap().entries.map((entry) {
                        final index = entry.key;
                        final comment = entry.value as Map<String, dynamic>;
                        final commentId = comment['comment_id']?.toString() ?? '';
                        return Padding(
                          padding: EdgeInsets.only(
                              bottom: index < comments.length - 1 ? 16 : 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.comment_rounded,
                                    size: 18,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comment['ticket_comments']
                                                  ?.toString() ??
                                              'N/A',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        if (comment['created_at'] != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            'Posted: ${comment['created_at']?.toString() ?? 'N/A'}',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: theme
                                                  .colorScheme.onSurfaceVariant,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (commentId.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 18),
                                      color: Colors.red,
                                      onPressed: () => _handleDeleteComment(commentId),
                                      tooltip: 'Delete Comment',
                                    ),
                                ],
                              ),
                              if (index < comments.length - 1)
                                const Divider(height: 24),
                            ],
                          ),
                        );
                      }).toList(),
                  ],
                ),

                // Attachments Section - Always show with Add button
                _InfoCard(
                  icon: Icons.attach_file_rounded,
                  title: 'Attachments',
                  theme: theme,
                  children: [
                    // Add Attachment Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: _showAddAttachmentDialog,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Attachment'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Attachments List
                    if (attachments.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'No attachments yet',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                    else
                      ...attachments.asMap().entries.map((entry) {
                        final index = entry.key;
                        final attachment = entry.value as Map<String, dynamic>;
                        final attachmentId = attachment['attachment_id']?.toString() ?? 
                                           attachment['id']?.toString() ?? '';
                        final fileName = attachment['file_name']?.toString() ?? 
                                       attachment['name']?.toString() ?? 
                                       'Unknown file';
                        return Padding(
                          padding: EdgeInsets.only(
                              bottom: index < attachments.length - 1 ? 16 : 0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.attach_file_rounded,
                                size: 18,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  fileName,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              if (attachmentId.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 18),
                                  color: Colors.red,
                                  onPressed: () => _handleDeleteAttachment(attachmentId),
                                  tooltip: 'Delete Attachment',
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                  ],
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
