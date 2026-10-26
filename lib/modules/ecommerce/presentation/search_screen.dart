import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../logic/controllers/order_controller.dart';
import '../logic/controllers/review_controller.dart';
import 'product_screen.dart';

class SearchScreen extends StatefulWidget {
  final String searchQuery;

  const SearchScreen({super.key, required this.searchQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final Color primaryGreen = const Color(0xFF7CB35A);
  final Color lightGreen = const Color(0xFFE8F1E2);
  final Color darkGreen = const Color(0xFF5E963F);

  late TextEditingController searchController;
  final ImagePicker imagePicker = ImagePicker();
  String searchQuery = '';
  XFile? _selectedSearchImage;

  final List<Map<String, dynamic>> products = [
    {
      'name': 'Pupuk NPK Mutiara',
      'category': 'Pupuk',
      'price': 75000,
      'icon': Icons.grass_rounded,
    },
    {
      'name': 'Benih Padi Unggul',
      'category': 'Benih',
      'price': 45000,
      'icon': Icons.spa_rounded,
    },
    {
      'name': 'Pestisida Tanaman',
      'category': 'Pestisida',
      'price': 65000,
      'icon': Icons.science_outlined,
    },
    {
      'name': 'Cangkul Besi',
      'category': 'Alat Pertanian',
      'price': 85000,
      'icon': Icons.agriculture_rounded,
    },
    {
      'name': 'Media Tanam Organik',
      'category': 'Media Tanam',
      'price': 35000,
      'icon': Icons.yard_rounded,
    },
    {
      'name': 'Pupuk Organik',
      'category': 'Pupuk',
      'price': 55000,
      'icon': Icons.grass_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    searchQuery = widget.searchQuery.toLowerCase().trim();
    searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _searchProduct(String value) {
    setState(() {
      searchQuery = value.toLowerCase().trim();
    });
  }

  Future<void> _pickSearchImage(ImageSource source) async {
    try {
      final XFile? image = await imagePicker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image == null || !mounted) return;
      setState(() => _selectedSearchImage = image);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            source == ImageSource.camera
                ? 'Foto berhasil diambil.'
                : 'Foto berhasil dipilih dari galeri.',
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
          content: Text(
            source == ImageSource.camera
                ? 'Kamera tidak dapat digunakan pada perangkat ini.'
                : 'Galeri tidak dapat dibuka pada perangkat ini.',
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

  void _showImageSourcePicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Cari dengan Gambar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              ListTile(
                leading: Icon(Icons.camera_alt_rounded, color: darkGreen),
                title: const Text('Ambil foto dari kamera'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickSearchImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library_rounded, color: darkGreen),
                title: const Text('Pilih gambar dari galeri'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickSearchImage(ImageSource.gallery);
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
    final filteredProducts =
        products.where((product) {
          if (searchQuery.isEmpty) return true;

          final productName = product['name'].toString().toLowerCase();
          final productCategory = product['category'].toString().toLowerCase();

          return productName.contains(searchQuery) ||
              productCategory.contains(searchQuery);
        }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F5),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(10, 12, 14, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryGreen, darkGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Material(
                    color: Colors.white.withOpacity(0.14),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      customBorder: const CircleBorder(),
                      child: const SizedBox(
                        width: 42,
                        height: 42,
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
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
                          const SizedBox(width: 14),
                          Icon(
                            Icons.search_rounded,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              textInputAction: TextInputAction.search,
                              onChanged: _searchProduct,
                              onSubmitted: _searchProduct,
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
                          IconButton(
                            onPressed: _showImageSourcePicker,
                            padding: EdgeInsets.zero,
                            splashRadius: 20,
                            icon: Icon(
                              Icons.camera_alt_rounded,
                              color: darkGreen,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_selectedSearchImage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Row(
                  children: [
                    Icon(Icons.image_rounded, color: darkGreen, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Gambar dipilih: ${_selectedSearchImage!.name}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: darkGreen,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Hapus gambar',
                      onPressed: () => setState(() => _selectedSearchImage = null),
                      icon: const Icon(Icons.close_rounded, size: 18),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            Expanded(
              child:
                  filteredProducts.isEmpty
                      ? _emptyResult()
                      : CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(18,22,18,13),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Hasil Pencarian',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: lightGreen,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${filteredProducts.length} produk',
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
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
                            sliver: SliverGrid(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) =>
                                    _productCard(filteredProducts[index]),
                                childCount: filteredProducts.length,
                              ),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
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
          ],
        ),
      ),
    );
  }

  Widget _emptyResult() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
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
              child: Icon(Icons.search_off_rounded, size: 50, color: darkGreen),
            ),
            const SizedBox(height: 20),
            const Text(
              'Produk tidak ditemukan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 7),
            Text(
              'Coba gunakan kata kunci lain.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      ),
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
                      child: Icon(product['icon'], size: 70, color: darkGreen),
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
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 31,
                      height: 31,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.94),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite_border_rounded,
                        color: Colors.grey.shade600,
                        size: 17,
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
                      Icon(
                        Icons.star_rounded,
                        color: Colors.amber.shade700,
                        size: 15,
                      ),
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
