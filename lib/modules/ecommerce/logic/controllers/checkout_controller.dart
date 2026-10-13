import 'package:flutter/material.dart';
import '../models/checkout_models.dart';

class CheckoutController extends ChangeNotifier {
  final List<CheckoutItemModel> _checkoutItems = [];
  final List<AddressModel> _addresses = [
    const AddressModel(
      id: '1',
      label: 'Rumah',
      isDefault: true,
      receiver: 'Budi Santoso',
      phone: '(+62) 812-3456-7890',
      fullAddress:
          'Jl. Raya Pertanian No. 45, Desa Sukamaju, Kec. Ciawi, Kabupaten Bogor, Jawa Barat 16720',
    ),
    const AddressModel(
      id: '2',
      label: 'Kebun / Ladang',
      isDefault: false,
      receiver: 'Budi Santoso (Kebun)',
      phone: '(+62) 812-3456-7890',
      fullAddress:
          'Blok Tani Makmur RT 03/RW 02, Desa Pasir Putih, Kec. Megamendung, Bogor, Jawa Barat 16770',
    ),
    const AddressModel(
      id: '3',
      label: 'Gudang Petani',
      isDefault: false,
      receiver: 'Pak Slamet (Gudang)',
      phone: '(+62) 857-1234-5678',
      fullAddress:
          'Komplek Pergudangan Agro No. 12, Jl. Pajajaran Raya, Kota Bogor, Jawa Barat 16143',
    ),
  ];

  int _selectedAddressIndex = 0;

  final List<CourierModel> _couriers = const [
    CourierModel(
      name: 'J&T Express',
      service: 'Reguler (EZ)',
      price: 9000,
      estimate: '2–3 hari',
      icon: Icons.local_shipping_rounded,
    ),
    CourierModel(
      name: 'JNE Reguler',
      service: 'Reguler (REG)',
      price: 10000,
      estimate: '2–4 hari',
      icon: Icons.inventory_2_outlined,
    ),
    CourierModel(
      name: 'SiCepat Ekspres',
      service: 'Reguler (SIUNT)',
      price: 11000,
      estimate: '2–3 hari',
      icon: Icons.electric_bolt_rounded,
    ),
    CourierModel(
      name: 'Anteraja',
      service: 'Reguler',
      price: 9500,
      estimate: '3–4 hari',
      icon: Icons.delivery_dining_rounded,
    ),
  ];

  int _selectedCourierIndex = 0;

  String _selectedPaymentType = 'bank';
  String _selectedBank = 'BCA';

  final List<BankModel> _bankList = const [
    BankModel(name: 'Bank BCA', code: 'BCA', desc: 'Virtual Account'),
    BankModel(
      name: 'Bank Mandiri',
      code: 'Mandiri',
      desc: 'Mandiri Bill Payment',
    ),
    BankModel(name: 'Bank BRI', code: 'BRI', desc: 'BRIVA'),
    BankModel(name: 'Bank BNI', code: 'BNI', desc: 'Virtual Account'),
  ];

  String _note = '';
  late final DateTime orderCreatedAt;

  CheckoutController({
    Map<String, dynamic>? product,
    int? quantity,
    List<Map<String, dynamic>>? items,
  }) {
    orderCreatedAt = DateTime.now();

    if (items != null && items.isNotEmpty) {
      _checkoutItems.addAll(items.map(CheckoutItemModel.fromMap));
    } else if (product != null) {
      final itemMap = Map<String, dynamic>.from(product);
      itemMap['quantity'] = quantity ?? 1;
      _checkoutItems.add(CheckoutItemModel.fromMap(itemMap));
    }
  }

  // Getters
  List<CheckoutItemModel> get checkoutItems =>
      List.unmodifiable(_checkoutItems);
  List<AddressModel> get addresses => List.unmodifiable(_addresses);
  int get selectedAddressIndex => _selectedAddressIndex;
  AddressModel get currentAddress => _addresses[_selectedAddressIndex];

  List<CourierModel> get couriers => List.unmodifiable(_couriers);
  int get selectedCourierIndex => _selectedCourierIndex;
  CourierModel get currentCourier => _couriers[_selectedCourierIndex];

  String get selectedPaymentType => _selectedPaymentType;
  String get selectedBank => _selectedBank;
  List<BankModel> get bankList => List.unmodifiable(_bankList);
  String get note => _note;

  // Perhitungan Keuangan
  int get subtotalProducts =>
      _checkoutItems.fold(0, (sum, item) => sum + item.subtotal);

  int get totalQuantity =>
      _checkoutItems.fold(0, (sum, item) => sum + item.quantity);

  int get shippingCost => currentCourier.price;
  int get serviceFee => 1000;
  int get grandTotal => subtotalProducts + shippingCost + serviceFee;

  String get shopName =>
      _checkoutItems.isNotEmpty
          ? _checkoutItems.first.shopName
          : 'Tani Makmur Official Store';

  // Info Pembayaran Terpilih
  String get currentPaymentTitle => switch (_selectedPaymentType) {
    'cod' => 'COD (Bayar di Tempat)',
    'bank' => 'Transfer Bank ($_selectedBank)',
    'qris' => 'QRIS / E-Wallet',
    _ => 'Transfer Bank',
  };

  String get currentPaymentDesc => switch (_selectedPaymentType) {
    'cod' => 'Bayar tunai kepada kurir saat pesanan tiba',
    'bank' => 'Virtual Account Bank $_selectedBank',
    'qris' => 'Scan QRIS instan via GoPay, ShopeePay, DANA, BCA, dll.',
    _ => 'Metode Pembayaran',
  };

  IconData get currentPaymentIcon => switch (_selectedPaymentType) {
    'cod' => Icons.payments_rounded,
    'bank' => Icons.account_balance_rounded,
    'qris' => Icons.qr_code_scanner_rounded,
    _ => Icons.account_balance_wallet_outlined,
  };

  // Aksi
  void selectAddress(int index) {
    if (index >= 0 && index < _addresses.length) {
      _selectedAddressIndex = index;
      notifyListeners();
    }
  }

  void addAddress(AddressModel address) {
    _addresses.add(address);
    _selectedAddressIndex = _addresses.length - 1;
    notifyListeners();
  }

  void updateAddress(int index, AddressModel address) {
    if (index >= 0 && index < _addresses.length) {
      _addresses[index] = address;
      notifyListeners();
    }
  }

  void selectCourier(int index) {
    if (index >= 0 && index < _couriers.length) {
      _selectedCourierIndex = index;
      notifyListeners();
    }
  }

  void setPaymentMethod({required String paymentType, String? bank}) {
    _selectedPaymentType = paymentType;
    if (bank != null) {
      _selectedBank = bank;
    }
    notifyListeners();
  }

  void setNote(String newNote) {
    _note = newNote;
    notifyListeners();
  }

  String generateOrderNumber() {
    return 'PT-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
  }

  String formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }
}
