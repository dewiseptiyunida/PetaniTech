import 'package:flutter/material.dart';
import '../logic/controllers/shopping_cart_controller.dart';
import '../logic/models/cart_item_model.dart';
import 'chat_list_screen.dart';
import 'checkout_screen.dart';

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({super.key});

  // Delegasi ke ShoppingCartController untuk kompatibilitas dengan screen lain
  static ShoppingCartController get controller =>
      ShoppingCartController.instance;

  static void addToCart(Map<String, dynamic> product) {
    controller.addToCart(product);
  }

  static int get itemCount => controller.itemCount;

  static int get totalQuantity => controller.totalQuantity;

  static List<Map<String, dynamic>> get cartItems =>
      controller.items.map((item) => item.toMap()).toList();

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  // Warna tema
  final Color primaryGreen = const Color(0xFF7CB35A);
  final Color lightGreen = const Color(0xFFE8F1E2);
  final Color darkGreen = const Color(0xFF5E963F);

  final ShoppingCartController _controller = ShoppingCartController.instance;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onCartStateChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onCartStateChanged);
    super.dispose();
  }

  void _onCartStateChanged() {
    if (mounted) setState(() {});
  }

  // ============================================================
  // AKSI KERANJANG VIA CONTROLLER
  // ============================================================

  void _toggleSelectAll(bool? value) {
    _controller.toggleSelectAll(value);
  }

  void _updateQuantity(int index, int newQuantity) {
    _controller.updateQuantity(index, newQuantity);
  }

  void _deleteItem(int index) {
    _controller.deleteItem(index);
    _showMessage('Produk berhasil dihapus dari keranjang.');
  }

  void _deleteSelected() async {
    if (_controller.selectedCount == 0) {
      _showMessage('Pilih produk yang ingin dihapus.');
      return;
    }

    final success = await _controller.deleteSelected();
    if (success) {
      _showMessage('Produk yang dipilih berhasil dihapus.');
    }
  }

  void _checkout() {
    if (_controller.selectedCount == 0) {
      _showMessage('Pilih produk yang ingin dibeli terlebih dahulu.');
      return;
    }

    final selectedProducts = _controller.getSelectedProductsMap();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(items: selectedProducts),
      ),
    ).then((orderCompleted) {
      if (orderCompleted == true) {
        _controller.removeCheckedOutSelected();
      }
    });
  }

  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatListScreen()),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final items = _controller.items;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      appBar: _appBar(),
      body:
          items.isEmpty
              ? _emptyCart()
              : Column(
                children: [
                  _selectAllSection(),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 15),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return _cartItem(index, items[index]);
                      },
                    ),
                  ),
                ],
              ),
      bottomNavigationBar: items.isEmpty ? null : _bottomCheckout(),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.white,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.black87,
          size: 19,
        ),
      ),
      title: const Text(
        'Keranjang',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _openChat,
          tooltip: 'Chat',
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                color: darkGreen,
                size: 24,
              ),
              if (ChatListScreen.unreadCount > 0)
                Positioned(
                  right: -8,
                  top: -7,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      ChatListScreen.unreadCount > 99
                          ? '99+'
                          : '${ChatListScreen.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 5),
      ],
    );
  }

  // ============================================================
  // PILIH SEMUA
  // ============================================================

  Widget _selectAllSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 7),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEFEB)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: _controller.isAllSelected,
            onChanged: _toggleSelectAll,
            activeColor: primaryGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const Text(
            'Pilih Semua',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: _controller.selectedCount == 0 ? null : _deleteSelected,
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text(
              'Hapus',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ITEM PRODUK
  // ============================================================

  Widget _cartItem(int index, CartItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDEFEB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: item.isSelected,
            onChanged: (value) => _controller.toggleItemSelection(index, value),
            activeColor: primaryGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(item.icon, color: darkGreen, size: 40),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.category.toUpperCase(),
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                if (item.variant != null && item.variant!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F4EE),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFDFE4DA)),
                    ),
                    child: Text(
                      'Varian: ${item.variant}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: darkGreen,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  'Rp ${_formatPrice(item.price)}',
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'Jumlah',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8F6),
                        border: Border.all(color: const Color(0xFFDEE2DB)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap:
                                item.quantity > 1
                                    ? () => _updateQuantity(
                                      index,
                                      item.quantity - 1,
                                    )
                                    : null,
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(7),
                            ),
                            child: Container(
                              width: 28,
                              height: 26,
                              alignment: Alignment.center,
                              color:
                                  item.quantity > 1
                                      ? Colors.transparent
                                      : Colors.grey.shade100,
                              child: Icon(
                                Icons.remove_rounded,
                                size: 14,
                                color:
                                    item.quantity > 1
                                        ? Colors.black87
                                        : Colors.grey.shade400,
                              ),
                            ),
                          ),
                          Container(
                            constraints: const BoxConstraints(minWidth: 30),
                            height: 26,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              border: Border.symmetric(
                                vertical: BorderSide(color: Color(0xFFDEE2DB)),
                              ),
                            ),
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap:
                                () => _updateQuantity(index, item.quantity + 1),
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(7),
                            ),
                            child: Container(
                              width: 28,
                              height: 26,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.add_rounded,
                                size: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _deleteItem(index),
            tooltip: 'Hapus Produk',
            icon: Icon(
              Icons.delete_outline_rounded,
              color: Colors.redAccent.shade200,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY CART
  // ============================================================

  Widget _emptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 105,
              height: 105,
              decoration: BoxDecoration(
                color: lightGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 50,
                color: darkGreen,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Keranjang masih kosong',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Produk yang kamu tambahkan ke keranjang akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.shopping_bag_outlined, size: 18),
              label: const Text('Mulai Belanja'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM CHECKOUT
  // ============================================================

  Widget _bottomCheckout() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(15, 11, 15, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFE9ECE7))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .09),
              blurRadius: 18,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_controller.selectedCount} produk dipilih',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${_formatPrice(_controller.selectedTotal)}',
                    style: TextStyle(
                      color: darkGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _controller.selectedCount == 0 ? null : _checkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  disabledBackgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.grey.shade500,
                  elevation: 3,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shopping_bag_rounded, size: 18),
                    const SizedBox(width: 7),
                    Text(
                      _controller.selectedCount == 0
                          ? 'Checkout'
                          : 'Checkout (${_controller.selectedCount})',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }
}
