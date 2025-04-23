// cart_item_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String id;
  final String productId;
  final int quantity;
  final double priceAtAddition;
  final DateTime addedAt;

  CartItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.priceAtAddition,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'quantity': quantity,
      'priceAtAddition': priceAtAddition,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map, String id) {
    return CartItem(
      id: id,
      productId: map['productId'] ?? '',
      quantity: map['quantity'] ?? 1,
      priceAtAddition: (map['priceAtAddition'] ?? 0).toDouble(),
      addedAt: (map['addedAt'] as Timestamp).toDate(),
    );
  }

  CartItem copyWith({
    String? id,
    String? productId,
    int? quantity,
    double? priceAtAddition,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      priceAtAddition: priceAtAddition ?? this.priceAtAddition,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}