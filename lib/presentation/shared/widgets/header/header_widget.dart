import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:bizzhrms_flutter_app/core/constants/app_constants.dart';
import 'package:bizzhrms_flutter_app/presentation/auth/view_model/auth_view_model.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';

class HeaderWidget extends StatelessWidget {
  final String? pageTitle;
  final VoidCallback? onSidebarToggle;
  final bool showMenu;

  const HeaderWidget({
    super.key,
    this.pageTitle,
    this.onSidebarToggle,
    this.showMenu = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color.fromARGB(255, 3, 89, 160),
            width: 2,
          ),
          bottom: BorderSide(
            color: Color.fromARGB(255, 3, 89, 160),
            width: 2,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Sidebar Toggle - opens drawer (only if showMenu is true)
          if (showMenu)
            Builder(
              builder: (context) => IconButton(
                icon:
                    const Icon(FontAwesomeIcons.bars, color: Color(0xFF2C3E50)),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
          if (showMenu) const SizedBox(width: 16),
          // Logo
          Expanded(
            child: _buildLogo(context),
          ),
          // User Profile Dropdown
          _buildUserProfile(context),
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to home screen when logo is clicked
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppConstants.routeHome,
          (route) => false,
        );
      },
      child: Row(
        children: [
          // BizzHRMS Logo Image
          Image.asset(
            'assets/images/BizzHRMS-Orange.png',
            height: 40,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback if image not found
              return const Text(
                'BizzHRMS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(-20, 50),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300, width: 2),
          color: Colors.blue,
        ),
        child: const Icon(
          FontAwesomeIcons.user,
          color: Colors.white,
          size: 20,
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(FontAwesomeIcons.user, size: 16),
              SizedBox(width: 8),
              Text('My Profile'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'password',
          child: Row(
            children: [
              Icon(FontAwesomeIcons.key, size: 16),
              SizedBox(width: 8),
              Text('Change Password'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(FontAwesomeIcons.arrowRightFromBracket, size: 16),
              SizedBox(width: 8),
              Text('Sign out'),
            ],
          ),
        ),
      ],
      onSelected: (value) async {
        if (value == 'profile') {
          Navigator.pushNamed(context, AppConstants.routeDashboard);
        } else if (value == 'password') {
          Navigator.pushNamed(context, AppConstants.routeChangePassword);
        } else if (value == 'logout') {
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
            // If logout fails, still navigate to sign in and clear local data
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
      },
    );
  }
}
