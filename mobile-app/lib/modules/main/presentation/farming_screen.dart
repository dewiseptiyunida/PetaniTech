import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:petanitech_mobile/core/app_module.dart';
import 'package:petanitech_mobile/core/app_theme.dart';
import 'package:petanitech_mobile/modules/farm/farm_module.dart';
import 'package:petanitech_mobile/modules/main/main_module.dart';
import 'package:petanitech_mobile/modules/monitoring/monitoring_module.dart';
import 'package:petanitech_mobile/utils/weather/weather_service.dart';

class FarmingScreen extends StatefulWidget {
  const FarmingScreen({super.key});

  @override
  State<FarmingScreen> createState() => _FarmingScreenState();
}

class _FarmingScreenState extends State<FarmingScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _deepPanel(),
            Stack(
              children: [
                Container(height: 32.0, color: AppTheme.accentColor),
                _buttonPanel(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherPredictionPanel extends StatefulWidget {
  @override
  __WeatherPredictionPanelState createState() =>
      __WeatherPredictionPanelState();
}

class __WeatherPredictionPanelState extends State<_WeatherPredictionPanel> {
  int _daysAhead = 7;
  bool _loading = false;
  List<double>? _data;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final all = await WeatherService.getForecast();
      setState(() {
        _data = all.take(_daysAhead).toList();
      });
    } catch (e) {
      print('Error fetching forecast: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Prediksi Cuaca',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children:
                [1, 7, 14, 30].map((d) {
                  return ChoiceChip(
                    label: Text('$d hari'),
                    selected: _daysAhead == d,
                    onSelected: (_) {
                      setState(() => _daysAhead = d);
                      _fetch();
                    },
                  );
                }).toList(),
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_data == null || _data!.isEmpty)
            const Text('Tidak ada data.')
          else
            _buildList(),
        ],
      ),
    );
  }

  Widget _buildList() {
    final today = DateTime.now();
    final maxRain = _data!.reduce((a, b) => a > b ? a : b);
    final totalRain = _data!.reduce((a, b) => a + b);

    String advice;
    if (maxRain == 0) {
      advice = 'Cuaca cerah, cocok untuk penyemprotan pestisida dan panen.';
    } else if (maxRain < 2) {
      advice = 'Hujan ringan, baik untuk pemupukan.';
    } else if (maxRain < 5) {
      advice = 'Hujan sedang, pastikan sistem drainase bekerja baik.';
    } else {
      advice = 'Hujan lebat, hindari aktivitas berat di lahan.';
    }

    final tiles = List.generate(_data!.length, (i) {
      final date = today.add(Duration(days: i + 1));
      final mm = _data![i];
      final icon = _getIcon(mm);
      final label = _getLabel(mm);
      final formatter = DateFormat('EEEE, dd MMM', 'id');

      return ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(formatter.format(date)),
        subtitle: Text('$label (${mm.toStringAsFixed(1)} mm)'),
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...tiles,
        const SizedBox(height: 12),
        Divider(),
        Text(
          'Total curah hujan $_daysAhead hari: ${totalRain.toStringAsFixed(1)} mm',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Saran: $advice',
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  IconData _getIcon(double mm) {
    if (mm == 0) return Icons.wb_sunny;
    if (mm < 2) return Icons.cloud;
    if (mm < 5) return Icons.cloud_queue;
    return Icons.thunderstorm;
  }

  String _getLabel(double mm) {
    if (mm == 0) return 'Cerah';
    if (mm < 2) return 'Hujan ringan';
    if (mm < 5) return 'Hujan sedang';
    return 'Hujan lebat';
  }
}

Widget _deepPanel() {
  final List<String> items = [
    'Lahan Padi',
    'Lahan Jagung',
    'Lahan Gandum',
    'Lahan Kedelai',
    'Lahan Kentang',
    'Lahan Tomat',
    'Lahan Cabai',
    'Lahan Terong',
  ];

  return Container(
    color: AppTheme.accentColor,
    padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Lahan".tr(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        DropdownSearch(items: items, onChanged: (item) {}),
        const SizedBox(height: 16),
        _gridCardPanel(),
      ],
    ),
  );
}

Widget _gridCardPanel() {
  return SizedBox(
    width: double.infinity,
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _itemGridCardPanel(
                Icon(Icons.calculate, color: Colors.green, size: 16),
                Colors.green,
                "Hasil Panen (Est)",
                "102.000 Kg",
                "2",
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _itemGridCardPanel(
                Icon(Icons.health_and_safety, color: Colors.red, size: 16),
                Colors.red,
                "Total Pupuk (Est)",
                "100 Kg",
                "2",
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _itemGridCardPanel(
                Icon(Icons.wallet, color: Colors.orange, size: 16),
                Colors.orange,
                "Biaya (Est)",
                "5,1 JT",
                "2",
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _itemGridCardPanel(
                Icon(
                  Icons.shopping_cart_checkout,
                  color: Colors.blue,
                  size: 16,
                ),
                Colors.blue,
                "Harga Jual (Est)",
                "68 JT",
                "2",
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _itemGridCardPanel(
  Icon icon,
  Color color,
  String title,
  String value,
  String farm,
) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    height: 120,
    padding: const EdgeInsets.all(10),
    child: Column(
      children: [
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: color.withAlpha(100),
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.all(2),
              child: icon,
            ),
            const SizedBox(width: 5),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
        Expanded(
          child: Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "dari $farm lahan aktif",
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    ),
  );
}

Widget _buttonPanel() {
  return Builder(
    builder: (context) {
      return Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 16.0),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(100)),
                color: Colors.grey.withAlpha(50),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _menuItem("Lahan", Icons.grid_3x3, () {
                    Modular.to.pushNamed(
                      AppModule.areaRoute + FarmModule.indexRoute,
                    );
                  }),
                  _menuItem("Device", Icons.device_hub, () {}),
                  _menuItem("Monitoring", Icons.bar_chart, () {
                    Modular.to.pushNamed(
                      AppModule.monitoringRoute + MonitoringModule.indexRoute,
                    );
                  }),
                  _menuItem("Penyakit", Icons.healing, () {}),
                  _menuItem("Keuangan", Icons.wallet_rounded, () {}),
                  _menuItem("Jual Beli", Icons.handshake, () {}),
                  _menuItem("Prediksi Cuaca", Icons.cloud, () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor:
                          Colors
                              .transparent, // biar bisa kasih latar bulat atas
                      builder:
                          (context) => DraggableScrollableSheet(
                            expand: false,
                            initialChildSize: 0.65,
                            minChildSize: 0.4,
                            maxChildSize: 0.95,
                            builder: (context, scrollController) {
                              return Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(24),
                                  ),
                                ),
                                padding: EdgeInsets.only(
                                  top: 16,
                                  left: 16,
                                  right: 16,
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom +
                                      16,
                                ),
                                child: SingleChildScrollView(
                                  controller: scrollController,
                                  child: _WeatherPredictionPanel(),
                                ),
                              );
                            },
                          ),
                    );
                  }),
                  _menuItem("Tanya Ahli", Icons.question_answer, () {}),
                  _menuItem("Toko Tani", Icons.store, () {}),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      );
    },
  );
}

