import 'package:bloc/bloc.dart';
import 'package:petanitech_mobile/data/models/commodity_model.dart';
import 'package:petanitech_mobile/data/models/community_model.dart';
import 'package:petanitech_mobile/data/models/post_model.dart';
import 'package:petanitech_mobile/data/repositories/commodity_repository.dart';
import 'package:petanitech_mobile/data/repositories/community_repository.dart';
import 'package:petanitech_mobile/data/repositories/post_repository.dart';
import 'package:petanitech_mobile/modules/main/logic/blocs/home/home_event.dart';
import 'package:petanitech_mobile/modules/main/logic/blocs/home/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final CommodityRepository _commodityRepository;
  final PostRepository _postRepository;
  final CommunityRepository _communityRepository;
  final List<CommodityModel> commodities = [];
  final List<PostModel> posts = [];
  final List<CommunityModel> communities = [];

  HomeBloc(
    this._commodityRepository,
    this._postRepository,
    this._communityRepository,
  ) : super(HomeInitial()) {
    on<RequestAll>(_onRequest);
  }

  Future<void> _onRequest(RequestAll event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final result = await _commodityRepository.getCommodities();
      result.fold((error) => null, (commodities) {
        this.commodities.clear();
        this.commodities.addAll(commodities);
      });
    } catch (_) {}

    try {
      final result = await _postRepository.getPosts();
      result.fold((error) => null, (posts) {
        this.posts.clear();
        this.posts.addAll(posts);
      });
    } catch (_) {}

    try {
      final result = await _communityRepository.getCommunities(
        fields: 'id,name,description,image,visibility,count(members)',
      );
      result.fold((error) => null, (communities) {
        this.communities.clear();
        this.communities.addAll(communities);
      });
    } catch (_) {}

    emit(
      HomeLoaded(
        commodities: List.from(commodities),
        posts: List.from(posts),
        communities: List.from(communities),
      ),
    );
  }
}
