// user_firebase_service.dart
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/address_dm.dart';
import '../models/product_dm.dart';
import '../models/user_dm.dart';

/// Abstract class for Firebase services
abstract class BaseFirebaseService {
  // Auth methods

  /// Sign in user with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password);

  /// Create new user with email and password
  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password);

  /// Sign out the current user
  Future<void> signOut();

  /// Stream to listen for authentication state changes
  Stream<User?> get authStateChanges;

  /// User profile methods
  /// Create or update a user profile
  Future<void> createOrUpdateUserProfile(UserDm user, {File? profileImage});

  /// Get a user profile by user ID
  Future<UserDm?> getUserProfile(String userId);

  /// Update user profile image
  Future<String> uploadUserProfileImage(String userId, File imageFile);

  /// Delete user profile image
  Future<void> deleteUserProfileImage(String imageUrl);

  // Product methods

  /// Upload a new product with associated images, returns the document ID
  Future<String> uploadProduct(Product product, List<File> images);

  /// Update product details without updating images
  Future<void> updateProduct(String productId, Product product);

  /// Update product details along with new images
  Future<void> updateProductWithImages(
      String productId, Product product, List<File> newImages);

  /// Delete a product and its associated images
  Future<void> deleteProduct(String productId);

  /// Get a single product by ID
  Future<Product> getProduct(String productId);

  /// Get a list of all products, ordered by creation date
  Future<List<Product>> getAllProducts();

  /// Get all addresses for a user
  Future<List<Address>> getUserAddresses(String userId);

  /// Add a new address for a user, returns the document ID
  Future<String> addUserAddress(String userId, Address address);

  /// Update an existing user address
  Future<void> updateUserAddress(String userId, Address address);

  /// Delete a user address
  Future<void> deleteUserAddress(String userId, String addressId);

}

