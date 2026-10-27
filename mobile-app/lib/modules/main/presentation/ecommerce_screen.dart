import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petanitech_mobile/core/config.dart';
import 'package:petanitech_mobile/utils/client/api_client.dart';
import 'package:petanitech_mobile/modules/ecommerce/presentation/search_screen.dart';
import 'package:petanitech_mobile/modules/ecommerce/presentation/product_screen.dart';
import 'package:petanitech_mobile/modules/ecommerce/presentation/shopping_cart_screen.dart';
import 'package:petanitech_mobile/modules/ecommerce/presentation/chat_list_screen.dart';
import 'package:petanitech_mobile/modules/ecommerce/logic/controllers/order_controller.dart';
import 'package:petanitech_mobile/modules/ecommerce/logic/controllers/review_controller.dart';

class EcommerceScreen extends StatefulWidget {
  const EcommerceScreen({super.key});

  @override
  State<EcommerceScreen> createState() => _EcommerceScreenState();
}

class _EcommerceScreenState extends State<EcommerceScreen> {
  final Color primaryGreen = const Color(0xFF7CB35A);
  final Color lightGreen = const Color(0xFFE8F1E2);
  final Color darkGreen = const Color(0xFF5E963F);

  String selectedCategory = 'Semua';

  final TextEditingController searchController = TextEditingController();
  final ImagePicker imagePicker = ImagePicker();

