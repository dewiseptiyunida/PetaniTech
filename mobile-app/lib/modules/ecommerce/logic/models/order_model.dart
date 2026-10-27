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
  final String? image;

  const OrderItemModel({
    required this.productName,
    required this.category,
    required this.price,
    required this.quantity,
    this.icon = Icons.agriculture_rounded,
    this.variant,
    this.image,
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
      'image': image,
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
      image: json['image']?.toString() ?? json['productImage']?.toString(),
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
  final String? paymentQrUrl;
  final String? paymentQrString;
  final String? paymentVaNumber;
  final String? paymentBillKey;
  final String? paymentBillerCode;

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
    this.paymentQrUrl,
    this.paymentQrString,
    this.paymentVaNumber,
    this.paymentBillKey,
    this.paymentBillerCode,
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
    String? paymentQrUrl,
    String? paymentQrString,
    String? paymentVaNumber,
    String? paymentBillKey,
    String? paymentBillerCode,
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
      paymentQrUrl: paymentQrUrl ?? this.paymentQrUrl,
      paymentQrString: paymentQrString ?? this.paymentQrString,
      paymentVaNumber: paymentVaNumber ?? this.paymentVaNumber,
      paymentBillKey: paymentBillKey ?? this.paymentBillKey,
      paymentBillerCode: paymentBillerCode ?? this.paymentBillerCode,
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
      'paymentQrUrl': paymentQrUrl,
      'paymentQrString': paymentQrString,
      'paymentVaNumber': paymentVaNumber,
      'paymentBillKey': paymentBillKey,
      'paymentBillerCode': paymentBillerCode,
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
      paymentQrUrl: json['paymentQrUrl']?.toString(),
      paymentQrString: json['paymentQrString']?.toString(),
      paymentVaNumber: json['paymentVaNumber']?.toString(),
      paymentBillKey: json['paymentBillKey']?.toString(),
      paymentBillerCode: json['paymentBillerCode']?.toString(),
    );
  }

  Map<String, dynamic> toBackendPayload() {
    String backendStatus;
    switch (status) {
      case OrderStatus.processing:
        backendStatus = 'Diproses';
        break;
      case OrderStatus.shipped:
        backendStatus = 'Dikirim';
        break;
      case OrderStatus.completed:
        backendStatus = 'Selesai';
        break;
      case OrderStatus.cancelled:
        backendStatus = 'Dibatalkan';
        break;
      case OrderStatus.awaitingPayment:
        backendStatus = 'Menunggu Pembayaran';
        break;
    }

    return {
      'id': id,
      'orderNumber': id,
      'storeName': shopName,
      'buyerName': receiver,
      'buyerPhone': phone,
      'buyerAddress': shippingAddress,
      'status': backendStatus,
      'totalAmount': total,
      'shippingFee': shippingCost,
      'courier': ('$courier $courierService').trim(),
      'trackingNumber': trackingNumber,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'note': cancellationReason ?? '',
      'items': items.map((item) => {
        'productName': item.productName,
        'category': item.category,
        'quantity': item.quantity,
        'unitPrice': item.price.toDouble(),
        'subtotal': item.subtotal.toDouble(),
        'variant': item.variant ?? '',
        'unit': item.variant ?? 'Pcs',
        'productImage': item.image ?? '',
      }).toList(),
    };
  }

  factory OrderModel.fromBackendJson(Map<String, dynamic> json) {
    final statusStr = json['status']?.toString().toLowerCase() ?? '';
    OrderStatus status = OrderStatus.awaitingPayment;
    if (statusStr.contains('batal') || statusStr == 'cancelled') {
      status = OrderStatus.cancelled;
    } else if (statusStr.contains('selesai') || statusStr == 'completed') {
      status = OrderStatus.completed;
    } else if (statusStr.contains('kirim') || statusStr == 'shipped') {
      status = OrderStatus.shipped;
    } else if (statusStr.contains('proses') || statusStr == 'processing') {
      status = OrderStatus.processing;
    } else {
      status = OrderStatus.awaitingPayment;
    }

    final rawItems = json['items'] as List<dynamic>? ?? [];
    final items = rawItems.map((item) {
      if (item is Map) {
        final itm = Map<String, dynamic>.from(item);
        final cat = itm['category']?.toString() ?? 'Produk';
        return OrderItemModel(
          productName: itm['productName']?.toString() ?? '',
          category: cat,
          price: (itm['unitPrice'] as num?)?.toInt() ?? 0,
          quantity: (itm['quantity'] as num?)?.toInt() ?? 1,
          variant: itm['unit']?.toString() ?? itm['variant']?.toString(),
          image: itm['productImage']?.toString() ?? itm['image']?.toString(),
        );
      }
      return const OrderItemModel(
        productName: '',
        category: '',
        price: 0,
        quantity: 1,
      );
    }).toList();

    DateTime createdAt = DateTime.tryParse(json['dateCreated']?.toString() ?? '') ??
        DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
        DateTime.now();

    final backendPayStatus = json['paymentStatus']?.toString() ??
        ((status == OrderStatus.completed || status == OrderStatus.shipped)
            ? 'Lunas'
            : (status == OrderStatus.cancelled ? 'Dibatalkan' : 'Menunggu Pembayaran'));

    return OrderModel(
      id: json['id']?.toString() ?? json['orderNumber']?.toString() ?? '',
      shopName: json['storeName']?.toString() ?? 'Tani Makmur Official Store',
      createdAt: createdAt,
      status: status,
      items: items,
      receiver: json['buyerName']?.toString() ?? '',
      phone: json['buyerPhone']?.toString() ?? '',
      shippingAddress: json['buyerAddress']?.toString() ?? '',
      courier: json['courier']?.toString() ?? 'Kurir PetaniTech',
      courierService: '',
      trackingNumber: json['trackingNumber']?.toString() ?? '',
      paymentMethod: json['paymentMethod']?.toString() ?? 'Transfer Bank',
      paymentStatus: backendPayStatus,
      cancellationReason: json['note']?.toString(),
      shippingCost: (json['shippingFee'] as num?)?.toInt() ?? 0,
      serviceFee: 2000,
      reviewed: false,
      paymentQrUrl: json['paymentQrUrl']?.toString() ?? json['payment_qr_url']?.toString(),
      paymentQrString: json['paymentQrString']?.toString() ?? json['payment_qr_string']?.toString(),
      paymentVaNumber: json['paymentVaNumber']?.toString() ?? json['payment_va_number']?.toString(),
      paymentBillKey: json['paymentBillKey']?.toString() ?? json['payment_bill_key']?.toString(),
      paymentBillerCode: json['paymentBillerCode']?.toString() ?? json['payment_biller_code']?.toString(),
    );
  }
}
