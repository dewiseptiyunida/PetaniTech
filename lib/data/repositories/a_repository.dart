import 'package:dio/dio.dart';

abstract class ARepository {
  final CancelToken _cancelToken = CancelToken();
  CancelToken get cancelToken => _cancelToken;
  void dispose() {
    _cancelToken.cancel("Aplikasi ditutup, semua permintaan dibatalkan.");
  }
}
