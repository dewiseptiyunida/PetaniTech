import 'package:flutter_modular/flutter_modular.dart';
import 'package:petanitech_mobile/data/repositories/commodity_repository.dart';
import 'package:petanitech_mobile/data/repositories/community_repository.dart';
import 'package:petanitech_mobile/data/repositories/post_repository.dart';
import 'package:petanitech_mobile/data/repositories/user_repository.dart';
import 'package:petanitech_mobile/logic/blocs/navigation/navigation_bloc.dart';
import 'package:petanitech_mobile/logic/blocs/user/user_bloc.dart';
import 'package:petanitech_mobile/modules/main/logic/blocs/home/home_bloc.dart';
import 'package:petanitech_mobile/modules/main/presentation/community_screen.dart';
import 'package:petanitech_mobile/modules/main/presentation/farming_screen.dart';
import 'package:petanitech_mobile/modules/main/presentation/home_screen.dart';
import 'package:petanitech_mobile/modules/main/presentation/main_screen.dart';
import 'package:petanitech_mobile/modules/main/presentation/profile_screen.dart';
import 'package:petanitech_mobile/modules/main/presentation/weather_forecast_page.dart';
import 'package:petanitech_mobile/modules/main/presentation/ecommerce_screen.dart';
import 'package:petanitech_mobile/utils/weather/weather.dart';

class MainModule extends Module {
  static final String indexRoute = '/';
  static final String homeRoute = '/home';
  static final String communityRoute = '/community';
  static final String ecommerceRoute = '/ecommerce';
  static final String farmingRoute = '/farming';
  static final String weatherRoute = '/weather';
  static final String profileRoute = '/profile';
  @override
  void binds(Injector i) {
    i.addLazySingleton<UserRepository>(
      UserRepository.new,
      config: BindConfig(
        onDispose: (r) {
          r.dispose();
        },
      ),
    );

    i.addLazySingleton<UserBloc>(
      UserBloc.new,
      config: BindConfig(
        onDispose: (bloc) {
          bloc.close();
        },
      ),
    );

    i.addLazySingleton<CommodityRepository>(
      CommodityRepository.new,
      config: BindConfig(
        onDispose: (r) {
          r.dispose();
        },
      ),
    );

    i.addLazySingleton<PostRepository>(
      PostRepository.new,
      config: BindConfig(
        onDispose: (r) {
          r.dispose();
        },
      ),
    );

    i.addLazySingleton<CommunityRepository>(
      CommunityRepository.new,
      config: BindConfig(
        onDispose: (r) {
          r.dispose();
        },
      ),
    );

    i.addLazySingleton<HomeBloc>(
      HomeBloc.new,
      config: BindConfig(
        onDispose: (bloc) {
          bloc.close();
        },
      ),
    );

    i.addLazySingleton<OpenMeteoService>(OpenMeteoService.new);
    i.addLazySingleton<NominatimService>(NominatimService.new);

    i.addLazySingleton<WeatherBloc>(
      WeatherBloc.new,
      config: BindConfig(
        onDispose: (bloc) {
          bloc.close();
        },
      ),
    );

    i.addLazySingleton<NavigationBloc>(
      NavigationBloc.new,
      config: BindConfig(
        onDispose: (bloc) {
          bloc.close();
        },
      ),
    );
  }

  @override
  void routes(RouteManager r) {
    r.child(
      indexRoute,
      child: (context) => const MainScreen(),
      transition: TransitionType.fadeIn,
      children: [
        ChildRoute(
          homeRoute,
          child: (context) => const HomeScreen(),
          transition: TransitionType.noTransition,
        ),
        ChildRoute(
          communityRoute,
          child: (context) => const CommunityScreen(),
          transition: TransitionType.noTransition,
        ),
        ChildRoute(
          ecommerceRoute,
          child: (context) => const EcommerceScreen(),
          transition: TransitionType.noTransition,
        ),
        ChildRoute(
          farmingRoute,
          child: (context) => const FarmingScreen(),
          transition: TransitionType.noTransition,
        ),
        ChildRoute(
          weatherRoute,
          child: (context) => const WeatherForecastPage(),
          transition: TransitionType.noTransition,
        ),
        ChildRoute(
          profileRoute,
          child: (context) => const ProfileScreen(),
          transition: TransitionType.noTransition,
        ),
      ],
    );
  }

}
