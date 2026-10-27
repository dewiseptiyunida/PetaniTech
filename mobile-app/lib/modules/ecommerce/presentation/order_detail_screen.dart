import 'package:flutter/material.dart';
import 'package:petanitech_mobile/utils/client/api_client.dart';
import '../logic/controllers/order_controller.dart';
import '../logic/controllers/review_controller.dart';
import '../logic/models/order_model.dart';
import 'add_review_screen.dart';
import 'product_reviews_screen.dart';
import 'payment/bank_transfer_payment_screen.dart';
import 'payment/qris_payment_screen.dart';

const _green = Color(0xFF7CB35A);
const _lightGreen = Color(0xFFE8F1E2);
const _darkGreen = Color(0xFF5E963F);

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({
    super.key,
    required this.orderId,
    this.controller,
  });

  final String orderId;
  final OrderController? controller;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late OrderController _controller;
  bool _openingPayment = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? orderController;
    _controller.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  String _rupiah(int value) =>
      'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  String _formatDateTime(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} WIB';

  void _confirmCancelOrder(BuildContext context, OrderModel order) {
    if (order.status == OrderStatus.shipped ||
        order.status == OrderStatus.completed ||
        order.status == OrderStatus.cancelled) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text(
            'Pembatalan Tidak Tersedia',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          content: Text(
            'Pesanan dengan status "${order.status.label}" tidak dapat dibatalkan.',
            style: const TextStyle(fontSize: 13),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Mengerti'),
            ),
          ],
        ),
      );
      return;
    }

    final reasons = [
      'Salah memilih produk atau varian',
      'Ingin mengubah jumlah pesanan',
      'Menemukan harga yang lebih murah di tempat lain',
      'Ingin mengubah alamat pengiriman',
      'Waktu pengiriman diperkirakan terlalu lama',
      'Berubah pikiran / tidak jadi membeli',
      'Alasan lainnya',
    ];

    String selectedReason = reasons.first;
    final otherReasonController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isOther = selectedReason == 'Alasan lainnya';

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pilih Alasan Pembatalan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(sheetCtx),
                          icon: const Icon(Icons.close_rounded, size: 22),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pilih alasan yang paling sesuai untuk pembatalan pesanan #${order.id}.',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const Divider(height: 20, thickness: 0.8),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          children: reasons.map((reason) {
                            final isChosen = selectedReason == reason;
                            return InkWell(
                              onTap: () {
                                setSheetState(() {
                                  selectedReason = reason;
                                });
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isChosen
                                      ? _lightGreen.withOpacity(0.5)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isChosen
                                        ? _green
                                        : Colors.grey.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isChosen
                                          ? Icons.radio_button_checked_rounded
                                          : Icons.radio_button_off_rounded,
                                      color: isChosen
                                          ? _darkGreen
                                          : Colors.grey.shade400,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        reason,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: isChosen
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: isChosen
                                              ? _darkGreen
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    if (isOther) ...[
                      const SizedBox(height: 10),
                      TextField(
                        controller: otherReasonController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Tuliskan alasan pembatalan Anda...',
                          hintStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF7F8F5),
                          contentPadding: const EdgeInsets.all(12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: _green,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          final finalReason =
                              isOther &&
                                      otherReasonController.text.trim().isNotEmpty
                                  ? otherReasonController.text.trim()
                                  : selectedReason;

                          Navigator.pop(sheetCtx);
                          _controller.cancelOrder(order.id, reason: finalReason);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pesanan berhasil dibatalkan.'),
                              backgroundColor: Color(0xFFD9534F),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD9534F),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Konfirmasi Pembatalan',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
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

  Future<void> _payNow(OrderModel order) async {
    if (_openingPayment || order.status != OrderStatus.awaitingPayment) return;
    setState(() => _openingPayment = true);

    final Widget paymentScreen;
    if (order.paymentMethod.toLowerCase().contains('qris')) {
      paymentScreen = QrisPaymentScreen(
        orderNumber: order.id,
        totalAmount: order.total,
      );
    } else {
      final bankMatch = RegExp(
        r'Transfer Bank\s*\(([^)]+)\)',
        caseSensitive: false,
      ).firstMatch(order.paymentMethod);
      final bankName = bankMatch?.group(1) ?? 'BCA';
      paymentScreen = BankTransferPaymentScreen(
        orderNumber: order.id,
        totalAmount: order.total,
        bankName: bankName,
        receiverName: order.receiver,
        orderCreatedAt: order.createdAt,
      );
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => paymentScreen),
    );
    if (mounted) {
      setState(() => _openingPayment = false);
    }
  }

  void _shipOrder(OrderModel order) {
    final trk =
        'PT-TRK-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
    _controller.updateStatus(
      order.id,
      OrderStatus.shipped,
      trackingNumber: trk,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Pesanan telah diserahkan ke kurir dan sedang dalam perjalanan.',
        ),
        backgroundColor: Color(0xFF7B61B5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _completeOrder(OrderModel order) {
    _controller.updateStatus(
      order.id,
      OrderStatus.completed,
      paymentStatus: 'Lunas',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Pesanan selesai! Terima kasih telah berbelanja di PetaniTech.',
        ),
        backgroundColor: _darkGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openAddReview(OrderModel order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddReviewScreen(order: order),
      ),
    ).then((result) {
      if (result == true) {
        _controller.markReviewed(order.id);
        setState(() {});
      }
    });
  }

  void _showExistingReview(OrderModel order) {
    final review = ReviewController.instance.getReviewForOrder(order.id);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ulasan Anda',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded, size: 22),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const Divider(height: 20, thickness: 0.8),
              if (review != null) ...[
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: _lightGreen,
                      child: const Icon(
                        Icons.person_rounded,
                        color: _darkGreen,
                        size: 20,
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
                          Text(
                            review.productName,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < review.rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: Colors.amber.shade700,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                if (review.variant != null && review.variant!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Varian: ${review.variant}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: _darkGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Text(
                  review.comment,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey.shade800,
                    height: 1.4,
                  ),
                ),
                if (review.courierRating > 0) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.local_shipping_outlined,
                        size: 16,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Penilaian Kurir: ${review.courierRating} / 5',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ] else ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('Ulasan untuk pesanan ini telah tercatat.'),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (order.items.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductReviewsScreen(
                            productName: order.items.first.productName,
                            productCategory: order.items.first.category,
                          ),
                        ),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _darkGreen,
                    side: const BorderSide(color: _green),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Lihat Semua Ulasan Produk',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
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

  @override
  Widget build(BuildContext context) {
    final order = _controller.findById(widget.orderId);
    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Pesanan')),
        body: const Center(child: Text('Pesanan tidak ditemukan.')),
      );
    }

    final stages = <OrderStatus>[
      OrderStatus.awaitingPayment,
      OrderStatus.processing,
      OrderStatus.shipped,
      OrderStatus.completed,
    ];
    final activeIndex = stages.indexOf(order.status);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F5),
      appBar: AppBar(
        title: const Text(
          'Detail Pesanan',
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Status
          _panel(children: [
            Row(children: [
              Expanded(
                child: Text(
                  'Pesanan #${order.id}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
              _statusPill(order.status),
            ]),
            const SizedBox(height: 7),
            Text(
              'Waktu Pemesanan: ${_formatDateTime(order.createdAt)}',
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
            const SizedBox(height: 18),
            const Text(
              'Perkembangan Pesanan',
              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            if (order.status == OrderStatus.cancelled)
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.cancel_rounded, color: Color(0xFFD9534F), size: 32),
                title: Text('Pesanan Dibatalkan',
                    style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFD9534F))),
                subtitle: Text('Pesanan ini telah dibatalkan dan tidak diproses lebih lanjut.',
                    style: TextStyle(fontSize: 12)),
              )
            else
              ...List.generate(stages.length, (i) {
                final done = activeIndex >= i;
                return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(
                    width: 28,
                    child: Column(children: [
                      Icon(
                        done ? Icons.check_circle : Icons.circle_outlined,
                        color: done ? _darkGreen : Colors.black26,
                        size: 20,
                      ),
                      if (i < stages.length - 1)
                        Container(
                          width: 2,
                          height: 28,
                          color: activeIndex > i ? _green : Colors.black12,
                        ),
                    ]),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2, bottom: 12),
                      child: Text(
                        stages[i].label,
                        style: TextStyle(
                          fontWeight: done ? FontWeight.w800 : FontWeight.w500,
                          color: done ? Colors.black87 : Colors.black45,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ),
                ]);
              }),
          ]),
          const SizedBox(height: 12),

          // Produk Dipesan
          _panel(title: 'Produk Dipesan (${order.shopName})', children: [
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _lightGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: (item.image != null && item.image!.isNotEmpty)
                          ? Image.network(
                              ApiClient.getAsset(item.image!),
                              fit: BoxFit.cover,
                              width: 50,
                              height: 50,
                              errorBuilder: (_, __, ___) =>
                                  Icon(item.icon, color: _darkGreen, size: 26),
                            )
                          : Icon(item.icon, color: _darkGreen, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.productName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 13)),
                          if (item.variant != null &&
                              item.variant!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text('Varian: ${item.variant}',
                                style: const TextStyle(
                                    color: _darkGreen,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          ],
                          const SizedBox(height: 3),
                          Text('${item.quantity} × ${_rupiah(item.price)}',
                              style: const TextStyle(
                                  color: Colors.black54, fontSize: 11.5)),
                        ],
                      ),
                    ),
                    Text(_rupiah(item.subtotal),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  ]),
                )),
          ]),
          const SizedBox(height: 12),

          // Alamat Pengiriman
          _panel(title: 'Alamat Pengiriman', children: [
            Text(order.receiver,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
            const SizedBox(height: 3),
            Text(order.phone, style: const TextStyle(color: Colors.black54, fontSize: 12)),
            const SizedBox(height: 6),
            Text(order.shippingAddress, style: const TextStyle(height: 1.4, fontSize: 12)),
          ]),
          const SizedBox(height: 12),

          // Informasi Pengiriman
          _panel(title: 'Informasi Pengiriman', children: [
            _row('Kurir', order.courier),
            _row('Layanan', order.courierService),
            _row('Nomor Resi',
                order.trackingNumber.isEmpty ? 'Belum tersedia' : order.trackingNumber),
          ]),
          const SizedBox(height: 12),

          // Informasi Pembatalan (jika pesanan dibatalkan)
          if (order.status == OrderStatus.cancelled &&
              order.cancellationReason != null &&
              order.cancellationReason!.isNotEmpty) ...[
            _panel(
              title: 'Informasi Pembatalan',
              children: [
                _row(
                  'Alasan Pembatalan',
                  order.cancellationReason!,
                  valueColor: const Color(0xFFD9534F),
                  bold: true,
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Rincian Pembayaran
          _panel(title: 'Rincian Pembayaran', children: [
            _row('Metode Pembayaran', order.paymentMethod),
            _row('Status Pembayaran', order.paymentStatus,
                valueColor: order.paymentStatus == 'Lunas'
                    ? _darkGreen
                    : const Color(0xFFE69B26)),
            const Divider(height: 18),
            _row('Subtotal Produk', _rupiah(order.productTotal)),
            _row('Ongkos Kirim', _rupiah(order.shippingCost)),
            _row('Biaya Layanan', _rupiah(order.serviceFee)),
            const Divider(height: 18),
            _row('Total Pembayaran', _rupiah(order.total), bold: true),
          ]),
          const SizedBox(height: 16),

          // ============================================================
          // AKSI PESANAN
          // ============================================================

          // Kasus 1: Belum Bayar
          if (order.status == OrderStatus.awaitingPayment) ...[
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _openingPayment ? null : () => _payNow(order),
                icon: const Icon(Icons.payment_rounded, size: 20),
                label: const Text(
                  'Bayar Sekarang',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () => _confirmCancelOrder(context, order),
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: const Text('Batalkan Pesanan'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD9534F),
                  side: const BorderSide(color: Color(0xFFD9534F)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],

          // Kasus 2: Diproses
          if (order.status == OrderStatus.processing) ...[
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _shipOrder(order),
                icon: const Icon(Icons.local_shipping_outlined, size: 20),
                label: const Text(
                  'Perbarui Pengiriman (Kirim Barang)',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3978C5),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () => _confirmCancelOrder(context, order),
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: const Text('Batalkan Pesanan'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD9534F),
                  side: const BorderSide(color: Color(0xFFD9534F)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],

          // Kasus 3: Dikirim
          if (order.status == OrderStatus.shipped) ...[
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _completeOrder(order),
                icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                label: const Text(
                  'Konfirmasi Pesanan Diterima',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],

          // Kasus 4: Selesai
          if (order.status == OrderStatus.completed) ...[
            Builder(builder: (context) {
              final isReviewed =
                  ReviewController.instance.hasReviewForOrder(order.id) ||
                      order.reviewed;

              if (isReviewed) {
                return SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => _showExistingReview(order),
                    icon: const Icon(Icons.rate_review_outlined, size: 20),
                    label: const Text(
                      'Lihat Ulasan',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _darkGreen,
                      side: const BorderSide(color: _green, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => _openAddReview(order),
                  icon: const Icon(Icons.star_rounded, size: 20),
                  label: const Text(
                    'Beri Penilaian',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              );
            }),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  static Widget _panel({String? title, required List<Widget> children}) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE9EDE5)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (title != null) ...[
            Text(
              title,
              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
          ],
          ...children,
        ]),
      );

  static Widget _row(
    String label,
    String value, {
    bool bold = false,
    Color? valueColor,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Row(children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
                color: valueColor ?? (bold ? _darkGreen : Colors.black87),
                fontSize: bold ? 15 : 12,
              ),
            ),
          ),
        ]),
      );

  static Widget _statusPill(OrderStatus status) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: status.color.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          status.label,
          style: TextStyle(
            color: status.color,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
}