  Future<void> _openCamera() async {
    try {
      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image == null) return;
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Foto berhasil diambil. Pencarian berdasarkan foto akan diproses.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: darkGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Kamera tidak dapat digunakan pada perangkat ini.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: darkGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }
  }

  final List<Map<String, dynamic>> categories = [
    {'name': 'Semua', 'icon': Icons.apps_rounded},
    {'name': 'Pupuk', 'icon': Icons.grass_rounded},
    {'name': 'Benih', 'icon': Icons.spa_rounded},
    {'name': 'Pestisida', 'icon': Icons.science_outlined},
    {'name': 'Alat Pertanian', 'icon': Icons.agriculture_rounded},
    {'name': 'Media Tanam', 'icon': Icons.yard_rounded},
    {'name': 'Irigasi', 'icon': Icons.water_drop_outlined},
    {'name': 'Bibit', 'icon': Icons.eco_rounded},
  ];

  bool _isLoading = true;
  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    ShoppingCartScreen.controller.addListener(_onCartChanged);
    orderController.addListener(_onCartChanged);
    reviewController.addListener(_onCartChanged);
    _fetchProducts();
  }

  Future<void> _fetchProducts({String? category}) async {
    final cat = category ?? selectedCategory;
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      final dio = Dio();
      final url = (cat.isNotEmpty && cat != 'Semua')
          ? '$appUrl/products?category=${Uri.encodeComponent(cat)}'
          : '$appUrl/products';
      final response = await dio.get(
        url,
        options: Options(
          receiveTimeout: const Duration(seconds: 8),
          sendTimeout: const Duration(seconds: 8),
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        final rawData = response.data;
        final List dynamicList = rawData is Map && rawData['data'] is List
            ? rawData['data']
            : (rawData is List ? rawData : []);

        final List<Map<String, dynamic>> apiProducts = [];
        for (var item in dynamicList) {
          final itemCat = item['category']?.toString() ?? 'Lainnya';
          final icon = _getCategoryIcon(itemCat);
          apiProducts.add({
            'id': item['id']?.toString(),
            'name': item['name']?.toString() ?? 'Produk',
            'category': itemCat,
            'price': (item['price'] is num) ? (item['price'] as num).toInt() : 50000,
            'icon': icon,
            'icons': [icon],
            'image': item['image']?.toString(),
            'description': item['description']?.toString(),
            'stock': item['stock'] ?? 10,
            'soldCount': item['sold_count'] ?? 0,
            'rating': (item['rating'] is num) ? (item['rating'] as num).toDouble() : 5.0,
            'shopName': item['store_name']?.toString() ?? item['seller_name']?.toString() ?? 'Toko Tani Makmur',
            'location': item['location']?.toString() ?? 'Indonesia',
            'variants': (item['unit'] != null && item['unit'].toString().isNotEmpty)
                ? [
                    {
                      'name': item['unit'].toString(),
                      'price': (item['price'] is num) ? (item['price'] as num).toInt() : 50000,
                    }
                  ]
                : [],
          });
        }
        if (mounted) {
          setState(() {
            products = apiProducts;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('[EcommerceScreen] Error loading backend products: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'pupuk':
        return Icons.grass_rounded;
      case 'benih':
      case 'bibit':
        return Icons.spa_rounded;
      case 'pestisida':
        return Icons.science_outlined;
      case 'alat pertanian':
      case 'alat':
        return Icons.agriculture_rounded;
      case 'media tanam':
        return Icons.yard_rounded;
      case 'irigasi':
        return Icons.water_drop_outlined;
      default:
        return Icons.eco_rounded;
    }
  }

  @override
  void dispose() {
    ShoppingCartScreen.controller.removeListener(_onCartChanged);
    orderController.removeListener(_onCartChanged);
    reviewController.removeListener(_onCartChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  void _submitSearch(String value) {
    final query = value.trim();
    if (query.isEmpty) return;

    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => SearchScreen(searchQuery: query),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = selectedCategory == 'Semua'
        ? products
        : products
            .where((product) => product['category'] == selectedCategory)
            .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F5),
      body: RefreshIndicator(
        color: darkGreen,
        onRefresh: () => _fetchProducts(category: selectedCategory),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryGreen, darkGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: darkGreen.withOpacity(0.18),
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
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.storefront_rounded,
                          color: Colors.white,
                          size: 23,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'E-commerce',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Belanja kebutuhan pertanian dengan mudah',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),

                      _headerIcon(
                        icon: Icons.shopping_cart_rounded,
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (_) => const ShoppingCartScreen(),
                            ),
                          ).then((_) {
                            if (mounted) {
                              setState(() {});
                            }
                          });
                        },
                        badge: ShoppingCartScreen.itemCount == 0
                            ? null
                            : ShoppingCartScreen.itemCount.toString(),
                      ),

                      const SizedBox(width: 7),

                      _headerIcon(
                        icon: Icons.chat_bubble_rounded,
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (_) => const ChatListScreen(),
                            ),
                          ).then((_) {
                            if (mounted) {
                              setState(() {});
                            }
                          });
                        },
                        badge: ChatListScreen.unreadCount == 0
                            ? null
                            : ChatListScreen.unreadCount > 99
                                ? '99+'
                                : ChatListScreen.unreadCount.toString(),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 18),

                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(17),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 15),
                        Icon(Icons.search_rounded, color: Colors.grey.shade600),
                        const SizedBox(width: 9),
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            textInputAction: TextInputAction.search,
                            onSubmitted: _submitSearch,
                            decoration: const InputDecoration(
                              hintText: 'Cari produk pertanian...',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        Container(
                          width: 38,
                          height: 38,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: lightGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: _openCamera,
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.camera_alt_rounded,
                              color: darkGreen,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
              child: Row(
                children: [
                  const Text(
                    'Kategori',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 88,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final bool isSelected = selectedCategory == category['name'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = category['name'];
                      });
                      _fetchProducts(category: selectedCategory);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 64,
                      padding: const EdgeInsets.only(top: 2),
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: isSelected ? primaryGreen : lightGreen,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(
                                      color: darkGreen,
                                      width: 2,
                                    )
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.035),
                                  blurRadius: 7,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              category['icon'],
                              size: 23,
                              color: isSelected ? Colors.white : darkGreen,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            category['name'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              height: 1.05,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                              color: isSelected ? darkGreen : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 23, 18, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Produk Pilihan',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
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
                      selectedCategory == 'Semua'
                          ? 'Semua Produk'
                          : selectedCategory,
                      style: TextStyle(
                        color: darkGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: darkGreen),
                      const SizedBox(height: 12),
                      Text(
                        'Memuat produk...',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (filteredProducts.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 54,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Belum ada produk untuk kategori ini',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Produk seller akan muncul di sini saat ditambahkan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 70),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _productCard(filteredProducts[index]),
                  childCount: filteredProducts.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.66,
                ),
              ),
            ),
        ],
      ),
    ),
  );
  }

  Widget _headerIcon({
    required IconData icon,
    required VoidCallback onTap,
    String? badge,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 42,
              height: 42,
              child: Icon(icon, color: Colors.white, size: 21),
            ),
          ),
        ),
        if (badge != null)
          Positioned(
            right: -4,
            top: -5,
            child: Container(
              constraints: const BoxConstraints(minWidth: 18),
              height: 18,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: primaryGreen, width: 1.5),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _productCard(Map<String, dynamic> product) {
    final pName = product['name']?.toString() ?? '';
    final dynamicRating = ReviewController.instance.getAverageRating(pName);
    final dynamicSold = OrderController.instance.getSoldCount(pName);

    return GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => ProductScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.045),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [lightGreen, const Color(0xFFF4F8F1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: (product['image'] != null &&
                              product['image'].toString().isNotEmpty)
                          ? Image.network(
                              ApiClient.getAsset(product['image'].toString()),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (_, __, ___) => Icon(
                                product['icon'] ?? Icons.eco_rounded,
                                size: 70,
                                color: darkGreen,
                              ),
                            )
                          : Icon(
                              product['icon'] ?? Icons.eco_rounded,
                              size: 70,
                              color: darkGreen,
                            ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        product['category'],
                        style: TextStyle(
                          color: darkGreen,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(11, 10, 11, 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Rp ${_formatPrice(product['price'])}',
                    style: TextStyle(
                      color: darkGreen,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, color: Colors.amber.shade700, size: 15),
                      const SizedBox(width: 3),
                      Text(
                        dynamicRating > 0 ? dynamicRating.toStringAsFixed(1) : '-',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '• $dynamicSold terjual',
                        style: const TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.shopping_cart_rounded,
                        color: darkGreen,
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
