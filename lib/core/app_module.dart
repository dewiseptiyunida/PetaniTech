import 'package:dio/dio.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:petanitech_mobile/middleware/auth_guard.dart';
import 'package:petanitech_mobile/modules/disesase/disease_modul.dart';
import 'package:petanitech_mobile/modules/farm/farm_module.dart';
import 'package:petanitech_mobile/modules/main/main_module.dart';
import 'package:petanitech_mobile/modules/monitoring/monitoring_module.dart';
import 'package:petanitech_mobile/modules/post/post_module.dart';
import 'package:petanitech_mobile/presentation/splash_screen.dart';
import 'package:petanitech_mobile/utils/client/api_client.dart';
import '../modules/auth/auth_module.dart';

class AppModule extends Module {
  static final String initialRoute = '/';
  static final String authRoute = '/auth';
  static final String mainRoute = '/main';
  static final String postRoute = '/post';
  static final String monitoringRoute = '/monitoring';
  static final String areaRoute = '/area';

  @override
  void binds(Injector i) {
    i.addInstance<Dio>(Dio()); // for general purpose without interceptor
    i.addInstance<ApiClient>(ApiClient()); // with interceptor cms rest api
  }

  @override
  void routes(RouteManager r) {
    r.child(initialRoute, child: (context) => SplashScreen());
    r.module(authRoute, module: AuthModule());
    // if ready for guest, remove guard
    r.module(mainRoute, module: MainModule(), guards: [AuthGuard()]);
    r.module(postRoute, module: PostModule(), guards: [AuthGuard()]);
    r.module(
      monitoringRoute,
      module: MonitoringModule(),
      guards: [AuthGuard()],
    );
    r.module(areaRoute, module: FarmModule(), guards: [AuthGuard()]);
    r.module('/disease', module: DiseaseModule());
  }
}
