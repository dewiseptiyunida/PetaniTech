import 'dart:io';
import 'package:flutter/material.dart';
import '../logic/controllers/review_controller.dart';
import '../logic/models/review_model.dart';

class ProductReviewsScreen extends StatefulWidget {
  final String productName;
  final String? productCategory;
  final List<String>? variants;

  const ProductReviewsScreen({
    super.key,
    required this.productName,
    this.productCategory,
    this.variants,
  });

  @override
  State<ProductReviewsScreen> createState() => _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends State<ProductReviewsScreen> {
  final Color primaryGreen = const Color(0xFF7CB35A);
  final Color lightGreen = const Color(0xFFE8F1E2);
  final Color darkGreen = const Color(0xFF5E963F);

  int? _selectedStar; // null means 'Semua'
  String? _selectedVariant; // null means 'Semua Varian'
  bool _onlyWithPhotos = false;

  @override
  void initState() {
    super.initState();
    reviewController.addListener(_onReviewsChanged);
  }

  @override
  void dispose() {
    reviewController.removeListener(_onReviewsChanged);
    super.dispose();
  }

  void _onReviewsChanged() {
    if (mounted) setState(() {});
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  Widget build(BuildContext context) {
    final allProductReviews =
        reviewController.getReviewsForProduct(widget.productName);

    // Filter ulasan berdasarkan filter aktif
    final filteredReviews = allProductReviews.where((r) {
      if (_selectedStar != null && r.rating != _selectedStar) {
        return false;
      }
      if (_selectedVariant != null && r.variant != _selectedVariant) {
        return false;
      }
      if (_onlyWithPhotos && r.photoPaths.isEmpty) {
        return false;
      }
      return true;
    }).toList();

    final avgRating = reviewController.getAverageRating(widget.productName);
    final totalCount = allProductReviews.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F5),
      appBar: AppBar(
        title: const Text(
          'Ulasan Pembeli',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
            size: 19,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Header Statistik Ulasan
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFEDEFEB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            avgRating.toString(),
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 6, left: 2),
                            child: Text(
                              '/5',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black45,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < avgRating.floor()
                                ? Icons.star_rounded
                                : (index < avgRating
                                    ? Icons.star_half_rounded
                                    : Icons.star_outline_rounded),
                            color: Colors.amber.shade700,
                            size: 18,
                          );
                        }),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$totalCount ulasan',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: List.generate(5, (idx) {
                        final star = 5 - idx;
                        final countForStar = allProductReviews
                            .where((r) => r.rating == star)
                            .length;
                        final pct = totalCount > 0
                            ? countForStar / totalCount
                            : 0.0;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Text(
                                '$star',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Icon(Icons.star_rounded,
                                  size: 12, color: Colors.amber),
                              const SizedBox(width: 6),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: pct,
                                    backgroundColor: const Color(0xFFF0F2ED),
                                    valueColor:
                                        AlwaysStoppedAnimation(primaryGreen),
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 22,
                                child: Text(
                                  '$countForStar',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filter Bar
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter Bintang
                SizedBox(
                  height: 42,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _starFilterChip('Semua Bintang', null),
                      _starFilterChip('5 Bintang', 5),
                      _starFilterChip('4 Bintang', 4),
                      _starFilterChip('3 Bintang', 3),
                      _starFilterChip('2 Bintang', 2),
                      _starFilterChip('1 Bintang', 1),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Filter Varian & Foto (jika ada varian)
                if (widget.variants != null && widget.variants!.isNotEmpty)
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _variantFilterChip('Semua Varian', null),
                        ...widget.variants!.map((v) => _variantFilterChip(v, v)),
                        _photoFilterChip(),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _photoFilterChip(),
                  ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Daftar Ulasan
          if (filteredReviews.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: lightGreen,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.rate_review_outlined,
                            size: 38, color: darkGreen),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Tidak Ada Ulasan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Belum ada ulasan yang cocok dengan filter yang dipilih.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final review = filteredReviews[index];
                    return _buildReviewCard(review);
                  },
                  childCount: filteredReviews.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _starFilterChip(String label, int? star) {
    final active = _selectedStar == star;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: active,
        onSelected: (_) => setState(() => _selectedStar = star),
        selectedColor: primaryGreen,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: active ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w700,
          fontSize: 11.5,
        ),
        side: BorderSide(
          color: active ? primaryGreen : const Color(0xFFE4E8E1),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        showCheckmark: false,
      ),
    );
  }

  Widget _variantFilterChip(String label, String? variant) {
    final active = _selectedVariant == variant;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: active,
        onSelected: (_) => setState(() => _selectedVariant = variant),
        selectedColor: darkGreen,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: active ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
        side: BorderSide(
          color: active ? darkGreen : const Color(0xFFE4E8E1),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        showCheckmark: false,
      ),
    );
  }

  Widget _photoFilterChip() {
    return FilterChip(
      avatar: Icon(Icons.camera_alt_outlined,
          size: 14,
          color: _onlyWithPhotos ? Colors.white : Colors.grey.shade700),
      label: const Text('Dengan Foto'),
      selected: _onlyWithPhotos,
      onSelected: (val) => setState(() => _onlyWithPhotos = val),
      selectedColor: darkGreen,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: _onlyWithPhotos ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w700,
        fontSize: 11,
      ),
      side: BorderSide(
        color: _onlyWithPhotos ? darkGreen : const Color(0xFFE4E8E1),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      showCheckmark: false,
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9EDE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: lightGreen,
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : 'P',
                  style: TextStyle(
                    color: darkGreen,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(review.createdAt),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: Colors.amber.shade700,
                    size: 16,
                  );
                }),
              ),
            ],
          ),

          if (review.variant != null && review.variant!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: lightGreen.withOpacity(.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Varian: ${review.variant}',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: darkGreen,
                ),
              ),
            ),
          ],

          const SizedBox(height: 10),

          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: Colors.black87,
            ),
          ),

          if (review.photoPaths.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: review.photoPaths.map((path) {
                return InkWell(
                  onTap: () => _viewFullPhoto(path),
                  borderRadius: BorderRadius.circular(10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(path),
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 64,
                        height: 64,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image_rounded, size: 20),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.local_shipping_outlined,
                  size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                'Rating Kurir: ${review.courierRating}/5',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _viewFullPhoto(String path) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(File(path), fit: BoxFit.contain),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded,
                  color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }
}
