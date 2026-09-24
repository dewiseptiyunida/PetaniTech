import 'package:flutter_modular/flutter_modular.dart';
import 'package:petanitech_mobile/data/repositories/farm_repository.dart';
import 'package:petanitech_mobile/modules/farm/logic/blocs/farm/farm_bloc.dart';
import 'package:petanitech_mobile/modules/farm/presentation/farm_create_screen.dart';
import 'package:petanitech_mobile/modules/farm/presentation/farm_detail_screen.dart';
import 'package:petanitech_mobile/modules/farm/presentation/farm_screen.dart';

class FarmModule extends Module {
  static final String indexRoute = '/';
  static final String createRoute = '/create';
  static final String detailRoute = '/detail';

  @override
  void binds(Injector i) {
    i.addLazySingleton<FarmRepository>(
      FarmRepository.new,
      config: BindConfig(
        onDispose: (repository) {
          repository.dispose();
        },
      ),
    );
    i.addLazySingleton<FarmBloc>(
      FarmBloc.new,
      config: BindConfig(
        onDispose: (bloc) {
          bloc.close();
        },
      ),
    );
  }

  @override
  void routes(RouteManager r) {
    r.child(indexRoute, child: (_) => FarmScreen());
    r.child(createRoute, child: (_) => FarmCreateScreen());
    r.child(detailRoute, child: (_) => FarmDetailScreen());
  }
}
