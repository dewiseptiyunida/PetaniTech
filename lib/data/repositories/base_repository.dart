import 'package:dio/dio.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:petanitech_mobile/data/repositories/a_repository.dart';

abstract class BaseRepository extends ARepository {
  final Dio _dio;
  BaseRepository({Dio? dio}) : _dio = dio ?? Modular.get<Dio>();
  Dio get dio => _dio;
}
