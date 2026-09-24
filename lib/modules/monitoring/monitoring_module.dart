import 'package:flutter_modular/flutter_modular.dart';
import 'package:petanitech_mobile/modules/monitoring/presentation/monitoring_screen.dart';

class MonitoringModule extends Module {
  static final String indexRoute = '/';
  @override
  void binds(Injector i) {}

  @override
  void routes(RouteManager r) {
    r.child(indexRoute, child: (context) => MonitoringScreen());
  }
}
