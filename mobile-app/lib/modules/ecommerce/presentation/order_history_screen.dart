import 'dart:async';
import 'package:flutter/material.dart';
import 'package:petanitech_mobile/utils/client/api_client.dart';
import '../logic/controllers/order_controller.dart';
import '../logic/controllers/review_controller.dart';
import '../logic/models/order_model.dart';
import 'add_review_screen.dart';
import 'order_detail_screen.dart';
import 'product_reviews_screen.dart';

const _green = Color(0xFF7CB35A);
const _lightGreen = Color(0xFFE8F1E2);
const _darkGreen = Color(0xFF5E963F);

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key, this.initialStatus, this.controller});

  final OrderStatus? initialStatus;
  final OrderController? controller;

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late OrderStatus? _selected;
  late OrderController _controller;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialStatus;
    _controller = widget.controller ?? orderController;
    _controller.addListener(_refresh);
    reviewController.addListener(_refresh);
    _controller.refreshOrders();
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    reviewController.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
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
        if (mounted) setState(() {});
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
                              color: Colors.grey.shade600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < review.rating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: Colors.amber.shade700,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (review.variant != null && review.variant!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _lightGreen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Varian: ${review.variant}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _darkGreen,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  review.comment,
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductReviewsScreen(
                            productName: review.productName,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Lihat Semua Ulasan Produk Ini',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                ),
              ] else ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text('Data ulasan tidak ditemukan.'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orders = _controller.filter(_selected);
    final filters = <(String, OrderStatus?)>[
      ('Semua', null),
      ('Belum Bayar', OrderStatus.awaitingPayment),
      ('Diproses', OrderStatus.processing),
      ('Dikirim', OrderStatus.shipped),
      ('Selesai', OrderStatus.completed),
      ('Dibatalkan', OrderStatus.cancelled),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
            size: 19,
          ),
        ),
        title: const Text(
          'Riwayat Pesanan',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 58,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = filters[index];
                final active = _selected == filter.$2;
                return ChoiceChip(
                  label: Text(filter.$1),
                  selected: active,
                  onSelected: (_) => setState(() => _selected = filter.$2),
                  selectedColor: _green,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: active ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  side: BorderSide(color: active ? _green : Colors.black12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: _green,
              onRefresh: () => _controller.refreshOrders(),
              child: orders.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: _emptyState(),
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: orders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return _OrderCard(
                          order: order,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrderDetailScreen(
                                orderId: order.id,
                                controller: _controller,
                              ),
                            ),
                          ),
                          onAddReview: () => _openAddReview(order),
                          onShowReview: () => _showExistingReview(order),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: _lightGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  size: 42,
                  color: _darkGreen,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Belum ada pesanan',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Pesanan kamu akan muncul di halaman ini.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      );
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.onTap,
    this.onAddReview,
    this.onShowReview,
  });

  final OrderModel order;
  final VoidCallback onTap;
  final VoidCallback? onAddReview;
  final VoidCallback? onShowReview;

  String _rupiah(int value) =>
      'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final first = order.items.isEmpty ? null : order.items.first;
    final isReviewed =
        order.reviewed || ReviewController.instance.hasReviewForOrder(order.id);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE9EDE5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.storefront_rounded,
                      color: _darkGreen,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.shopName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'No: ${order.id} • ${_date(order.createdAt)}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: order.status.color.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status.label,
                      style: TextStyle(
                        color: order.status.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              if (first != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: _lightGreen,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: (first.image != null && first.image!.isNotEmpty)
                          ? Image.network(
                              ApiClient.getAsset(first.image!),
                              fit: BoxFit.cover,
                              width: 58,
                              height: 58,
                              errorBuilder: (_, __, ___) =>
                                  Icon(first.icon, size: 28, color: _darkGreen),
                            )
                          : Icon(first.icon, size: 28, color: _darkGreen),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            first.productName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (first.variant != null &&
                              first.variant!.isNotEmpty) ...[
                            Text(
                              'Varian: ${first.variant}',
                              style: const TextStyle(
                                color: _darkGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            '${first.quantity} barang × ${_rupiah(first.price)}',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 11.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (order.items.length > 1)
                            Text(
                              '+ ${order.items.length - 1} produk lainnya',
                              style: const TextStyle(
                                color: _darkGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.paymentMethod,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (order.status == OrderStatus.awaitingPayment &&
                            (order.paymentMethod.toLowerCase().contains('qris') ||
                                order.paymentMethod.toLowerCase().contains('bank') ||
                                order.paymentMethod.toLowerCase().contains('transfer'))) ...[
                          const SizedBox(height: 5),
                          _OrderPaymentCountdown(order: order),
                        ],
                        const SizedBox(height: 2),
                        Text(
                          'Total Pembayaran',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _rupiah(order.total),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: _darkGreen,
                      fontSize: 15.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: onTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _darkGreen,
                      side: const BorderSide(color: _green),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Lihat Detail',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (order.status == OrderStatus.completed) ...[
                    const SizedBox(width: 8),
                    if (isReviewed)
                      OutlinedButton.icon(
                        onPressed: onShowReview,
                        icon: const Icon(Icons.rate_review_outlined, size: 15),
                        label: const Text(
                          'Lihat Ulasan',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _darkGreen,
                          side: const BorderSide(color: _green, width: 1.2),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: onAddReview,
                        icon: const Icon(Icons.star_rounded, size: 16),
                        label: const Text(
                          'Beri Penilaian',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/// Countdown berdasarkan batas waktu transaksi, bukan waktu halaman dibuka.
class _OrderPaymentCountdown extends StatefulWidget {
  const _OrderPaymentCountdown({required this.order});

  final OrderModel order;

  @override
  State<_OrderPaymentCountdown> createState() => _OrderPaymentCountdownState();
}

class _OrderPaymentCountdownState extends State<_OrderPaymentCountdown> {
  late DateTime _expiresAt;
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _expiresAt = _resolveExpiry(widget.order);
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(_refresh);
      if (_remaining.inSeconds <= 0) _timer?.cancel();
    });
  }

  DateTime _resolveExpiry(OrderModel order) {
    if (order.paymentMethod.toLowerCase().contains('qris')) {
      // Untuk pesanan QRIS lama yang belum menyimpan expiry, gunakan createdAt
      // sebagai acuan agar tidak memulai 10 menit baru saat membuka riwayat.
      return order.paymentExpiresAt ?? order.createdAt.add(const Duration(minutes: 10));
    }
    // Transfer bank tetap menggunakan batas 24 jam yang sudah ada.
    return order.createdAt.add(const Duration(hours: 24));
  }

  void _refresh() {
    _remaining = _expiresAt.difference(DateTime.now());
    if (_remaining.isNegative) _remaining = Duration.zero;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seconds = _remaining.inSeconds;
    final isExpired = seconds <= 0;
    final label = isExpired
        ? 'Waktu pembayaran habis'
        : 'Sisa waktu: ${(_remaining.inHours > 0 ? _remaining.inHours.toString().padLeft(2, '0') + ':' : '')}${(_remaining.inMinutes % 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.timer_outlined,
          size: 12,
          color: isExpired ? Colors.redAccent : _darkGreen,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              color: isExpired ? Colors.redAccent : _darkGreen,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
