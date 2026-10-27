import 'package:equatable/equatable.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object?> get props => [];
}

class WeatherEventLoadWeather extends WeatherEvent {
  final double latitude;
  final double longitude;
  final List<String> parameters;
  final String timezone;

  const WeatherEventLoadWeather({
    required this.latitude,
    required this.longitude,
    required this.parameters,
    required this.timezone,
  });

  @override
  List<Object?> get props => [latitude, longitude, parameters, timezone];
}
