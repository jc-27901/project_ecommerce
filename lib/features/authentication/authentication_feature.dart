import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../provider/authentication_provider.dart';
import '../../utils/basWidgets/animated_input_fields.dart';
import '../../utils/basWidgets/animated_filled_button.dart';
part 'login_widget.dart';
part 'signup_widget.dart';

/// AuthenticationFeature is a stateful widget that provides both login
/// and signup functionality with smooth animations between the two states.
class AuthenticationFeature extends StatefulWidget {
  const AuthenticationFeature({super.key});

  @override
  State<AuthenticationFeature> createState() => _AuthenticationFeatureState();
}

class _AuthenticationFeatureState extends State<AuthenticationFeature> {
  // Controls which authentication mode is currently active
  bool isLogin = true;

  // Text controllers for form fields
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final TextEditingController _nameController;

  // Form key for validation
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  /// Toggles between login and signup modes with animation
  void _toggleAuthMode() {
    setState(() {
      _formKey = GlobalKey<FormState>(); // Reinitialize to reset form state
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _nameController.clear();
      isLogin = !isLogin;
    });
  }

  /// Handles the authentication process (login or signup)
  /// Handles the authentication process (login or signup)
  Future<void> _handleAuthentication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final AuthenticationProvider authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);

    if (isLogin) {
      await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      // Check if email is already registered
      // final isEmailExists = await authProvider.isEmailRegistered(
      //   _emailController.text.trim(),
      // );

      // if (isEmailExists) {
      //   // If email exists, show dialog to suggest login
      //   if (!context.mounted) return;
      //
      //   showDialog(
      //     context: context,
      //     builder: (context) => AlertDialog(
      //       title: const Text('Account Exists'),
      //       content: const Text(
      //           'An account with this email already exists. Would you like to login instead?'
      //       ),
      //       actions: [
      //         TextButton(
      //           onPressed: () {
      //             Navigator.of(context).pop();
      //           },
      //           child: const Text('Cancel'),
      //         ),
      //         TextButton(
      //           onPressed: () {
      //             Navigator.of(context).pop();
      //             setState(() {
      //               isLogin = true;
      //             });
      //           },
      //           child: const Text('Login'),
      //         ),
      //       ],
      //     ),
      //   );
      //   return;
      // } else {
      // If email doesn't exist, proceed with registration
      await authProvider.register(
        _emailController.text.trim(),
        _passwordController.text,
      );
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<AuthenticationProvider>(
          builder: (context, authProvider, _) {
            // Show error snackbar if there's an error
            if (authProvider.authResult.status == AuthStatus.error) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(authProvider.authResult.errorMessage ??
                        'An error occurred'),
                    backgroundColor: Colors.red,
                  ),
                );
                // Clear the error after showing it
                authProvider.clearError();
              });
            }

            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(24),
                height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: isLogin
                      ? LoginWidget(
                          key: const ValueKey('login'),
                          onSignUpTap: _toggleAuthMode,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          onLogin: _handleAuthentication,
                          formKey: _formKey,
                          isLoading: authProvider.authResult.status ==
                              AuthStatus.authenticating,
                        )
                      : SignUpWidget(
                          key: const ValueKey('signup'),
                          onLoginTap: _toggleAuthMode,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          confirmPasswordController: _confirmPasswordController,
                          nameController: _nameController,
                          onSignUp: _handleAuthentication,
                          formKey: _formKey,
                          isLoading: authProvider.authResult.status ==
                              AuthStatus.authenticating,
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

