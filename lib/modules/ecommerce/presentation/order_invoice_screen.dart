import 'package:flutter/material.dart';
import '../logic/models/order_model.dart';

class OrderInvoiceScreen extends StatelessWidget {
  final OrderModel order;

  const OrderInvoiceScreen({super.key, required this.order});

  static const Color _darkGreen = Color(0xFF5E963F);
  static const Color _lightGreen = Color(0xFFE8F1E2);
  static const Color _canvasGrey = Color(0xFFECEFEA);
  static const Color _tableBorder = Color(0xFFD6DDD1);

  String _rupiah(int value) =>
      'Rp${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  Widget build(BuildContext context) {
    final totalQty =
        order.items.fold(0, (sum, item) => sum + item.quantity);

    return Scaffold(
      backgroundColor: _canvasGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              // ── 1. LOGO PETANITECH (Tema Aplikasi) ────────────
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _lightGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.eco_rounded,
                            color: _darkGreen,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'PetaniTech',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: _darkGreen,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ── 2. JUDUL NOTA ─────────────────────────────────
              const Text(
                'Nota Pesanan',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // ── 3. METADATA PEMBELI & PENJUAL ─────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: Colors.black87,
                          height: 1.35,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Nama Pembeli: ',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(text: order.receiver),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: Colors.black87,
                          height: 1.35,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Nama Penjual: ',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(text: order.shopName),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Alamat Pembeli
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Colors.black87,
                    height: 1.35,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Alamat Pembeli:\n',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(text: order.shippingAddress),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // No. Handphone Pembeli
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Colors.black87,
                    height: 1.35,
                  ),
                  children: [
                    const TextSpan(
                      text: 'No. Handphone Pembeli: ',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(text: order.phone),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ── 4. INFORMASI TRANSAKSI 4 KOLOM ────────────────
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: _buildColumnInfo('No. Pesanan', order.id),
                    ),
                    Expanded(
                      flex: 3,
                      child: _buildColumnInfo(
                        'Tanggal Transaksi',
                        _formatDate(order.createdAt),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: _buildColumnInfo(
                        'Metode Pembayaran',
                        order.paymentMethod,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: _buildColumnInfo(
                        'Jasa Kirim',
                        '${order.courier} ${order.courierService}'.trim(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ── 5. RINCIAN PESANAN (TABEL) ────────────────────
              const Text(
                'Rincian Pesanan',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              const Divider(height: 1, thickness: 1, color: _tableBorder),
              const SizedBox(height: 4),

              // Header Tabel
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: const [
                    SizedBox(
                      width: 22,
                      child: Text(
                        'No.',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text(
                        'Produk',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Variasi',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Harga Produk',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Kuantitas',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Subtotal',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: _tableBorder),

              // Item Tabel
              ...order.items.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final item = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 22,
                        child: Text(
                          '$index',
                          style: const TextStyle(
                            fontSize: 9.5,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Text(
                          item.productName,
                          style: const TextStyle(
                            fontSize: 9.5,
                            color: Colors.black87,
                            height: 1.25,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          (item.variant != null && item.variant!.isNotEmpty)
                              ? item.variant!
                              : '-',
                          style: const TextStyle(
                            fontSize: 9.5,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          _rupiah(item.price),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 9.5,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${item.quantity}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 9.5,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          _rupiah(item.subtotal),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 9.5,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const Divider(height: 1, thickness: 1, color: _tableBorder),
              const SizedBox(height: 12),

              // ── 6. SUBTOTAL & TOTAL KUANTITAS (Rata Kanan) ───
              Align(
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Subtotal  ',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          _rupiah(order.productTotal),
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Total Kuantitas (Aktif) $totalQty produk',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── 7. RINCIAN HARGA / BREAKDOWN (Rata Kanan) ────
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 260,
                  child: Column(
                    children: [
                      _buildSummaryRow(
                        'Subtotal Pesanan',
                        _rupiah(order.productTotal),
                      ),
                      if (order.shippingCost > 0)
                        _buildSummaryRow(
                          'Biaya Pengiriman',
                          _rupiah(order.shippingCost),
                        ),
                      if (order.serviceFee > 0)
                        _buildSummaryRow(
                          'Biaya Layanan',
                          _rupiah(order.serviceFee),
                        ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Pembayaran',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            _rupiah(order.total),
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              color: _darkGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── 8. KETERANGAN PPN ─────────────────────────────
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Biaya-biaya yang ditagihkan oleh PetaniTech (jika ada)\nsudah termasuk PPN',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.black87,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: 50),

              // ── 9. FOOTER END OF RECEIPT ──────────────────────
              Center(
                child: Column(
                  children: const [
                    Text(
                      '1 of 1',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'End of receipt',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                '← Kembali ke Pesanan',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _darkGreen,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    ),
  ),
),
);
}

  // ── HELPER WIDGETS ───────────────────────────────────────────

  Widget _buildColumnInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value.isNotEmpty ? value : '-',
          style: const TextStyle(
            fontSize: 9.5,
            color: Colors.black87,
            height: 1.25,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
