import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:petanitech_mobile/data/models/farm_model.dart';
import 'package:petanitech_mobile/data/repositories/farm_repository.dart';
import 'package:petanitech_mobile/modules/farm/logic/blocs/farm/farm_event.dart';

class FarmBloc extends Bloc<FarmEvent, PagingState<int, FarmModel>> {
  final FarmRepository farmRepository;
  bool _isProcessing = false;

  FarmBloc(this.farmRepository) : super(PagingState()) {
    on<LoadFarms>(_onLoadFarms);
    on<RefreshFarms>(_onRefreshFarms);
  }

  Future<void> _onLoadFarms(
    LoadFarms event,
    Emitter<PagingState<int, FarmModel>> emit,
  ) async {
    if (state.isLoading || !state.hasNextPage || _isProcessing) return;

    _isProcessing = true;

    emit(state.copyWith(isLoading: true, error: null));

    try {
      final newKey =
          state.keys?.last == null ? 0 : (state.keys?.last ?? 0) + event.limit;

      final result = await farmRepository.getFarms(
        offset: newKey,
        limit: event.limit,
      );

      result.fold(
        (error) => emit(
          state.copyWith(error: '[FT_ERROR] : $error', isLoading: false),
        ),
        (farms) {
          emit(
            state.copyWith(
              pages: [...?state.pages, farms],
              keys: [...?state.keys, newKey],
              hasNextPage: farms.isNotEmpty,
              isLoading: false,
            ),
          );
        },
      );
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _onRefreshFarms(
    RefreshFarms event,
    Emitter<PagingState<int, FarmModel>> emit,
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
    add(LoadFarms());
  }
}
