import 'package:equatable/equatable.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object> get props => [];
}

class LoadPosts extends PostEvent {
  final int offset;
  final int limit;

  const LoadPosts({this.offset = 0, this.limit = 5});

  @override
  List<Object> get props => [offset, limit];
}

class RefreshPosts extends PostEvent {}
