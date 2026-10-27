import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petanitech_mobile/utils/weather/nominatim/nominatim.dart';
import 'package:petanitech_mobile/utils/weather/blocs/weather_event.dart';
import 'package:petanitech_mobile/utils/weather/blocs/weather_state.dart';
import 'package:petanitech_mobile/utils/weather/openmeteo/openmeteo.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final OpenMeteoService _openMeteoService;
  final NominatimService _nominatimService;

  WeatherBloc(this._openMeteoService, this._nominatimService)
    : super(WeatherState(status: WeatherStatus.initial)) {
    on<WeatherEventLoadWeather>(_onLoadWeather);
  }

  Future<void> _onLoadWeather(
    WeatherEventLoadWeather event,
    Emitter<WeatherState> emit,
  ) async {
    debugPrint('[WEATHER] Load weather');
    emit(state.copyWith(status: WeatherStatus.loading));
    try {
      final weather = await _openMeteoService.getWeather(
        latitude: event.latitude,
        longitude: event.longitude,
        parameters: event.parameters,
        timezone: event.timezone,
      );

      final geocoding = await _nominatimService.getReverseGeocoding(
        event.latitude,
        event.longitude,
      );

      emit(
        state.copyWith(
          status: WeatherStatus.success,
          weather: weather,
          geocoding: geocoding,
        ),
      );
    } on Exception catch (e) {
      emit(state.copyWith(status: WeatherStatus.failure, error: e));
    }
  }
}
