import 'package:flutter/material.dart';
import 'package:project_ecommerce/features/user/user_profile.dart';
import 'package:provider/provider.dart';
import '../../provider/authentication_provider.dart';
import '../dashboard/dashboard_screen.dart';

/// A widget that handles app routing based on authentication state
/// This component decides whether to show authentication screens or the main app
class AuthenticationRouter extends StatefulWidget {
  final Widget authenticationScreen;

  const AuthenticationRouter({
    super.key,
    required this.authenticationScreen,
  });

  @override
  State<AuthenticationRouter> createState() => _AuthenticationRouterState();
}

class _AuthenticationRouterState extends State<AuthenticationRouter> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationProvider>(
      builder: (context, authProvider, _) {
        // Show loading indicator while checking initial auth state
        if (authProvider.authResult.status == AuthStatus.initial) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If user is not authenticated, show authentication screen
        if (!authProvider.isAuthenticated) {
          return widget.authenticationScreen;
        }

        // If user is authenticated, check if they have a profile
        return FutureBuilder<bool>(
          future: authProvider.userHasProfile(),
          builder: (context, snapshot) {
            // Show loading indicator while checking profile
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // Navigate based on whether user has a profile
            if (snapshot.data == true) {
              // User has a profile, show dashboard
              return DashboardScreen();
            } else {
              // User needs to create a profile
              return CreateProfileScreen(firebaseUser: authProvider.currentUser);
            }
          },
        );
      },
    );
  }
}


