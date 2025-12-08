import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bizzhrms_flutter_app/core/constants/app_constants.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/header/header_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/sidebar/sidebar_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/back_button_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/loading_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/error_widget.dart';
import '../view_model/profile_view_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditMode = true; // Open in edit mode by default
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _initializeControllers(Map<String, dynamic> userData) {
    // Only create controllers if they don't exist, otherwise update text
    _controllers['first_name'] ??= TextEditingController();
    _controllers['first_name']!.text = userData['first_name']?.toString() ?? '';

    _controllers['last_name'] ??= TextEditingController();
    _controllers['last_name']!.text = userData['last_name']?.toString() ?? '';

    _controllers['email'] ??= TextEditingController();
    _controllers['email']!.text = userData['email']?.toString() ?? '';

    _controllers['contact_no'] ??= TextEditingController();
    _controllers['contact_no']!.text = userData['contact_no']?.toString() ?? '';

    _controllers['address'] ??= TextEditingController();
    _controllers['address']!.text = userData['address']?.toString() ?? '';

    _controllers['skype_id'] ??= TextEditingController();
    _controllers['skype_id']!.text = userData['skype_id']?.toString() ?? '';

    _controllers['facebook_link'] ??= TextEditingController();
    _controllers['facebook_link']!.text =
        userData['facebook_link']?.toString() ?? '';

    _controllers['twitter_link'] ??= TextEditingController();
    _controllers['twitter_link']!.text =
        userData['twitter_link']?.toString() ?? '';

    _controllers['linkdedin_link'] ??= TextEditingController();
    _controllers['linkdedin_link']!.text =
        userData['linkdedin_link']?.toString() ?? '';

    _controllers['instagram_link'] ??= TextEditingController();
    _controllers['instagram_link']!.text =
        userData['instagram_link']?.toString() ?? '';

    _controllers['youtube_link'] ??= TextEditingController();
    _controllers['youtube_link']!.text =
        userData['youtube_link']?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel()..loadProfileData(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;

          if (isMobile) {
            // Mobile: Drawer instead of sidebar
            return Scaffold(
              drawer: Drawer(
                child: SafeArea(
                  child: SidebarWidget(currentRoute: AppConstants.routeProfile),
                ),
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    // Header with drawer button
                    const HeaderWidget(pageTitle: 'My Profile'),
                    // Back Button with Title
                    const BackButtonWidget(title: 'My Profile'),
                    // Content
                    Expanded(
                      child: _buildContent(),
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
                        currentRoute: AppConstants.routeProfile),
                    // Main Content
                    Expanded(
                      child: Column(
                        children: [
                          // Header
                          const HeaderWidget(pageTitle: 'My Profile'),
                          // Back Button with Title
                          const BackButtonWidget(title: 'My Profile'),
                          // Content
                          Expanded(
                            child: _buildContent(),
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

  Widget _buildContent() {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.status == ProfileStatus.loading) {
          return const LoadingWidget(message: 'Loading profile...');
        }

        if (viewModel.status == ProfileStatus.error) {
          return ErrorDisplayWidget(
            message: viewModel.errorMessage ?? 'Failed to load profile',
            onRetry: () => viewModel.refresh(),
          );
        }

        final userData = viewModel.userData;
        if (userData == null) {
          return const LoadingWidget(message: 'Loading profile...');
        }

        // Initialize or update controllers when data changes
        _initializeControllers(userData);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header Card with Edit Toggle
              _buildProfileHeader(context, viewModel, userData),
              const SizedBox(height: 24),
              // Personal Information Section
              _buildSectionTitle('Personal Information'),
              const SizedBox(height: 16),
              _buildEditableField(
                icon: FontAwesomeIcons.user,
                label: 'First Name',
                controller: _controllers['first_name']!,
                enabled: _isEditMode,
              ),
              const SizedBox(height: 12),
              _buildEditableField(
                icon: FontAwesomeIcons.user,
                label: 'Last Name',
                controller: _controllers['last_name']!,
                enabled: _isEditMode,
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: FontAwesomeIcons.calendar,
                title: 'Date of Birth',
                value:
                    viewModel.formatDate(userData['date_of_birth']?.toString()),
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: FontAwesomeIcons.venusMars,
                title: 'Gender',
                value: userData['gender']?.toString() ?? 'N/A',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: FontAwesomeIcons.heart,
                title: 'Marital Status',
                value: userData['marital_status']?.toString() ?? 'N/A',
              ),
              const SizedBox(height: 24),
              // Contact Information Section
              _buildSectionTitle('Contact Information'),
              const SizedBox(height: 16),
              _buildEditableField(
                icon: FontAwesomeIcons.envelope,
                label: 'Email',
                controller: _controllers['email']!,
                enabled: _isEditMode,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              _buildEditableField(
                icon: FontAwesomeIcons.phone,
                label: 'Contact Number',
                controller: _controllers['contact_no']!,
                enabled: _isEditMode,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _buildEditableField(
                icon: FontAwesomeIcons.locationDot,
                label: 'Address',
                controller: _controllers['address']!,
                enabled: _isEditMode,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              _buildEditableField(
                icon: FontAwesomeIcons.skype,
                label: 'Skype ID',
                controller: _controllers['skype_id']!,
                enabled: _isEditMode,
              ),
              const SizedBox(height: 24),
              // Work Information Section
              _buildSectionTitle('Work Information'),
              const SizedBox(height: 16),
              _buildInfoCard(
                icon: FontAwesomeIcons.idCard,
                title: 'Employee ID',
                value: userData['employee_id']?.toString() ?? 'N/A',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: FontAwesomeIcons.user,
                title: 'Username',
                value: userData['username']?.toString() ?? 'N/A',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: FontAwesomeIcons.building,
                title: 'Department ID',
                value: userData['department_id']?.toString() ?? 'N/A',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: FontAwesomeIcons.briefcase,
                title: 'Designation ID',
                value: userData['designation_id']?.toString() ?? 'N/A',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: FontAwesomeIcons.building,
                title: 'Company ID',
                value: userData['company_id']?.toString() ?? 'N/A',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: FontAwesomeIcons.clock,
                title: 'Office Shift ID',
                value: userData['office_shift_id']?.toString() ?? 'N/A',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: FontAwesomeIcons.calendarDays,
                title: 'Date of Joining',
                value: viewModel
                    .formatDate(userData['date_of_joining']?.toString()),
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: FontAwesomeIcons.calendarXmark,
                title: 'Date of Leaving',
                value: viewModel
                    .formatDate(userData['date_of_leaving']?.toString()),
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: FontAwesomeIcons.dollarSign,
                title: 'Salary',
                value: userData['salary']?.toString().isEmpty ?? true
                    ? 'N/A'
                    : userData['salary']?.toString() ?? 'N/A',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: FontAwesomeIcons.fileLines,
                title: 'Salary Template',
                value: userData['salary_template']?.toString().isEmpty ?? true
                    ? 'N/A'
                    : userData['salary_template']?.toString() ?? 'N/A',
              ),
              const SizedBox(height: 24),
              // Social Media Section
              _buildSectionTitle('Social Media'),
              const SizedBox(height: 16),
              _buildInfoCard(
                icon: FontAwesomeIcons.facebook,
                title: 'Facebook',
                value: userData['facebook_link']?.toString().isEmpty ?? true
                    ? 'N/A'
                    : userData['facebook_link']?.toString() ?? 'N/A',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: FontAwesomeIcons.twitter,
                title: 'Twitter',
                value: userData['twitter_link']?.toString().isEmpty ?? true
                    ? 'N/A'
                    : userData['twitter_link']?.toString() ?? 'N/A',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: FontAwesomeIcons.linkedin,
                title: 'LinkedIn',
                value: userData['linkdedin_link']?.toString().isEmpty ?? true
                    ? 'N/A'
                    : userData['linkdedin_link']?.toString() ?? 'N/A',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: FontAwesomeIcons.instagram,
                title: 'Instagram',
                value: userData['instagram_link']?.toString().isEmpty ?? true
                    ? 'N/A'
                    : userData['instagram_link']?.toString() ?? 'N/A',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: FontAwesomeIcons.youtube,
                title: 'YouTube',
                value: userData['youtube_link']?.toString().isEmpty ?? true
                    ? 'N/A'
                    : userData['youtube_link']?.toString() ?? 'N/A',
              ),
              const SizedBox(height: 24),
              // System Information Section
              _buildSectionTitle('System Information'),
              const SizedBox(height: 16),
              _buildInfoCard(
                icon: FontAwesomeIcons.user,
                title: 'User ID',
                value: userData['user_id']?.toString() ?? 'N/A',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: FontAwesomeIcons.shield,
                title: 'User Role ID',
                value: userData['user_role_id']?.toString() ?? 'N/A',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: FontAwesomeIcons.clock,
                title: 'Last Login',
                value: viewModel
                    .formatDateTime(userData['last_login_date']?.toString()),
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: FontAwesomeIcons.arrowRightFromBracket,
                title: 'Last Logout',
                value: viewModel
                    .formatDateTime(userData['last_logout_date']?.toString()),
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: FontAwesomeIcons.networkWired,
                title: 'Last Login IP',
                value: userData['last_login_ip']?.toString() ?? 'N/A',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: FontAwesomeIcons.circleCheck,
                title: 'Status',
                value: userData['is_active'] == '1' ? 'Active' : 'Inactive',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: FontAwesomeIcons.circleDot,
                title: 'Online Status',
                value: userData['online'] == '1' ? 'Online' : 'Offline',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: FontAwesomeIcons.calendar,
                title: 'Account Created',
                value: viewModel
                    .formatDateTime(userData['created_at']?.toString()),
              ),
              // Save/Cancel buttons when in edit mode
              if (_isEditMode) ...[
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isEditMode = false;
                          // Reset controllers to original values
                          _initializeControllers(userData);
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => _saveProfile(context, viewModel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C3E50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                      ),
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, ProfileViewModel viewModel,
      Map<String, dynamic> userData) {
    final profilePicUrl = viewModel.getProfilePictureUrl();
    final fullName =
        '${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}'.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Avatar with edit button
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                  border: Border.all(
                    color: Colors.blue.shade300,
                    width: 3,
                  ),
                ),
                child: profilePicUrl.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          profilePicUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              FontAwesomeIcons.user,
                              color: Colors.white,
                              size: 50,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        FontAwesomeIcons.user,
                        color: Colors.white,
                        size: 50,
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () =>
                        _pickAndUploadProfilePicture(context, viewModel),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C3E50),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        FontAwesomeIcons.camera,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            fullName.isEmpty ? 'N/A' : fullName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          // Email
          Text(
            userData['email']?.toString().isEmpty ?? true
                ? 'No email provided'
                : userData['email']?.toString() ?? 'No email provided',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          // Employee ID
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Employee ID: ${userData['employee_id']?.toString() ?? 'N/A'}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2C3E50),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.blue,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF2C3E50),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required bool enabled,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enabled ? const Color(0xFF2C3E50) : Colors.grey.shade200,
          width: enabled ? 2 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: enabled ? Colors.blue.shade50 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: enabled ? Colors.blue : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: enabled
                ? TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    maxLines: maxLines,
                    decoration: InputDecoration(
                      labelText: label,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 4),
                      labelStyle: TextStyle(
                        color: enabled ? const Color(0xFF2C3E50) : Colors.grey,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF2C3E50),
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.text.isEmpty ? 'N/A' : controller.text,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2C3E50),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile(
      BuildContext context, ProfileViewModel viewModel) async {
    final profileData = <String, dynamic>{};

    if (_controllers['first_name']!.text.isNotEmpty) {
      profileData['first_name'] = _controllers['first_name']!.text.trim();
    }
    if (_controllers['last_name']!.text.isNotEmpty) {
      profileData['last_name'] = _controllers['last_name']!.text.trim();
    }
    if (_controllers['email']!.text.isNotEmpty) {
      profileData['email'] = _controllers['email']!.text.trim();
    }
    if (_controllers['contact_no']!.text.isNotEmpty) {
      profileData['contact_no'] = _controllers['contact_no']!.text.trim();
    }
    if (_controllers['address']!.text.isNotEmpty) {
      profileData['address'] = _controllers['address']!.text.trim();
    }
    if (_controllers['skype_id']!.text.isNotEmpty) {
      profileData['skype_id'] = _controllers['skype_id']!.text.trim();
    }
    if (_controllers['facebook_link']!.text.isNotEmpty) {
      profileData['facebook_link'] = _controllers['facebook_link']!.text.trim();
    }
    if (_controllers['twitter_link']!.text.isNotEmpty) {
      profileData['twitter_link'] = _controllers['twitter_link']!.text.trim();
    }
    if (_controllers['linkdedin_link']!.text.isNotEmpty) {
      profileData['linkdedin_link'] =
          _controllers['linkdedin_link']!.text.trim();
    }
    if (_controllers['instagram_link']!.text.isNotEmpty) {
      profileData['instagram_link'] =
          _controllers['instagram_link']!.text.trim();
    }
    if (_controllers['youtube_link']!.text.isNotEmpty) {
      profileData['youtube_link'] = _controllers['youtube_link']!.text.trim();
    }

    if (profileData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill at least one field')),
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

    final success = await viewModel.updateProfile(profileData);

    if (context.mounted) {
      Navigator.pop(context); // Close loading dialog

      if (success) {
        setState(() {
          _isEditMode = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage ?? 'Failed to update profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickAndUploadProfilePicture(
      BuildContext context, ProfileViewModel viewModel) async {
    final ImagePicker picker = ImagePicker();

    // Show options: Camera or Gallery
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(FontAwesomeIcons.camera),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(FontAwesomeIcons.image),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      // Pick image
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) return;

      // Show loading dialog
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Upload image
      final imageFile = File(image.path);
      final success = await viewModel.updateProfilePicture(imageFile);

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  viewModel.errorMessage ?? 'Failed to update profile picture'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
