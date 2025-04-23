import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_services.dart';

/// Status of the authentication process
enum AuthStatus {
  initial,
  authenticating,
  authenticated,
  unauthenticated,
  error,
}

/// Authentication result with status and optional error message
class AuthResult {
  final AuthStatus status;
  final String? errorMessage;
  final User? user;

  AuthResult({
    required this.status,
    this.errorMessage,
    this.user,
  });

  factory AuthResult.initial() => AuthResult(status: AuthStatus.initial);

  factory AuthResult.authenticating() => AuthResult(status: AuthStatus.authenticating);

  factory AuthResult.authenticated(User user) => AuthResult(
    status: AuthStatus.authenticated,
    user: user,
  );

  factory AuthResult.unauthenticated() => AuthResult(status: AuthStatus.unauthenticated);

  factory AuthResult.error(String message) => AuthResult(
    status: AuthStatus.error,
    errorMessage: message,
  );
}

/// Provider for authentication-related operations
class AuthenticationProvider extends ChangeNotifier {
  final BaseFirebaseService _firebaseService;
  User? _currentUser;
  AuthResult _authResult = AuthResult.initial();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthenticationProvider(this._firebaseService) {
    // Initialize - Check if user is already logged in
    _initializeAuthState();
  }

  /// Initialize the authentication state by checking Firebase Auth
  Future<void> _initializeAuthState() async {
    // Set initial state
    _authResult = AuthResult.initial();
    notifyListeners();

    // Listen to auth state changes
    _firebaseService.authStateChanges.listen((User? user) {
      _currentUser = user;
      if (user != null) {
        _authResult = AuthResult.authenticated(user);
      } else {
        _authResult = AuthResult.unauthenticated();
      }
      notifyListeners();
    });
  }

  /// Get the current authentication result
  AuthResult get authResult => _authResult;

  /// Get the current user
  User? get currentUser => _currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _currentUser != null;

  /// Login with email and password
  Future<AuthResult> login(String email, String password) async {
    try {
      _authResult = AuthResult.authenticating();
      notifyListeners();

      final result = await _firebaseService.signInWithEmailAndPassword(
        email,
        password,
      );

      _currentUser = result.user;
      _authResult = AuthResult.authenticated(result.user!);
      notifyListeners();
      return _authResult;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase auth errors with user-friendly messages
      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled.';
          break;
        default:
          errorMessage = 'Login failed: ${e.message}';
      }

      _authResult = AuthResult.error(errorMessage);
      notifyListeners();
      return _authResult;
    } catch (e) {
      _authResult = AuthResult.error('Login failed: $e');
      notifyListeners();
      return _authResult;
    }
  }

  /// Register a new user with email and password
  Future<AuthResult> register(String email, String password) async {
    try {
      _authResult = AuthResult.authenticating();
      notifyListeners();

      final result = await _firebaseService.createUserWithEmailAndPassword(
        email,
        password,
      );

      _currentUser = result.user;
      _authResult = AuthResult.authenticated(result.user!);
      notifyListeners();
      return _authResult;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase auth errors with user-friendly messages
      String errorMessage;

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'The email address is already in use. Please login instead.';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak. Please use a stronger password.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        default:
          errorMessage = 'Registration failed: ${e.message}';
      }

      _authResult = AuthResult.error(errorMessage);
      notifyListeners();
      return _authResult;
    } catch (e) {
      _authResult = AuthResult.error('Registration failed: $e');
      notifyListeners();
      return _authResult;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _firebaseService.signOut();
      _authResult = AuthResult.unauthenticated();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _authResult = AuthResult.error('Sign out failed: $e');
      notifyListeners();
    }
  }

  /// Check if the user has created a profile
  Future<bool> userHasProfile() async {
    try {
      if (_currentUser == null) {
        return false;
      }

      // Check Firestore for user profile
      final docSnapshot = await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      return docSnapshot.exists;
    } catch (e) {
      print('Error checking user profile: $e');
      return false;
    }
  }

  /// Send password reset email
  Future<AuthResult> resetPassword(String email) async {
    try {
      _authResult = AuthResult.authenticating();
      notifyListeners();

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      _authResult = AuthResult.unauthenticated();
      notifyListeners();
      return AuthResult(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Password reset email sent to $email',
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        default:
          errorMessage = 'Password reset failed: ${e.message}';
      }

      _authResult = AuthResult.error(errorMessage);
      notifyListeners();
      return _authResult;
    } catch (e) {
      _authResult = AuthResult.error('Password reset failed: $e');
      notifyListeners();
      return _authResult;
    }
  }

  /// Check if an email is already registered
  Future<bool> isEmailRegistered(String email) async {
    try {
      // This method uses the fetchSignInMethodsForEmail Firebase Auth API
      final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      // If the list is not empty, this email is already registered
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Clear any error state
  void clearError() {
    if (_authResult.status == AuthStatus.error) {
      _authResult = _currentUser != null
          ? AuthResult.authenticated(_currentUser!)
          : AuthResult.unauthenticated();
      notifyListeners();
    }
  }
}