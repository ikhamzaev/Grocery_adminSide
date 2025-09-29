import 'package:flutter/material.dart';

class Order {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String deliveryAddress;
  final String deliveryInstructions;
  final DateTime deliveryTime;
  final OrderStatus status;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem> items;
  final String? notes;

  const Order({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.deliveryAddress,
    required this.deliveryInstructions,
    required this.deliveryTime,
    required this.status,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
    this.notes,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      customerId: json['customer_id'] ?? '',
      customerName: json['customer_name'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      customerEmail: json['customer_email'] ?? '',
      deliveryAddress: json['delivery_address'] ?? '',
      deliveryInstructions: json['delivery_instructions'] ?? '',
      deliveryTime: DateTime.tryParse(json['delivery_time'] ?? '') ?? DateTime.now(),
      status: OrderStatus.fromString(json['status'] ?? 'pending'),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      deliveryFee: (json['delivery_fee'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'] ?? '',
      paymentStatus: json['payment_status'] ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_email': customerEmail,
      'delivery_address': deliveryAddress,
      'delivery_instructions': deliveryInstructions,
      'delivery_time': deliveryTime.toIso8601String(),
      'status': status.value,
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'total': total,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'notes': notes,
    };
  }

  Order copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? deliveryAddress,
    String? deliveryInstructions,
    DateTime? deliveryTime,
    OrderStatus? status,
    double? subtotal,
    double? deliveryFee,
    double? total,
    String? paymentMethod,
    String? paymentStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderItem>? items,
    String? notes,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      status: status ?? this.status,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
      notes: notes ?? this.notes,
    );
  }

  // Helper getters
  String get formattedTotal => '${total.toStringAsFixed(0)} сум';
  String get formattedSubtotal => '${subtotal.toStringAsFixed(0)} сум';
  String get formattedDeliveryFee => '${deliveryFee.toStringAsFixed(0)} сум';
  
  String get statusDisplayName {
    switch (status) {
      case OrderStatus.pending:
        return 'Кутилмоқда';
      case OrderStatus.confirmed:
        return 'Тасдиқланган';
      case OrderStatus.preparing:
        return 'Тайёрланишда';
      case OrderStatus.outForDelivery:
        return 'Етказиб беришда';
      case OrderStatus.delivered:
        return 'Етказилган';
      case OrderStatus.cancelled:
        return 'Бекор қилинган';
    }
  }

  Color get statusColor {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.purple;
      case OrderStatus.outForDelivery:
        return Colors.indigo;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.preparing:
        return Icons.restaurant;
      case OrderStatus.outForDelivery:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }
}

class OrderItem {
  final String id;
  final String productId;
  final String productName;
  final String productUnit;
  final double unitPrice;
  final int quantity;
  final double totalPrice;

  const OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productUnit,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      productUnit: json['product_unit'] ?? '',
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      totalPrice: (json['total_price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'product_unit': productUnit,
      'unit_price': unitPrice,
      'quantity': quantity,
      'total_price': totalPrice,
    };
  }

  String get formattedPrice => '${unitPrice.toStringAsFixed(0)} сум';
  String get formattedTotal => '${totalPrice.toStringAsFixed(0)} сум';
}

enum OrderStatus {
  pending('pending'),
  confirmed('confirmed'),
  preparing('preparing'),
  outForDelivery('out_for_delivery'),
  delivered('delivered'),
  cancelled('cancelled');

  const OrderStatus(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Кутилмоқда';
      case OrderStatus.confirmed:
        return 'Тасдиқланган';
      case OrderStatus.preparing:
        return 'Тайёрланишда';
      case OrderStatus.outForDelivery:
        return 'Етказиб беришда';
      case OrderStatus.delivered:
        return 'Етказилган';
      case OrderStatus.cancelled:
        return 'Бекор қилинган';
    }
  }

  static OrderStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'out_for_delivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}