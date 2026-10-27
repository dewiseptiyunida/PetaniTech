import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:petanitech_mobile/utils/weather/nominatim/models/nominatim_model.dart';

class NominatimService {
  final Dio _dio = Modular.get<Dio>();

  Future<NominatimModel?> getReverseGeocoding(double lat, double lon) async {
    const String baseUrl = 'https://nominatim.openstreetmap.org/reverse';
    try {
      final response = await _dio.get(
        baseUrl,
        queryParameters: {'format': 'json', 'lat': lat, 'lon': lon},
      );

      if (response.statusCode == 200) {
        debugPrint('[NOMINATIM]: ${response.data}');
        return NominatimModel.fromJson(response.data);
      } else {
        debugPrint('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Exception: $e');
      return null;
    }
  }
}
