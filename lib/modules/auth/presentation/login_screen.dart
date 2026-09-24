import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:petanitech_mobile/core/app_module.dart';
import 'package:petanitech_mobile/core/app_theme.dart';
import 'package:petanitech_mobile/core/assets.dart';
import 'package:petanitech_mobile/core/consts.dart';
import 'package:petanitech_mobile/modules/auth/auth_module.dart';
import 'package:petanitech_mobile/modules/auth/logic/blocs/auth_bloc.dart';
import 'package:petanitech_mobile/modules/auth/logic/blocs/auth_event.dart';
import 'package:petanitech_mobile/modules/auth/logic/blocs/auth_state.dart';
import 'package:petanitech_mobile/modules/main/main_module.dart';
import 'package:petanitech_mobile/presentation/components/button.dart';
import 'package:petanitech_mobile/presentation/components/textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _showLoader(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }

  void _hideLoader(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  void initState() {
    super.initState();
    _emailController.text = "ahmadrifai716@gmail.com";
    _passwordController.text = "12345678";
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: Modular.get<AuthBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            _showLoader(context);
          } else {
            _hideLoader(context);
            if (state is AuthSuccess) {
              Modular.to.navigate(AppModule.mainRoute + MainModule.homeRoute);
            } else if (state is AuthFailure) {
              debugPrint('[LOGIN] Failed: ${state.message}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(
                    tr(
                      'form_validation.login.failure',
                      namedArgs: {"message": "Please check your account"},
                    ),
                  ),
                ),
              );
            }
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(Consts.padding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PTTextField(
                  icon: Icons.email,
                  controller: _emailController,
                  hintText: tr('auth.email'),
                ),
                SizedBox(height: Consts.padding),
                PTTextField(
                  icon: Icons.lock,
                  controller: _passwordController,
                  hintText: tr('auth.password'),
                  isPassword: true,
                ),
                SizedBox(height: Consts.padding - 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Modular.to.navigate(
                        AppModule.authRoute + AuthModule.forgotPasswordRoute,
                      );
                    },
                    child: Text(
                      tr('auth.forgot_password'),
                      style: TextStyle(
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: Consts.padding - 20),
                PTButton(
                  label: tr('auth.login'),
                  onPressed: () {
                    Modular.get<AuthBloc>().add(
                      AuthLogin(
                        _emailController.text,
                        _passwordController.text,
                      ),
                    );
                  },
                  styleBuilder: PrimaryButtonStyleBuilder(),
                  icon: Icon(Icons.login, color: Colors.white),
                ),
                SizedBox(height: Consts.padding),
                PTButton(
                  label: tr('auth.login_with_google'),
                  onPressed: () {},
                  styleBuilder: OutlinedButtonStyleBuilder(),
                  icon: Image.asset(PTAsset.iconGoogle, width: 20),
                ),
                SizedBox(height: Consts.padding + 10),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey, thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        tr('auth.or').toUpperCase(),
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey, thickness: 1)),
                  ],
                ),
                SizedBox(height: Consts.padding + 10),
                PTButton(
                  label: tr('auth.register_notice'),
                  onPressed: () {
                    Modular.to.navigate(
                      AppModule.authRoute + AuthModule.registerRoute,
                    );
                  },
                  icon: Icon(Icons.person_add, color: Colors.white),
                  styleBuilder: SecondaryButtonStyleBuilder(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
