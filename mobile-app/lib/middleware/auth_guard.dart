import 'package:flutter_modular/flutter_modular.dart';
import 'package:petanitech_mobile/core/app_module.dart';
import 'package:petanitech_mobile/modules/auth/auth_module.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthGuard extends RouteGuard {
  AuthGuard() : super(redirectTo: AppModule.authRoute + AuthModule.loginRoute);

  @override
  Future<bool> canActivate(String path, ModularRoute router) async {
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    return accessToken?.isNotEmpty ?? false;
  }
}
