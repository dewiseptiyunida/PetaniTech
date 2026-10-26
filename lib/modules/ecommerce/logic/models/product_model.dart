import 'package:flutter/material.dart';

class ProductVariantModel {
  final String name;
  final int price;
  final int stock;

  const ProductVariantModel({
    required this.name,
    required this.price,
    this.stock = 99,
  });

  factory ProductVariantModel.fromMap(Map<String, dynamic> map) {
    return ProductVariantModel(
      name: map['name']?.toString() ?? '',
      price: (map['price'] as num?)?.toInt() ?? 0,
      stock: (map['stock'] as num?)?.toInt() ?? 99,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'stock': stock,
    };
  }
}

class ProductModel {
  final String name;
  final String category;
  final int price;
  final IconData icon;
  final List<IconData> icons;
  final List<ProductVariantModel> variants;
  final int stock;
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
    this.icons = const [],
    this.variants = const [],
    this.stock = 99,
    this.rating = 4.8,
    this.soldCount = '100+ terjual',
    this.description = '',
    this.shopName = 'Tani Makmur Official Store',
    this.location = 'Kab. Bogor',
  });

  bool get hasVariants => variants.isNotEmpty;

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    final rawIcon = map['icon'] is IconData
        ? map['icon'] as IconData
        : Icons.shopping_bag_outlined;

    final List<IconData> parsedIcons = [];
    if (map['icons'] is List) {
      for (final item in map['icons'] as List) {
        if (item is IconData) {
          parsedIcons.add(item);
        }
      }
    }
    if (parsedIcons.isEmpty) {
      parsedIcons.add(rawIcon);
    }

    final List<ProductVariantModel> parsedVariants = [];
    if (map['variants'] is List) {
      for (final v in map['variants'] as List) {
        if (v is Map<String, dynamic>) {
          parsedVariants.add(ProductVariantModel.fromMap(v));
        } else if (v is Map) {
          parsedVariants.add(
            ProductVariantModel.fromMap(Map<String, dynamic>.from(v)),
          );
        }
      }
    }

    return ProductModel(
      name: map['name']?.toString() ?? 'Nama Produk',
      category: map['category']?.toString() ?? 'Produk',
      price: (map['price'] as num?)?.toInt() ?? 0,
      icon: rawIcon,
      icons: parsedIcons,
      variants: parsedVariants,
      stock: (map['stock'] as num?)?.toInt() ?? 99,
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
      'icons': icons,
      'variants': variants.map((v) => v.toMap()).toList(),
      'stock': stock,
      'rating': rating,
      'soldCount': soldCount,
      'description': description,
      'shopName': shopName,
      'location': location,
    };
  }
}

