import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petanitech_mobile/core/config.dart';
import 'package:petanitech_mobile/utils/client/api_client.dart';
import 'chat_screen.dart';
import 'product_screen.dart';

class StoreScreen extends StatefulWidget {
  final String storeName;
  final String? storeLocation;
  final String? storePhoto;
  final Map<String, dynamic>? initialProduct;
  final List<Map<String, dynamic>>? initialProducts;

  const StoreScreen({
    super.key,
    this.storeName = 'Toko Tani Sejahtera',
    this.storeLocation,
    this.storePhoto,
    this.initialProduct,
    this.initialProducts,
  });

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final Color primaryGreen = const Color(0xFF7CB35A);
  final Color lightGreen = const Color(0xFFE8F1E2);
  final Color darkGreen = const Color(0xFF5E963F);

  String? _currentPhotoUrl;
  File? _localPhotoFile;
  bool _isLoading = false;
  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    _currentPhotoUrl = widget.storePhoto;
    if (widget.initialProducts != null && widget.initialProducts!.isNotEmpty) {
      _products = List<Map<String, dynamic>>.from(widget.initialProducts!);
    } else if (widget.initialProduct != null) {
      _products = [widget.initialProduct!];
    }
    _fetchStoreProducts();
  }

  Future<void> _fetchStoreProducts() async {
    setState(() => _isLoading = true);
    try {
      final dio = Dio();
      final response = await dio.get(
        '$appUrl/products',
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

        final List<Map<String, dynamic>> storeProducts = [];
        for (var item in dynamicList) {
          final sName = item['store_name']?.toString() ??
              item['seller_name']?.toString() ??
              item['shopName']?.toString();
          
          // Match by store name or if we have initial product from this store
          final matchesStore = sName != null &&
              (sName.toLowerCase() == widget.storeName.toLowerCase() ||
               widget.storeName.toLowerCase().contains(sName.toLowerCase()) ||
               sName.toLowerCase().contains(widget.storeName.toLowerCase()));

          if (matchesStore || _products.isEmpty) {
            final itemCat = item['category']?.toString() ?? 'Lainnya';
            storeProducts.add({
              'id': item['id']?.toString(),
              'name': item['name']?.toString() ?? 'Produk',
              'category': itemCat,
              'price': (item['price'] is num) ? (item['price'] as num).toInt() : 50000,
              'icon': _getCategoryIcon(itemCat),
              'image': item['image']?.toString(),
              'images': item['images'],
              'description': item['description']?.toString(),
              'stock': item['stock'] ?? 10,
              'soldCount': item['sold_count'] ?? 0,
              'rating': (item['rating'] is num) ? (item['rating'] as num).toDouble() : 5.0,
              'shopName': widget.storeName,
              'location': widget.storeLocation ?? item['location']?.toString() ?? 'Indonesia',
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
        }

        if (mounted && storeProducts.isNotEmpty) {
          setState(() {
            _products = storeProducts;
          });
        }
      }
    } catch (e) {
      debugPrint('[StoreScreen] Error fetching products: $e');
    } finally {
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

  Future<void> _pickStorePhoto() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ubah Foto Profil Toko',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF5E963F)),
                title: const Text('Pilih dari Galeri'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    setState(() {
                      _localPhotoFile = File(picked.path);
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Foto profil toko berhasil diperbarui!'),
                          backgroundColor: Color(0xFF5E963F),
                        ),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFF5E963F)),
                title: const Text('Ambil dari Kamera'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(source: ImageSource.camera);
                  if (picked != null) {
                    setState(() {
                      _localPhotoFile = File(picked.path);
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Foto profil toko berhasil diperbarui!'),
                          backgroundColor: Color(0xFF5E963F),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storeLoc = widget.storeLocation ?? 'Indonesia';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Detail Toko',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: primaryGreen,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(25),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Store profile avatar with add photo capability
                      Stack(
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _localPhotoFile != null
                                ? Image.file(_localPhotoFile!, fit: BoxFit.cover)
                                : (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty)
                                    ? Image.network(
                                        ApiClient.getAsset(_currentPhotoUrl!),
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(
                                          Icons.storefront_rounded,
                                          size: 42,
                                          color: darkGreen,
                                        ),
                                      )
                                    : Icon(
                                        Icons.storefront_rounded,
                                        size: 42,
                                        color: darkGreen,
                                      ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: InkWell(
                              onTap: _pickStorePhoto,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: darkGreen,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.storeName,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('$storeLoc', style: const TextStyle(color: Colors.white, fontSize: 11.5)),
                            const SizedBox(height: 6),
                            const Row(
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber,
                                  size: 17,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '4.8  •  125 ulasan',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.16),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: _StoreStat(
                            value: '4.8',
                            label: 'Rating',
                          ),
                        ),
                        Expanded(
                          child: _StoreStat(
                            value: '${_products.length}',
                            label: 'Produk',
                          ),
                        ),
                        const Expanded(
                          child: _StoreStat(
                            value: 'Aktif',
                            label: 'Status Toko',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              storeName: widget.storeName,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 18,
                      ),
                      label: const Text(
                        'Chat Toko',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: darkGreen,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Produk Toko',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    '${_products.length} produk',
                    style: TextStyle(
                      fontSize: 12,
                      color: darkGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          else if (_products.isEmpty)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Belum ada produk di toko ini.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = _products[index];
                    final price = (product['price'] is num)
                        ? (product['price'] as num).toInt()
                        : 0;

                    return InkWell(
                      borderRadius: BorderRadius.circular(17),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductScreen(
                              product: product,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(17),
                          border: Border.all(
                            color: const Color(0xFFEDEFEB),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: lightGreen,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(17),
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: (product['image'] != null &&
                                        product['image'].toString().isNotEmpty)
                                    ? Image.network(
                                        ApiClient.getAsset(product['image'].toString()),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                        errorBuilder: (_, __, ___) => Icon(
                                          product['icon'] as IconData? ?? Icons.eco_rounded,
                                          size: 55,
                                          color: darkGreen,
                                        ),
                                      )
                                    : Icon(
                                        product['icon'] as IconData? ?? Icons.eco_rounded,
                                        size: 55,
                                        color: darkGreen,
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                10,
                                10,
                                10,
                                12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'] as String? ?? 'Produk',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Rp ${_formatPrice(price)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: darkGreen,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    product['category'] as String? ?? 'Pertanian',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: _products.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 225,
                ),
              ),
            ),
        ],
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

class _StoreStat extends StatelessWidget {
  final String value;
  final String label;

  const _StoreStat({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
