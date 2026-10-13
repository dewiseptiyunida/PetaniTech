import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BankTransferPaymentScreen extends StatefulWidget {
  final String orderNumber;
  final int totalAmount;
  final String bankName;
  final String receiverName;
  final DateTime? orderCreatedAt;

  const BankTransferPaymentScreen({
    super.key,
    required this.orderNumber,
    required this.totalAmount,
    required this.bankName,
    required this.receiverName,
    this.orderCreatedAt,
  });

  @override
  State<BankTransferPaymentScreen> createState() =>
      _BankTransferPaymentScreenState();
}

class _BankTransferPaymentScreenState extends State<BankTransferPaymentScreen> {
  final Color primaryGreen = const Color(0xFF7CB35A);
  final Color lightGreen = const Color(0xFFE8F1E2);
  final Color darkGreen = const Color(0xFF5E963F);
  final Color bgGrey = const Color(0xFFF7F8F6);

  Timer? _timer;
  late final DateTime _paymentDeadline;
  int _secondsRemaining = 0;
  bool isCheckingStatus = false;

  @override
  void initState() {
    super.initState();
    _paymentDeadline = (widget.orderCreatedAt ?? DateTime.now()).add(
      const Duration(hours: 24),
    );
    _updateRemainingTime();
    if (_secondsRemaining > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(_updateRemainingTime);
        if (_secondsRemaining <= 0) _timer?.cancel();
      });
    }
  }

  void _updateRemainingTime() {
    final seconds = _paymentDeadline.difference(DateTime.now()).inSeconds;
    _secondsRemaining = seconds > 0 ? seconds : 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTimer {
    final hours = (_secondsRemaining ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((_secondsRemaining % 3600) ~/ 60).toString().padLeft(
      2,
      '0',
    );
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String get virtualAccountNumber {
    final prefix = switch (widget.bankName.toUpperCase()) {
      'BCA' => '8801',
      'MANDIRI' => '8902',
      'BRI' => '8803',
      'BNI' => '8804',
      _ => '8800',
    };
    return '$prefix 0812 3456 7890';
  }

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final time =
        '${deadline.hour.toString().padLeft(2, '0')}:${deadline.minute.toString().padLeft(2, '0')}';

    if (deadline.year == now.year &&
        deadline.month == now.month &&
        deadline.day == now.day) {
      return 'Hari ini, $time';
    }

    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    if (deadline.year == tomorrow.year &&
        deadline.month == tomorrow.month &&
        deadline.day == tomorrow.day) {
      return 'Besok, $time';
    }

    return '${deadline.day.toString().padLeft(2, '0')}/'
        '${deadline.month.toString().padLeft(2, '0')}/'
        '${deadline.year}, $time';
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text.replaceAll(' ', '')));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: darkGreen, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$label berhasil disalin',
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: lightGreen,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          elevation: 0,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: primaryGreen.withValues(alpha: 0.3)),
          ),
        ),
      );
  }

  void _simulateCheckPayment() {
    setState(() => isCheckingStatus = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => isCheckingStatus = false);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (ctx) => Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: lightGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: darkGreen,
                        size: 42,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Pembayaran Terverifikasi!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pembayaran Virtual Account Bank ${widget.bankName} telah berhasil kami terima.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE9ECE5)),
                      ),
                      child: Column(
                        children: [
                          _dialogRow('No. Pesanan', widget.orderNumber),
                          const SizedBox(height: 6),
                          _dialogRow(
                            'Total Dibayar',
                            'Rp ${_formatPrice(widget.totalAmount)}',
                          ),
                          const SizedBox(height: 6),
                          _dialogRow('Status', 'Sedang Diproses'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.pop(context, true);
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
                          'Lihat Pesanan Saya',
                          style: TextStyle(
                            fontSize: 13.5,
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
    });
  }

  Widget _dialogRow(String label, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
      ),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.end,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          onPressed: () => Navigator.pop(context, true),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
            size: 19,
          ),
        ),
        title: const Text(
          'Pembayaran Transfer Bank',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
        children: [
          _buildCountdownCard(),
          const SizedBox(height: 14),
          _buildTotalPaymentCard(),
          const SizedBox(height: 14),
          _buildVirtualAccountCard(),
          const SizedBox(height: 14),
          _buildTransferInstructions(),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(),
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
          child: Icon(Icons.timer_outlined, color: darkGreen, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selesaikan Pembayaran Dalam',
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
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: darkGreen,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Jatuh tempo: ${_formatDeadline(_paymentDeadline)} WIB',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildTotalPaymentCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFEDEFEB)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Pembayaran',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            InkWell(
              onTap:
                  () => _copyToClipboard(
                    widget.totalAmount.toString(),
                    'Jumlah Pembayaran',
                  ),
              child: Row(
                children: [
                  Icon(Icons.copy_rounded, color: darkGreen, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Salin',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: darkGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Rp ${_formatPrice(widget.totalAmount)}',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: darkGreen,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'No. Pesanan: ${widget.orderNumber}',
          style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
        ),
      ],
    ),
  );

  Widget _buildVirtualAccountCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFEDEFEB)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.account_balance_rounded,
                color: darkGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bank ${widget.bankName.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const Text(
                    'Virtual Account (Dicek Otomatis)',
                    style: TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Divider(height: 22, thickness: 0.8),
        const Text(
          'Nomor Virtual Account',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                virtualAccountNumber,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed:
                  () => _copyToClipboard(
                    virtualAccountNumber,
                    'Nomor Virtual Account',
                  ),
              icon: const Icon(Icons.copy_rounded, size: 14),
              label: const Text('Salin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: lightGreen,
                foregroundColor: darkGreen,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Nama Rekening: PetaniTech / ${widget.receiverName}',
          style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
        ),
      ],
    ),
  );

  Widget _buildTransferInstructions() {
    final bank = widget.bankName.toUpperCase();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEFEB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: darkGreen, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Petunjuk Pembayaran',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          _instructionTile('m-Banking ($bank Mobile)', [
            'Buka aplikasi mobile banking $bank Anda dan login.',
            'Pilih menu Transfer > Virtual Account.',
            'Masukkan nomor Virtual Account: $virtualAccountNumber.',
            'Pastikan nama penerima dan tagihan Rp ${_formatPrice(widget.totalAmount)} sesuai.',
            'Masukkan PIN transaksi Anda untuk menyelesaikan pembayaran.',
          ], expanded: true),
          _instructionTile('ATM $bank', [
            'Masukkan kartu ATM $bank dan PIN Anda.',
            'Pilih menu Transaksi Lainnya > Pembayaran > Virtual Account.',
            'Masukkan nomor Virtual Account: $virtualAccountNumber.',
            'Periksa informasi konfirmasi tagihan.',
            'Tekan "Ya" untuk memproses pembayaran.',
          ]),
          _instructionTile('Internet Banking $bank', [
            'Login ke portal Internet Banking $bank.',
            'Pilih menu Pembayaran Tagihan > Virtual Account.',
            'Masukkan nomor Virtual Account dan konfirmasi token.',
          ]),
        ],
      ),
    );
  }

  Widget _instructionTile(
    String title,
    List<String> steps, {
    bool expanded = false,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: expanded,
        title: Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Column(
              children: [
                for (var i = 0; i < steps.length; i++)
                  _stepItem('${i + 1}', steps[i]),
              ],
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildBottomActions() => SafeArea(
    top: false,
    child: Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE9ECE7), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context, true),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Bayar Nanti',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: isCheckingStatus ? null : _simulateCheckPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child:
                  isCheckingStatus
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Text(
                        'Cek Status',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
            ),
          ),
        ],
      ),
    ),
  );

  String _formatPrice(int price) => price.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );
}
