import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:petanitech_mobile/utils/weather/openmeteo/models/weather_model.dart';

class OpenMeteoService {
  final Dio _dio = Modular.get<Dio>();
  final String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<WeatherModel> getWeather({
    required double latitude,
    required double longitude,
    required List<String> parameters,
    required String timezone,
  }) async {
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'timezone': timezone,
          'hourly': parameters.join(','),
        },
      );

      if (response.statusCode == 200) {
        debugPrint('[OPENMETEO]: ${response.data}');
        return WeatherModel.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch weather data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
