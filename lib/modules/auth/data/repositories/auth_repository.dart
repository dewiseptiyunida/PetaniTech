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
        String accessToken = '';
        String refreshToken = '';
        int expires = 3600;

        if (data is Map<String, dynamic>) {
          if (data['data'] != null && data['data'] is Map<String, dynamic>) {
            accessToken = data['data']['access_token'] ?? '';
            refreshToken = data['data']['refresh_token'] ?? accessToken;
            expires = data['data']['expires'] ?? 3600;
          } else if (data['token'] != null) {
            accessToken = data['token'];
            refreshToken = data['token'];
          }
        }

        await ApiClient.saveTokens(accessToken, refreshToken);
        return Right(AuthModel(
          expires: expires,
          refreshToken: refreshToken,
          accessToken: accessToken,
        ));
      } else {
        return Left("Login gagal. Coba lagi.");
      }
    } catch (e) {
      if (e is DioException) {
        if (CancelToken.isCancel(e)) {
          return Left("Permintaan dibatalkan.");
        }
        if (e.response?.data != null && e.response?.data is Map) {
          final err = e.response?.data['error'] ?? e.response?.data['message'];
          if (err != null) return Left(err.toString());
        }
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

      ApiClient.clearTokens();
      return const Right(true);
    } catch (e) {
      ApiClient.clearTokens();
      return const Right(true);
    }
  }

  Future<Either<String, bool>> register(
    String name,
    String email,
    String password,
  ) async {
    final url = '$appUrl/auth/register';

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

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return const Right(true);
      } else {
        return const Left('Register gagal, coba lagi.');
      }
    } catch (e) {
      if (e is DioException &&
          e.response?.data != null &&
          e.response?.data is Map) {
        final err = e.response?.data['error'] ?? e.response?.data['message'];
        if (err != null) {
          return Left(err.toString());
        }
      }
      return Left('Terjadi kesalahan: $e');
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
