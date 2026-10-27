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
        debugPrint('Response [/items/farms]: ${data is Map ? data['data'] : data}');
        final list = (data is Map && data['data'] != null)
            ? data['data']
            : (data is List ? data : []);
        final farms =
            (list as List)
                .map((item) => FarmModel.fromJson(item as Map<String, dynamic>))
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

  Future<Either<String, FarmModel>> createFarm({
    required String name,
    required String areaSize,
    String areaUnit = 'm2',
    String? address,
    int soilType = 1,
    String ownershipType = 'Pribadi',
  }) async {
    final url = '$appUrl/items/farms';
    try {
      final response = await apiClient.dio.post(
        url,
        data: {
          'name': name,
          'area_size': areaSize,
          'area_unit': areaUnit,
          'address': address ?? '',
          'soil_type': soilType,
          'ownership_type': ownershipType,
          'status': 'published',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic data = response.data;
        final farmData =
            (data is Map && data['data'] != null) ? data['data'] : data;
        return Right(FarmModel.fromJson(farmData as Map<String, dynamic>));
      } else {
        return Left("Gagal menambahkan lahan");
      }
    } catch (e) {
      return Left("Terjadi kesalahan: $e");
    }
  }

  Future<Either<String, FarmModel>> getFarmById(String id) async {
    final url = '$appUrl/items/farms/$id';
    try {
      final response = await apiClient.dio.get(url, cancelToken: cancelToken);
      if (response.statusCode == 200) {
        final dynamic data = response.data;
        debugPrint('Response [/items/farm]: ${data is Map ? data['data'] : data}');
        final farmData =
            (data is Map && data['data'] != null) ? data['data'] : data;
        return Right(FarmModel.fromJson(farmData as Map<String, dynamic>));
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
