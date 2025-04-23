import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum to define product categories
enum ProductCategory {
  electronics,
  clothing,
  furniture,
  groceries,
  beauty,
  toys,
  other
}

/// Enum for discount types
enum DiscountType {
  percentage,
  fixedAmount,
  none
}

/// Model class for Product
class Product {
  final String? id;
  final String name;
  final String description;
  final double price;
  final int stockQuantity;
  final DiscountType discountType;
  final double discountValue;
  final ProductCategory category;
  final List<String> imageUrls;
  final bool isAvailable;
  final Map<String, dynamic> attributes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stockQuantity,
    required this.discountType,
    required this.discountValue,
    required this.category,
    required this.imageUrls,
    required this.isAvailable,
    required this.attributes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert Product instance to Firestore document map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'stockQuantity': stockQuantity,
      'discountType': discountType.toString().split('.').last,
      'discountValue': discountValue,
      'category': category.toString().split('.').last,
      'imageUrls': imageUrls,
      'isAvailable': isAvailable,
      'attributes': attributes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create Product instance from Firestore document map
  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      stockQuantity: map['stockQuantity'] ?? 0,
      discountType: DiscountType.values.firstWhere(
            (e) => e.toString().split('.').last == map['discountType'],
        orElse: () => DiscountType.none,
      ),
      discountValue: (map['discountValue'] ?? 0).toDouble(),
      category: ProductCategory.values.firstWhere(
            (e) => e.toString().split('.').last == map['category'],
        orElse: () => ProductCategory.other,
      ),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      isAvailable: map['isAvailable'] ?? true,
      attributes: map['attributes'] ?? {},
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Calculate the final price after applying discount
  double get finalPrice {
    if (discountType == DiscountType.none || discountValue <= 0) {
      return price;
    } else if (discountType == DiscountType.percentage) {
      return price - (price * discountValue / 100);
    } else {
      return price - discountValue;
    }
  }

  /// Create a copy of the product with optional overrides
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? stockQuantity,
    DiscountType? discountType,
    double? discountValue,
    ProductCategory? category,
    List<String>? imageUrls,
    bool? isAvailable,
    Map<String, dynamic>? attributes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      category: category ?? this.category,
      imageUrls: imageUrls ?? this.imageUrls,
      isAvailable: isAvailable ?? this.isAvailable,
      attributes: attributes ?? this.attributes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}