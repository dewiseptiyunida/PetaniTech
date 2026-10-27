import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../logic/controllers/order_controller.dart';
import '../logic/controllers/review_controller.dart';
import '../logic/models/order_model.dart';
import '../logic/models/review_model.dart';

class AddReviewScreen extends StatefulWidget {
  final OrderModel order;

  const AddReviewScreen({super.key, required this.order});

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final Color primaryGreen = const Color(0xFF7CB35A);
  final Color lightGreen = const Color(0xFFE8F1E2);
  final Color darkGreen = const Color(0xFF5E963F);

  int _productRating = 5;
  int _courierRating = 5;
  final TextEditingController _commentController = TextEditingController();
  final List<String> _photoPaths = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (file != null) {
        // Salin foto ke direktori dokumen agar tetap tersimpan (tidak hilang dari cache)
        final docsDir = await getApplicationDocumentsDirectory();
        final reviewDir = Directory(p.join(docsDir.path, 'review_photos'));
        if (!reviewDir.existsSync()) reviewDir.createSync(recursive: true);
        final fileName = 'review_${DateTime.now().millisecondsSinceEpoch}${p.extension(file.path)}';
        final saved = await File(file.path).copy(p.join(reviewDir.path, fileName));
        if (mounted) {
          setState(() {
            _photoPaths.add(saved.path);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memilih foto.')),
        );
      }
    }
  }

  void _showImageSourceModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pilih Sumber Foto',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: lightGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.camera_alt_rounded, color: darkGreen),
                ),
                title: const Text('Ambil dari Kamera',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: lightGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.photo_library_rounded, color: darkGreen),
                ),
                title: const Text('Pilih dari Galeri',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan tulis ulasan tentang produk ini.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final firstItem = widget.order.items.isNotEmpty
        ? widget.order.items.first
        : null;

    final review = ReviewModel(
      id: 'REV-${DateTime.now().millisecondsSinceEpoch}',
      orderId: widget.order.id,
      productName: firstItem?.productName ?? 'Produk Pertanian',
      variant: firstItem?.variant,
      userName: widget.order.receiver.isNotEmpty
          ? widget.order.receiver
          : 'Petani Modern',
      rating: _productRating,
      courierRating: _courierRating,
      comment: comment,
      photoPaths: List.from(_photoPaths),
      createdAt: DateTime.now(),
    );

    await reviewController.addReview(review);
    await orderController.markReviewed(widget.order.id);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Expanded(child: Text('Ulasan berhasil disimpan! Terima kasih.')),
          ],
        ),
        backgroundColor: darkGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context, true);
  }

  String _ratingLabel(int rating) => switch (rating) {
        1 => 'Sangat Buruk',
        2 => 'Buruk',
        3 => 'Cukup',
        4 => 'Puas',
        5 => 'Sangat Puas!',
        _ => '',
      };

  @override
  Widget build(BuildContext context) {
    final firstItem = widget.order.items.isNotEmpty
        ? widget.order.items.first
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F5),
      appBar: AppBar(
        title: const Text(
          'Beri Penilaian',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87, size: 19),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info Produk yang diulas
          if (firstItem != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE9EDE5)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: lightGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(firstItem.icon, color: darkGreen, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firstItem.productName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                          ),
                        ),
                        if (firstItem.variant != null &&
                            firstItem.variant!.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            'Varian: ${firstItem.variant}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 14),

          // Rating Produk
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE9EDE5)),
            ),
            child: Column(
              children: [
                const Text(
                  'Kualitas Produk',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  _ratingLabel(_productRating),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: darkGreen,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final star = index + 1;
                    return IconButton(
                      onPressed: () => setState(() => _productRating = star),
                      icon: Icon(
                        star <= _productRating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: Colors.amber.shade700,
                        size: 38,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Ulasan Teks & Foto
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE9EDE5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tulis Ulasan Anda',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _commentController,
                  maxLines: 4,
                  maxLength: 500,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText:
                        'Bagikan kepuasan Anda mengenai kualitas barang, efektivitas penggunaan, atau kesesuaian deskripsi...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9FAF8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE4E8E1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE4E8E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: primaryGreen, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Foto Produk (Opsional)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ..._photoPaths.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final path = entry.value;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(path),
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: -6,
                            right: -6,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _photoPaths.removeAt(idx);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close_rounded,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    if (_photoPaths.length < 5)
                      InkWell(
                        onTap: _showImageSourceModal,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F6F2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFD8DED3),
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined,
                                  color: darkGreen, size: 24),
                              const SizedBox(height: 4),
                              Text(
                                'Tambah',
                                style: TextStyle(
                                  color: darkGreen,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Rating Pelayanan Kurir & Pengiriman
          Container(
            padding: const EdgeInsets.all(18),
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
                    Icon(Icons.local_shipping_outlined,
                        color: darkGreen, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Pelayanan Kurir (${widget.order.courier})',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (index) {
                    final star = index + 1;
                    return IconButton(
                      onPressed: () => setState(() => _courierRating = star),
                      icon: Icon(
                        star <= _courierRating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: Colors.amber.shade700,
                        size: 28,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Tombol Simpan
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Kirim Penilaian',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
