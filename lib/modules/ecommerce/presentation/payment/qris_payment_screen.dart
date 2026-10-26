import 'dart:async';
import 'package:flutter/material.dart';
import '../../logic/controllers/order_controller.dart';
import '../../logic/models/order_model.dart';

class QrisPaymentScreen extends StatefulWidget {
  final String orderNumber;
  final int totalAmount;

  const QrisPaymentScreen({
    super.key,
    required this.orderNumber,
    required this.totalAmount,
  });

  @override
  State<QrisPaymentScreen> createState() => _QrisPaymentScreenState();
}

class _QrisPaymentScreenState extends State<QrisPaymentScreen> {
  final Color primaryGreen = const Color(0xFF7CB35A);
  final Color lightGreen = const Color(0xFFE8F1E2);
  final Color darkGreen = const Color(0xFF5E963F);
  final Color bgGrey = const Color(0xFFF7F8F6);

  Timer? _timer;
  late DateTime _paymentExpiresAt;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    final order = orderController.findById(widget.orderNumber);
    // Gunakan waktu kedaluwarsa dari pesanan yang sama agar membuka ulang
    // halaman QRIS tidak memulai ulang hitung mundur.
    _paymentExpiresAt = order?.paymentExpiresAt ??
        order?.createdAt.add(const Duration(minutes: 10)) ??
        DateTime.now().add(const Duration(minutes: 10));
    _updateRemainingTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(_updateRemainingTime);
      if (_secondsRemaining <= 0) {
        _timer?.cancel();
        final order = orderController.findById(widget.orderNumber);
        if (order != null && order.status == OrderStatus.awaitingPayment) {
          orderController.cancelOrder(
            widget.orderNumber,
            reason: 'Waktu pembayaran QRIS telah habis',
          );
        }
      }
    });
  }

  void _updateRemainingTime() {
    final remaining = _paymentExpiresAt.difference(DateTime.now()).inSeconds;
    _secondsRemaining = remaining > 0 ? remaining : 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTimer {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _saveQrImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.download_done_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('Kode QR berhasil disimpan ke Galeri perangkat'),
          ],
        ),
        backgroundColor: darkGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          'Pembayaran QRIS',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
        children: [
          _buildCountdownCard(),
          const SizedBox(height: 14),
          _buildQrisCard(),
          const SizedBox(height: 14),
          _buildQrisInstructions(),
        ],
      ),
      bottomNavigationBar: _buildBottomAction(),
    );
  }

  Widget _buildCountdownCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFEDEFEB)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: lightGreen, shape: BoxShape.circle),
          child: Icon(
            Icons.qr_code_scanner_rounded,
            color: darkGreen,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bayar Sebelum Waktu Habis',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formattedTimer,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: _secondsRemaining == 0 ? Colors.red : darkGreen,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _secondsRemaining == 0
                    ? 'Kode QR telah kedaluwarsa'
                    : 'Kode QR akan kedaluwarsa dalam 10 menit',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildQrisCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFEDEFEB)),
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'QRIS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Standar Pembayaran Nasional',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'PETANITECH INDONESIA',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: darkGreen,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'NMID: ID1020304050607 • No: ${widget.orderNumber}',
          style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 18),
        Container(
          width: 220,
          height: 220,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _qrCornerMarker(),
                      _qrDottedBlock(),
                      _qrCornerMarker(),
                    ],
                  ),
                  _qrCenterPattern(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _qrCornerMarker(),
                      _qrDottedBlock(),
                      _qrDottedBlock(),
                    ],
                  ),
                ],
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryGreen, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.energy_savings_leaf_rounded,
                  color: darkGreen,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Total Tagihan: Rp ${_formatPrice(widget.totalAmount)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: darkGreen,
          ),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: _saveQrImage,
          icon: Icon(Icons.download_rounded, color: darkGreen, size: 18),
          label: Text(
            'Simpan Gambar QR',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: darkGreen,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: primaryGreen),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _qrCornerMarker() => Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black87, width: 6),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Center(
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    ),
  );

  Widget _qrDottedBlock() => SizedBox(
    width: 44,
    height: 44,
    child: Wrap(
      spacing: 3,
      runSpacing: 3,
      children: List.generate(
        16,
        (i) => Container(
          width: 7,
          height: 7,
          color: i.isEven ? Colors.black87 : Colors.transparent,
        ),
      ),
    ),
  );

  Widget _qrCenterPattern() => SizedBox(
    width: 170,
    height: 50,
    child: Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: List.generate(
        24,
        (i) => Container(
          width: 8,
          height: 8,
          color: i % 3 != 0 ? Colors.black87 : Colors.grey.shade400,
        ),
      ),
    ),
  );

  Widget _buildQrisInstructions() => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFEDEFEB)),
    ),
    child: Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: Icon(Icons.info_outline_rounded, color: darkGreen, size: 20),
        title: const Text(
          'Cara Membayar dengan QRIS',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                _stepItem(
                  '1',
                  'Buka aplikasi e-Wallet atau Mobile Banking Anda (BCA, Mandiri, BRI, BNI, GoPay, OVO, ShopeePay, DANA, dll).',
                ),
                _stepItem('2', 'Pilih menu Scan / Bayar QR.'),
                _stepItem(
                  '3',
                  'Arahkan kamera ke kode QR di atas atau unggah dari galeri jika sudah disimpan.',
                ),
                _stepItem(
                  '4',
                  'Pastikan nama penerima PETANITECH INDONESIA dan total nominal Rp ${_formatPrice(widget.totalAmount)} sesuai.',
                ),
                _stepItem(
                  '5',
                  'Masukkan PIN transaksi Anda untuk menyelesaikan pembayaran.',
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _stepItem(String number, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18,
          height: 18,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: lightGreen, shape: BoxShape.circle),
          child: Text(
            number,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: darkGreen,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              height: 1.35,
            ),
          ),
        ),
      ],
    ),
  );

  void _payLater() {
    // Pesanan sudah disimpan saat checkout. Kembali tanpa membuat transaksi baru.
    Navigator.pop(context);
  }

  Widget _buildBottomAction() => SafeArea(
    top: false,
    child: Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE9ECE7))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton(
          onPressed: _payLater,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: primaryGreen),
            foregroundColor: darkGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            'Bayar Nanti',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    ),
  );

  String _formatPrice(int price) => price.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );
}
