import 'package:flutter/material.dart';

enum OrderStatus { awaitingPayment, processing, shipped, completed, cancelled }

extension OrderStatusInfo on OrderStatus {
  String get label => switch (this) {
    OrderStatus.awaitingPayment => 'Belum Bayar',
    OrderStatus.processing => 'Diproses',
    OrderStatus.shipped => 'Dikirim',
    OrderStatus.completed => 'Selesai',
    OrderStatus.cancelled => 'Dibatalkan',
  };

  Color get color => switch (this) {
    OrderStatus.awaitingPayment => const Color(0xFFE69B26),
    OrderStatus.processing => const Color(0xFF3978C5),
    OrderStatus.shipped => const Color(0xFF7B61B5),
    OrderStatus.completed => const Color(0xFF5E963F),
    OrderStatus.cancelled => const Color(0xFFD9534F),
  };

  IconData get icon => switch (this) {
    OrderStatus.awaitingPayment => Icons.payment_rounded,
    OrderStatus.processing => Icons.inventory_2_outlined,
    OrderStatus.shipped => Icons.local_shipping_outlined,
    OrderStatus.completed => Icons.check_circle_outline_rounded,
    OrderStatus.cancelled => Icons.cancel_outlined,
  };
}

class OrderItemModel {
  final String productName;
  final String category;
  final int price;
  final int quantity;
  final IconData icon;
  final String? variant;

  const OrderItemModel({
    required this.productName,
    required this.category,
    required this.price,
    required this.quantity,
    this.icon = Icons.agriculture_rounded,
    this.variant,
  });

  int get subtotal => price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'category': category,
      'price': price,
      'quantity': quantity,
      'iconCodePoint': icon.codePoint,
      'variant': variant,
    };
  }

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productName: json['productName']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      icon: json['iconCodePoint'] != null
          ? IconData(
              json['iconCodePoint'] as int,
              fontFamily: 'MaterialIcons',
            )
          : (json['icon'] is IconData
              ? json['icon'] as IconData
              : Icons.agriculture_rounded),
      variant: json['variant']?.toString(),
    );
  }
}

class OrderModel {
  final String id;
  final String shopName;
  final DateTime createdAt;
  final OrderStatus status;
  final List<OrderItemModel> items;
  final String receiver;
  final String phone;
  final String shippingAddress;
  final String courier;
  final String courierService;
  final String trackingNumber;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime? paymentExpiresAt;
  final String? cancellationReason;
  final int shippingCost;
  final int serviceFee;
  final bool reviewed;

  const OrderModel({
    required this.id,
    required this.shopName,
    required this.createdAt,
    required this.status,
    required this.items,
    required this.receiver,
    required this.phone,
    required this.shippingAddress,
    required this.courier,
    required this.courierService,
    required this.trackingNumber,
    required this.paymentMethod,
    this.paymentStatus = 'Belum Dibayar',
    this.paymentExpiresAt,
    this.cancellationReason,
    this.shippingCost = 0,
    this.serviceFee = 0,
    this.reviewed = false,
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  int get productTotal => items.fold(0, (sum, item) => sum + item.subtotal);
  int get total => productTotal + shippingCost + serviceFee;

  OrderModel copyWith({
    OrderStatus? status,
    String? paymentStatus,
    String? cancellationReason,
    bool? reviewed,
    String? trackingNumber,
  }) {
    return OrderModel(
      id: id,
      shopName: shopName,
      createdAt: createdAt,
      status: status ?? this.status,
      items: items,
      receiver: receiver,
      phone: phone,
      shippingAddress: shippingAddress,
      courier: courier,
      courierService: courierService,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentExpiresAt: paymentExpiresAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      shippingCost: shippingCost,
      serviceFee: serviceFee,
      reviewed: reviewed ?? this.reviewed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopName': shopName,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'items': items.map((item) => item.toJson()).toList(),
      'receiver': receiver,
      'phone': phone,
      'shippingAddress': shippingAddress,
      'courier': courier,
      'courierService': courierService,
      'trackingNumber': trackingNumber,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'paymentExpiresAt': paymentExpiresAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
      'shippingCost': shippingCost,
      'serviceFee': serviceFee,
      'reviewed': reviewed,
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      shopName: json['shopName']?.toString() ?? 'Tani Makmur Official Store',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      status: OrderStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => OrderStatus.awaitingPayment,
      ),
      items: (json['items'] as List<dynamic>?)
              ?.map(
                (item) => OrderItemModel.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      receiver: json['receiver']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      shippingAddress: json['shippingAddress']?.toString() ?? '',
      courier: json['courier']?.toString() ?? '',
      courierService: json['courierService']?.toString() ?? '',
      trackingNumber: json['trackingNumber']?.toString() ?? '',
      paymentMethod: json['paymentMethod']?.toString() ?? 'Transfer Bank',
      paymentStatus: json['paymentStatus']?.toString() ?? 'Belum Dibayar',
      paymentExpiresAt: DateTime.tryParse(json['paymentExpiresAt']?.toString() ?? ''),
      cancellationReason: json['cancellationReason']?.toString(),
      shippingCost: (json['shippingCost'] as num?)?.toInt() ?? 0,
      serviceFee: (json['serviceFee'] as num?)?.toInt() ?? 0,
      reviewed: json['reviewed'] == true,
    );
  }
}
