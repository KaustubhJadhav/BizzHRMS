import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../view_model/auth_view_model.dart';
import 'package:bizzhrms_flutter_app/core/constants/app_constants.dart';
import 'package:bizzhrms_flutter_app/core/utils/preferences_helper.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _adminUsernameController = TextEditingController();
  final _adminPasswordController = TextEditingController();
  final _adminFormKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _adminObscurePassword = true;
  bool _rememberMe = false;
  bool _adminRememberMe = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkAuthenticationAndLoadCredentials();
  }

  Future<void> _checkAuthenticationAndLoadCredentials() async {
    // Check if user is already authenticated
    final token = PreferencesHelper.getUserToken();
    final userId = PreferencesHelper.getUserId();

    if (token != null &&
        token.isNotEmpty &&
        userId != null &&
        userId.isNotEmpty) {
      // User is already logged in, navigate to home
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppConstants.routeHome);
        }
      });
      return;
    }

    // Load saved credentials if "Remember Me" was checked
    final rememberMe = PreferencesHelper.getRememberMe();
    if (rememberMe) {
      final savedUsername = PreferencesHelper.getUsername();
      final savedPassword = PreferencesHelper.getPassword();

      if (savedUsername != null && savedPassword != null) {
        // Check if it's admin or user based on saved role
        final savedRole = PreferencesHelper.getUserRole();
        if (savedRole == 'admin') {
          setState(() {
            _adminRememberMe = true;
            _adminUsernameController.text = savedUsername;
            _adminPasswordController.text = savedPassword;
            // Switch to admin tab after a small delay to ensure tab controller is ready
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _tabController.index != 1) {
                _tabController.animateTo(1);
              }
            });
          });
        } else {
          setState(() {
            _rememberMe = true;
            _usernameController.text = savedUsername;
            _passwordController.text = savedPassword;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _adminUsernameController.dispose();
    _adminPasswordController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: Scaffold(
        // Set background color to match gradient (prevents white flash when keyboard appears)
        backgroundColor: const Color(0xFF2C3E50),
        // Gradient background for liquid glass effect
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF2C3E50),
                const Color(0xFF3498DB),
                const Color(0xFF1ABC9C),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(24.0),
                child: _buildTabbedLoginForm(context),
              ),
            ),
          ),
        ),
        resizeToAvoidBottomInset: true,
      ),
    );
  }

  Widget _buildTabbedLoginForm(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tab Bar - Clean Design
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(4),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white.withOpacity(0.2),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.6),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 18,
              ),
              tabs: const [
                Tab(text: 'User'),
                Tab(text: 'Admin'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Tab Bar View with Cards
          LayoutBuilder(
            builder: (context, constraints) {
              // Get available height, accounting for keyboard
              final mediaQuery = MediaQuery.of(context);
              final availableHeight = mediaQuery.size.height -
                  mediaQuery.padding.top -
                  mediaQuery.padding.bottom -
                  mediaQuery.viewInsets.bottom -
                  250; // Account for tab bar, padding, etc.

              return SizedBox(
                height: availableHeight.clamp(350.0, 500.0),
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildUserLoginCard(context),
                    _buildAdminLoginCard(context),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserLoginCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'User Login',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            // Description
            Text(
              'Sign in to your account to access your dashboard and manage your attendance.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            // Form Content
            _buildUserLoginForm(context),
            const SizedBox(height: 12),
            // Footer Button
            Consumer<AuthViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.status == AuthStatus.success) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushReplacementNamed(
                        context, AppConstants.routeHome);
                  });
                }
                return _buildSignInButton(context, viewModel);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminLoginCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Admin Login',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            // Description
            const Text(
              'Sign in as administrator to manage employees, attendance, and system settings.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            // Form Content
            _buildAdminLoginForm(context),
            const SizedBox(height: 16),
            // Footer Button
            Consumer<AuthViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.status == AuthStatus.success) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushReplacementNamed(
                        context, AppConstants.routeHome);
                  });
                }
                return _buildAdminSignInButton(context, viewModel);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserLoginForm(BuildContext context) {
    return AutofillGroup(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Username Field
            TextFormField(
              controller: _usernameController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.text,
              autofillHints: const [AutofillHints.username],
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: const Icon(
                  FontAwesomeIcons.user,
                  color: Colors.white,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.6),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter username';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Password Field
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.text,
              enableSuggestions: false,
              autocorrect: false,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) {
                if (_formKey.currentState!.validate()) {
                  final viewModel = context.read<AuthViewModel>();
                  _handleSignIn(context, viewModel);
                }
              },
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: const Icon(
                  FontAwesomeIcons.key,
                  color: Colors.white,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? FontAwesomeIcons.eye
                        : FontAwesomeIcons.eyeSlash,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.6),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter password';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Remember Me Checkbox
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                  activeColor: Colors.white,
                  checkColor: const Color(0xFF2C3E50),
                  side: BorderSide(
                    color: Colors.white.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                const Text(
                  'Remember Me',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminLoginForm(BuildContext context) {
    return AutofillGroup(
      child: Form(
        key: _adminFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Admin Username Field
            TextFormField(
              controller: _adminUsernameController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.text,
              autofillHints: const [AutofillHints.username],
              decoration: InputDecoration(
                labelText: 'Admin Username',
                labelStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: const Icon(
                  FontAwesomeIcons.userShield,
                  color: Colors.white,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.6),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter admin username';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Admin Password Field
            TextFormField(
              controller: _adminPasswordController,
              obscureText: _adminObscurePassword,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.text,
              enableSuggestions: false,
              autocorrect: false,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) {
                if (_adminFormKey.currentState!.validate()) {
                  final viewModel = context.read<AuthViewModel>();
                  _handleAdminSignIn(context, viewModel);
                }
              },
              decoration: InputDecoration(
                labelText: 'Admin Password',
                labelStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: const Icon(
                  FontAwesomeIcons.key,
                  color: Colors.white,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _adminObscurePassword
                        ? FontAwesomeIcons.eye
                        : FontAwesomeIcons.eyeSlash,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _adminObscurePassword = !_adminObscurePassword;
                    });
                  },
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.6),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter admin password';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Admin Remember Me Checkbox
            Row(
              children: [
                Checkbox(
                  value: _adminRememberMe,
                  onChanged: (value) {
                    setState(() {
                      _adminRememberMe = value ?? false;
                    });
                  },
                  activeColor: Colors.white,
                  checkColor: const Color(0xFF2C3E50),
                  side: BorderSide(
                    color: Colors.white.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                const Text(
                  'Remember Me',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInButton(BuildContext context, AuthViewModel viewModel) {
    if (viewModel.status == AuthStatus.loading) {
      return const SizedBox(
        height: 50,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    } else if (viewModel.status == AuthStatus.error) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    const Color.fromARGB(255, 255, 255, 255).withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    viewModel.errorMessage ?? 'Login failed',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 300),
              child: ElevatedButton(
                onPressed: () => _handleSignIn(context, viewModel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.25),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: Colors.white.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 300),
          child: ElevatedButton(
            onPressed: () => _handleSignIn(context, viewModel),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2C3E50),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Sign In',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }
  }

  Future<void> _handleSignIn(
      BuildContext context, AuthViewModel viewModel) async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim();
      final password = _passwordController.text;

      // Set as regular user (not admin)
      await PreferencesHelper.saveUserRole('user');

      final success = await viewModel.signIn(username, password);

      if (success && context.mounted) {
        // Save credentials if "Remember Me" is checked
        if (_rememberMe) {
          await PreferencesHelper.setRememberMe(true);
          await PreferencesHelper.saveUsername(username);
          await PreferencesHelper.savePassword(password);
        } else {
          // Clear saved credentials if "Remember Me" is unchecked
          await PreferencesHelper.setRememberMe(false);
          await PreferencesHelper.savePassword('');
        }

        // Close keyboard and autofill
        SystemChannels.textInput.invokeMethod('TextInput.hide');

        Navigator.pushReplacementNamed(context, AppConstants.routeHome);
      }
    }
  }

  Future<void> _handleAdminSignIn(
      BuildContext context, AuthViewModel viewModel) async {
    if (_adminFormKey.currentState!.validate()) {
      final username = _adminUsernameController.text.trim();
      final password = _adminPasswordController.text;

      // Set as admin before login
      await PreferencesHelper.saveUserRole('admin');

      final success = await viewModel.signIn(username, password);

      if (success && context.mounted) {
        // Save credentials if "Remember Me" is checked
        if (_adminRememberMe) {
          await PreferencesHelper.setRememberMe(true);
          await PreferencesHelper.saveUsername(username);
          await PreferencesHelper.savePassword(password);
        } else {
          // Clear saved credentials if "Remember Me" is unchecked
          await PreferencesHelper.setRememberMe(false);
          await PreferencesHelper.savePassword('');
        }

        // Close keyboard
        SystemChannels.textInput.invokeMethod('TextInput.hide');

        Navigator.pushReplacementNamed(context, AppConstants.routeHome);
      }
    }
  }

  Widget _buildAdminSignInButton(
      BuildContext context, AuthViewModel viewModel) {
    if (viewModel.status == AuthStatus.loading) {
      return const SizedBox(
        height: 50,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    } else if (viewModel.status == AuthStatus.error) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    const Color.fromARGB(255, 255, 255, 255).withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    viewModel.errorMessage ?? 'Login failed',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 300),
              child: ElevatedButton(
                onPressed: () => _handleAdminSignIn(context, viewModel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.25),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: Colors.white.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Sign in as Admin',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 300),
          child: ElevatedButton(
            onPressed: () => _handleAdminSignIn(context, viewModel),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2C3E50),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Sign in as Admin',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }
  }
}
