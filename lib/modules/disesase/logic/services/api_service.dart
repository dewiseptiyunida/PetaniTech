// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../models/prediction_model.dart';
import '../models/chat_model.dart';
import '../models/history_model.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.18.9:8080/api/v1';
  static const Duration timeoutDuration = Duration(seconds: 60);

  // Toggle untuk verbose log
  static const bool _enableVerboseLogging = false;

  static String? _userId;
  static String? _deviceId;
  static Map<String, String>? _deviceInfo;

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // -------------------- Logging Helper --------------------
  void _log(String msg, {bool error = false, bool verbose = false}) {
    if (error) {
      print('❌ $msg');
      return;
    }
    if (verbose && !_enableVerboseLogging) return;
    print(msg);
  }

  // -------------------- Session & Device --------------------
  Future<void> initializeSession() async {
    await _getUserId();
    await _getDeviceInfo();
    _log('Session siap (user: $_userId)');
  }

  Future<String> _getUserId() async {
    if (_userId != null) return _userId!;
    await _getDeviceInfo();
    _userId =
        (_deviceId != null && _deviceId!.isNotEmpty && _deviceId != 'unknown')
            ? _deviceId
            : DateTime.now().millisecondsSinceEpoch.toString();
    return _userId!;
  }

  Future<Map<String, String>> _getDeviceInfo() async {
    if (_deviceInfo != null) return _deviceInfo!;

    final deviceInfoPlugin = DeviceInfoPlugin();
    final prefs = await SharedPreferences.getInstance();

    try {
      final cachedInfo = prefs.getString('device_info');
      if (cachedInfo != null) {
        _deviceInfo = Map<String, String>.from(jsonDecode(cachedInfo));
        _deviceId = _deviceInfo!['device_id'];
        return _deviceInfo!;
      }

      Map<String, String> info = {};
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        _deviceId = androidInfo.id;
        info = {
          'platform': 'Android',
          'model': androidInfo.model,
          'version': androidInfo.version.release,
          'brand': androidInfo.brand,
          'device': androidInfo.device,
          'sdk': androidInfo.version.sdkInt.toString(),
          'device_id': _deviceId!,
          'manufacturer': androidInfo.manufacturer,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        _deviceId = iosInfo.identifierForVendor ?? const Uuid().v4();
        info = {
          'platform': 'iOS',
          'model': iosInfo.model,
          'version': iosInfo.systemVersion,
          'name': iosInfo.name,
          'device': iosInfo.utsname.machine,
          'device_id': _deviceId!,
        };
      } else {
        _deviceId = const Uuid().v4();
        info = {'platform': Platform.operatingSystem, 'device_id': _deviceId!};
      }

      info['app_version'] = '1.0.0';
      info['build_number'] = '1';
      info['timestamp'] = DateTime.now().toIso8601String();

      _deviceInfo = info;
      await prefs.setString('device_info', jsonEncode(info));
    } catch (e) {
      _log('Gagal ambil device info: $e', error: true);
      _deviceId = prefs.getString('fallback_device_id') ?? const Uuid().v4();
      await prefs.setString('fallback_device_id', _deviceId!);
      _deviceInfo = {
        'platform': Platform.operatingSystem,
        'app_version': '1.0.0',
        'device_id': _deviceId!,
        'error': 'device_info_error',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
    return _deviceInfo!;
  }

  Future<bool> _checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (_) {
      return true; // fallback
    }
  }

  // -------------------- Generic Request --------------------
  Future<http.Response?> _makeRequest(
    String method,
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    bool requiresAuth = true,
  }) async {
    if (!await _checkConnectivity()) {
      throw Exception('Tidak ada koneksi internet');
    }

    final uri = Uri.parse('$baseUrl$endpoint');
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?headers,
    };

    if (requiresAuth) {
      try {
        final userId = await _getUserId();
        final deviceInfo = await _getDeviceInfo();
        requestHeaders.addAll({
          'X-User-ID': userId,
          'X-Device-Info': jsonEncode(deviceInfo),
        });
      } catch (e) {
        _log('Gagal tambah auth header: $e', error: true);
      }
    }

    try {
      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http
              .get(uri, headers: requestHeaders)
              .timeout(timeoutDuration);
          break;
        case 'POST':
          response = await http
              .post(uri, headers: requestHeaders, body: body)
              .timeout(timeoutDuration);
          break;
        case 'PUT':
          response = await http
              .put(uri, headers: requestHeaders, body: body)
              .timeout(timeoutDuration);
          break;
        case 'DELETE':
          response = await http
              .delete(uri, headers: requestHeaders)
              .timeout(timeoutDuration);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      _log('${method.toUpperCase()} $endpoint -> ${response.statusCode}');
      return response;
    } catch (e) {
      _log('Request gagal ($method $endpoint): $e', error: true);
      rethrow;
    }
  }

  // -------------------- Prediction --------------------
  Future<PredictionResult?> predictImage(File imageFile) async {
    try {
      if (!await imageFile.exists()) {
        throw Exception('File gambar tidak ditemukan');
      }

      await initializeSession();
      final userId = await _getUserId();
      final deviceInfo = await _getDeviceInfo();

      final uri = Uri.parse('$baseUrl/predict');
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll({
          'Accept': 'application/json',
          'X-User-ID': userId,
          'X-Device-Info': jsonEncode(deviceInfo),
        });

      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: http_parser.MediaType.parse('image/jpeg'),
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send().timeout(timeoutDuration);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        try {
          final jsonData = jsonDecode(response.body);
          final result = PredictionResult.fromJson(jsonData);

          // Simpan prediction_id
          if (jsonData['prediction_id'] != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(
              'current_prediction_id',
              jsonData['prediction_id'],
            );
          }
          return result;
        } catch (e) {
          _log('Parsing prediction gagal: $e', error: true);
          return null;
        }
      } else {
        _log('Server error prediction: ${response.statusCode}', error: true);
        return null;
      }
    } catch (e) {
      _log('Prediction error: $e', error: true);
      return null;
    }
  }

  // -------------------- Chat --------------------
  Future<ChatResponse?> chatWithExpert(
    String question,
    String diseaseContext, {
    String? predictionId,
  }) async {
    try {
      await initializeSession();
      predictionId ??= (await SharedPreferences.getInstance()).getString(
        'current_prediction_id',
      );
      final userId = await _getUserId();

      final uri = Uri.parse('$baseUrl/chat');
      final body = {
        'question': question,
        'disease_context': diseaseContext,
        if (predictionId != null) 'prediction_id': predictionId,
      };

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'X-User-ID': userId,
            },
            body: body,
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        try {
          return ChatResponse.fromJson(jsonDecode(response.body));
        } catch (e) {
          _log('Parsing chat gagal: $e', error: true);
          return null;
        }
      } else {
        _log('Chat error: ${response.statusCode}', error: true);
        return null;
      }
    } catch (e) {
      _log('Chat request error: $e', error: true);
      return null;
    }
  }

  // -------------------- History --------------------
  Future<HistoryResponse?> getUserHistory({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      await initializeSession();
      final deviceInfo = await _getDeviceInfo();
      final deviceId = deviceInfo['device_id'] ?? await _getUserId();
      final encoded = Uri.encodeComponent(deviceId);

      final response = await _makeRequest(
        'GET',
        '/history/$encoded?limit=$limit&offset=$offset',
      );

      if (response?.statusCode == 200) {
        try {
          final jsonData = jsonDecode(response!.body);
          if (jsonData is! Map<String, dynamic>) return null;
          return HistoryResponse.fromJson(jsonData);
        } catch (e) {
          _log('Parsing history gagal: $e', error: true);
          return null;
        }
      }
      return null;
    } catch (e) {
      _log('Get history error: $e', error: true);
      return null;
    }
  }

  Future<String?> getImageUrl(String predictionId) async {
    try {
      final response = await _makeRequest(
        'GET',
        '/prediction/$predictionId/image',
      );
      if (response?.statusCode == 200) {
        final jsonData = jsonDecode(response!.body);
        return jsonData['image_url'];
      }
      return null;
    } catch (e) {
      _log('Get image URL error: $e', error: true);
      return null;
    }
  }

  Future<bool> deleteHistoryItem(String predictionId) async {
    try {
      await initializeSession();
      final response = await _makeRequest(
        'DELETE',
        '/history/item/$predictionId',
      );
      if (response?.statusCode == 200) {
        final jsonData = jsonDecode(response!.body);
        return jsonData['success'] ?? false;
      }
      return false;
    } catch (e) {
      _log('Delete history error: $e', error: true);
      return false;
    }
  }

  Future<Map<String, dynamic>?> debugUserData() async {
    try {
      await initializeSession();
      final deviceInfo = await _getDeviceInfo();
      final encoded = Uri.encodeComponent(
        deviceInfo['device_id'] ?? await _getUserId(),
      );
      final response = await _makeRequest('GET', '/debug/user/$encoded');
      if (response?.statusCode == 200) {
        return jsonDecode(response!.body);
      }
      return null;
    } catch (e) {
      _log('Debug user data error: $e', error: true);
      return null;
    }
  }

  Future<Map<String, dynamic>?> testConnection() async {
    try {
      final health = await _makeRequest('GET', '/health', requiresAuth: false);
      if (health?.statusCode != 200) return null;

      final healthData = jsonDecode(health!.body);
      try {
        final db = await _makeRequest('GET', '/db-test', requiresAuth: false);
        if (db?.statusCode == 200) {
          final dbData = jsonDecode(db!.body);
          return {
            'server_status': healthData,
            'database_status': dbData,
            'overall_status': 'healthy',
          };
        }
        return {
          'server_status': healthData,
          'database_status': {'status': 'error'},
          'overall_status': 'degraded',
        };
      } catch (e) {
        return {
          'server_status': healthData,
          'database_status': {'status': 'error', 'message': e.toString()},
          'overall_status': 'degraded',
        };
      }
    } catch (e) {
      return {
        'server_status': {'status': 'error', 'message': e.toString()},
        'database_status': {'status': 'unknown'},
        'overall_status': 'error',
      };
    }
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('current_prediction_id');
    await prefs.remove('device_info');
    await prefs.remove('fallback_device_id');
    _userId = null;
    _deviceId = null;
    _deviceInfo = null;
  }

  Future<String?> getCurrentUserId() async {
    try {
      return await _getUserId();
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> getDebugInfo() async {
    await initializeSession();
    return {
      'user_id': _userId,
      'device_id': _deviceId,
      'device_info': _deviceInfo,
      'base_url': baseUrl,
      'connectivity': await _checkConnectivity(),
    };
  }

  // -------------------- Utility --------------------
  Future<bool> checkServerStatus() async {
    try {
      final uri = Uri.parse('$baseUrl/');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }
}
