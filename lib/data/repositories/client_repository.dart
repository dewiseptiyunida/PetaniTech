import 'package:flutter_modular/flutter_modular.dart';
import 'package:petanitech_mobile/data/repositories/a_repository.dart';
import 'package:petanitech_mobile/utils/client/api_client.dart';

abstract class ClientRepository extends ARepository {
  final ApiClient _apiClient;
  ClientRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? Modular.get<ApiClient>();
  ApiClient get apiClient => _apiClient;
}
