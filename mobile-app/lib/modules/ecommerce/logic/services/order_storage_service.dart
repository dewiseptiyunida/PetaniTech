import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:petanitech_mobile/core/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_model.dart';

class OrderStorageService {
  static const String _storageKey = 'petanitech_orders_history_v1';
  final Dio _dio = Dio();

  /// Memuat riwayat pesanan dari cache lokal (SharedPreferences).
  Future<List<OrderModel>> loadOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded
          .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[OrderStorageService] Error loading orders from local cache: $e');
      return [];
    }
  }

  /// Mengambil data pesanan langsung dari backend Go (GET /api/v1/orders).
  /// Sekaligus memperbarui cache lokal untuk performa dan offline fallback.
  Future<List<OrderModel>> fetchOrdersFromBackend() async {
    try {
      final response = await _dio.get(
        '$appUrl/orders',
        options: Options(
          receiveTimeout: const Duration(seconds: 8),
          sendTimeout: const Duration(seconds: 8),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final rawData = response.data;
        final List<dynamic> listData = rawData is List
            ? rawData
            : (rawData is Map && rawData['data'] is List
                ? rawData['data'] as List
                : []);

        final List<OrderModel> backendOrders = [];
        for (var item in listData) {
          if (item is Map<String, dynamic>) {
            backendOrders.add(OrderModel.fromBackendJson(item));
          } else if (item is Map) {
            backendOrders.add(
              OrderModel.fromBackendJson(Map<String, dynamic>.from(item)),
            );
          }
        }

        if (backendOrders.isNotEmpty) {
          await saveOrders(backendOrders);
        }
        return backendOrders;
      }
    } catch (e) {
      debugPrint('[OrderStorageService] Error fetching orders from backend: $e');
    }
    return [];
  }

  /// Membuat pesanan baru ke backend Go (POST /api/v1/orders).
  /// Mengurangi stok produk seller dan mencatat order secara terpusat di database.
  Future<bool> createOrderToBackend(OrderModel order) async {
    try {
      final payload = order.toBackendPayload();
      final response = await _dio.post(
        '$appUrl/orders',
        data: payload,
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
        ),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('[OrderStorageService] Error creating order to backend: $e');
      return false;
    }
  }

  /// Membatalkan pesanan di backend Go (PUT /api/v1/orders/:id/cancel).
  Future<bool> cancelOrderToBackend(String orderId, {String? reason}) async {
    try {
      final response = await _dio.put(
        '$appUrl/orders/$orderId/cancel',
        data: {'reason': reason ?? 'Dibatalkan oleh pembeli'},
        options: Options(
          receiveTimeout: const Duration(seconds: 8),
          sendTimeout: const Duration(seconds: 8),
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[OrderStorageService] Error cancelling order on backend: $e');
      return false;
    }
  }

  /// Melakukan charge transaksi ke Midtrans Core API via backend Go
  Future<Map<String, dynamic>?> chargeMidtrans({
    required String orderId,
    String? paymentType,
    String? bank,
    double? grossAmount,
  }) async {
    try {
      final response = await _dio.post(
        '$appUrl/payments/midtrans/charge',
        data: {
          'orderId': orderId,
          if (paymentType != null) 'paymentType': paymentType,
          if (bank != null) 'bank': bank,
          if (grossAmount != null) 'grossAmount': grossAmount,
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
          headers: {'Content-Type': 'application/json'},
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) return data;
        if (data is Map) return Map<String, dynamic>.from(data);
      }
    } catch (e) {
      debugPrint('[OrderStorageService] Error charging midtrans: $e');
    }
    return null;
  }

  /// Sinkronisasi / cek status pembayaran secara manual ke backend Go
  Future<OrderModel?> syncMidtransStatus(String orderId) async {
    try {
      final response = await _dio.get(
        '$appUrl/payments/midtrans/status/$orderId',
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        final rawData = response.data['data'];
        if (rawData is Map) {
          final updated = OrderModel.fromBackendJson(Map<String, dynamic>.from(rawData));
          return updated;
        }
      }
    } catch (e) {
      debugPrint('[OrderStorageService] Error syncing midtrans status: $e');
    }
    return null;
  }

  /// Menyimpan daftar pesanan ke SharedPreferences.
  Future<void> saveOrders(List<OrderModel> orders) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(orders.map((o) => o.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      debugPrint('[OrderStorageService] Error saving orders to storage: $e');
    }
  }

  /// Menghapus seluruh riwayat pesanan dari penyimpanan lokal.
  Future<void> clearOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, '[]');
    } catch (e) {
      debugPrint('[OrderStorageService] Error clearing orders storage: $e');
    }
  }
}
