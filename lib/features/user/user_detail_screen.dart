import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:project_ecommerce/features/user/user_profile.dart';
import 'package:project_ecommerce/provider/address_provider.dart';
import 'package:project_ecommerce/provider/authentication_provider.dart';
import 'package:project_ecommerce/provider/user_profile_provider.dart';
import 'package:provider/provider.dart';
import '../../models/address_dm.dart';
import '../../models/user_dm.dart';
import '../address/address_form.dart';

class UserDetailScreen extends StatefulWidget {
  const UserDetailScreen({super.key, this.loggedInUser});

  final UserDm? loggedInUser;

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  late final UserDm loggedInUser;
  final List<Address> _addresses = []; // Will be populated from provider later

  @override
  void initState() {
    loggedInUser = widget.loggedInUser ??
        UserDm(
            id: '',
            email: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now());
    super.initState();

    // Mock data for preview - remove in production
    WidgetsBinding.instance.addPostFrameCallback((_){
      if(widget.loggedInUser != null) {
        Provider.of<AddressProvider>(context,listen: false).loadUserAddresses(
            widget.loggedInUser!.id);
      }
    });
  }

  void _navigateToAddAddressScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddressFormScreen(),
      ),
    );
  }

  void _navigateToEditAddressScreen(Address address) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddressFormScreen(addressToEdit: address),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.primaryContainer],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: loggedInUser.profileImageUrl != null
                    ? Image.network(
                        loggedInUser.profileImageUrl!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: colorScheme.primaryContainer,
                        child: Icon(
                          Icons.person,
                          size: 80,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
              ),
              title: Text(
                loggedInUser.name ?? 'User Profile',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateProfileScreen(
                        firebaseUser: Provider.of<AuthenticationProvider>(
                                context,
                                listen: false)
                            .currentUser,
                        loggedInUser: Provider.of<UserProfileProvider>(context,
                                listen: false)
                            .currentUserProfile,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: _buildProfileDetails(colorScheme),
          ),
          SliverToBoxAdapter(
            child: Consumer<AddressProvider>(builder: (context, provider, _) {
              if (provider.isLoading) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (provider.addresses.isNotEmpty) {
                _addresses.clear();
                _addresses.addAll(provider.addresses);
                return _buildAddressSection(colorScheme);
              }
              return _buildAddressSection(colorScheme);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ).animate().fade(duration: const Duration(milliseconds: 500)),
          const SizedBox(height: 16),
          _buildInfoCard(
            icon: Icons.person_outline,
            title: 'Name',
            value: loggedInUser.name ?? 'Not provided',
            colorScheme: colorScheme,
            delay: const Duration(milliseconds: 100),
          ),
          _buildInfoCard(
            icon: Icons.email_outlined,
            title: 'Email',
            value: loggedInUser.email,
            colorScheme: colorScheme,
            delay: const Duration(milliseconds: 200),
          ),
          _buildInfoCard(
            icon: Icons.phone_outlined,
            title: 'Phone',
            value: loggedInUser.phoneNumber ?? 'Not provided',
            colorScheme: colorScheme,
            delay: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required ColorScheme colorScheme,
    required Duration delay,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: const Duration(milliseconds: 400))
        .slideX(
            begin: 0.2,
            end: 0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut);
  }

  Widget _buildAddressSection(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Addresses',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              if (_addresses.isNotEmpty)
                TextButton.icon(
                  onPressed: _navigateToAddAddressScreen,
                  icon: const Icon(Icons.add),
                  label: const Text('Add New'),
                ),
            ],
          ).animate().fade(duration: const Duration(milliseconds: 500)),
          const SizedBox(height: 8),
          _addresses.isEmpty
              ? _buildEmptyAddressState(colorScheme)
              : _buildAddressList(colorScheme),
        ],
      ),
    )
        .animate(delay: const Duration(milliseconds: 400))
        .fadeIn(duration: const Duration(milliseconds: 500))
        .slideY(
            begin: 0.1,
            end: 0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut);
  }

  Widget _buildEmptyAddressState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on_outlined,
              size: 60,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No addresses saved yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a new address for faster checkout',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _navigateToAddAddressScreen,
            icon: const Icon(Icons.add_location_alt_outlined),
            label: const Text('Add New Address'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )
              .animate()
              .fadeIn(
                  delay: const Duration(milliseconds: 500),
                  duration: const Duration(milliseconds: 400))
              .scale(
                  delay: const Duration(milliseconds: 500),
                  duration: const Duration(milliseconds: 300)),
        ],
      ).animate().fadeIn(duration: const Duration(milliseconds: 600)).slideY(
          begin: 0.1, end: 0, duration: const Duration(milliseconds: 500)),
    );
  }

  Widget _buildAddressList(ColorScheme colorScheme) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _addresses.length,
        itemBuilder: (context, index) {
          final Address address = _addresses[index];
          return Container(
            width: 250,
            margin: const EdgeInsets.only(right: 16),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: address.isDefault
                    ? BorderSide(color: colorScheme.primary, width: 2)
                    : BorderSide.none,
              ),
              child: Stack(
                children: [
                  if (address.isDefault)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Default',
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0,top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on, color: colorScheme.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                address.fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          address.addressLine1,
                          style: const TextStyle(fontSize: 14),
                        ),
                        if (address.addressLine2 != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            address.addressLine2!,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                        const SizedBox(height: 2),
                        Text(
                          '${address.city}, ${address.state} ${address.postalCode}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          address.country,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          address.phoneNumber,
                          style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () =>
                                  _navigateToEditAddressScreen(address),
                              tooltip: 'Edit address',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(
                  delay: Duration(milliseconds: 100 * index),
                  duration: const Duration(milliseconds: 400))
              .slideX(
                begin: 0.2,
                end: 0,
                delay: Duration(milliseconds: 100 * index),
                duration: const Duration(milliseconds: 400),
              );
        },
      ),
    );
  }
}
