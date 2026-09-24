import 'package:equatable/equatable.dart';
import 'package:petanitech_mobile/utils/weather/nominatim/models/nominatim_model.dart';
import 'package:petanitech_mobile/utils/weather/openmeteo/models/weather_model.dart';

enum WeatherStatus { initial, loading, success, failure }

class WeatherState extends Equatable {
  final WeatherStatus status;
  final WeatherModel? weather;
  final NominatimModel? geocoding;
  final Exception? error;

  const WeatherState({
    this.status = WeatherStatus.initial,
    this.weather,
    this.geocoding,
    this.error,
  });

  WeatherState copyWith({
    WeatherStatus? status,
    WeatherModel? weather,
    NominatimModel? geocoding,
    Exception? error,
  }) => WeatherState(
    status: status ?? this.status,
    weather: weather ?? this.weather,
    geocoding: geocoding ?? this.geocoding,
    error: error ?? this.error,
  );

  @override
  List<Object?> get props => [status, weather, geocoding, error];
}
