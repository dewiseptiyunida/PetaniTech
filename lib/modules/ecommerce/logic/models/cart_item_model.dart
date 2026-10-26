import 'package:flutter/material.dart';

class CartItemModel {
  final String name;
  final String category;
  final int price;
  final IconData icon;
  final String shopName;
  final String? variant;

  int quantity;
  bool isSelected;

  CartItemModel({
    required this.name,
    required this.category,
    required this.price,
    required this.icon,
    this.shopName = 'Tani Makmur Official Store',
    this.variant,
    this.quantity = 1,
    this.isSelected = false,
  });

  int get subtotal => price * quantity;

  factory CartItemModel.fromProduct(Map<String, dynamic> product) {
    return CartItemModel(
      name: product['name']?.toString() ?? 'Nama Produk',
      category: product['category']?.toString() ?? 'Produk',
      price: (product['price'] as num?)?.toInt() ?? 0,
      icon: product['icon'] is IconData
          ? product['icon'] as IconData
          : (product['iconCodePoint'] is int
              ? IconData(
                  product['iconCodePoint'] as int,
                  fontFamily: 'MaterialIcons',
                )
              : Icons.shopping_bag_outlined),
      shopName: product['shopName']?.toString() ?? 'Tani Makmur Official Store',
      variant: product['variant']?.toString(),
      quantity: (product['quantity'] as num?)?.toInt() ?? 1,
      isSelected: product['isSelected'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'icon': icon,
      'iconCodePoint': icon.codePoint,
      'shopName': shopName,
      'variant': variant,
      'quantity': quantity,
      'isSelected': isSelected,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'iconCodePoint': icon.codePoint,
      'shopName': shopName,
      'variant': variant,
      'quantity': quantity,
      'isSelected': isSelected,
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      name: json['name']?.toString() ?? 'Nama Produk',
      category: json['category']?.toString() ?? 'Produk',
      price: (json['price'] as num?)?.toInt() ?? 0,
      icon: json['iconCodePoint'] != null
          ? IconData(
              json['iconCodePoint'] as int,
              fontFamily: 'MaterialIcons',
            )
          : (json['icon'] is IconData
              ? json['icon'] as IconData
              : Icons.shopping_bag_outlined),
      shopName: json['shopName']?.toString() ?? 'Tani Makmur Official Store',
      variant: json['variant']?.toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      isSelected: json['isSelected'] == true,
    );
  }

  CartItemModel copy() {
    return CartItemModel(
      name: name,
      category: category,
      price: price,
      icon: icon,
      shopName: shopName,
      variant: variant,
      quantity: quantity,
      isSelected: isSelected,
    );
  }
}
