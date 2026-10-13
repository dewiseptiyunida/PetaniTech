import 'package:flutter/material.dart';
import '../controllers/checkout_controller.dart';
import '../models/checkout_models.dart';
import 'payment/bank_transfer_payment_screen.dart';
import 'payment/qris_payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<String, dynamic>? product;
  final int? quantity;
  final List<Map<String, dynamic>>? items;

  const CheckoutScreen({super.key, this.product, this.quantity, this.items});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final Color primaryGreen = const Color(0xFF7CB35A);
  final Color lightGreen = const Color(0xFFE8F1E2);
  final Color darkGreen = const Color(0xFF5E963F);
  final Color bgGrey = const Color(0xFFF7F8F6);
  final Color borderGrey = const Color(0xFFEDEFEB);

  late final CheckoutController _controller;
  late final TextEditingController noteController;

  @override
  void initState() {
    super.initState();
    _controller = CheckoutController(
      product: widget.product,
      quantity: widget.quantity,
      items: widget.items,
    );
    _controller.addListener(_onControllerUpdate);
    noteController = TextEditingController();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    noteController.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: bgGrey,
    appBar: _buildAppBar(),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
      children: [
        _buildAddressSection(),
        const SizedBox(height: 12),
        _buildStoreAndProductSection(),
        const SizedBox(height: 12),
        _buildShippingSection(),
        const SizedBox(height: 12),
        _buildNoteSection(),
        const SizedBox(height: 12),
        _buildPaymentSection(),
        const SizedBox(height: 12),
        _buildPaymentSummarySection(),
      ],
    ),
    bottomNavigationBar: _buildBottomCheckoutBar(),
  );

  PreferredSizeWidget _buildAppBar() => AppBar(
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
    title: const Text(
      'Checkout Pembelian',
      style: TextStyle(
        color: Colors.black87,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    ),
    centerTitle: true,
  );

  Widget _card({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(14),
  }) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: borderGrey),
    ),
    child: child,
  );

  Widget _sectionTitle(
    IconData icon,
    String title, {
    String? action,
    VoidCallback? onAction,
  }) => Row(
    children: [
      Icon(icon, color: darkGreen, size: 19),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
      ),
      if (action != null)
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            foregroundColor: darkGreen,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            action,
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
          ),
        ),
    ],
  );

  // ============================================================
  // BAGIAN ALAMAT
  // ============================================================

  Widget _buildAddressSection() {
    final addr = _controller.currentAddress;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGrey),
      ),
      child: Column(
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, color: darkGreen, size: 19),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Alamat Pengiriman',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: lightGreen,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        addr.label,
                        style: TextStyle(
                          color: darkGreen,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: _showAddressListBottomSheet,
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 5,
                        ),
                        child: Text(
                          'Ubah',
                          style: TextStyle(
                            color: darkGreen,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '${addr.receiver} | ${addr.phone}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  addr.fullAddress,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BAGIAN TOKO & PRODUK
  // ============================================================

  Widget _buildStoreAndProductSection() => _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.storefront_rounded, color: darkGreen, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                _controller.shopName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const Divider(height: 20),
        if (_controller.checkoutItems.isEmpty)
          const Text('Belum ada produk untuk checkout.')
        else
          ...List.generate(_controller.checkoutItems.length, (index) {
            final item = _controller.checkoutItems[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < _controller.checkoutItems.length - 1 ? 12 : 0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: lightGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, color: darkGreen, size: 34),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Kategori: ${item.category}',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Rp ${_controller.formatPrice(item.price)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: darkGreen,
                              ),
                            ),
                            Text(
                              '${item.quantity} pcs',
                              style: const TextStyle(
                                fontSize: 11,
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
            );
          }),
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 10),
        _summaryRow(
          'Subtotal (${_controller.totalQuantity} Produk)',
          'Rp ${_controller.formatPrice(_controller.subtotalProducts)}',
        ),
      ],
    ),
  );

  // ============================================================
  // BAGIAN PENGIRIMAN
  // ============================================================

  Widget _buildShippingSection() {
    final courier = _controller.currentCourier;
    return _card(
      child: Column(
        children: [
          _sectionTitle(
            Icons.local_shipping_outlined,
            'Opsi Pengiriman',
            action: 'Pilih Kurir',
            onAction: _showCourierPickerBottomSheet,
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: _showCourierPickerBottomSheet,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: lightGreen.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryGreen.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  Icon(courier.icon, color: darkGreen, size: 23),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${courier.name} • ${courier.service}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Estimasi tiba: ${courier.estimate}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Rp ${_controller.formatPrice(_controller.shippingCost)}',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: darkGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BAGIAN PESAN / CATATAN
  // ============================================================

  Widget _buildNoteSection() => _card(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    child: Row(
      children: [
        Icon(Icons.chat_outlined, color: darkGreen, size: 18),
        const SizedBox(width: 10),
        const Text(
          'Pesan:',
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: noteController,
            onChanged: (val) => _controller.setNote(val),
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Tinggalkan catatan untuk penjual...',
              hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    ),
  );

  // ============================================================
  // BAGIAN METODE PEMBAYARAN
  // ============================================================

  Widget _buildPaymentSection() => _card(
    child: Column(
      children: [
        _sectionTitle(
          Icons.account_balance_wallet_outlined,
          'Metode Pembayaran',
          action: 'Ubah Metode',
          onAction: _showPaymentPickerBottomSheet,
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: _showPaymentPickerBottomSheet,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAF8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E8E2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: lightGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _controller.currentPaymentIcon,
                    color: darkGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _controller.currentPaymentTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _controller.currentPaymentDesc,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  // ============================================================
  // BAGIAN RINCIAN BIAYA
  // ============================================================

  Widget _buildPaymentSummarySection() => _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(Icons.receipt_long_rounded, 'Rincian Pembayaran'),
        const SizedBox(height: 12),
        _summaryRow(
          'Subtotal Produk',
          'Rp ${_controller.formatPrice(_controller.subtotalProducts)}',
        ),
        const SizedBox(height: 6),
        _summaryRow(
          'Ongkos Kirim (${_controller.currentCourier.name})',
          'Rp ${_controller.formatPrice(_controller.shippingCost)}',
        ),
        const SizedBox(height: 6),
        _summaryRow(
          'Biaya Layanan Aplikasi',
          'Rp ${_controller.formatPrice(_controller.serviceFee)}',
        ),
        const Divider(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Pembayaran',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
            ),
            Text(
              'Rp ${_controller.formatPrice(_controller.grandTotal)}',
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w900,
                color: darkGreen,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _summaryRow(String label, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Text(
          label,
          style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        value,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ],
  );

  // ============================================================
  // BOTTOM BAR CHECKOUT
  // ============================================================

  Widget _buildBottomCheckoutBar() => SafeArea(
    top: false,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE9ECE7))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Pembayaran',
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
                const SizedBox(height: 2),
                Text(
                  'Rp ${_controller.formatPrice(_controller.grandTotal)}',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                    color: darkGreen,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed:
                  _controller.checkoutItems.isEmpty ? null : _handlePlaceOrder,
              icon: const Icon(Icons.shopping_bag_rounded, size: 18),
              label: const Text(
                'Buat Pesanan',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  // ============================================================
  // BOTTOM SHEETS
  // ============================================================

  void _showAddressListBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder:
          (sheetContext) => SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.72,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Column(
                  children: [
                    _sheetHeader(
                      'Pilih Alamat Pengiriman',
                      () => Navigator.pop(sheetContext),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _controller.addresses.length,
                        itemBuilder: (context, index) {
                          final address = _controller.addresses[index];
                          final selected =
                              _controller.selectedAddressIndex == index;
                          return Card(
                            elevation: 0,
                            color:
                                selected
                                    ? lightGreen.withValues(alpha: 0.4)
                                    : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: selected ? primaryGreen : borderGrey,
                              ),
                            ),
                            child: ListTile(
                              onTap: () {
                                _controller.selectAddress(index);
                                Navigator.pop(sheetContext);
                              },
                              leading: Icon(
                                selected
                                    ? Icons.check_circle
                                    : Icons.location_on_outlined,
                                color: selected ? darkGreen : Colors.grey,
                              ),
                              title: Text(
                                '${address.label}${address.isDefault ? ' • Utama' : ''}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              subtitle: Text(
                                '${address.receiver} (${address.phone})\n${address.fullAddress}',
                                style: const TextStyle(fontSize: 11),
                              ),
                              isThreeLine: true,
                              trailing: IconButton(
                                onPressed: () {
                                  Navigator.pop(sheetContext);
                                  _showEditAddressBottomSheet(
                                    addressIndex: index,
                                  );
                                },
                                icon: Icon(
                                  Icons.edit_outlined,
                                  color: darkGreen,
                                  size: 19,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          _showEditAddressBottomSheet();
                        },
                        icon: Icon(
                          Icons.add_location_alt_rounded,
                          color: darkGreen,
                        ),
                        label: Text(
                          'Tambah Alamat Baru',
                          style: TextStyle(
                            color: darkGreen,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _sheetHeader(String title, VoidCallback onClose) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      IconButton(onPressed: onClose, icon: const Icon(Icons.close_rounded)),
    ],
  );

  void _showEditAddressBottomSheet({int? addressIndex}) {
    final isEdit = addressIndex != null;
    final AddressModel? existing =
        isEdit ? _controller.addresses[addressIndex] : null;

    final label = TextEditingController(text: existing?.label ?? '');
    final receiver = TextEditingController(text: existing?.receiver ?? '');
    final phone = TextEditingController(text: existing?.phone ?? '');
    final fullAddress = TextEditingController(
      text: existing?.fullAddress ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder:
          (sheetContext) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _sheetHeader(
                      isEdit ? 'Edit Alamat Pengiriman' : 'Tambah Alamat Baru',
                      () => Navigator.pop(sheetContext),
                    ),
                    const Divider(),
                    _buildFormField(
                      'Label Alamat',
                      label,
                      'Rumah / Kebun / Kantor',
                    ),
                    _buildFormField('Nama Penerima', receiver, 'Nama lengkap'),
                    _buildFormField(
                      'Nomor Telepon / WhatsApp',
                      phone,
                      '(+62) 8...',
                      keyboardType: TextInputType.phone,
                    ),
                    _buildFormField(
                      'Alamat Lengkap',
                      fullAddress,
                      'Jalan, RT/RW, Desa, Kecamatan, Kabupaten/Kota',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          if (receiver.text.trim().isEmpty ||
                              fullAddress.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Nama dan alamat wajib diisi'),
                              ),
                            );
                            return;
                          }

                          final newAddress = AddressModel(
                            id:
                                isEdit
                                    ? existing!.id
                                    : DateTime.now().millisecondsSinceEpoch
                                        .toString(),
                            label:
                                label.text.trim().isEmpty
                                    ? 'Alamat'
                                    : label.text.trim(),
                            receiver: receiver.text.trim(),
                            phone: phone.text.trim(),
                            fullAddress: fullAddress.text.trim(),
                            isDefault: isEdit ? existing!.isDefault : false,
                          );

                          if (isEdit) {
                            _controller.updateAddress(addressIndex, newAddress);
                          } else {
                            _controller.addAddress(newAddress);
                          }

                          Navigator.pop(sheetContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEdit
                                    ? 'Alamat berhasil diperbarui.'
                                    : 'Alamat baru berhasil ditambahkan.',
                              ),
                              backgroundColor: darkGreen,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          isEdit ? 'Simpan Perubahan' : 'Gunakan Alamat Ini',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 12.5),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            filled: true,
            fillColor: const Color(0xFFF7F8F5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: primaryGreen, width: 1.5),
            ),
          ),
        ),
      ],
    ),
  );

  void _showCourierPickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder:
          (sheetContext) => SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.62,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Column(
                  children: [
                    _sheetHeader(
                      'Pilih Opsi Pengiriman',
                      () => Navigator.pop(sheetContext),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _controller.couriers.length,
                        itemBuilder: (context, index) {
                          final courier = _controller.couriers[index];
                          final selected =
                              _controller.selectedCourierIndex == index;
                          return Card(
                            elevation: 0,
                            color:
                                selected
                                    ? lightGreen.withValues(alpha: 0.4)
                                    : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: selected ? primaryGreen : borderGrey,
                              ),
                            ),
                            child: ListTile(
                              onTap: () {
                                _controller.selectCourier(index);
                                Navigator.pop(sheetContext);
                              },
                              leading: Icon(courier.icon, color: darkGreen),
                              title: Text(
                                '${courier.name} - ${courier.service}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                'Estimasi ${courier.estimate}',
                                style: const TextStyle(fontSize: 11),
                              ),
                              trailing: Text(
                                'Rp ${_controller.formatPrice(courier.price)}',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: darkGreen,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  void _showPaymentPickerBottomSheet() {
    var tempType = _controller.selectedPaymentType;
    var tempBank = _controller.selectedBank;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder:
          (sheetContext) => StatefulBuilder(
            builder:
                (ctx, setModalState) => SafeArea(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.82,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
                          child: _sheetHeader(
                            'Pilih Metode Pembayaran',
                            () => Navigator.pop(sheetContext),
                          ),
                        ),
                        const Divider(),
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                            children: [
                              _buildPaymentOption(
                                type: 'cod',
                                icon: Icons.payments_rounded,
                                title: 'COD (Bayar di Tempat)',
                                desc:
                                    'Bayar tunai kepada kurir saat pesanan tiba',
                                tempType: tempType,
                                onTap:
                                    () => setModalState(() => tempType = 'cod'),
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap:
                                    () =>
                                        setModalState(() => tempType = 'bank'),
                                child: Container(
                                  padding: const EdgeInsets.all(13),
                                  decoration: BoxDecoration(
                                    color:
                                        tempType == 'bank'
                                            ? lightGreen.withValues(alpha: 0.45)
                                            : Colors.white,
                                    borderRadius: BorderRadius.circular(13),
                                    border: Border.all(
                                      color:
                                          tempType == 'bank'
                                              ? primaryGreen
                                              : borderGrey,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.account_balance_rounded,
                                            color: darkGreen,
                                          ),
                                          const SizedBox(width: 10),
                                          const Expanded(
                                            child: Text(
                                              'Transfer Bank',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                          if (tempType == 'bank')
                                            Icon(
                                              Icons.check_circle_rounded,
                                              color: darkGreen,
                                            ),
                                        ],
                                      ),
                                      if (tempType == 'bank') ...[
                                        const Divider(height: 20),
                                        const Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Pilih Bank:',
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ..._controller.bankList.map((bank) {
                                          final selected =
                                              tempBank == bank.code;
                                          return ListTile(
                                            dense: true,
                                            onTap:
                                                () => setModalState(
                                                  () => tempBank = bank.code,
                                                ),
                                            leading: Icon(
                                              Icons.account_balance_outlined,
                                              color:
                                                  selected
                                                      ? darkGreen
                                                      : Colors.grey,
                                            ),
                                            title: Text(
                                              bank.name,
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                fontWeight:
                                                    selected
                                                        ? FontWeight.w800
                                                        : FontWeight.w600,
                                              ),
                                            ),
                                            subtitle: Text(
                                              bank.desc,
                                              style: const TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                            trailing: Icon(
                                              selected
                                                  ? Icons.radio_button_checked
                                                  : Icons
                                                      .radio_button_unchecked,
                                              color:
                                                  selected
                                                      ? darkGreen
                                                      : Colors.grey,
                                            ),
                                          );
                                        }),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildPaymentOption(
                                type: 'qris',
                                icon: Icons.qr_code_scanner_rounded,
                                title: 'QRIS / E-Wallet',
                                desc:
                                    'Scan QRIS via GoPay, ShopeePay, DANA, OVO, dll.',
                                tempType: tempType,
                                onTap:
                                    () =>
                                        setModalState(() => tempType = 'qris'),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                _controller.setPaymentMethod(
                                  paymentType: tempType,
                                  bank: tempType == 'bank' ? tempBank : null,
                                );
                                Navigator.pop(sheetContext);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Konfirmasi Metode Pembayaran',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  Widget _buildPaymentOption({
    required String type,
    required IconData icon,
    required String title,
    required String desc,
    required String tempType,
    required VoidCallback onTap,
  }) {
    final selected = tempType == type;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected ? lightGreen.withValues(alpha: 0.45) : Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: selected ? primaryGreen : borderGrey),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? darkGreen : Colors.grey.shade600,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: darkGreen, size: 20),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PLACE ORDER
  // ============================================================

  void _handlePlaceOrder() {
    final orderNumber = _controller.generateOrderNumber();

    if (_controller.selectedPaymentType == 'cod') {
      _showCodSuccessDialog(orderNumber);
      return;
    }

    final Widget paymentScreen =
        _controller.selectedPaymentType == 'bank'
            ? BankTransferPaymentScreen(
              orderNumber: orderNumber,
              totalAmount: _controller.grandTotal,
              bankName: _controller.selectedBank,
              receiverName: _controller.currentAddress.receiver,
              orderCreatedAt: _controller.orderCreatedAt,
            )
            : QrisPaymentScreen(
              orderNumber: orderNumber,
              totalAmount: _controller.grandTotal,
            );

    Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => paymentScreen),
    ).then((result) {
      if (result == true && mounted) Navigator.pop(context, true);
    });
  }

  void _showCodSuccessDialog(String orderNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: lightGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: darkGreen,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pesanan Berhasil Dibuat!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No. Pesanan: $orderNumber',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: darkGreen,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: lightGreen.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: primaryGreen.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: darkGreen,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Bayar tunai kepada kurir saat pesanan tiba. Siapkan uang pas untuk memudahkan transaksi.',
                            style: TextStyle(fontSize: 11.5, height: 1.45),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _summaryRow(
                    'Total Bayar (COD)',
                    'Rp ${_controller.formatPrice(_controller.grandTotal)}',
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Kembali ke Belanja',
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
          ),
    );
  }
}
