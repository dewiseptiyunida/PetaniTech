import 'package:flutter/material.dart';

class ProductModel {
  final String name;
  final String category;
  final int price;
  final IconData icon;
  final double rating;
  final String soldCount;
  final String description;
  final String shopName;
  final String location;

  const ProductModel({
    required this.name,
    required this.category,
    required this.price,
    required this.icon,
    this.rating = 4.8,
    this.soldCount = '100+ terjual',
    this.description = '',
    this.shopName = 'Tani Makmur Official Store',
    this.location = 'Kab. Bogor',
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      name: map['name']?.toString() ?? 'Nama Produk',
      category: map['category']?.toString() ?? 'Produk',
      price: (map['price'] as num?)?.toInt() ?? 0,
      icon:
          map['icon'] is IconData
              ? map['icon'] as IconData
              : Icons.shopping_bag_outlined,
      rating: (map['rating'] as num?)?.toDouble() ?? 4.8,
      soldCount: map['soldCount']?.toString() ?? '100+ terjual',
      description: map['description']?.toString() ?? '',
      shopName: map['shopName']?.toString() ?? 'Tani Makmur Official Store',
      location: map['location']?.toString() ?? 'Kab. Bogor',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'icon': icon,
      'rating': rating,
      'soldCount': soldCount,
      'description': description,
      'shopName': shopName,
      'location': location,
    };
  }
}
