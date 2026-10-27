import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:petanitech_mobile/core/config.dart';
import 'package:dartz/dartz.dart';
import 'package:petanitech_mobile/data/models/post_model.dart';
import 'package:petanitech_mobile/data/repositories/client_repository.dart';

class PostRepository extends ClientRepository {
  PostRepository({super.apiClient});

  Future<Either<String, List<PostModel>>> getPosts({
    int offset = 0,
    int limit = 5,
  }) async {
    final url =
        '$appUrl/items/posts?fields=*.*&filter[status][_eq]=published&sort=-date_created&offset=$offset&limit=$limit';
    try {
      final response = await apiClient.dio.get(url, cancelToken: cancelToken);
      if (response.statusCode == 200) {
        final dynamic data = response.data;
        debugPrint('Response [/items/posts]: ${data['data']}');
        final posts =
            (data['data'] as List)
                .map((item) => PostModel.fromJson(item))
                .toList();
        return Right(posts);
      } else {
        return Left("Data posts tidak ditemukan.");
      }
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        return Left("Data posts tidak ditemukan.");
      }
      return Left("Terjadi kesalahan: $e");
    }
  }

  Future<Either<String, PostModel>> getPostById(String id) async {
    final url = '$appUrl/items/posts/$id?fields=*.*';
    try {
      final response = await apiClient.dio.get(url, cancelToken: cancelToken);
      if (response.statusCode == 200) {
        final dynamic data = response.data;
        debugPrint('Response [/items/post]: ${data['data']}');
        return Right(PostModel.fromJson(data['data']));
      } else {
        return Left("Data post tidak ditemukan.");
      }
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        return Left("Data post tidak ditemukan.");
      }
      return Left("Terjadi kesalahan: $e");
    }
  }
}
