import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_model.dart';

class OrderStorageService {
  static const String _storageKey = 'petanitech_orders_history_v1';

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
      debugPrint('Error loading orders from storage: $e');
      return [];
    }
  }

  List<OrderModel> _getInitialSeedOrders() {
    final now = DateTime.now();
    return [
      OrderModel(
        id: 'PT-HIST-01',
        shopName: 'Toko Tani Makmur',
        createdAt: now.subtract(const Duration(days: 3)),
        status: OrderStatus.completed,
        paymentStatus: 'Lunas',
        receiver: 'Budi Santoso',
        phone: '0812-3456-7890',
        shippingAddress: 'Jl. Raya Pertanian No. 45, Karanganyar, Jawa Tengah',
        courier: 'J&T Express',
        courierService: 'Reguler',
        trackingNumber: 'PT-TRK-992101',
        paymentMethod: 'QRIS',
        shippingCost: 10000,
        serviceFee: 2000,
        reviewed: true,
        items: const [
          OrderItemModel(
            productName: 'Pupuk NPK Mutiara',
            category: 'Pupuk',
            price: 25000,
            quantity: 2,
            variant: '1 Kg',
            icon: Icons.eco_rounded,
          ),
        ],
      ),
      OrderModel(
        id: 'PT-HIST-02',
        shopName: 'Toko Tani Makmur',
        createdAt: now.subtract(const Duration(days: 7)),
        status: OrderStatus.completed,
        paymentStatus: 'Lunas',
        receiver: 'Budi Santoso',
        phone: '0812-3456-7890',
        shippingAddress: 'Jl. Raya Pertanian No. 45, Karanganyar, Jawa Tengah',
        courier: 'SiCepat',
        courierService: 'Halu',
        trackingNumber: 'PT-TRK-981203',
        paymentMethod: 'Transfer Bank (BCA)',
        shippingCost: 10000,
        serviceFee: 2000,
        reviewed: true,
        items: const [
          OrderItemModel(
            productName: 'Pupuk NPK Mutiara',
            category: 'Pupuk',
            price: 115000,
            quantity: 1,
            variant: '5 Kg',
            icon: Icons.eco_rounded,
          ),
        ],
      ),
      OrderModel(
        id: 'PT-HIST-03',
        shopName: 'Benih Unggul Nusantara',
        createdAt: now.subtract(const Duration(days: 10)),
        status: OrderStatus.completed,
        paymentStatus: 'Lunas',
        receiver: 'Budi Santoso',
        phone: '0812-3456-7890',
        shippingAddress: 'Jl. Raya Pertanian No. 45, Karanganyar, Jawa Tengah',
        courier: 'JNE',
        courierService: 'Regular',
        trackingNumber: 'PT-TRK-971032',
        paymentMethod: 'QRIS',
        shippingCost: 10000,
        serviceFee: 2000,
        reviewed: true,
        items: const [
          OrderItemModel(
            productName: 'Benih Padi Unggul',
            category: 'Benih',
            price: 45000,
            quantity: 3,
            variant: 'Kemasan 1 Kg',
            icon: Icons.grass_rounded,
          ),
        ],
      ),
      OrderModel(
        id: 'PT-HIST-04',
        shopName: 'Perkakas Tani Jaya',
        createdAt: now.subtract(const Duration(days: 14)),
        status: OrderStatus.completed,
        paymentStatus: 'Lunas',
        receiver: 'Budi Santoso',
        phone: '0812-3456-7890',
        shippingAddress: 'Jl. Raya Pertanian No. 45, Karanganyar, Jawa Tengah',
        courier: 'Anteraja',
        courierService: 'Reguler',
        trackingNumber: 'PT-TRK-950291',
        paymentMethod: 'COD (Bayar di Tempat)',
        shippingCost: 10000,
        serviceFee: 2000,
        reviewed: true,
        items: const [
          OrderItemModel(
            productName: 'Cangkul Besi',
            category: 'Alat',
            price: 85000,
            quantity: 1,
            icon: Icons.hardware_rounded,
          ),
        ],
      ),
      OrderModel(
        id: 'PT-ORD-005',
        shopName: 'Alat Pertanian Mandiri',
        createdAt: now.subtract(const Duration(days: 1)),
        status: OrderStatus.completed,
        paymentStatus: 'Lunas',
        receiver: 'Budi Santoso',
        phone: '0812-3456-7890',
        shippingAddress: 'Jl. Raya Pertanian No. 45, Karanganyar, Jawa Tengah',
        courier: 'SiCepat',
        courierService: 'Best',
        trackingNumber: 'PT-TRK-990812',
        paymentMethod: 'Transfer Bank (Mandiri)',
        shippingCost: 10000,
        serviceFee: 2000,
        reviewed: false,
        items: const [
          OrderItemModel(
            productName: 'Sprayer Elektrik',
            category: 'Alat',
            price: 250000,
            quantity: 1,
            icon: Icons.shower_rounded,
          ),
        ],
      ),
      OrderModel(
        id: 'PT-ORD-006',
        shopName: 'Toko Tani Makmur',
        createdAt: now.subtract(const Duration(days: 2)),
        status: OrderStatus.shipped,
        paymentStatus: 'Lunas',
        receiver: 'Budi Santoso',
        phone: '0812-3456-7890',
        shippingAddress: 'Jl. Raya Pertanian No. 45, Karanganyar, Jawa Tengah',
        courier: 'J&T Express',
        courierService: 'EZ',
        trackingNumber: 'PT-TRK-771822',
        paymentMethod: 'QRIS',
        shippingCost: 10000,
        serviceFee: 2000,
        reviewed: false,
        items: const [
          OrderItemModel(
            productName: 'Pupuk NPK Mutiara',
            category: 'Pupuk',
            price: 25000,
            quantity: 2,
            variant: '1 Kg',
            icon: Icons.eco_rounded,
          ),
        ],
      ),
      OrderModel(
        id: 'PT-ORD-007',
        shopName: 'Benih Unggul Nusantara',
        createdAt: now.subtract(const Duration(hours: 4)),
        status: OrderStatus.processing,
        paymentStatus: 'Lunas',
        receiver: 'Budi Santoso',
        phone: '0812-3456-7890',
        shippingAddress: 'Jl. Raya Pertanian No. 45, Karanganyar, Jawa Tengah',
        courier: 'JNE',
        courierService: 'Regular',
        trackingNumber: '',
        paymentMethod: 'Transfer Bank (BRI)',
        shippingCost: 10000,
        serviceFee: 2000,
        reviewed: false,
        items: const [
          OrderItemModel(
            productName: 'Benih Padi Unggul',
            category: 'Benih',
            price: 210000,
            quantity: 1,
            variant: 'Kemasan 5 Kg',
            icon: Icons.grass_rounded,
          ),
        ],
      ),
      OrderModel(
        id: 'PT-ORD-008',
        shopName: 'Toko Tani Makmur',
        createdAt: now.subtract(const Duration(minutes: 15)),
        status: OrderStatus.awaitingPayment,
        paymentStatus: 'Belum Dibayar',
        receiver: 'Budi Santoso',
        phone: '0812-3456-7890',
        shippingAddress: 'Jl. Raya Pertanian No. 45, Karanganyar, Jawa Tengah',
        courier: 'J&T Express',
        courierService: 'EZ',
        trackingNumber: '',
        paymentMethod: 'QRIS',
        shippingCost: 10000,
        serviceFee: 2000,
        reviewed: false,
        items: const [
          OrderItemModel(
            productName: 'Pupuk NPK Mutiara',
            category: 'Pupuk',
            price: 550000,
            quantity: 1,
            variant: '25 Kg',
            icon: Icons.eco_rounded,
          ),
        ],
      ),
      OrderModel(
        id: 'PT-ORD-009',
        shopName: 'Perkakas Tani Jaya',
        createdAt: now.subtract(const Duration(days: 5)),
        status: OrderStatus.cancelled,
        paymentStatus: 'Dibatalkan',
        cancellationReason: 'Salah memilih produk atau varian',
        receiver: 'Budi Santoso',
        phone: '0812-3456-7890',
        shippingAddress: 'Jl. Raya Pertanian No. 45, Karanganyar, Jawa Tengah',
        courier: 'Anteraja',
        courierService: 'Reguler',
        trackingNumber: '',
        paymentMethod: 'COD (Bayar di Tempat)',
        shippingCost: 10000,
        serviceFee: 2000,
        reviewed: false,
        items: const [
          OrderItemModel(
            productName: 'Cangkul Besi',
            category: 'Alat',
            price: 85000,
            quantity: 1,
            icon: Icons.hardware_rounded,
          ),
        ],
      ),
    ];
  }

  /// Menyimpan daftar pesanan ke SharedPreferences.
  Future<void> saveOrders(List<OrderModel> orders) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(orders.map((o) => o.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      debugPrint('Error saving orders to storage: $e');
    }
  }

  /// Menghapus seluruh riwayat pesanan dari penyimpanan lokal.
  Future<void> clearOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, '[]');
    } catch (e) {
      debugPrint('Error clearing orders storage: $e');
    }
  }
}
