import 'package:bloc/bloc.dart';
import 'package:petanitech_mobile/data/models/post_model.dart';
import 'package:petanitech_mobile/data/repositories/post_repository.dart';
import 'post_detail_event.dart';
import 'post_detail_state.dart';

class PostDetailBloc extends Bloc<PostDetailEvent, PostDetailState> {
  final PostRepository postRepository;
  final List<PostModel> posts = [];

  PostDetailBloc({required this.postRepository}) : super(PostInitial()) {
    on<LoadPostById>(_onFetchPostById);
  }

  Future<void> _onFetchPostById(
    LoadPostById event,
    Emitter<PostDetailState> emit,
  ) async {
    emit(PostLoading());
    try {
      final result = await postRepository.getPostById(event.id);
      result.fold(
        (error) => emit(PostError(error)),
        (post) => emit(PostLoaded(post)),
      );
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }
}
