import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:petanitech_mobile/core/config.dart';
import 'package:petanitech_mobile/modules/auth/data/models/auth_model.dart';
import 'package:dartz/dartz.dart';
import 'package:petanitech_mobile/data/repositories/base_repository.dart';
import 'package:petanitech_mobile/utils/client/api_client.dart';

class AuthRepository extends BaseRepository {
  AuthRepository({super.dio});

  Future<Either<String, AuthModel>> login(String email, String password) async {
    final url = '$appUrl/auth/login';
    try {
      final response = await dio.post(
        url,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: jsonEncode({'email': email, 'password': password}),
        cancelToken: cancelToken,
      );
      if (response.statusCode == 200) {
        final dynamic data = response.data;
        ApiClient.saveTokens(
          data['data']['access_token'],
          data['data']['refresh_token'],
        );
        return Right(AuthModel.fromJson(data['data']));
      } else {
        return Left("Login gagal. Coba lagi.");
      }
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        return Left("Permintaan dibatalkan.");
      }
      return Left("Terjadi kesalahan: $e");
    }
  }

  Future<Either<String, bool>> logout(String accessToken) async {
    final url = '$appUrl/auth/logout';
    try {
      final response = await dio.post(
        url,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: jsonEncode({'access_token': accessToken}),
        cancelToken: cancelToken,
      );

      if (response.statusCode == 204) {
        ApiClient.clearTokens();
        return const Right(true);
      } else {
        return const Left("Logout gagal.");
      }
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        return Left("Permintaan dibatalkan.");
      }
      return Left("Terjadi kesalahan: $e");
    }
  }

  Future<Either<String, bool>> register(
    String name,
    String email,
    String password,
  ) async {
    final url = '$appUrl/users/register';

    try {
      final response = await dio.post(
        url,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: jsonEncode({
          'first_name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 204) {
        return Right(true);
      } else {
        return Left('Register gagal, coba lagi.');
      }
    } catch (e) {
      return Left('Terjadi kesalahan');
    }
  }

  Future<Either<String, bool>> requestForgotPassword(String email) async {
    final url = '$appUrl/auth/password/request';

    try {
      final response = await dio.post(url, data: jsonEncode({'email': email}));

      if (response.statusCode == 204) {
        return Right(true);
      } else {
        return Left('Terjadi kesalahan, mohon coba lagi.');
      }
    } catch (e) {
      return Left('Terjadi kesalahan.');
    }
  }
}