/// Concrete implementation of Firebase services
class FirebaseService implements BaseFirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collection name for products
  final String _productsCollection = 'products';

  /// Sign in using email and password
  @override
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  /// Create a new user using email and password
  @override
  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  /// Sign out the current user
  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Get authentication state changes as a stream
  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Upload a product and associated images to Firebase Storage and Firestore
  @override
  Future<String> uploadProduct(Product product, List<File> images) async {
    try {
      List<String> imageUrls = [];
      for (var image in images) {
        String fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';
        Reference ref = _storage.ref().child('products/$fileName');

        UploadTask uploadTask = ref.putFile(image);
        TaskSnapshot snapshot = await uploadTask;

        String downloadUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }

      Product newProduct = product.copyWith(
        imageUrls: imageUrls,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      DocumentReference docRef = await _firestore
          .collection(_productsCollection)
          .add(newProduct.toMap());

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to upload product: $e');
    }
  }

  /// Update product data in Firestore (excluding image updates)
  @override
  Future<void> updateProduct(String productId, Product product) async {
    try {
      Product updatedProduct = product.copyWith(
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(_productsCollection)
          .doc(productId)
          .update(updatedProduct.toMap());
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  /// Update product with new images, replace old images
  @override
  Future<void> updateProductWithImages(
      String productId, Product product, List<File> newImages) async {
    try {
      Product existingProduct = await getProduct(productId);

      List<String> newImageUrls = [];
      for (var image in newImages) {
        String fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';
        Reference ref = _storage.ref().child('products/$fileName');

        UploadTask uploadTask = ref.putFile(image);
        TaskSnapshot snapshot = await uploadTask;

        String downloadUrl = await snapshot.ref.getDownloadURL();
        newImageUrls.add(downloadUrl);
      }

      Product updatedProduct = product.copyWith(
        imageUrls: newImageUrls,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(_productsCollection)
          .doc(productId)
          .update(updatedProduct.toMap());

      for (String imageUrl in existingProduct.imageUrls) {
        try {
          await _storage.refFromURL(imageUrl).delete();
        } catch (e) {
          print('Failed to delete old image: $e');
        }
      }
    } catch (e) {
      throw Exception('Failed to update product with images: $e');
    }
  }

  /// Delete a product and its associated images from Firestore and Storage
  @override
  Future<void> deleteProduct(String productId) async {
    try {
      Product product = await getProduct(productId);

      await _firestore.collection(_productsCollection).doc(productId).delete();

      for (String imageUrl in product.imageUrls) {
        try {
          await _storage.refFromURL(imageUrl).delete();
        } catch (e) {
          print('Failed to delete image: $e');
        }
      }
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  /// Fetch a single product from Firestore by ID
  @override
  Future<Product> getProduct(String productId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(_productsCollection).doc(productId).get();

      if (!doc.exists) {
        throw Exception('Product not found');
      }

      return Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('Failed to get product: $e');
    }
  }

  /// Fetch all products from Firestore, ordered by createdAt descending
  @override
  Future<List<Product>> getAllProducts() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_productsCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get products: $e');
    }
  }

  // Collection name for users
  final String _usersCollection = 'users';

  /// Create or update a user profile in Firestore
  @override
  Future<void> createOrUpdateUserProfile(UserDm user,
      {File? profileImage}) async {
    try {
      String? profileImageUrl = user.profileImageUrl;

      // If a new profile image is provided, upload it first
      if (profileImage != null) {
        // If there's an existing profile image, delete it first
        if (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty) {
          try {
            await deleteUserProfileImage(user.profileImageUrl!);
          } catch (e) {
            print('Failed to delete old profile image: $e');
          }
        }

        // Upload the new profile image
        profileImageUrl = await uploadUserProfileImage(user.id, profileImage);
      }

      // Create updated user object with new image URL if applicable
      UserDm updatedUser = user.copyWith(
        profileImageUrl: profileImageUrl,
        updatedAt: DateTime.now(),
      );

      // Check if user document already exists
      DocumentSnapshot userDoc =
          await _firestore.collection(_usersCollection).doc(user.id).get();

      if (userDoc.exists) {
        // Update existing user document
        await _firestore
            .collection(_usersCollection)
            .doc(user.id)
            .update(updatedUser.toMap());
      } else {
        // Create new user document with creation timestamp
        UserDm newUser = updatedUser.copyWith(createdAt: DateTime.now());
        await _firestore
            .collection(_usersCollection)
            .doc(user.id)
            .set(newUser.toMap());
      }
    } catch (e) {
      throw Exception('Failed to create or update user profile: $e');
    }
  }

  /// Get a user profile by user ID
  @override
  Future<UserDm?> getUserProfile(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(_usersCollection).doc(userId).get();

      if (!doc.exists) {
        return null;
      }

      return UserDm.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  /// Upload user profile image to Firebase Storage
  @override
  Future<String> uploadUserProfileImage(String userId, File imageFile) async {
    try {
      String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      Reference ref = _storage.ref().child('users/$userId/profile/$fileName');

      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  /// Delete user profile image from Firebase Storage
  @override
  Future<void> deleteUserProfileImage(String imageUrl) async {
    try {
      await _storage.refFromURL(imageUrl).delete();
    } catch (e) {
      throw Exception('Failed to delete profile image: $e');
    }
  }

  // Collection name for user addresses
  final String _addressesCollection = 'addresses';

  /// Get all addresses for a user
  @override
  Future<List<Address>> getUserAddresses(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_addressesCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Address.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get user addresses: $e');
    }
  }

  /// Add a new address for a user
  @override
  Future<String> addUserAddress(String userId, Address address) async {
    try {
      // Create a new address with the userId field
      final addressWithUser = address.copyWith(
        userId: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      DocumentReference docRef = await _firestore
          .collection(_addressesCollection)
          .add(addressWithUser.toMap());

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add user address: $e');
    }
  }

  /// Update an existing user address
  @override
  Future<void> updateUserAddress(String userId, Address address) async {
    try {
      // Make sure we have the latest updatedAt timestamp
      final updatedAddress = address.copyWith(
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(_addressesCollection)
          .doc(address.id)
          .update(updatedAddress.toMap());
    } catch (e) {
      throw Exception('Failed to update user address: $e');
    }
  }

  /// Delete a user address
  @override
  Future<void> deleteUserAddress(String userId, String addressId) async {
    try {
      await _firestore
          .collection(_addressesCollection)
          .doc(addressId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete user address: $e');
    }
  }

}
