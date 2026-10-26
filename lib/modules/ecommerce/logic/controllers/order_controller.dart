import 'dart:async';

import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../services/order_storage_service.dart';

class OrderController extends ChangeNotifier {
  static final OrderController instance = OrderController();

  final OrderStorageService _storageService;
  final List<OrderModel> _orders;
  bool _isLoaded = false;
  Timer? _expiryTimer;

  OrderController({
    List<OrderModel>? initialOrders,
    OrderStorageService? storageService,
  })  : _storageService = storageService ?? OrderStorageService(),
        _orders = List<OrderModel>.of(initialOrders ?? []) {
    loadFromStorage();
  }

  // Daftar seluruh pesanan (terurut terbaru di atas).
  List<OrderModel> get orders => List.unmodifiable(_orders);

  bool get isLoaded => _isLoaded;

  // Pesanan selesai yang belum diulas.
  List<OrderModel> get unreviewedCompletedOrders => _orders
      .where((o) => o.status == OrderStatus.completed && !o.reviewed)
      .toList(growable: false);

  // Menghitung jumlah pesanan berdasarkan status.
  int countByStatus(OrderStatus status) =>
      _orders.where((order) => order.status == status).length;

  Future<void>? _loadFuture;

  @override
  void dispose() {
    _expiryTimer?.cancel();
    super.dispose();
  }

  /// Memuat riwayat pesanan dari penyimpanan lokal (SharedPreferences).
  Future<void> loadFromStorage() {
    _loadFuture ??= _doLoad();
    return _loadFuture!;
  }

  Future<void> _doLoad() async {
    final loaded = await _storageService.loadOrders();
    if (_orders.isEmpty && loaded.isNotEmpty) {
      _orders.addAll(loaded);
      _sortOrders();
    }
    _isLoaded = true;
    await _cancelExpiredOrders();
    _expiryTimer ??= Timer.periodic(
      const Duration(seconds: 1),
      (_) => _cancelExpiredOrders(),
    );
    notifyListeners();
  }

  Future<void> _persist() async {
    await _storageService.saveOrders(_orders);
  }

  /// Batas pembayaran: QRIS 10 menit, transfer bank 24 jam.
  /// Pesanan kedaluwarsa dibatalkan hanya jika masih menunggu pembayaran.
  DateTime _paymentDeadline(OrderModel order) {
    if (order.paymentExpiresAt != null) return order.paymentExpiresAt!;
    final isQris = order.paymentMethod.toLowerCase().contains('qris');
    return order.createdAt.add(
      isQris ? const Duration(minutes: 10) : const Duration(hours: 24),
    );
  }

  Future<void> _cancelExpiredOrders() async {
    if (!_isLoaded) return;
    final now = DateTime.now();
    var changed = false;

    for (var i = 0; i < _orders.length; i++) {
      final order = _orders[i];
      if (order.status != OrderStatus.awaitingPayment) continue;
      if (order.paymentStatus.toLowerCase().contains('lunas')) continue;
      if (now.isBefore(_paymentDeadline(order))) continue;

      _orders[i] = order.copyWith(
        status: OrderStatus.cancelled,
        paymentStatus: 'Dibatalkan',
        cancellationReason: 'Waktu pembayaran telah habis',
      );
      changed = true;
    }

    if (changed) {
      notifyListeners();
      await _persist();
    }
  }

  void _sortOrders() {
    _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Menambahkan pesanan baru.
  Future<void> addOrder(OrderModel order) async {
    await loadFromStorage();
    // Hindari pesanan ganda dengan nomor order yang sama.
    if (_orders.any((existing) => existing.id == order.id)) return;
    _orders.insert(0, order);
    notifyListeners();
    await _persist();
    await _cancelExpiredOrders();
  }

  /// Mencari pesanan berdasarkan ID.
  OrderModel? findById(String id) {
    for (final order in _orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  /// Memfilter pesanan berdasarkan status.
  List<OrderModel> filter(OrderStatus? status) {
    if (status == null) return List.unmodifiable(_orders);
    return _orders.where((order) => order.status == status).toList();
  }

  /// Memperbarui status pesanan dan status pembayaran.
  Future<void> updateStatus(
    String id,
    OrderStatus status, {
    String? paymentStatus,
    String? trackingNumber,
  }) async {
    final index = _orders.indexWhere((order) => order.id == id);
    if (index < 0) return;
    _orders[index] = _orders[index].copyWith(
      status: status,
      paymentStatus: paymentStatus,
      trackingNumber: trackingNumber,
    );
    notifyListeners();
    await _persist();
  }

  /// Membatalkan pesanan.
  Future<void> cancelOrder(String id, {String? reason}) async {
    final index = _orders.indexWhere((order) => order.id == id);
    if (index < 0) return;
    _orders[index] = _orders[index].copyWith(
      status: OrderStatus.cancelled,
      paymentStatus: 'Dibatalkan',
      cancellationReason: reason ?? 'Dibatalkan oleh pembeli',
    );
    notifyListeners();
    await _persist();
  }

  /// Menghitung total barang yang terjual dari pesanan aktif.
  int getSoldCount(String productName) {
    int sold = 0;
    for (final order in _orders) {
      if (order.status != OrderStatus.cancelled) {
        for (final item in order.items) {
          if (item.productName.toLowerCase().trim() ==
              productName.toLowerCase().trim()) {
            sold += item.quantity;
          }
        }
      }
    }
    return sold;
  }

  /// Menandai pesanan selesai telah diberi ulasan.
  Future<void> markReviewed(String id) async {
    final index = _orders.indexWhere((order) => order.id == id);
    if (index < 0) return;
    _orders[index] = _orders[index].copyWith(reviewed: true);
    notifyListeners();
    await _persist();
  }

  /// Mengosongkan data pesanan (untuk pengujian atau reset).
  Future<void> clear() async {
    await loadFromStorage();
    _orders.clear();
    _isLoaded = true;
    notifyListeners();
    await _storageService.clearOrders();
  }
}

final OrderController orderController = OrderController.instance;
