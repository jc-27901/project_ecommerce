import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_ecommerce/utils/basWidgets/animated_filled_button.dart';
import 'package:provider/provider.dart';

import '../../models/user_dm.dart';
import '../../provider/authentication_provider.dart';
import '../../provider/user_profile_provider.dart';
import '../../utils/basWidgets/animated_input_fields.dart';

/// Creates a profile screen that handles user information input
/// with enhanced animations and UI interactions
class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen(
      {super.key, required this.firebaseUser, this.loggedInUser});
  final User? firebaseUser;
  final UserDm? loggedInUser;

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  // Form controllers
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // State variables
  File? _profileImage;
  bool _isFormComplete = false;

  String? _userProfileUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.loggedInUser?.name);
    _phoneController =
        TextEditingController(text: widget.loggedInUser?.phoneNumber);
    _emailController = TextEditingController(
        text: widget.firebaseUser?.email ?? widget.loggedInUser?.email);
    _userProfileUrl = widget.loggedInUser?.profileImageUrl;
    // Add listeners to check if form is complete
    _nameController.addListener(_checkFormCompleteness);
    _phoneController.addListener(_checkFormCompleteness);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Checks if all required fields are filled to enable the submit button
  void _checkFormCompleteness() {
    setState(() {
      _isFormComplete =
          _nameController.text.isNotEmpty && _phoneController.text.isNotEmpty;
    });
  }

  /// Handles profile image selection from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedImage = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedImage != null) {
        setState(() {
          _profileImage = File(pickedImage.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      // Show error message
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  /// Shows image source selection bottom sheet
  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select Profile Picture',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ImageSourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _ImageSourceOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ).animate().slideY(
            begin: 1,
            end: 0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          ),
    );
  }

  /// Handles the form submission
  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final UserProfileProvider userProfileProvider =
            Provider.of<UserProfileProvider>(context, listen: false);

        if (widget.firebaseUser == null) {
          throw Exception('No user logged in');
        }

        await userProfileProvider.createUserProfile(
          userId: widget.firebaseUser!.uid,
          email: _emailController.text.trim(),
          name: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          profileImage: _profileImage,
          profileUrl: _userProfileUrl,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile created successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to home screen or next screen
          // Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create profile: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final UserProfileProvider userProfileProvider =
        Provider.of<UserProfileProvider>(context);
    final bool isLoading = userProfileProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Also clear the user profile data when signing out
              Provider.of<UserProfileProvider>(context, listen: false)
                  .clearUserProfile();
              await Provider.of<AuthenticationProvider>(context, listen: false)
                  .signOut();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Welcome message
                Text(
                  'Welcome',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fade().slideY(
                      begin: -0.2,
                      end: 0,
                      duration: const Duration(milliseconds: 400),
                    ),

                const SizedBox(height: 8),

                const Text(
                  'Please complete your profile',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                )
                    .animate()
                    .fade(delay: const Duration(milliseconds: 200))
                    .slideY(
                      begin: -0.2,
                      end: 0,
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 400),
                    ),

                const SizedBox(height: 32),

                // Profile image selection
                GestureDetector(
                  onTap: _showImageSourceOptions,
                  child: Stack(
                    children: [
                      if (_userProfileUrl != null)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(_userProfileUrl!),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    colorScheme.primary.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                        )
                      else
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                            image: _profileImage != null
                                ? DecorationImage(
                                    image: FileImage(_profileImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    colorScheme.primary.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: _profileImage == null
                              ? Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey.shade400,
                                )
                              : null,
                        ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fade(delay: const Duration(milliseconds: 400))
                    .scale(
                      delay: const Duration(milliseconds: 400),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                    ),

                const SizedBox(height: 40),

                // Form fields
                AnimatedInputField(
                  controller: _nameController,
                  label: 'Full Name',
                  prefixIcon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                  animationDelay: const Duration(milliseconds: 600),
                ),

                AnimatedInputField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                  animationDelay: const Duration(milliseconds: 800),
                ),

                AnimatedInputField(
                  controller: _emailController,
                  label: 'Email Address',
                  isReadOnly: true,
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                  animationDelay: const Duration(milliseconds: 1000),
                ),

                const SizedBox(height: 40),

                // Submit button
                AnimatedFilledButton(
                  onPressed: _saveProfile,
                  label: 'Create Profile',
                  isLoading: isLoading,
                  isEnabled: _isFormComplete && !isLoading,
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget for image source selection options
class _ImageSourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageSourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 36,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: const Duration(milliseconds: 300),
        );
  }
}
