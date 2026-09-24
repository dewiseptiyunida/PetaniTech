import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:petanitech_mobile/core/config.dart';
import 'package:dartz/dartz.dart';
import 'package:petanitech_mobile/data/models/user_model.dart';
import 'package:petanitech_mobile/data/repositories/client_repository.dart';

class UserRepository extends ClientRepository {
  UserRepository({super.apiClient});

  Future<Either<String, UserModel>> getMe() async {
    final url = '$appUrl/users/me';
    try {
      final response = await apiClient.dio.get(url, cancelToken: cancelToken);
      if (response.statusCode == 200) {
        final dynamic data = response.data;
        debugPrint('Response [/users/me]: ${data['data']}');
        return Right(UserModel.fromJson(data['data']));
      } else {
        return Left("Data user tidak ditemukan.");
      }
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        return Left("Data user tidak ditemukan.");
      }
      return Left("Terjadi kesalahan: $e");
    }
  }
}
