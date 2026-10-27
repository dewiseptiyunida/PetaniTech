import 'package:flutter/material.dart';

class AddressModel {
  final String id;
  final String label;
  final bool isDefault;
  final String receiver;
  final String phone;
  final String fullAddress;

  const AddressModel({
    required this.id,
    required this.label,
    this.isDefault = false,
    required this.receiver,
    required this.phone,
    required this.fullAddress,
  });

  AddressModel copyWith({
    String? id,
    String? label,
    bool? isDefault,
    String? receiver,
    String? phone,
    String? fullAddress,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      isDefault: isDefault ?? this.isDefault,
      receiver: receiver ?? this.receiver,
      phone: phone ?? this.phone,
      fullAddress: fullAddress ?? this.fullAddress,
    );
  }

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id']?.toString() ?? '',
      label: map['label']?.toString() ?? 'Alamat',
      isDefault: map['isDefault'] == true,
      receiver: map['receiver']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      fullAddress: map['fullAddress']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'isDefault': isDefault,
      'receiver': receiver,
      'phone': phone,
      'fullAddress': fullAddress,
    };
  }
}

class CourierModel {
  final String name;
  final String service;
  final int price;
  final String estimate;
  final IconData icon;

  const CourierModel({
    required this.name,
    required this.service,
    required this.price,
    required this.estimate,
    required this.icon,
  });

  factory CourierModel.fromMap(Map<String, dynamic> map) {
    return CourierModel(
      name: map['name']?.toString() ?? '',
      service: map['service']?.toString() ?? '',
      price: (map['price'] as num?)?.toInt() ?? 0,
      estimate: map['estimate']?.toString() ?? '',
      icon:
          map['icon'] is IconData
              ? map['icon'] as IconData
              : Icons.local_shipping_rounded,
    );
  }
}

class BankModel {
  final String name;
  final String code;
  final String desc;

  const BankModel({required this.name, required this.code, required this.desc});
}

class CheckoutItemModel {
  final String name;
  final String category;
  final int price;
  final IconData icon;
  final int quantity;
  final String shopName;
  final String? variant;
  final String? image;

  const CheckoutItemModel({
    required this.name,
    required this.category,
    required this.price,
    required this.icon,
    this.quantity = 1,
    this.shopName = 'Tani Makmur Official Store',
    this.variant,
    this.image,
  });

  int get subtotal => price * quantity;

  factory CheckoutItemModel.fromMap(Map<String, dynamic> map) {
    return CheckoutItemModel(
      name: map['name']?.toString() ?? 'Nama Produk',
      category: map['category']?.toString() ?? 'Produk',
      price:
          (map['price'] as num?)?.toInt() ??
          int.tryParse('${map['price']}') ??
          0,
      icon:
          map['icon'] is IconData
              ? map['icon'] as IconData
              : (map['iconCodePoint'] is int
                  ? IconData(map['iconCodePoint'] as int,
                      fontFamily: 'MaterialIcons')
                  : Icons.shopping_bag_outlined),
      quantity:
          (map['quantity'] as num?)?.toInt() ??
          int.tryParse('${map['quantity']}') ??
          1,
      shopName: map['shopName']?.toString() ?? 'Tani Makmur Official Store',
      variant: map['variant']?.toString(),
      image: map['image']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'icon': icon,
      'quantity': quantity,
      'shopName': shopName,
      'variant': variant,
      'image': image,
    };
  }
}
