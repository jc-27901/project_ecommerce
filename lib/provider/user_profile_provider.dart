// user_profile_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_dm.dart';
import '../services/firebase_services.dart';

class UserProfileProvider with ChangeNotifier {
  final BaseFirebaseService _firebaseService;
  UserDm? _currentUserProfile;
  bool _isLoading = false;

  UserProfileProvider(BaseFirebaseService firebaseService)
      : _firebaseService = firebaseService {
    _initializeUserProfile();
  }

  // Getters
  UserDm? get currentUserProfile => _currentUserProfile;
  bool get isLoading => _isLoading;

  /// Initialize user profile by loading data for the current authenticated user
  Future<void> _initializeUserProfile() async {
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      await loadUserProfile(firebaseUser.uid);
    }
  }

  /// Load user profile data from Firestore
  Future<void> loadUserProfile(String userId) async {
    try {
      _setLoading(true);
      _currentUserProfile = await _firebaseService.getUserProfile(userId);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  /// Create a new user profile
  Future<void> createUserProfile({
    required String userId,
    required String email,
    required String name,
    required String phoneNumber,
    File? profileImage,
    String? profileUrl,
  }) async {
    try {
      _setLoading(true);

      UserDm newUser = UserDm(
        id: userId,
        email: email,
        name: name,
        phoneNumber: phoneNumber,
        profileImageUrl: profileUrl, // Will be set during upload if image provided
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firebaseService.createOrUpdateUserProfile(newUser,
          profileImage: profileImage);

      // Reload the user profile to get the updated data including image URL
      await loadUserProfile(userId);

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  /// Update an existing user profile
  Future<void> updateUserProfile({
    required String name,
    required String phoneNumber,
    File? profileImage,
  }) async {
    try {
      if (_currentUserProfile == null) {
        throw Exception('No user profile loaded to update');
      }

      _setLoading(true);

      UserDm updatedUser = _currentUserProfile!.copyWith(
        name: name,
        phoneNumber: phoneNumber,
        updatedAt: DateTime.now(),
      );

      await _firebaseService.createOrUpdateUserProfile(updatedUser,
          profileImage: profileImage);

      // Reload the user profile to get the updated data
      await loadUserProfile(_currentUserProfile!.id);

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  /// Update just the profile image
  Future<void> updateProfileImage(File profileImage) async {
    try {
      if (_currentUserProfile == null) {
        throw Exception('No user profile loaded to update');
      }

      _setLoading(true);

      await _firebaseService.createOrUpdateUserProfile(
        _currentUserProfile!,
        profileImage: profileImage,
      );

      // Reload the user profile to get the updated image URL
      await loadUserProfile(_currentUserProfile!.id);

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  /// Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Clear user profile data (e.g., on sign out)
  void clearUserProfile() {
    _currentUserProfile = null;
    notifyListeners();
  }
}
