// lib/modules/main/presentation/weather_forecast_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petanitech_mobile/utils/weather/weather_service.dart';

class WeatherForecastPage extends StatefulWidget {
  const WeatherForecastPage({Key? key}) : super(key: key);

  @override
  _WeatherForecastPageState createState() => _WeatherForecastPageState();
}

class _WeatherForecastPageState extends State<WeatherForecastPage> {
  List<double>? _predictions;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final p = await WeatherService.getForecast();
      setState(() => _predictions = p);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _predictions = [];
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Rule: Cerah (<1.0), Mendung (1.0..4.99), Hujan (>=5.0)
  Map<String, dynamic> _ruleFor(double mm) {
    if (mm < 1.0) {
      return {
        'icon': Icons.wb_sunny,
        'label': 'Cerah',
        'color': Colors.orange.shade700,
      };
    } else if (mm < 5.0) {
      return {
        'icon': Icons.cloud,
        'label': 'Mendung',
        'color': Colors.blueGrey,
      };
    } else {
      return {
        'icon': Icons.umbrella,
        'label': 'Hujan',
        'color': Colors.blue.shade700,
      };
    }
  }

  Widget _timeOfDayIcon(String label, double mm) {
    final rule = _ruleFor(mm);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 28,
          width: 28,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Icon(rule['icon'], color: rule['color']),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dayNameFmt = DateFormat.E('id');
    final dayNumFmt = DateFormat.d('id');
    final preds = _predictions ?? [];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Prediksi Cuaca',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: SafeArea(
        bottom: false,
        child:
            _loading
                ? const Center(child: CircularProgressIndicator())
                : (preds.isEmpty)
                ? Center(child: Text(_error ?? 'Tidak ada data prediksi.'))
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Aksi petani (header hijau)
                    Container(
                      color: Colors.green[800],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Tindakan Petani:',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '• Cerah : Pemberian pestisida atau panen',
                            style: TextStyle(color: Colors.white70),
                          ),
                          Text(
                            '• Mendung: Pantau hama dan kelembapan',
                            style: TextStyle(color: Colors.white70),
                          ),
                          Text(
                            '• Hujan  : Periksa drainase dan penutup tanah',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),

                    // Header "Cuaca Hari Ini" (background putih) + right-side summary
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // left: title + date + times of day
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Cuaca Hari Ini',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  DateFormat.yMMMMd('id').format(today),
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                const SizedBox(height: 10),
                                // time-of-day icons, gunakan nilai harian karena backend hanya memberikan daily
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _timeOfDayIcon(
                                      'Pagi',
                                      preds.isNotEmpty
                                          ? max(0.0, preds[0])
                                          : 0.0,
                                    ),
                                    _timeOfDayIcon(
                                      'Siang',
                                      preds.isNotEmpty
                                          ? max(0.0, preds[0])
                                          : 0.0,
                                    ),
                                    _timeOfDayIcon(
                                      'Sore',
                                      preds.isNotEmpty
                                          ? max(0.0, preds[0])
                                          : 0.0,
                                    ),
                                    _timeOfDayIcon(
                                      'Malam',
                                      preds.isNotEmpty
                                          ? max(0.0, preds[0])
                                          : 0.0,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 10),

                          // right: highlighted today summary
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Builder(
                                  builder: (ctx) {
                                    final todayMm =
                                        preds.isNotEmpty
                                            ? max(0.0, preds[0])
                                            : 0.0;
                                    final rule = _ruleFor(todayMm);
                                    return Icon(
                                      rule['icon'],
                                      size: 40,
                                      color: rule['color'],
                                    );
                                  },
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${(preds.isNotEmpty ? max(0.0, preds[0]) : 0.0).toStringAsFixed(1)} mm',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _ruleFor(
                                    preds.isNotEmpty ? max(0.0, preds[0]) : 0.0,
                                  )['label'],
                                  style: const TextStyle(color: Colors.blue),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Grid (4 kolom)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 12,
                          right: 12,
                          bottom:
                              MediaQuery.of(context).padding.bottom +
                              kBottomNavigationBarHeight +
                              24,
                        ),
                        child: GridView.builder(
                          itemCount: min(preds.length, 30),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4, // tetap 4 kolom
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 0.5, // mencegah overflow
                              ),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemBuilder: (ctx, i) {
                            final raw = preds[i];
                            final mm =
                                raw.isNaN || raw.isInfinite
                                    ? 0.0
                                    : max(0.0, raw);
                            final date = today.add(Duration(days: i));
                            final rule = _ruleFor(mm);

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade200),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 2,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 8,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat.E('id').format(date),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dayNumFmt.format(date),
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                  const SizedBox(height: 6),
                                  SizedBox(
                                    height: 30,
                                    child: FittedBox(
                                      child: Icon(
                                        rule['icon'],
                                        color: rule['color'],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    rule['label'],
                                    style: TextStyle(
                                      color: rule['color'],
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${mm.toStringAsFixed(1)} mm',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
