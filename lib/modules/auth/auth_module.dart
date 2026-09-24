import 'package:flutter_modular/flutter_modular.dart';
import 'package:petanitech_mobile/modules/auth/presentation/auth_screen.dart';
import 'package:petanitech_mobile/modules/auth/presentation/forgot_password_screen.dart';
import 'package:petanitech_mobile/modules/auth/presentation/login_screen.dart';
import 'package:petanitech_mobile/modules/auth/presentation/register_screen.dart';
import 'data/repositories/auth_repository.dart';
import 'logic/blocs/auth_bloc.dart';

class AuthModule extends Module {
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String forgotPasswordRoute = '/forgot-password';

  @override
  void binds(i) {
    i.addLazySingleton<AuthRepository>(
      AuthRepository.new,
      config: BindConfig(
        onDispose: (repository) {
          repository.dispose();
        },
      ),
    );
    i.addLazySingleton<AuthBloc>(
      AuthBloc.new,
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
      '/',
      child: (context) => AuthScreen(),
      transition: TransitionType.upToDown,
      children: [
        ChildRoute(
          loginRoute,
          child: (context) => LoginScreen(),
          transition: TransitionType.leftToRight,
        ),
        ChildRoute(
          registerRoute,
          child: (context) => RegisterScreen(),
          transition: TransitionType.rightToLeft,
        ),
        ChildRoute(
          forgotPasswordRoute,
          child: (context) => ForgotPasswordScreen(),
          transition: TransitionType.downToUp,
        ),
      ],
    );
    // r.child(loginRoute, child: (context) => LoginScreen());
    // r.child(registerRoute, child: (context) => RegisterScreen());
    // r.child(forgotPasswordRoute, child: (context) => ForgotPasswordScreen());
  }
}
