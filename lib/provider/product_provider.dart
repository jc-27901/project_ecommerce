// product_provider.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../models/product_dm.dart';
import '../services/firebase_services.dart';

class ProductProvider extends ChangeNotifier {
  final BaseFirebaseService _firebaseService;
  bool _isLoading = false;
  String? _error;
  List<Product> _products = [];
  bool _isLoadingProducts = false;

  ProductProvider(this._firebaseService);

  bool get isLoading => _isLoading;
  bool get isLoadingProducts => _isLoadingProducts;
  String? get error => _error;
  List<Product> get products => _products;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<bool> createProduct({
    required String name,
    required String description,
    required double price,
    required int stockQuantity,
    required DiscountType discountType,
    required double discountValue,
    required ProductCategory category,
    required List<File> images,
    required bool isAvailable,
    required Map<String, dynamic> attributes,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      Product product = Product(
        name: name,
        description: description,
        price: price,
        stockQuantity: stockQuantity,
        discountType: discountType,
        discountValue: discountValue,
        category: category,
        imageUrls: [],
        isAvailable: isAvailable,
        attributes: attributes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firebaseService.uploadProduct(product, images);
      _setLoading(false);
      // Refresh product list after adding a new one
      fetchProducts();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> fetchProducts() async {
    _isLoadingProducts = true;
    _setError(null);
    notifyListeners();

    try {
      _products = await _firebaseService.getAllProducts();
      _isLoadingProducts = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  Future<bool> updateProduct(String productId, Product updatedProduct, List<File>? newImages) async {
    _setLoading(true);
    _setError(null);

    try {
      if (newImages != null && newImages.isNotEmpty) {
        // Upload new images and update product with new image URLs
        await _firebaseService.updateProductWithImages(productId, updatedProduct, newImages);
      } else {
        // Just update product data without changing images
        await _firebaseService.updateProduct(productId, updatedProduct);
      }

      _setLoading(false);
      // Refresh product list after update
      fetchProducts();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    _setLoading(true);
    _setError(null);

    try {
      await _firebaseService.deleteProduct(productId);
      _setLoading(false);
      // Refresh product list after deletion
      fetchProducts();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }
}