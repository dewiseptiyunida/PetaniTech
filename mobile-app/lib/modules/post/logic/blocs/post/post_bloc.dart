import 'package:bloc/bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:petanitech_mobile/data/models/post_model.dart';
import 'package:petanitech_mobile/data/repositories/post_repository.dart';
import 'post_event.dart';

class PostBloc extends Bloc<PostEvent, PagingState<int, PostModel>> {
  final PostRepository postRepository;
  bool _isProcessing = false;

  PostBloc({required this.postRepository}) : super(PagingState()) {
    on<LoadPosts>(_onLoadPosts);
    on<RefreshPosts>(_onRefreshPosts);
  }

  Future<void> _onLoadPosts(
    LoadPosts event,
    Emitter<PagingState<int, PostModel>> emit,
  ) async {
    if (state.isLoading || !state.hasNextPage || _isProcessing) return;

    _isProcessing = true;

    emit(state.copyWith(isLoading: true, error: null));

    try {
      final newKey =
          state.keys?.last == null ? 0 : (state.keys?.last ?? 0) + event.limit;

      final result = await postRepository.getPosts(
        offset: newKey,
        limit: event.limit,
      );

      result.fold(
        (error) => emit(
          state.copyWith(error: '[PT_ERROR] : $error', isLoading: false),
        ),
        (posts) {
          emit(
            state.copyWith(
              pages: [...?state.pages, posts],
              keys: [...?state.keys, newKey],
              hasNextPage: posts.isNotEmpty,
              isLoading: false,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          error: '[PT_ERROR_CATCH] : ${e.toString()}',
          isLoading: false,
        ),
      );
    }
    _isProcessing = false;
  }

  Future<void> _onRefreshPosts(
    RefreshPosts event,
    Emitter<PagingState<int, PostModel>> emit,
  ) async {
    if (_isProcessing) return;
    emit(
      state.copyWith(
        pages: null,
        keys: null,
        hasNextPage: true,
        isLoading: false,
      ),
    );
    add(LoadPosts());
  }
}
