import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petanitech_mobile/data/models/user_model.dart';
import 'package:petanitech_mobile/data/repositories/user_repository.dart';

// Events
abstract class UserEvent extends Equatable {
  const UserEvent();
  @override
  List<Object> get props => [];
}

class LoadUser extends UserEvent {}

class UpdateUser extends UserEvent {
  final String firstName;
  final String lastName;
  final String? phone;
  final String? avatar;
  final XFile? avatarFile;
  final String? location;

  const UpdateUser({
    required this.firstName,
    required this.lastName,
    this.phone,
    this.avatar,
    this.avatarFile,
    this.location,
  });

  @override
  List<Object> get props => [
        firstName,
        lastName,
        phone ?? '',
        avatar ?? '',
        avatarFile?.path ?? '',
        location ?? '',
      ];
}

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
  List<Object> get props => [
        user.id,
        user.avatar ?? '',
        user.firstName ?? '',
        user.lastName ?? '',
        user.email ?? '',
        user.phone ?? '',
        user.location ?? '',
      ];
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
    on<UpdateUser>(_onUpdateUser);
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

  void _onUpdateUser(UpdateUser event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final result = await userRepository.updateProfile(
        firstName: event.firstName,
        lastName: event.lastName,
        phone: event.phone,
        avatar: event.avatar,
        avatarFile: event.avatarFile,
        location: event.location,
      );
      result.fold(
        (error) => emit(UserError(error)),
        (user) => emit(UserLoaded(user)),
      );
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}
