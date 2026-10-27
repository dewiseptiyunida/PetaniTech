// lib/utils/weather/weather_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // Ganti defaultValue dengan base URL server-mu (tanpa trailing slash)
  static const _baseUrl = String.fromEnvironment(
    'WEATHER_API_URL',
    defaultValue: 'https://climatepredict.petanitech.com/',
  );

  static Future<List<double>> getForecast() async {
    final uri = Uri.parse('$_baseUrl/forecast');
    final response = await http.get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Server error: ${response.statusCode}');
    }

    final body = _safeDecode(response.body);
    if (body == null) return [];

    // Banyak kemungkinan bentuk JSON -> coba beberapa pola
    if (body is Map && body.containsKey('predictions')) {
      final p = body['predictions'];
      if (p is List) return _toDoubleList(p);
      if (p is Map) {
        final vals =
            p.values
                .map((v) {
                  if (v is Map && v.containsKey('mm')) return v['mm'];
                  if (v is num) return v;
                  return null;
                })
                .where((e) => e != null)
                .toList();
        return _toDoubleList(vals);
      }
    }

    if (body is Map &&
        body.keys.first.toString().toLowerCase().contains('day')) {
      final keys = body.keys.toList()..sort();
      final vals =
          keys
              .map((k) {
                final v = body[k];
                if (v is Map && v.containsKey('mm')) return v['mm'];
                if (v is num) return v;
                return null;
              })
              .where((e) => e != null)
              .toList();
      return _toDoubleList(vals);
    }

    if (body is List) {
      return _toDoubleList(body);
    }

    // fallback: cari semua nilai numerik di map
    if (body is Map) {
      final numeric = <dynamic>[];
      for (final v in body.values) {
        if (v is num)
          numeric.add(v);
        else if (v is Map && v.containsKey('mm'))
          numeric.add(v['mm']);
      }
      if (numeric.isNotEmpty) return _toDoubleList(numeric);
    }

    return [];
  }

  static Future<double?> getTomorrowPrediction() async {
    final uri = Uri.parse('$_baseUrl/forecast/tomorrow');
    final response = await http.get(uri).timeout(const Duration(seconds: 8));

    if (response.statusCode != 200)
      throw Exception('Server error: ${response.statusCode}');

    final body = _safeDecode(response.body);
    if (body == null) return null;

    if (body is Map) {
      if (body.containsKey('mm')) {
        final mm = body['mm'];
        return mm == null ? null : (mm as num).toDouble();
      }
      if (body.containsKey('prediction')) {
        final p = body['prediction'];
        return p == null ? null : (p as num).toDouble();
      }
      if (body.containsKey('predictions')) {
        final p = body['predictions'];
        if (p is List && p.isNotEmpty) {
          final first = p[0];
          if (first is num) return first.toDouble();
          if (first is Map && first.containsKey('mm'))
            return (first['mm'] as num).toDouble();
        }
      }
    }

    if (body is List && body.isNotEmpty) {
      final first = body[0];
      if (first is num) return first.toDouble();
      if (first is Map && first.containsKey('mm'))
        return (first['mm'] as num).toDouble();
    }

    return null;
  }

  // --- helpers ---
  static dynamic _safeDecode(String s) {
    try {
      return json.decode(s);
    } catch (_) {
      return null;
    }
  }

  static List<double> _toDoubleList(List<dynamic> raw) {
    return raw.map<double>((e) {
      if (e == null) return 0.0;
      if (e is num) return e.toDouble();
      if (e is String) return double.tryParse(e) ?? 0.0;
      if (e is Map && e.containsKey('mm')) {
        final mm = e['mm'];
        if (mm is num) return mm.toDouble();
        if (mm is String) return double.tryParse(mm) ?? 0.0;
      }
      return 0.0;
    }).toList();
  }
}
