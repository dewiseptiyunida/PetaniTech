import 'dart:async';
import 'package:flutter/material.dart';
import 'order_invoice_screen.dart';
import 'package:flutter/services.dart';
import 'package:petanitech_mobile/utils/client/api_client.dart';
import '../logic/controllers/order_controller.dart';
import '../logic/controllers/review_controller.dart';
import '../logic/models/order_model.dart';
import 'add_review_screen.dart';
import 'product_reviews_screen.dart';
import 'shopping_cart_screen.dart';
import 'payment/bank_transfer_payment_screen.dart';
import 'payment/qris_payment_screen.dart';
import 'store_screen.dart';

const _green = Color(0xFF7CB35A);
const _lightGreen = Color(0xFFE8F1E2);
const _darkGreen = Color(0xFF5E963F);

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({
    super.key,
    required this.orderId,
    this.controller,
    this.fromSource,
  });

  final String orderId;
  final OrderController? controller;
  final String? fromSource;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late OrderController _controller;
  bool _openingPayment = false;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? orderController;
    _controller.addListener(_onStateChanged);
    _controller.cancelExpiredOrders();
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _controller.removeListener(_onStateChanged);
    super.dispose();
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final order = _controller.findById(widget.orderId);
      if (order != null && order.status == OrderStatus.awaitingPayment) {
        final deadline = order.paymentExpiresAt ??
            order.createdAt.add(
              order.paymentMethod.toLowerCase().contains('qris')
                  ? const Duration(minutes: 10)
                  : const Duration(hours: 24),
            );
        if (DateTime.now().isAfter(deadline)) {
          _controller.cancelExpiredOrders();
        }
        setState(() {});
      }
    });
  }

  String _formatCountdown(OrderModel order) {
    final deadline = order.paymentExpiresAt ??
        order.createdAt.add(
          order.paymentMethod.toLowerCase().contains('qris')
              ? const Duration(minutes: 10)
              : const Duration(hours: 24),
        );
    final diff = deadline.difference(DateTime.now());
    if (diff.isNegative || diff.inSeconds <= 0) {
      return '00:00:00 (Waktu Habis)';
    }
    final hours = diff.inHours.toString().padLeft(2, '0');
    final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  String _rupiah(int value) =>
      'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  String _formatDateTime(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} WIB';

  void _onBackPressed() {
    final order = _controller.findById(widget.orderId);
    final origin = widget.fromSource ?? order?.checkoutOrigin;

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      if (origin == 'cart') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ShoppingCartScreen()),
        );
      } else {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    }
  }

  void _confirmCancelOrder(BuildContext context, OrderModel order) {
    if (order.status == OrderStatus.shipped ||
        order.status == OrderStatus.completed ||
        order.status == OrderStatus.cancelled) {
      showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
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
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Divider(height: 20, thickness: 0.8),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          children:
                              reasons.map((reason) {
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
                                      color:
                                          isChosen
                                              ? _lightGreen.withOpacity(0.5)
                                              : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color:
                                            isChosen
                                                ? _green
                                                : Colors.grey.shade200,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isChosen
                                              ? Icons
                                                  .radio_button_checked_rounded
                                              : Icons.radio_button_off_rounded,
                                          color:
                                              isChosen
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
                                              fontWeight:
                                                  isChosen
                                                      ? FontWeight.w700
                                                      : FontWeight.w500,
                                              color:
                                                  isChosen
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
                                      otherReasonController.text
                                          .trim()
                                          .isNotEmpty
                                  ? otherReasonController.text.trim()
                                  : selectedReason;

                          Navigator.pop(sheetCtx);
                          _controller.cancelOrder(
                            order.id,
                            reason: finalReason,
                          );
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

  void _openAddReview(OrderModel order) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddReviewScreen(order: order)),
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
      builder:
          (ctx) => SafeArea(
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
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
                    if (review.variant != null &&
                        review.variant!.isNotEmpty) ...[
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
                              builder:
                                  (_) => ProductReviewsScreen(
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _onBackPressed();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        appBar: AppBar(
          titleSpacing: 0,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0.5,
          title: const Text(
            'Rincian Pesanan',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          centerTitle: false,
          leading: IconButton(
            onPressed: _onBackPressed,
            icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
          ),
        ),
        body: RefreshIndicator(
          color: _darkGreen,
          onRefresh: () async {
            await _controller.loadFromStorage();
            await _controller.cancelExpiredOrders();
            if (mounted) setState(() {});
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
            children: [
            _orderInfoPanel(
              children: [
                _statusSection(order),
                _shippingCard(order),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE9EDE6),
                ),
                _addressSection(order),
              ],
            ),
            const SizedBox(height: 14),

            _panel(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => StoreScreen(
                              storeName: order.shopName,
                              initialProducts:
                                  order.items
                                      .map(
                                        (item) => {
                                          'name': item.productName,
                                          'category': item.category,
                                          'price': item.price,
                                          'icon': item.icon,
                                          'image': item.image,
                                          'shopName': order.shopName,
                                        },
                                      )
                                      .toList(),
                            ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.storefront_outlined,
                        color: _darkGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order.shopName,
                          style: const TextStyle(
                            color: _darkGreen,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: _darkGreen,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: _lightGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child:
                              (item.image != null && item.image!.isNotEmpty)
                                  ? Image.network(
                                    ApiClient.getAsset(item.image!),
                                    fit: BoxFit.cover,
                                    width: 76,
                                    height: 76,
                                    errorBuilder:
                                        (_, __, ___) => Icon(
                                          item.icon,
                                          color: _darkGreen,
                                          size: 34,
                                        ),
                                  )
                                  : Icon(
                                    item.icon,
                                    color: _darkGreen,
                                    size: 34,
                                  ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                  Text(
                                    item.productName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  if (item.variant != null &&
                                      item.variant!.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      'Varian: ${item.variant}',
                                      style: const TextStyle(
                                        color: _darkGreen,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 3),
                                  Text(
                                    '${item.quantity} × ${_rupiah(item.price)}',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 11.5,
                                    ),
                                  ),
                            ],
                          ),
                        ),
                        Text(
                          _rupiah(item.subtotal),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE9EDE6),
                ),
                const Padding(padding: EdgeInsets.only(bottom: 10)),
                _row('Subtotal Produk', _rupiah(order.productTotal)),
                _row('Subtotal Pengiriman', _rupiah(order.shippingCost)),
                _row('Biaya Layanan', _rupiah(order.serviceFee)),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE9EDE6),
                ),
                const Padding(padding: EdgeInsets.only(bottom: 8)),
                _row('Total Pembayaran', _rupiah(order.total), bold: true),
              ],
            ),
            const SizedBox(height: 12),

            _panel(
              title: 'Rincian Pembayaran',
              children: [
                _row('Metode Pembayaran', order.paymentMethod),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Nota Pesanan / Faktur',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ),
                    Material(
                      color: _lightGreen.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () => _openInvoice(order),
                        borderRadius: BorderRadius.circular(10),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.receipt_long_rounded,
                                color: _darkGreen,
                                size: 15,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Lihat Nota',
                                style: TextStyle(
                                  color: _darkGreen,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 3),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: _darkGreen,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (order.status == OrderStatus.cancelled &&
                order.cancellationReason != null &&
                order.cancellationReason!.isNotEmpty) ...[
              _panel(
                title: 'Informasi Pembatalan',
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Alasan Pembatalan',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4F2),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text(
                          order.cancellationReason!,
                          style: const TextStyle(
                            color: Color(0xFFD9534F),
                            fontSize: 12,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            _panel(
              title: 'Riwayat Waktu',
              children: [
                _row('Waktu Pemesanan', _formatDateTime(order.createdAt)),
                _row(
                  'Waktu Pembayaran',
                  order.paidAt == null
                      ? 'Belum tersedia'
                      : _formatDateTime(order.paidAt!),
                ),
                _row(
                  'Waktu Pengiriman',
                  order.shippedAt == null
                      ? 'Belum tersedia'
                      : _formatDateTime(order.shippedAt!),
                ),
                _row(
                  'Waktu Pesanan Selesai',
                  order.completedAt == null
                      ? 'Belum tersedia'
                      : _formatDateTime(order.completedAt!),
                ),
              ],
            ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],

            // Kasus 2: Diproses (hanya sisakan Batalkan Pesanan)
            if (order.status == OrderStatus.processing) ...[
              SizedBox(
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmCancelOrder(context, order),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text(
                    'Batalkan Pesanan',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFD9534F),
                    side: const BorderSide(
                      color: Color(0xFFD9534F),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],

            if (order.status == OrderStatus.completed) ...[
              Builder(
                builder: (context) {
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
                },
              ),
            ],
            const SizedBox(height: 5),
          ],
        ),
        ),
      ),
    );
  }

  static Widget _orderInfoPanel({required List<Widget> children}) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE5EAE1)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .025),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );

  static Widget _panel({String? title, required List<Widget> children}) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5EAE1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .025),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
            ],
            ...children,
          ],
        ),
      );

  Widget _shippingCard(OrderModel order) {
    final hasTrackingNumber = order.trackingNumber.trim().isNotEmpty;
    final courierName = '${order.courier} ${order.courierService}'.trim();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 5, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  courierName.isEmpty ? 'Layanan pengiriman' : courierName,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          hasTrackingNumber
                              ? order.trackingNumber
                              : 'No. Resi belum tersedia',
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Colors.black54,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      if (hasTrackingNumber)
                        InkWell(
                          onTap: () async {
                            await Clipboard.setData(
                              ClipboardData(text: order.trackingNumber),
                            );
                            if (!mounted) return;
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                const SnackBar(
                                  content: Text('Nomor resi berhasil disalin'),
                                  duration: Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: const Padding(
                            padding: EdgeInsets.only(left: 4, top: 3),
                            child: Icon(
                              Icons.copy_rounded,
                              color: _darkGreen,
                              size: 15,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (order.status != OrderStatus.cancelled) ...[
            const Divider(height: 1, thickness: 1, color: Color(0xFFE9EDE6)),
            const SizedBox(height: 12),
            Text(
              'Status Pesanan',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _shipmentTimeline(order),
          ],
        ],
      ),
    );
  }

  Widget _addressSection(OrderModel order) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alamat Tujuan Pengiriman',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w800,
              letterSpacing: .35,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: _darkGreen,
                size: 21,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.receiver,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      order.phone,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      order.shippingAddress,
                      style: const TextStyle(height: 1.4, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusSection(OrderModel order) {
    final icon = switch (order.status) {
      OrderStatus.completed => Icons.check_rounded,
      OrderStatus.shipped => Icons.local_shipping_outlined,
      OrderStatus.processing => Icons.inventory_2_outlined,
      OrderStatus.awaitingPayment => Icons.payment_outlined,
      OrderStatus.cancelled => Icons.close_rounded,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  order.status == OrderStatus.cancelled
                      ? const [Color(0xFFC62828), Color(0xFFEF5350)]
                      : const [Color(0xFF5E963F), Color(0xFF9BCB69)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color:
                      order.status == OrderStatus.cancelled
                          ? const Color(0xFFD32F2F)
                          : _darkGreen,
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pesanan ${order.status.label}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (order.status == OrderStatus.awaitingPayment) ...[
                      const SizedBox(height: 3),
                      Text(
                        'Selesaikan pembayaran dalam: ${_formatCountdown(order)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 1),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Nomor Pesanan',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '#${order.id}',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 11.5,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () async {
                      await Clipboard.setData(
                        ClipboardData(text: '#${order.id}'),
                      );
                      if (!mounted) return;
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(
                            content: Text('Nomor pesanan berhasil disalin'),
                            duration: Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 4, top: 3, bottom: 3),
                      child: Icon(
                        Icons.copy_rounded,
                        color: _darkGreen,
                        size: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _shipmentTimeline(OrderModel order) {
    const stages = [
      (OrderStatus.processing, 'Pesanan\ndiproses'),
      (OrderStatus.shipped, 'Dalam\npengiriman'),
      (OrderStatus.completed, 'Tiba di\ntujuan'),
      (OrderStatus.completed, 'Pesanan\nselesai'),
    ];
    final activeIndex = switch (order.status) {
      OrderStatus.awaitingPayment => -1,
      OrderStatus.processing => 0,
      OrderStatus.shipped => 1,
      OrderStatus.completed => 3,
      OrderStatus.cancelled => -1,
    };

    if (order.status == OrderStatus.cancelled) {
      return Row(
        children: [
          const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 20),
          const SizedBox(width: 8),
          const Text(
            'Pesanan dibatalkan',
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < stages.length; index++) ...[
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 2,
                        color:
                            index == 0
                                ? Colors.transparent
                                : (index <= activeIndex
                                    ? _green
                                    : Colors.black12),
                      ),
                    ),
                    Container(
                      width: 21,
                      height: 21,
                      decoration: BoxDecoration(
                        color: index <= activeIndex ? _darkGreen : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              index <= activeIndex
                                  ? _darkGreen
                                  : Colors.black26,
                        ),
                      ),
                      child:
                          index <= activeIndex
                              ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 14,
                              )
                              : null,
                    ),
                    Expanded(
                      child: Container(
                        height: 2,
                        color:
                            index == stages.length - 1
                                ? Colors.transparent
                                : (index < activeIndex
                                    ? _green
                                    : Colors.black12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  stages[index].$2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _darkGreen,
                    fontSize: 10,
                    height: 1.15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _openInvoice(OrderModel order) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrderInvoiceScreen(order: order)),
    );
  }

  static Widget _row(
    String label,
    String value, {
    bool bold = false,
    Color? valueColor,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 150,
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
              color: valueColor ?? (bold ? _darkGreen : Colors.black87),
              fontSize: bold ? 15 : 12,
            ),
          ),
        ),
      ],
    ),
  );
}
