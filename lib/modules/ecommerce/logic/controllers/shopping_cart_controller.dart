import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../services/cart_storage_service.dart';

class ShoppingCartController extends ChangeNotifier {
  // Singleton instance agar state keranjang sinkron di semua halaman.
  static final ShoppingCartController instance = ShoppingCartController._();

  final CartStorageService _storageService = CartStorageService();
  final List<CartItemModel> _items = [];
  bool _isLoaded = false;

  ShoppingCartController._() {
    loadFromStorage();
  }

  factory ShoppingCartController() => instance;

  // Daftar produk dalam keranjang.
  List<CartItemModel> get items => List.unmodifiable(_items);

  // Status apakah data telah dimuat dari penyimpanan lokal.
  bool get isLoaded => _isLoaded;

  // Jumlah jenis produk.
  int get itemCount => _items.length;

  // Jumlah seluruh kuantitas barang.
  int get totalQuantity {
    return _items.fold(0, (total, item) => total + item.quantity);
  }

  // Jumlah jenis produk yang dipilih.
  int get selectedCount {
    return _items.where((item) => item.isSelected).length;
  }

  // Status apakah semua produk terpilih.
  bool get isAllSelected {
    return _items.isNotEmpty && _items.every((item) => item.isSelected);
  }

  // Total harga seluruh produk yang dipilih.
  int get selectedTotal {
    return _items.fold(
      0,
      (total, item) => total + (item.isSelected ? item.subtotal : 0),
    );
  }

  /// Memuat data keranjang dari local persistence (SharedPreferences).
  Future<void> loadFromStorage() async {
    final loadedItems = await _storageService.loadCart();
    _items.clear();
    _items.addAll(loadedItems);
    _isLoaded = true;
    notifyListeners();
  }

  /// Menyimpan status saat ini ke penyimpanan lokal.
  Future<void> _persist() async {
    await _storageService.saveCart(_items);
  }

  // Menambahkan produk ke keranjang.
  Future<void> addToCart(Map<String, dynamic> product) async {
    final name = product['name']?.toString() ?? 'Nama Produk';
    final variant = product['variant']?.toString();
    final qty = (product['quantity'] as num?)?.toInt() ?? 1;
    final index = _items.indexWhere(
      (item) => item.name == name && item.variant == variant,
    );

    if (index != -1) {
      _items[index].quantity += qty;
    } else {
      _items.add(CartItemModel.fromProduct(product));
    }

    notifyListeners();
    await _persist();
  }

  // Memilih atau membatalkan pilihan satu produk.
  Future<void> toggleItemSelection(int index, bool? value) async {
    if (!_isValidIndex(index)) return;
    _items[index].isSelected = value ?? false;
    notifyListeners();
    await _persist();
  }

  // Memilih atau membatalkan pilihan semua produk.
  Future<void> toggleSelectAll(bool? value) async {
    final selected = value ?? false;
    for (final item in _items) {
      item.isSelected = selected;
    }
    notifyListeners();
    await _persist();
  }

  // Mengubah jumlah produk.
  Future<void> updateQuantity(int index, int newQuantity) async {
    if (!_isValidIndex(index) || newQuantity < 1) return;
    _items[index].quantity = newQuantity;
    notifyListeners();
    await _persist();
  }

  // Menghapus satu produk.
  Future<void> deleteItem(int index) async {
    if (!_isValidIndex(index)) return;
    _items.removeAt(index);
    notifyListeners();
    await _persist();
  }

  // Menghapus seluruh produk yang dipilih.
  Future<bool> deleteSelected() async {
    if (selectedCount == 0) return false;
    _items.removeWhere((item) => item.isSelected);
    notifyListeners();
    await _persist();
    return true;
  }

  // Mengambil salinan produk yang dipilih untuk checkout.
  List<CartItemModel> getSelectedItems() {
    return _items
        .where((item) => item.isSelected)
        .map((item) => item.copy())
        .toList();
  }

  // Mengambil salinan produk terpilih dalam format Map untuk checkout.
  List<Map<String, dynamic>> getSelectedProductsMap() {
    return _items
        .where((item) => item.isSelected)
        .map((item) => item.toMap())
        .toList();
  }

  // Menghapus produk yang telah berhasil di-checkout.
  Future<void> removeCheckedOutSelected() async {
    _items.removeWhere((item) => item.isSelected);
    notifyListeners();
    await _persist();
  }

  // Menghapus produk berdasarkan daftar nama produk.
  Future<void> removeCheckedOutItems(List<String> productNames) async {
    _items.removeWhere(
      (item) => productNames.contains(item.name),
    );
    notifyListeners();
    await _persist();
  }

  // Menghapus produk spesifik berdasarkan kombinasi nama dan varian produk.
  Future<void> removeCheckedOutItemsWithVariants(
    List<Map<String, String?>> itemsToRemove,
  ) async {
    for (final target in itemsToRemove) {
      _items.removeWhere(
        (item) =>
            item.name == target['name'] && item.variant == target['variant'],
      );
    }
    notifyListeners();
    await _persist();
  }

  // Reset/kosongkan keranjang.
  Future<void> clear() async {
    _items.clear();
    notifyListeners();
    await _storageService.clearCart();
  }

  bool _isValidIndex(int index) {
    return index >= 0 && index < _items.length;
  }
}
