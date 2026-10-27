import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:petanitech_mobile/core/config.dart';
import 'package:dartz/dartz.dart';
import 'package:petanitech_mobile/data/models/commodity_model.dart';
import 'package:petanitech_mobile/data/repositories/client_repository.dart';

class CommodityRepository extends ClientRepository {
  CommodityRepository({super.apiClient});

  Future<Either<String, List<CommodityModel>>> getCommodities() async {
    final url = '$appUrl/items/commodities';
    try {
      final response = await apiClient.dio.get(url, cancelToken: cancelToken);
      if (response.statusCode == 200) {
        final dynamic data = response.data;
        debugPrint('Response [/items/commodities]: ${data['data']}');
        final commodities =
            (data['data'] as List)
                .map((item) => CommodityModel.fromJson(item))
                .toList();
        return Right(commodities);
      } else {
        return Left("Data commodities tidak ditemukan.");
      }
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        return Left("Data commodities tidak ditemukan.");
      }
      return Left("Terjadi kesalahan: $e");
    }
  }
}