Widget _menuItem(String title, IconData icon, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppTheme.accentColor.withAlpha(30),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: AppTheme.accentColor),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(color: AppTheme.accentColor, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class DropdownSearch extends StatefulWidget {
  const DropdownSearch({
    super.key,
    required this.items,
    required this.onChanged,
  });

  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  State<DropdownSearch> createState() => _DropdownSearchState();
}

class _DropdownSearchState extends State<DropdownSearch> {
  late final TextEditingController _textEditingController;
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: const Text('Select Item', style: TextStyle(fontSize: 14)),
          items:
              widget.items
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item, style: const TextStyle(fontSize: 14)),
                    ),
                  )
                  .toList(),
          value: _selectedValue,
          onChanged: (value) {
            setState(() => _selectedValue = value);
            widget.onChanged(value);
          },
          buttonStyleData: const ButtonStyleData(
            padding: EdgeInsets.symmetric(horizontal: 16),
            height: 40,
            width: 200,
          ),
          dropdownStyleData: const DropdownStyleData(maxHeight: 200),
          menuItemStyleData: const MenuItemStyleData(height: 40),
          dropdownSearchData: DropdownSearchData(
            searchController: _textEditingController,
            searchInnerWidgetHeight: 50,
            searchInnerWidget: Container(
              height: 50,
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 4,
                right: 8,
                left: 8,
              ),
              child: TextFormField(
                expands: true,
                maxLines: null,
                controller: _textEditingController,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  hintText: 'Search for an item...',
                  hintStyle: const TextStyle(fontSize: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            searchMatchFn:
                (item, searchValue) =>
                    item.value.toString().contains(searchValue),
          ),
          onMenuStateChange: (isOpen) {
            if (!isOpen) _textEditingController.clear();
          },
        ),
      ),
    );
  }
}
