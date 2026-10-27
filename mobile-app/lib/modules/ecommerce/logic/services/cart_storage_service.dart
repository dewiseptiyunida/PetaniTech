import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';

class CartStorageService {
  static const String _storageKey = 'petanitech_cart_items_v1';

  Future<List<CartItemModel>> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading cart from storage: $e');
      return [];
    }
  }

  /// Menyimpan seluruh data keranjang
  Future<void> saveCart(List<CartItemModel> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(items.map((i) => i.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      debugPrint('Error saving cart to storage: $e');
    }
  }

  /// Menghapus seluruh data keranjang 
  Future<void> clearCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      debugPrint('Error clearing cart storage: $e');
    }
  }
}
