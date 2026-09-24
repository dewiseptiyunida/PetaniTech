import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:geolocator/geolocator.dart';
import 'package:marquee/marquee.dart';
import 'package:petanitech_mobile/core/app_theme.dart';
import 'package:petanitech_mobile/core/consts.dart';
import 'package:petanitech_mobile/utils/weather/weather.dart';
import 'package:shimmer/shimmer.dart';

class SliderWeather extends StatefulWidget {
  const SliderWeather({super.key});

  @override
  State<SliderWeather> createState() => _SliderWeatherState();
}

class _SliderWeatherState extends State<SliderWeather> {
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    super.initState();
    _determinePosition()
        .then((v) {
          Modular.get<WeatherBloc>().add(
            WeatherEventLoadWeather(
              latitude: v.latitude,
              longitude: v.longitude,
              parameters: [
                'temperature_2m',
                'rain',
                'weather_code',
                'relative_humidity_2m',
              ],
              timezone: 'Asia/Jakarta',
            ),
          );
        })
        .onError((error, stackTrace) {
          debugPrint('[POSITION] Error: $error');
        });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherBloc, WeatherState>(
      bloc: Modular.get<WeatherBloc>(),
      builder: (context, state) {
        if (state.status == WeatherStatus.success) {
          return _a(context, state.weather!, state.geocoding!);
        } else if (state.status == WeatherStatus.failure) {
          return Center(child: Text('Error: ${state.error}'));
        } else {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          );
        }
      },
    );
  }
}

Widget _a(
  BuildContext context,
  WeatherModel weatherData,
  NominatimModel geocodingData,
) {
  final index = DateTime.now().hour;
  final timeOfDay = index > 18 ? 'night' : 'day';
  final iconUrl = weatherData.getWeatherIcon(
    weatherData.weatherCode[index],
    timeOfDay,
  );
  final description = weatherData.getWeatherDescription(
    weatherData.weatherCode[index],
    timeOfDay,
  );

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(50),
          blurRadius: 6.0,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.red, size: 16),
              SizedBox(width: 4.0),
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    '${geocodingData.address.village} ${geocodingData.address.county} ${geocodingData.address.country}, ${DateTime.now().toLocal().day} ${Consts.months[DateTime.now().toLocal().month - 1]} ${DateTime.now().toLocal().year}',
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(
                            Icons.thermostat,
                            color: Colors.orange,
                            size: 24,
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            '${weatherData.temperature2m[index]} °C',
                            style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          SizedBox(width: 6.0),
                          Icon(Icons.water_drop, color: Colors.blue, size: 12),
                          SizedBox(width: 8.0),
                          Text(
                            'Kelembapan ${weatherData.relativeHumidity2m[index]}%',
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      Positioned(
                        top: -15,
                        right: 0,
                        child: ClipRect(
                          child: Image.network(
                            iconUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Text(
                          description,
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.accentColor,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2),
              child: Row(
                children: [
                  Icon(Icons.recommend, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      height: 20,
                      child: Marquee(
                        text:
                            'Hari ini cocok untuk penyemprotan pestisida, menghindari tanah terkena tanah basah · ',
                        style: TextStyle(fontSize: 12.0, color: Colors.white),
                        velocity: 30.0,
                        blankSpace: 0,
                        numberOfRounds: 1,
                        scrollAxis: Axis.horizontal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
