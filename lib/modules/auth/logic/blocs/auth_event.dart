import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthLogin extends AuthEvent {
  final String email;
  final String password;

  AuthLogin(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class AuthRegister extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String rePassword;

  AuthRegister(this.name, this.email, this.password, this.rePassword);

  @override
  List<Object?> get props => [name, email, password, rePassword];
}

class AuthLogout extends AuthEvent {}

class AuthForgotPassword extends AuthEvent {
  final String email;

  AuthForgotPassword(this.email);

  @override
  List<Object?> get props => [email];
}
