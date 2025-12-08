import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:bizzhrms_flutter_app/core/constants/app_constants.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';
import 'package:bizzhrms_flutter_app/data/data_sources/remote_data_source.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/header/header_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/sidebar/sidebar_widget.dart';
import 'package:bizzhrms_flutter_app/presentation/shared/widgets/common/back_button_widget.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Get token and user_id from preferences
        final token = await PreferencesHelper.getUserToken();
        final userId = await PreferencesHelper.getUserId();

        if (token == null || token.isEmpty) {
          throw Exception('Please login again');
        }

        if (userId == null || userId.isEmpty) {
          throw Exception('User ID not found. Please login again');
        }

        // Call change password API
        final remoteDataSource = RemoteDataSource();
        final response = await remoteDataSource.changePassword(
          token,
          userId,
          _newPasswordController.text,
          _confirmPasswordController.text,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          // Check if password change was successful
          if (response['status'] == true) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    response['message'] ?? 'Password changed successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );

            // Clear form
            _currentPasswordController.clear();
            _newPasswordController.clear();
            _confirmPasswordController.clear();

            // Navigate back after a short delay
            await Future.delayed(const Duration(milliseconds: 500));
            if (mounted) {
              Navigator.pop(context);
            }
          } else {
            // Show error message from API
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(response['message'] ?? 'Failed to change password'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        if (isMobile) {
          // Mobile: Drawer instead of sidebar
          return Scaffold(
            drawer: Drawer(
              child: SafeArea(
                child: SidebarWidget(
                  currentRoute: AppConstants.routeChangePassword,
                ),
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // Header with drawer button
                  const HeaderWidget(pageTitle: 'Change Password'),
                  // Back Button with Title
                  const BackButtonWidget(title: 'Change Password'),
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.all(24.0),
                      child: _buildForm(),
                    ),
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
                    currentRoute: AppConstants.routeChangePassword,
                  ),
                  // Main Content
                  Expanded(
                    child: Column(
                      children: [
                        // Header
                        const HeaderWidget(pageTitle: 'Change Password'),
                        // Back Button with Title
                        const BackButtonWidget(title: 'Change Password'),
                        // Content
                        Expanded(
                          child: SingleChildScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: const EdgeInsets.all(24.0),
                            child: _buildForm(),
                          ),
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
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Instructions Card
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.shade200,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  FontAwesomeIcons.circleInfo,
                  color: Colors.blue.shade700,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Please enter your current password and choose a new password.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Current Password Field
          TextFormField(
            controller: _currentPasswordController,
            obscureText: _obscureCurrentPassword,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.text,
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: 'Current Password',
              prefixIcon: const Icon(
                FontAwesomeIcons.lock,
                color: Color(0xFF2C3E50),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureCurrentPassword
                      ? FontAwesomeIcons.eye
                      : FontAwesomeIcons.eyeSlash,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscureCurrentPassword = !_obscureCurrentPassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter current password';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          // New Password Field
          TextFormField(
            controller: _newPasswordController,
            obscureText: _obscureNewPassword,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.text,
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: 'New Password',
              prefixIcon: const Icon(
                FontAwesomeIcons.key,
                color: Color(0xFF2C3E50),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNewPassword
                      ? FontAwesomeIcons.eye
                      : FontAwesomeIcons.eyeSlash,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter new password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          // Confirm Password Field
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.text,
            enableSuggestions: false,
            autocorrect: false,
            onFieldSubmitted: (_) {
              if (_formKey.currentState!.validate()) {
                _handleChangePassword();
              }
            },
            decoration: InputDecoration(
              labelText: 'Confirm New Password',
              prefixIcon: const Icon(
                FontAwesomeIcons.lock,
                color: Color(0xFF2C3E50),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? FontAwesomeIcons.eye
                      : FontAwesomeIcons.eyeSlash,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm new password';
              }
              if (value != _newPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          // Change Password Button
          ElevatedButton(
            onPressed: _isLoading ? null : _handleChangePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C3E50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  )
                : const Text(
                    'Change Password',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
