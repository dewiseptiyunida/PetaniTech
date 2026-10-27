import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:form_validator/form_validator.dart';
import 'package:petanitech_mobile/core/app_module.dart';
import 'package:petanitech_mobile/core/assets.dart';
import 'package:petanitech_mobile/core/consts.dart';
import 'package:petanitech_mobile/modules/auth/auth_module.dart';
import 'package:petanitech_mobile/modules/auth/logic/blocs/auth_bloc.dart';
import 'package:petanitech_mobile/modules/auth/logic/blocs/auth_event.dart';
import 'package:petanitech_mobile/modules/auth/logic/blocs/auth_state.dart';
import 'package:petanitech_mobile/modules/main/main_module.dart';
import 'package:petanitech_mobile/presentation/components/button.dart';
import 'package:petanitech_mobile/presentation/components/textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rePasswordController = TextEditingController();

  final nameValidator = ValidationBuilder().required().build();
  final emailValidator =
      ValidationBuilder()
          .required()
          .email(tr('form_validation.email.invalid'))
          .build();
  final passwordValidator =
      ValidationBuilder()
          .required()
          .minLength(
            6,
            'form_validation.password.length.min'.tr(namedArgs: {"val": "6"}),
          )
          .build();

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
            child: const Padding(
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

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _rePasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(tr("form_validation.password.match")),
          ),
        );
        return;
      }

      Modular.get<AuthBloc>().add(
        AuthRegister(
          _nameController.text,
          _emailController.text,
          _passwordController.text,
          _rePasswordController.text,
        ),
      );
    }
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
              Modular.to.pushReplacementNamed(
                AppModule.authRoute + AuthModule.loginRoute,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green,
                  content: Text(tr('form_validation.register.success')),
                ),
              );
            } else if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    tr(
                      'form_validation.register.failure',
                      namedArgs: {"message": state.message},
                    ),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(Consts.padding),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PTTextField(
                    isFormField: true,
                    icon: Icons.person,
                    controller: _nameController,
                    hintText: tr('auth.name'),
                    validator: nameValidator,
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: Consts.padding),
                  PTTextField(
                    isFormField: true,
                    icon: Icons.email,
                    controller: _emailController,
                    hintText: tr('auth.email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: emailValidator,
                  ),
                  const SizedBox(height: Consts.padding),
                  PTTextField(
                    isFormField: true,
                    icon: Icons.lock,
                    controller: _passwordController,
                    hintText: tr('auth.password'),
                    isPassword: true,
                    validator: passwordValidator,
                  ),
                  const SizedBox(height: Consts.padding),
                  PTTextField(
                    isFormField: true,
                    icon: Icons.lock,
                    controller: _rePasswordController,
                    hintText: tr('auth.re_password'),
                    isPassword: true,
                    validator: passwordValidator,
                  ),
                  const SizedBox(height: Consts.padding),
                  PTButton(
                    label: tr('auth.register'),
                    onPressed: () => _submitForm(context),
                    styleBuilder: PrimaryButtonStyleBuilder(),
                    icon: const Icon(Icons.person_add, color: Colors.white),
                  ),
                  const SizedBox(height: Consts.padding),
                  PTButton(
                    label: tr('auth.register_with_google'),
                    onPressed: () {},
                    styleBuilder: OutlinedButtonStyleBuilder(),
                    icon: Image.asset(PTAsset.iconGoogle, width: 20),
                  ),
                  const SizedBox(height: Consts.padding + 10),
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: Colors.grey, thickness: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          tr('auth.or').toUpperCase(),
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: Colors.grey, thickness: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: Consts.padding + 10),
                  PTButton(
                    label: tr('auth.back_login'),
                    onPressed: () {
                      Modular.to.navigate(
                        AppModule.authRoute + AuthModule.loginRoute,
                      );
                    },
                    icon: const Icon(Icons.login, color: Colors.white),
                    styleBuilder: SecondaryButtonStyleBuilder(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
