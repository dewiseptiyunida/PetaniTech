import 'package:flutter/material.dart';
import 'checkout_screen.dart';
import 'shipping_screen.dart';
import 'shopping_cart_screen.dart';
import 'chat_screen.dart';
import 'store_screen.dart';

class ProductScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductScreen({super.key, required this.product});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final Color primaryGreen = const Color(0xFF7CB35A);
  final Color lightGreen = const Color(0xFFE8F1E2);
  final Color darkGreen = const Color(0xFF5E963F);

  String selectedShipping = 'Pilih pengiriman';

  @override
  void initState() {
    super.initState();
    ShoppingCartScreen.controller.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    ShoppingCartScreen.controller.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final String productName = product['name'] ?? 'Nama Produk';
    final String category = product['category'] ?? 'Produk';
    final int price = product['price'] ?? 0;
    final IconData productIcon = product['icon'] ?? Icons.shopping_bag_outlined;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      bottomNavigationBar: _bottomAction(),
      body: CustomScrollView(
        slivers: [
          _hero(productIcon),
          SliverToBoxAdapter(child: _productInfo(productName, category, price)),
          SliverToBoxAdapter(child: _shippingSection()),
          SliverToBoxAdapter(child: _descriptionSection(productName, category)),
          SliverToBoxAdapter(child: _storeSection()),
          SliverToBoxAdapter(child: _reviewSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  Widget _hero(IconData productIcon) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      elevation: 0,
      backgroundColor: primaryGreen,

      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: _floatingIcon(
          Icons.arrow_back_ios_new_rounded,
          () => Navigator.pop(context),
        ),
      ),

      actions: [
        Padding(padding: const EdgeInsets.all(8), child: _cartTopButton()),
      ],

      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,

        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [lightGreen, const Color(0xFFF5F8F1), Colors.white],
            ),
          ),

          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 55,
                left: -55,
                child: _decorCircle(130, primaryGreen.withOpacity(.10)),
              ),

              Positioned(
                right: -45,
                bottom: 30,
                child: _decorCircle(150, darkGreen.withOpacity(.08)),
              ),

              Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: darkGreen.withOpacity(.12),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Icon(productIcon, size: 100, color: darkGreen),
              ),

              Positioned(
                bottom: 22,
                child: Row(children: [_dot(true), _dot(false), _dot(false)]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _productInfo(String name, String category, int price) {
    return Transform.translate(
      offset: const Offset(0, -12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: lightGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category.toUpperCase(),
                    style: TextStyle(
                      color: darkGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .5,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              name,
              style: const TextStyle(
                fontSize: 21,
                height: 1.2,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Rp ${_formatPrice(price)}',
              style: TextStyle(
                color: darkGreen,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 13),

            Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  color: Colors.amber.shade700,
                  size: 19,
                ),

                const SizedBox(width: 4),

                const Text(
                  '4.8',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),

                const SizedBox(width: 5),

                Text(
                  '125 ulasan',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),

                _verticalDivider(),

                Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.grey.shade600,
                  size: 15,
                ),

                const SizedBox(width: 4),

                Text(
                  '80+ terjual',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _shippingSection() {
    return GestureDetector(
      onTap: _openShipping,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 2, 12, 0),
        padding: const EdgeInsets.fromLTRB(16, 14, 13, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEDEFEB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.025),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                Icons.local_shipping_outlined,
                color: darkGreen,
                size: 22,
              ),
            ),

            const SizedBox(width: 11),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pengiriman',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    selectedShipping,
                    style: TextStyle(
                      color:
                          selectedShipping == 'Pilih pengiriman'
                              ? Colors.grey.shade600
                              : darkGreen,
                      fontSize: 11.5,
                      fontWeight:
                          selectedShipping == 'Pilih pengiriman'
                              ? FontWeight.w500
                              : FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            Text(
              selectedShipping == 'Pilih pengiriman' ? 'Pilih' : 'Ubah',
              style: TextStyle(
                color: darkGreen,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(width: 4),

            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade500,
              size: 21,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openShipping() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const ShippingScreen()),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      selectedShipping =
          '${result['name']} '
          '${result['service']} • '
          'Rp ${_formatPrice(result['price'] as int)}';
    });
  }

  Widget _descriptionSection(String name, String category) {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Deskripsi Produk', Icons.description_outlined),

          const SizedBox(height: 12),

          Text(
            '$name merupakan produk '
            'kategori $category yang cocok '
            'digunakan untuk mendukung '
            'kebutuhan pertanian. Informasi '
            'produk, ukuran, dan ketersediaan '
            'dapat disesuaikan dengan data '
            'dari toko.',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }

  Widget _storeSection() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Toko',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [lightGreen, const Color(0xFFD9EBCF)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.storefront_rounded,
                  color: darkGreen,
                  size: 28,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Toko Tani Sejahtera',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      'Toko produk pertanian',
                      style: TextStyle(color: Colors.grey, fontSize: 11.5),
                    ),
                  ],
                ),
              ),

              OutlinedButton.icon(
                onPressed: _openStore,
                icon: Icon(
                  Icons.storefront_outlined,
                  color: darkGreen,
                  size: 16,
                ),
                label: Text(
                  'Kunjungi',
                  style: TextStyle(
                    color: darkGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: primaryGreen),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 9,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _reviewSection() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Ulasan Pembeli',
                  

                ),
              ),

              Text(
                '125 ulasan',
                style: TextStyle(
                  color: darkGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          _reviewItem(
            name: 'Andi',
            rating: 5,
            comment: 'Produknya bagus dan sesuai dengan deskripsi.',
          ),

          const Padding(padding: EdgeInsets.symmetric(vertical: 14)),

          _reviewItem(
            name: 'Siti',
            rating: 4,
            comment: 'Pengiriman cukup cepat, produk juga bagus.',
          ),

          const SizedBox(height: 8),

          Center(
            child: TextButton(
              onPressed: () {},
              child: Text(
                'Lihat Semua Ulasan  ›',
                style: TextStyle(
                  color: darkGreen,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewItem({
    required String name,
    required int rating,
    required String comment,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 21,
          backgroundColor: lightGreen,
          child: Icon(Icons.person_rounded, color: darkGreen, size: 22),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const Spacer(),

                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 14,
                        color: Colors.amber.shade700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Text(
                comment,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDEFEB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: lightGreen,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: darkGreen, size: 17),
        ),

        const SizedBox(width: 9),

        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  Widget _bottomAction() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 9, 12, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFE9ECE7))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.09),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Row(
          children: [
            // CHAT
            _bottomActionIcon(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Chat',
              onTap: _openChat,
            ),

            const SizedBox(width: 10),

            // KERANJANG
            _bottomActionIcon(
              icon: Icons.shopping_cart_outlined,
              label: 'Keranjang',
              badge: null,
              onTap: _addToCart,
            ),

            const SizedBox(width: 12),

            Container(width: 1, height: 36, color: const Color(0xFFE4E8E1)),

            const SizedBox(width: 12),

            // BELI SEKARANG
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _buyNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: primaryGreen.withOpacity(.30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_rounded, size: 19),
                      SizedBox(width: 8),
                      Text(
                        'Beli Sekarang',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomActionIcon({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    String? badge,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: SizedBox(
          width: 58,
          height: 52,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: darkGreen, size: 22),

                    const SizedBox(height: 3),

                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              if (badge != null && badge != '0')
                Positioned(
                  top: 2,
                  right: 7,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 17),
                    height: 17,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _addToCart() {
    try {
      if (widget.product.isEmpty) {
        _showNotification('Data produk tidak ditemukan.', isError: true);
        return;
      }

      ShoppingCartScreen.addToCart(widget.product);

      final productName = widget.product['name'] ?? 'Produk';
      _showNotification('$productName berhasil dimasukkan ke keranjang');
    } catch (e) {
      _showNotification('Gagal menambahkan produk ke keranjang.', isError: true);
    }
  }

  void _showNotification(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: isError ? Colors.redAccent : darkGreen,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  void _openCart() {
    Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(builder: (_) => const ShoppingCartScreen()))
        .then((_) {
          if (mounted) {
            setState(() {});
          }
        });
  }

  void _buyNow() {
    _showQuantityBottomSheet();
  }

  void _showQuantityBottomSheet() {
    int quantity = 1;

    final int price = (widget.product['price'] as num?)?.toInt() ?? 0;

    final String productName =
        widget.product['name']?.toString() ?? 'Nama Produk';

    final IconData productIcon =
        widget.product['icon'] as IconData? ?? Icons.shopping_bag_outlined;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final int subtotal = price * quantity;

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 18,
                  right: 18,
                  top: 18,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Informasi produk
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: lightGreen,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2EAD8)),
                          ),
                          child: Icon(productIcon, color: darkGreen, size: 36),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Rp ${_formatPrice(price)} / pcs',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: darkGreen,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Stok: Tersedia',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(bottomSheetContext);
                          },
                          icon: const Icon(Icons.close_rounded, size: 22),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),

                    const Divider(height: 24, thickness: 0.8),

                    // Pemilihan jumlah
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Jumlah Pembelian',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Minimal beli 1 produk',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              // Kurangi jumlah
                              InkWell(
                                onTap:
                                    quantity > 1
                                        ? () {
                                          setModalState(() {
                                            quantity--;
                                          });
                                        }
                                        : null,
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(9),
                                ),
                                child: Container(
                                  width: 36,
                                  height: 34,
                                  alignment: Alignment.center,
                                  color:
                                      quantity > 1
                                          ? Colors.grey.shade50
                                          : Colors.grey.shade100,
                                  child: Icon(
                                    Icons.remove_rounded,
                                    size: 18,
                                    color:
                                        quantity > 1
                                            ? Colors.black87
                                            : Colors.grey.shade400,
                                  ),
                                ),
                              ),

                              // jumlah
                              Container(
                                width: 44,
                                height: 34,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.symmetric(
                                    vertical: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  '$quantity',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),

                              // Tambah jumlah
                              InkWell(
                                onTap: () {
                                  setModalState(() {
                                    quantity++;
                                  });
                                },
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(9),
                                ),
                                child: Container(
                                  width: 36,
                                  height: 34,
                                  alignment: Alignment.center,
                                  color: Colors.grey.shade50,
                                  child: const Icon(
                                    Icons.add_rounded,
                                    size: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Subtotal
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtotal ($quantity pcs):',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Rp ${_formatPrice(subtotal)}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: darkGreen,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(bottomSheetContext);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => CheckoutScreen(
                                    product: widget.product,
                                    quantity: quantity,
                                  ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Lanjut Beli Sekarang',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _cartTopButton() {
    return Material(
      color: Colors.black.withOpacity(.28),
      shape: const CircleBorder(),

      child: InkWell(
        onTap: _openCart,
        customBorder: const CircleBorder(),

        child: SizedBox(
          width: 43,
          height: 43,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Center(
                child: Icon(
                  Icons.shopping_cart_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),

              if (ShoppingCartScreen.itemCount > 0)
                Positioned(
                  right: 1,
                  top: 0,
                  child: Container(
                    width: 18,
                    height: 18,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      ShoppingCartScreen.itemCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _floatingIcon(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.black.withOpacity(.28),
      shape: const CircleBorder(),

      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),

        child: SizedBox(
          width: 43,
          height: 43,
          child: Icon(icon, color: Colors.white, size: 19),
        ),
      ),
    );
  }

  Widget _decorCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _dot(bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: active ? 18 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: active ? darkGreen : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 15,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.grey.shade300,
    );
  }

  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ChatScreen(
          storeName: 'Toko Tani Sejahtera',
        ),
      ),
    );
  }

  void _openStore() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const StoreScreen(
          storeName: 'Toko Tani Sejahtera',
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
