import 'package:flutter_modular/flutter_modular.dart';
import 'package:petanitech_mobile/data/repositories/post_repository.dart';
import 'package:petanitech_mobile/modules/post/logic/blocs/post/post_bloc.dart';
import 'package:petanitech_mobile/modules/post/logic/blocs/post_detail/post_detail_bloc.dart';
import 'package:petanitech_mobile/modules/post/presentation/post_detail_screen.dart';
import 'package:petanitech_mobile/modules/post/presentation/post_screen.dart';

class PostModule extends Module {
  static final String indexRoute = '/';
  static final String postDetailRoute = '/:id';

  @override
  void binds(Injector i) {
    i.addLazySingleton<PostRepository>(
      PostRepository.new,
      config: BindConfig(
        onDispose: (repository) {
          repository.dispose();
        },
      ),
    );
    i.addLazySingleton<PostBloc>(
      PostBloc.new,
      config: BindConfig(
        onDispose: (bloc) {
          bloc.close();
        },
      ),
    );
    i.addLazySingleton<PostDetailBloc>(
      PostDetailBloc.new,
      config: BindConfig(
        onDispose: (bloc) {
          bloc.close();
        },
      ),
    );
  }

  @override
  void routes(RouteManager r) {
    r.child(indexRoute, child: (_) => PostScreen());
    r.child(
      postDetailRoute,
      child: (_) => PostDetailScreen(id: r.args.params['id']),
      transition: TransitionType.downToUp,
    );
  }
}
