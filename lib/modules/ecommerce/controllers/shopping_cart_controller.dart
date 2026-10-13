import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';

class ShoppingCartController extends ChangeNotifier {
  // Singleton instance agar state keranjang sinkron di semua halaman.
  static final ShoppingCartController instance = ShoppingCartController._();
  ShoppingCartController._();
  factory ShoppingCartController() => instance;
  final List<CartItemModel> _items = [];
  // Daftar produk dalam keranjang.
  List<CartItemModel> get items => List.unmodifiable(_items);
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

  // Menambahkan produk ke keranjang.
  void addToCart(Map<String, dynamic> product) {
    final name = product['name']?.toString() ?? 'Nama Produk';
    final index = _items.indexWhere((item) => item.name == name);
    if (index != -1) {
      _items[index].quantity++;
    } else {
      _items.add(CartItemModel.fromProduct(product));
    }
    notifyListeners();
  }

  // Memilih atau membatalkan pilihan satu produk.
  void toggleItemSelection(int index, bool? value) {
    if (!_isValidIndex(index)) return;
    _items[index].isSelected = value ?? false;
    notifyListeners();
  }

  // Memilih atau membatalkan pilihan semua produk.
  void toggleSelectAll(bool? value) {
    final selected = value ?? false;
    for (final item in _items) {
      item.isSelected = selected;
    }
    notifyListeners();
  }

  // Mengubah jumlah produk.
  void updateQuantity(int index, int newQuantity) {
    if (!_isValidIndex(index) || newQuantity < 1) return;
    _items[index].quantity = newQuantity;
    notifyListeners();
  }

  // Menghapus satu produk.
  void deleteItem(int index) {
    if (!_isValidIndex(index)) return;
    _items.removeAt(index);
    notifyListeners();
  }

  // Menghapus seluruh produk yang dipilih.
  bool deleteSelected() {
    if (selectedCount == 0) return false;
    _items.removeWhere((item) => item.isSelected);
    notifyListeners();
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
  void removeCheckedOutSelected() {
    _items.removeWhere((item) => item.isSelected);
    notifyListeners();
  }

  // Menghapus produk berdasarkan daftar nama produk.
  void removeCheckedOutItems(List<String> productNames) {
    _items.removeWhere(
      (item) => item.isSelected && productNames.contains(item.name),
    );
    notifyListeners();
  }

  // Reset/kosongkan keranjang.
  void clear() {
    _items.clear();
    notifyListeners();
  }

  bool _isValidIndex(int index) {
    return index >= 0 && index < _items.length;
  }
}
