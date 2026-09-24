import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:petanitech_mobile/modules/auth/data/repositories/auth_repository.dart';
import 'package:petanitech_mobile/modules/auth/data/models/auth_model.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<AuthLogin>(_onLogin);
    on<AuthRegister>(_onRegister);
    on<AuthForgotPassword>(_onForgotPassword);
  }

  void _onLogin(AuthLogin event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final Either<String, AuthModel> result = await authRepository.login(
      event.email,
      event.password,
    );

    result.fold((failure) => emit(AuthFailure(failure)), (user) {
      return emit(AuthSuccess(user));
    });
  }

  void _onRegister(AuthRegister event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    if (event.password != event.rePassword) {
      emit(AuthFailure(tr('form_validation.password.match')));
      return;
    }

    final Either<String, bool> result = await authRepository.register(
      event.name,
      event.email,
      event.password,
    );

    result.fold(
      (failure) => emit(AuthFailure(failure)),
      (success) => emit(RegisterSuccess(success)),
    );
  }

  void _onForgotPassword(
    AuthForgotPassword event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final Either<String, bool> result = await authRepository
        .requestForgotPassword(event.email);

    result.fold(
      (failure) => emit(AuthFailure(failure)),
      (success) => emit(RegisterSuccess(success)),
    );
  }
}
