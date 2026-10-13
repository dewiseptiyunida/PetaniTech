import 'package:flutter/material.dart';

class CartItemModel {
  final String name;
  final String category;
  final int price;
  final IconData icon;
  final String shopName;

  int quantity;
  bool isSelected;

  CartItemModel({
    required this.name,
    required this.category,
    required this.price,
    required this.icon,
    this.shopName = 'Tani Makmur Official Store',
    this.quantity = 1,
    this.isSelected = false,
  });

  int get subtotal => price * quantity;

  factory CartItemModel.fromProduct(Map<String, dynamic> product) {
    return CartItemModel(
      name: product['name']?.toString() ?? 'Nama Produk',
      category: product['category']?.toString() ?? 'Produk',
      price: (product['price'] as num?)?.toInt() ?? 0,
      icon:
          product['icon'] is IconData
              ? product['icon'] as IconData
              : Icons.shopping_bag_outlined,
      shopName: product['shopName']?.toString() ?? 'Tani Makmur Official Store',
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
      'shopName': shopName,
      'quantity': quantity,
      'isSelected': isSelected,
    };
  }

  CartItemModel copy() {
    return CartItemModel(
      name: name,
      category: category,
      price: price,
      icon: icon,
      shopName: shopName,
      quantity: quantity,
      isSelected: isSelected,
    );
  }
}
