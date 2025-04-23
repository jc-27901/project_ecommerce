import 'package:flutter/material.dart';
import 'package:project_ecommerce/features/dashboard/product_listing_screen.dart';
import 'package:project_ecommerce/features/user/user_detail_screen.dart';
import 'package:project_ecommerce/provider/user_profile_provider.dart';
import 'package:provider/provider.dart';
import '../../provider/authentication_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserProfileProvider userProfileProvider =
        Provider.of<UserProfileProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_2_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserDetailScreen(
                    loggedInUser: userProfileProvider.currentUserProfile,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ProductListingScreen(),
    );
  }
}
