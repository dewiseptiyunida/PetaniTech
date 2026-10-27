import 'package:equatable/equatable.dart';
import 'package:petanitech_mobile/modules/auth/data/models/auth_model.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final AuthModel user;

  AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class RegisterSuccess extends AuthState {
  final bool status;

  RegisterSuccess(this.status);

  @override
  List<Object?> get props => [status];
}
