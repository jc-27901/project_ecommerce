import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_item_dm.dart';
import '../models/product_dm.dart';
import '../services/firebase_services.dart';

class CartProvider extends ChangeNotifier {
  final BaseFirebaseService _firebaseService;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String? _error;
  List<CartItem> _cartItems = [];
  Map<String, Product> _cartProducts = {};
  double _cartTotal = 0.0;

  CartProvider(this._firebaseService);

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<CartItem> get cartItems => _cartItems;
  Map<String, Product> get cartProducts => _cartProducts;
  double get cartTotal => _cartTotal;
  int get cartItemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  String? get userId => _auth.currentUser?.uid;

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  // Calculate cart total
  void _calculateCartTotal() {
    _cartTotal = 0.0;
    for (CartItem item in _cartItems) {
      if (_cartProducts.containsKey(item.productId)) {
        final product = _cartProducts[item.productId]!;
        _cartTotal += product.finalPrice * item.quantity;
      } else {
        // Fallback to stored price at addition if product details not available
        _cartTotal += item.priceAtAddition * item.quantity;
      }
    }
    notifyListeners();
  }

  // Load cart items and their associated products
  Future<void> loadCart() async {
    if (userId == null) {
      _setError('User not signed in');
      return;
    }

    _setLoading(true);
    _setError(null);

    try {
      // Load cart items
      _cartItems = await _firebaseService.getUserCartItems(userId!);

      // Fetch product details for cart items
      _cartProducts = {};

      for (CartItem item in _cartItems) {
        try {
          final product = await _firebaseService.getProduct(item.productId);
          _cartProducts[item.productId] = product;
        } catch (e) {
          print('Failed to load product ${item.productId}: $e');
          // Don't halt execution if one product fails to load
        }
      }

      _calculateCartTotal();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Add product to cart
  Future<bool> addToCart(Product product, int quantity) async {
    if (userId == null) {
      _setError('User not signed in');
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      final cartItem = CartItem(
        id: '', // ID will be assigned by Firestore
        productId: product.id ?? 'nullID',
        quantity: quantity,
        priceAtAddition: product.finalPrice,
        addedAt: DateTime.now(),
      );

      await _firebaseService.addToCart(userId!, cartItem);

      // Reload cart
      await loadCart();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Update quantity of a cart item
  Future<bool> updateQuantity(String cartItemId, int newQuantity) async {
    if (userId == null) {
      _setError('User not signed in');
      return false;
    }

    if (newQuantity <= 0) {
      return removeFromCart(cartItemId);
    }

    _setLoading(true);
    _setError(null);

    try {
      await _firebaseService.updateCartItemQuantity(userId!, cartItemId, newQuantity);

      // Update local state
      final index = _cartItems.indexWhere((item) => item.id == cartItemId);
      if (index != -1) {
        _cartItems[index] = _cartItems[index].copyWith(quantity: newQuantity);
        _calculateCartTotal();
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Remove an item from cart
  Future<bool> removeFromCart(String cartItemId) async {
    if (userId == null) {
      _setError('User not signed in');
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      await _firebaseService.removeFromCart(userId!, cartItemId);

      // Update local state
      _cartItems.removeWhere((item) => item.id == cartItemId);
      _calculateCartTotal();

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Clear the entire cart
  Future<bool> clearCart() async {
    if (userId == null) {
      _setError('User not signed in');
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      await _firebaseService.clearCart(userId!);

      // Update local state
      _cartItems = [];
      _cartTotal = 0.0;

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Check if a product exists in cart
  bool isInCart(String productId) {
    return _cartItems.any((item) => item.productId == productId);
  }

  // Get cart item for a specific product
  CartItem? getCartItemForProduct(String productId) {
    try {
      return _cartItems.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }
}