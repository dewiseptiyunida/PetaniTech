import 'package:petanitech_mobile/utils/weather/wmo_standard/wmo_standard.dart';

class WeatherModel {
  final double latitude;
  final double longitude;
  final String timezone;
  final Map<String, String> hourlyUnits;
  final List<String> time;
  final List<double> temperature2m;
  final List<double> rain;
  final List<int> weatherCode;
  final List<int> relativeHumidity2m;

  WeatherModel({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.hourlyUnits,
    required this.time,
    required this.temperature2m,
    required this.rain,
    required this.weatherCode,
    required this.relativeHumidity2m,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      latitude: json['latitude'],
      longitude: json['longitude'],
      timezone: json['timezone'],
      hourlyUnits: Map<String, String>.from(json['hourly_units']),
      time: List<String>.from(json['hourly']['time']),
      temperature2m: List<double>.from(json['hourly']['temperature_2m']),
      rain: List<double>.from(json['hourly']['rain']),
      weatherCode: List<int>.from(json['hourly']['weather_code']),
      relativeHumidity2m: List<int>.from(
        json['hourly']['relative_humidity_2m'],
      ),
    );
  }

  String getWeatherDescription(int code, String timeOfDay) {
    return wmoStandardDescriptionIcon[code]?[timeOfDay]?['description'] ??
        'Unknown';
  }

  String getWeatherIcon(int code, String timeOfDay) {
    return wmoStandardDescriptionIcon[code]?[timeOfDay]?['image'] ?? '';
  }
}
