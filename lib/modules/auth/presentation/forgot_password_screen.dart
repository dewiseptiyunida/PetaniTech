import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:petanitech_mobile/core/app_module.dart';
import 'package:petanitech_mobile/core/consts.dart';
import 'package:petanitech_mobile/modules/auth/auth_module.dart';
import 'package:petanitech_mobile/modules/auth/logic/blocs/auth_bloc.dart';
import 'package:petanitech_mobile/modules/auth/logic/blocs/auth_event.dart';
import 'package:petanitech_mobile/modules/auth/logic/blocs/auth_state.dart';
import 'package:petanitech_mobile/presentation/components/button.dart';
import 'package:petanitech_mobile/presentation/components/textfield.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

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
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: Modular.get<AuthBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            _showLoader(context);
          } else {
            _hideLoader(context);
            if (state is RegisterSuccess) {
              // Modular.to.pushReplacementNamed('/home');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Silahkan cek Email anda.')),
              );
            } else if (state is AuthFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
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
                  hintText: 'Email',
                ),
                SizedBox(height: Consts.padding),
                PTButton(
                  label: 'Reset Password',
                  onPressed: () {
                    Modular.get<AuthBloc>().add(
                      AuthForgotPassword(_emailController.text),
                    );
                  },
                  styleBuilder: PrimaryButtonStyleBuilder(),
                  icon: Icon(Icons.lock_reset_outlined, color: Colors.white),
                ),
                SizedBox(height: Consts.padding + 10),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey, thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        "ATAU",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey, thickness: 1)),
                  ],
                ),
                SizedBox(height: Consts.padding + 10),
                PTButton(
                  label: 'Kembali Masuk',
                  onPressed: () {
                    Modular.to.navigate(
                      AppModule.authRoute + AuthModule.loginRoute,
                    );
                  },
                  icon: Icon(Icons.login, color: Colors.white),
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
