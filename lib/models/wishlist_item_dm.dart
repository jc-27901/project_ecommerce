// wishlist_item_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistItem {
  final String id;
  final String productId;
  final DateTime addedAt;

  WishlistItem({
    required this.id,
    required this.productId,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  factory WishlistItem.fromMap(Map<String, dynamic> map, String id) {
    return WishlistItem(
      id: id,
      productId: map['productId'] ?? '',
      addedAt: (map['addedAt'] as Timestamp).toDate(),
    );
  }
}