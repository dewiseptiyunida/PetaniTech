import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:petanitech_mobile/core/config.dart';
import 'package:dartz/dartz.dart';
import 'package:petanitech_mobile/data/models/community_model.dart';
import 'package:petanitech_mobile/data/repositories/client_repository.dart';

class CommunityRepository extends ClientRepository {
  CommunityRepository({super.apiClient});

  Future<Either<String, List<CommunityModel>>> getCommunities({
    int offset = 0,
    int limit = 5,
    String? fields,
  }) async {
    final url =
        '$appUrl/items/communities?fields=${fields ?? '*'}&filter[status][_eq]=published&sort=date_created&offset=$offset&limit=$limit';
    try {
      final response = await apiClient.dio.get(url, cancelToken: cancelToken);
      if (response.statusCode == 200) {
        final dynamic data = response.data;
        debugPrint('Response [/items/communities]: ${data['data']}');
        final posts =
            (data['data'] as List)
                .map((item) => CommunityModel.fromJson(item))
                .toList();
        return Right(posts);
      } else {
        return Left("Data communities tidak ditemukan.");
      }
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        return Left("Data communities tidak ditemukan.");
      }
      return Left("Terjadi kesalahan: $e");
    }
  }

  Future<Either<String, CommunityModel>> getCommunityById(String id) async {
    final url = '$appUrl/items/communities/$id';
    try {
      final response = await apiClient.dio.get(url, cancelToken: cancelToken);
      if (response.statusCode == 200) {
        final dynamic data = response.data;
        debugPrint('Response [/items/community_post]: ${data['data']}');
        return Right(CommunityModel.fromJson(data['data']));
      } else {
        return Left("Data community tidak ditemukan.");
      }
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        return Left("Data community tidak ditemukan.");
      }
      return Left("Terjadi kesalahan: $e");
    }
  }
}
