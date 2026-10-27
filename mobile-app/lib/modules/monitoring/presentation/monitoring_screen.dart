import 'package:flutter/material.dart';
import 'package:petanitech_mobile/core/app_theme.dart';
import 'package:petanitech_mobile/modules/monitoring/presentation/components/realtime_chart.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: AppTheme.accentColor,
        title: const Text('Monitoring', style: TextStyle(color: Colors.white)),
        centerTitle: false,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.white,
                child: Column(children: [RealtimeFarmChart()]),
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildSensorCard(
                    icon: Icons.thermostat,
                    title: 'Temperature',
                    value: '26.5',
                    unit: "°C",
                    trend: Icons.trending_up,
                  ),
                  _buildSensorCard(
                    icon: Icons.water_drop,
                    title: 'Humidity',
                    value: '65',
                    unit: "%",
                    trend: Icons.trending_flat,
                  ),
                  _buildSensorCard(
                    icon: Icons.grass,
                    title: 'Soil Moisture',
                    value: '42',
                    unit: "%",
                    trend: Icons.trending_down,
                  ),
                  _buildSensorCard(
                    icon: Icons.wb_sunny,
                    title: 'Light Intensity',
                    value: '1200',
                    unit: "lux",
                    trend: Icons.trending_up,
                  ),
                  _buildSensorCard(
                    icon: Icons.air,
                    title: 'Wind Speed',
                    value: '8',
                    unit: "km/h",
                    trend: Icons.trending_flat,
                  ),
                  _buildSensorCard(
                    icon: Icons.opacity,
                    title: 'Rainfall',
                    value: '0',
                    unit: "mm",
                    trend: Icons.trending_down,
                  ),
                  _buildSensorCard(
                    icon: Icons.navigation,
                    title: 'Wind Direction',
                    value: 'SE',
                    unit: "",
                    trend: Icons.trending_flat,
                  ),
                  _buildSensorCard(
                    icon: Icons.wb_sunny_outlined,
                    title: 'Solar Radiation',
                    value: '200',
                    unit: "W/m\u00B2",
                    trend: Icons.trending_up,
                  ),
                  _buildSensorCard(
                    icon: Icons.speed,
                    title: 'Pressure',
                    value: '1013',
                    unit: "hPa",
                    trend: Icons.trending_down,
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required IconData trend,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Colors.black.withAlpha(150)),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  final DateTime time;
  final double value;

  ChartData(this.time, this.value);
}
