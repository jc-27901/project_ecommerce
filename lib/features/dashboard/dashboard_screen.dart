import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:project_ecommerce/features/cart/cart_screen.dart';
import 'package:project_ecommerce/features/dashboard/product_listing_screen.dart';
import 'package:project_ecommerce/features/user/user_detail_screen.dart';
import 'package:project_ecommerce/provider/cart_provider.dart';
import 'package:project_ecommerce/provider/user_profile_provider.dart';
import 'package:provider/provider.dart';

import '../../utils/basWidgets/circular_notch.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    _pageController = PageController();
    // Load cart when the screen is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCartData();
    });
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadCartData() async {
    await Provider.of<CartProvider>(context, listen: false).loadCart();
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserProfileProvider userProfileProvider =
        Provider.of<UserProfileProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard')
            .animate()
            .fadeIn(duration: 500.ms)
            .slideX(begin: -0.2, end: 0, duration: 500.ms),
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
          ).animate().scale(
              begin: const Offset(0.8, 0.8),
              end: Offset(1.0, 1.0),
              duration: 300.ms),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          // Product Listing Screen
          ProductListingScreen().animate().fadeIn(duration: 300.ms),

          // Search Screen Placeholder
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search,
                        size: 80, color: Theme.of(context).primaryColor)
                    .animate()
                    .scale(duration: 400.ms, curve: Curves.easeOut)
                    .then()
                    .shake(hz: 2, curve: Curves.easeOut),
                const SizedBox(height: 16),
                const Text(
                  'Search Screen',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
              ],
            ),
          ),

          // Cart Screen Placeholder
          CartScreen().animate().fadeIn(duration: 300.ms),

          // Wishlist Screen Placeholder
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite,
                        size: 80, color: Theme.of(context).primaryColor)
                    .animate()
                    .scale(duration: 400.ms, curve: Curves.easeOut)
                    .then()
                    .shake(hz: 2, curve: Curves.easeOut),
                const SizedBox(height: 16),
                const Text(
                  'Wishlist Screen',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
              ],
            ),
          ),

          // Settings Screen Placeholder
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.settings,
                        size: 80, color: Theme.of(context).primaryColor)
                    .animate()
                    .scale(duration: 400.ms, curve: Curves.easeOut)
                    .then()
                    .shake(hz: 2, curve: Curves.easeOut),
                const SizedBox(height: 16),
                const Text(
                  'Settings Screen',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _onTabTapped(2); // Navigate to cart screen
        },
        child: Consumer<CartProvider>(
          builder: (context,provider,_){
            int cartItems = provider.cartItems.length;
            return cartItems > 0
                ? Badge(
              label: Text('$cartItems'),
              child: Icon(Icons.shopping_cart),
            )
                : Icon(Icons.shopping_cart);
          },
        ),
      ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.1, 1.1),
            duration: 800.ms,
          ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

class AnimatedBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AnimatedBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      notchMargin: 8.0,
      shape: const CircularNotch(
        notchMargin: 8,
        centerOffset: 0,
      ),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Home Button
            Expanded(
              child: _buildNavItem(
                icon: Icons.home,
                label: 'Home',
                index: 0,
                context: context,
              ),
            ),

            // Search Button
            Expanded(
              child: _buildNavItem(
                icon: Icons.search,
                label: 'Search',
                index: 1,
                context: context,
              ),
            ),

            // Empty space for FAB
            const Expanded(child: SizedBox()),

            // Wishlist Button
            Expanded(
              child: _buildNavItem(
                icon: Icons.favorite_border,
                label: 'Wishlist',
                index: 3,
                context: context,
              ),
            ),

            // Settings Button
            Expanded(
              child: _buildNavItem(
                icon: Icons.settings,
                label: 'Settings',
                index: 4,
                context: context,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .slideY(begin: 1, end: 0, duration: 500.ms, curve: Curves.easeOutQuint);
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required BuildContext context,
  }) {
    final isSelected = currentIndex == index;

    return InkWell(
      onTap: () => onTap(index),
      customBorder: const CircleBorder(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
          )
              .animate(target: isSelected ? 1 : 0)
              .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2))
              .tint(color: Theme.of(context).primaryColor),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}


