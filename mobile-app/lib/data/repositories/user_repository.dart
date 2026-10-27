import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
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
        debugPrint('Response [/users/me]: $data');
        final dynamic rawUser =
            (data is Map<String, dynamic> && data['data'] != null)
                ? data['data']
                : data;
        final Map<String, dynamic> userMap =
            Map<String, dynamic>.from(rawUser as Map);
        userMap['email_notifications'] ??= false;
        userMap['id'] = userMap['id']?.toString() ?? '';
        return Right(UserModel.fromJson(userMap));
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

  Future<Either<String, String>> uploadAvatar(XFile imageFile) async {
    final url = '$appUrl/upload';
    try {
      final bytes = await imageFile.readAsBytes();
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: imageFile.name.isNotEmpty ? imageFile.name : 'avatar.jpg',
        ),
      });

      final response = await apiClient.dio.post(
        url,
        data: formData,
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200) {
        final dynamic data = response.data;
        debugPrint('Response POST [/upload]: $data');
        if (data is Map<String, dynamic>) {
          if (data['data'] != null && data['data'] is Map) {
            final inner = data['data'] as Map;
            if (inner['filename'] != null) {
              return Right(inner['filename'].toString());
            }
            if (inner['url'] != null) {
              return Right(inner['url'].toString());
            }
          }
          if (data['filename'] != null) {
            return Right(data['filename'].toString());
          }
          if (data['url'] != null) {
            return Right(data['url'].toString());
          }
        }
        return Right(imageFile.name);
      } else {
        return Left("Gagal mengunggah foto profil.");
      }
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        return Left("Unggah dibatalkan.");
      }
      return Left("Terjadi kesalahan unggah foto: $e");
    }
  }

  Future<Either<String, UserModel>> updateProfile({
    required String firstName,
    required String lastName,
    String? phone,
    String? avatar,
    XFile? avatarFile,
    String? location,
  }) async {
    String? resolvedAvatar = avatar;

    if (avatarFile != null) {
      final uploadResult = await uploadAvatar(avatarFile);
      uploadResult.fold(
        (error) => debugPrint('Warning uploadAvatar: $error'),
        (filename) => resolvedAvatar = filename,
      );
    }

    final url = '$appUrl/users/me';
    try {
      final response = await apiClient.dio.put(
        url,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          if (phone != null) 'phone': phone,
          if (resolvedAvatar != null) 'avatar': resolvedAvatar,
          if (location != null) 'location': location,
        },
        cancelToken: cancelToken,
      );
      if (response.statusCode == 200) {
        final dynamic data = response.data;
        debugPrint('Response PUT [/users/me]: $data');
        final dynamic rawUser =
            (data is Map<String, dynamic> && data['data'] != null)
                ? data['data']
                : data;
        final Map<String, dynamic> userMap =
            Map<String, dynamic>.from(rawUser as Map);
        userMap['email_notifications'] ??= false;
        userMap['id'] = userMap['id']?.toString() ?? '';
        return Right(UserModel.fromJson(userMap));
      } else {
        return Left("Gagal memperbarui profil.");
      }
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        return Left("Permintaan dibatalkan.");
      }
      return Left("Terjadi kesalahan: $e");
    }
  }
}
