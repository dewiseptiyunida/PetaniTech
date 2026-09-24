import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:petanitech_mobile/data/models/user_model.dart';
import 'package:petanitech_mobile/data/repositories/user_repository.dart';

// Events
abstract class UserEvent extends Equatable {
  const UserEvent();
  @override
  List<Object> get props => [];
}

class LoadUser extends UserEvent {}

// States
abstract class UserState extends Equatable {
  const UserState();
  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final UserModel user;
  const UserLoaded(this.user);
  @override
  List<Object> get props => [user];
}

class UserError extends UserState {
  final String message;
  const UserError(this.message);
  @override
  List<Object> get props => [message];
}

// Bloc
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;

  UserBloc({required this.userRepository}) : super(UserInitial()) {
    on<LoadUser>(_onLoadUser);
  }

  void _onLoadUser(LoadUser event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final result = await userRepository.getMe();
      result.fold(
        (error) => emit(UserError(error)),
        (user) => emit(UserLoaded(user)),
      );
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}
