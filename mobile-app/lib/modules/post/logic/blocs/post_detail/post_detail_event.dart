import 'package:equatable/equatable.dart';

abstract class PostDetailEvent extends Equatable {
  const PostDetailEvent();

  @override
  List<Object> get props => [];
}

class LoadPosts extends PostDetailEvent {}

class GetPosts extends PostDetailEvent {}

class LoadPostById extends PostDetailEvent {
  final String id;

  const LoadPostById(this.id);

  @override
  List<Object> get props => [id];
}
