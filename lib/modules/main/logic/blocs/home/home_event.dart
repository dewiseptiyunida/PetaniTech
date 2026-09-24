import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class RequestAll extends HomeEvent {}

class RequestCommodity extends HomeEvent {}

class RequestPost extends HomeEvent {}

class RequestCommunity extends HomeEvent {}
