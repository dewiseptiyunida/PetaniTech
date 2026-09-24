import 'package:equatable/equatable.dart';
import 'package:petanitech_mobile/data/models/commodity_model.dart';
import 'package:petanitech_mobile/data/models/community_model.dart';
import 'package:petanitech_mobile/data/models/post_model.dart';

abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeError extends HomeState {
  final String message;
  HomeError({required this.message});
}

class HomeLoaded extends HomeState {
  final List<CommodityModel> commodities;
  final List<PostModel> posts;
  final List<CommunityModel> communities;
  HomeLoaded({
    required this.commodities,
    required this.posts,
    required this.communities,
  });
}

class CommodityLoading extends HomeState {}

class CommodityLoaded extends HomeState {
  final List<CommodityModel> commodities;

  CommodityLoaded(this.commodities);

  @override
  List<Object?> get props => [commodities];
}

class PostLoading extends HomeState {}

class PostLoaded extends HomeState {
  final List<PostModel> posts;

  PostLoaded(this.posts);

  @override
  List<Object?> get props => [posts];
}

class CommunityLoading extends HomeState {}

class CommunityLoaded extends HomeState {
  final List<CommunityModel> communities;

  CommunityLoaded(this.communities);

  @override
  List<Object?> get props => [communities];
}
