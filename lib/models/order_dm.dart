// order_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled,
  returned
}

class OrderItem {
  final String productId;
  final String productName;
  final double productPrice;
  final int quantity;
  final String? productImageUrl;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.quantity,
    this.productImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productPrice': productPrice,
      'quantity': quantity,
      'productImageUrl': productImageUrl,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productPrice: (map['productPrice'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
      productImageUrl: map['productImageUrl'],
    );
  }
}

class OrderDm {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double shippingCost;
  final double total;
  final OrderStatus status;
  final Map<String, dynamic> shippingAddress;
  final String? paymentMethod;
  final String? paymentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderDm({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.shippingCost,
    required this.total,
    required this.status,
    required this.shippingAddress,
    this.paymentMethod,
    this.paymentId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'shippingCost': shippingCost,
      'total': total,
      'status': status.toString().split('.').last,
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
      'paymentId': paymentId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory OrderDm.fromMap(Map<String, dynamic> map, String id) {
    return OrderDm(
      id: id,
      userId: map['userId'] ?? '',
      items: List<OrderItem>.from(
          (map['items'] ?? []).map((item) => OrderItem.fromMap(item))
      ),
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      tax: (map['tax'] ?? 0).toDouble(),
      shippingCost: (map['shippingCost'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      status: OrderStatus.values.firstWhere(
            (e) => e.toString().split('.').last == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      shippingAddress: map['shippingAddress'] ?? {},
      paymentMethod: map['paymentMethod'],
      paymentId: map['paymentId'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  OrderDm copyWith({
    String? id,
    String? userId,
    List<OrderItem>? items,
    double? subtotal,
    double? tax,
    double? shippingCost,
    double? total,
    OrderStatus? status,
    Map<String, dynamic>? shippingAddress,
    String? paymentMethod,
    String? paymentId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderDm(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      shippingCost: shippingCost ?? this.shippingCost,
      total: total ?? this.total,
      status: status ?? this.status,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentId: paymentId ?? this.paymentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}