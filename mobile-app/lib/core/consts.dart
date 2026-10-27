import 'package:flutter/material.dart';

class Consts {
  static const double padding = 26.0;
  static const double padding16 = 16.0;
  static const double paddingHorizontal = 26.0;
  static const double paddingVertical = 10.0;
  static const double borderRadius = 20.0;

  static const List<String> months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<Map<String, dynamic>> bottomNavigation = [
    {
      "url": "/home",
      "name": "Beranda",
      "active": Icon(Icons.home, color: Colors.white, size: 20),
      "inactive": Icon(Icons.home, color: Colors.white, size: 20),
    },
    {
      "url": "/community",
      "name": "Komunitas",
      "active": Icon(Icons.group, color: Colors.white, size: 20),
      "inactive": Icon(Icons.group, color: Colors.white70, size: 20),
    },
    {
      "url": "/ecommerce",
      "name": "E-commerce",
      "active": Icon(Icons.shopping_cart, color: Colors.white, size: 20),
      "inactive": Icon(Icons.shopping_cart, color: Colors.white70, size: 20),
    },
    {
      "url": "/farming",
      "name": "Pertanian",
      "active": Icon(Icons.energy_savings_leaf, color: Colors.white, size: 20),
      "inactive": Icon(
        Icons.energy_savings_leaf,
        color: Colors.white70,
        size: 20,
      ),
    },
    {
      "url": "/weather",
      "name": "Cuaca",
      "active": Icon(Icons.cloudy_snowing, color: Colors.white, size: 20),
      "inactive": Icon(Icons.cloudy_snowing, color: Colors.white70, size: 20),
    },
    {
      "url": "/profile",
      "name": "Profil",
      "active": Icon(Icons.person_2, color: Colors.white, size: 20),
      "inactive": Icon(Icons.person_2, color: Colors.white70, size: 20),
    },
  ];
}
