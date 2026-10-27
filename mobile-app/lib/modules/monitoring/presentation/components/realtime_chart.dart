import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class RealtimeFarmChart extends StatefulWidget {
  const RealtimeFarmChart({super.key});

  @override
  State<RealtimeFarmChart> createState() => _RealtimeFarmChartState();
}

class _RealtimeFarmChartState extends State<RealtimeFarmChart> {
  late List<SensorData> _temperatureData;
  late List<SensorData> _moistureData;
  late List<SensorData> _humidityData;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Data dummy awal
    _temperatureData = _generateDummyData('temperature');
    _moistureData = _generateDummyData('moisture');
    _humidityData = _generateDummyData('humidity');

    // Update data setiap 2 detik (simulasi realtime)
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _updateDummyData();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  List<SensorData> _generateDummyData(String type) {
    final now = DateTime.now();
    final random = Random();
    return List.generate(10, (index) {
      final value = switch (type) {
        'temperature' => 20 + random.nextDouble() * 15, // 20-35°C
        'moisture' => 30 + random.nextDouble() * 50, // 30-80%
        'humidity' => 40 + random.nextDouble() * 40, // 40-80%
        _ => 0.0,
      };
      return SensorData(
        time: now.subtract(Duration(minutes: 10 - index)),
        value: double.parse(value.toStringAsFixed(1)),
      );
    });
  }

  void _updateDummyData() {
    setState(() {
      // Pertahankan 10 data terbaru
      if (_temperatureData.length >= 10) {
        _temperatureData.removeAt(0);
        _moistureData.removeAt(0);
        _humidityData.removeAt(0);
      }

      final now = DateTime.now();
      final random = Random();

      // Tambah data baru dengan sedikit variasi dari data sebelumnya
      _temperatureData.add(
        SensorData(
          time: now,
          value:
              (_temperatureData.last.value + (random.nextDouble() * 2 - 1))
                  .clamp(20, 35)
                  .toDouble(),
        ),
      );

      _moistureData.add(
        SensorData(
          time: now,
          value:
              (_moistureData.last.value + (random.nextDouble() * 5 - 2.5))
                  .clamp(30, 80)
                  .toDouble(),
        ),
      );

      _humidityData.add(
        SensorData(
          time: now,
          value:
              (_humidityData.last.value + (random.nextDouble() * 3 - 1.5))
                  .clamp(40, 80)
                  .toDouble(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        SizedBox(
          height: 250,
          child: SfCartesianChart(
            plotAreaBorderWidth: 0,
            primaryXAxis: DateTimeAxis(
              intervalType: DateTimeIntervalType.minutes,
              axisLine: const AxisLine(width: 0),
              majorGridLines: const MajorGridLines(width: 0),
              labelStyle: const TextStyle(fontSize: 10),
            ),
            primaryYAxis: NumericAxis(
              labelFormat: '{value}',
              axisLine: const AxisLine(width: 0),
              majorTickLines: const MajorTickLines(size: 0),
              labelStyle: const TextStyle(fontSize: 10),
            ),
            legend: Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              textStyle: const TextStyle(fontSize: 12),
            ),
            tooltipBehavior: TooltipBehavior(
              enable: true,
              format: 'point.x : point.y',
            ),
            series: <CartesianSeries<dynamic, dynamic>>[
              LineSeries<SensorData, DateTime>(
                dataSource: _temperatureData,
                xValueMapper: (SensorData data, _) => data.time,
                yValueMapper: (SensorData data, _) => data.value,
                name: 'Temperature (°C)',
                color: Colors.redAccent,
                width: 2.5,
                markerSettings: const MarkerSettings(isVisible: true),
                animationDuration: 500,
              ),
              LineSeries<SensorData, DateTime>(
                dataSource: _humidityData,
                xValueMapper: (SensorData data, _) => data.time,
                yValueMapper: (SensorData data, _) => data.value,
                name: 'Humidity (%)',
                color: Colors.blueAccent,
                width: 2.5,
                markerSettings: const MarkerSettings(isVisible: true),
                animationDuration: 500,
              ),
              LineSeries<SensorData, DateTime>(
                dataSource: _moistureData,
                xValueMapper: (SensorData data, _) => data.time,
                yValueMapper: (SensorData data, _) => data.value,
                name: 'Soil Moisture (%)',
                color: Colors.brown,
                width: 2.5,
                markerSettings: const MarkerSettings(isVisible: true),
                animationDuration: 500,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _ChartStatistic(
              title: 'Current Temp',
              value: '26.5°C',
              color: Colors.redAccent,
            ),
            _ChartStatistic(
              title: 'Humidity',
              value: '68%',
              color: Colors.blueAccent,
            ),
            _ChartStatistic(
              title: 'Soil Moisture',
              value: '45%',
              color: Colors.brown,
            ),
          ],
        ),
      ],
    );
  }
}

class SensorData {
  final DateTime time;
  final double value;

  SensorData({required this.time, required this.value});
}

class _ChartStatistic extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _ChartStatistic({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
