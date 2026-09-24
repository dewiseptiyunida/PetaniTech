import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:petanitech_mobile/core/config.dart';
import 'package:dartz/dartz.dart';
import 'package:petanitech_mobile/data/models/farm_model.dart';
import 'package:petanitech_mobile/data/repositories/client_repository.dart';

class FarmRepository extends ClientRepository {
  FarmRepository({super.apiClient});

  Future<Either<String, List<FarmModel>>> getFarms({
    int offset = 0,
    int limit = 5,
  }) async {
    final url =
        '$appUrl/items/farms?filter[status][_eq]=published&sort=-date_created&offset=$offset&limit=$limit';
    try {
      final response = await apiClient.dio.get(url, cancelToken: cancelToken);
      if (response.statusCode == 200) {
        final dynamic data = response.data;
        debugPrint('Response [/items/farms]: ${data['data']}');
        final farms =
            (data['data'] as List)
                .map((item) => FarmModel.fromJson(item))
                .toList();
        return Right(farms);
      } else {
        return Left("Data farms tidak ditemukan.");
      }
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        return Left("Data farms tidak ditemukan.");
      }
      return Left("Terjadi kesalahan: $e");
    }
  }

  Future<Either<String, FarmModel>> getFarmById(String id) async {
    final url = '$appUrl/items/farms/$id';
    try {
      final response = await apiClient.dio.get(url, cancelToken: cancelToken);
      if (response.statusCode == 200) {
        final dynamic data = response.data;
        debugPrint('Response [/items/farm]: ${data['data']}');
        return Right(FarmModel.fromJson(data['data']));
      } else {
        return Left("Data farm tidak ditemukan.");
      }
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        return Left("Data farm tidak ditemukan.");
      }
      return Left("Terjadi kesalahan: $e");
    }
  }
}
