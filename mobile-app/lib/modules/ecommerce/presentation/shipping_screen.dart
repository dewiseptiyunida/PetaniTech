import 'package:flutter/material.dart';

class ShippingScreen extends StatefulWidget {
  const ShippingScreen({super.key});

  @override
  State<ShippingScreen> createState() => _ShippingScreenState();
}

class _ShippingScreenState extends State<ShippingScreen> {
  final Color primaryGreen = const Color(0xFF7CB35A);
  final Color lightGreen = const Color(0xFFE8F1E2);
  final Color darkGreen = const Color(0xFF5E963F);

  int selectedIndex = 0;

  final List<Map<String, dynamic>> shippingOptions = [
    {
      'name': 'JNE',
      'service': 'REG',
      'description': 'Reguler',
      'price': 10000,
      'estimate': '2–3 hari',
      'icon': Icons.local_shipping_outlined,
    },
    {
      'name': 'J&T',
      'service': 'EZ',
      'description': 'Reguler',
      'price': 9000,
      'estimate': '2–3 hari',
      'icon': Icons.inventory_2_outlined,
    },
    {
      'name': 'SiCepat',
      'service': 'REG',
      'description': 'Reguler',
      'price': 11000,
      'estimate': '2–4 hari',
      'icon': Icons.local_shipping_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
        ),
        title: const Text(
          'Pilih Pengiriman',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: _confirmButton(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
        children: [
          _addressCard(),
          const SizedBox(height: 14),
          _sectionHeader(),
          const SizedBox(height: 8),
          ...List.generate(
            shippingOptions.length,
            (index) => _shippingCard(index, shippingOptions[index]),
          ),
        ],
      ),
    );
  }

  Widget _addressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDEFEB)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.location_on_rounded, color: darkGreen, size: 23),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dikirim dari',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Indramayu, Jawa Barat',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(4, 4, 4, 0),
      child: Text(
        'Pilih jasa pengiriman',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _shippingCard(int index, Map<String, dynamic> option) {
    final bool selected = selectedIndex == index;
    final int price = option['price'] as int;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: selected ? primaryGreen : const Color(0xFFE6EAE3),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: primaryGreen.withOpacity(.10),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: selected ? lightGreen : const Color(0xFFF5F6F4),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                option['icon'] as IconData,
                color: selected ? darkGreen : Colors.grey.shade600,
                size: 23,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        option['name'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: lightGreen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          option['service'] as String,
                          style: TextStyle(
                            color: darkGreen,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${option['description']} • ${option['estimate']}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Rp ${_formatPrice(price)}',
                    style: TextStyle(
                      color: darkGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? primaryGreen : Colors.grey.shade400,
                  width: 1.5,
                ),
                color: selected ? primaryGreen : Colors.transparent,
              ),
              child:
                  selected
                      ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 15,
                      )
                      : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _confirmButton() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFE9ECE7))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.07),
              blurRadius: 16,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              final selected = shippingOptions[selectedIndex];
              Navigator.pop(context, selected);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Konfirmasi Pengiriman',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }
}
