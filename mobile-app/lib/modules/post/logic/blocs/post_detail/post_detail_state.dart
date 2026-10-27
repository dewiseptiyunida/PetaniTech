import 'package:equatable/equatable.dart';
import 'package:petanitech_mobile/data/models/post_model.dart';

abstract class PostDetailState extends Equatable {
  const PostDetailState();

  @override
  List<Object?> get props => [];
}

class PostInitial extends PostDetailState {}

class PostLoading extends PostDetailState {}

class PostLoaded extends PostDetailState {
  final PostModel post;

  const PostLoaded(this.post);

  @override
  List<Object?> get props => [post];
}

class PostError extends PostDetailState {
  final String message;

  const PostError(this.message);

  @override
  List<Object?> get props => [message];
}
