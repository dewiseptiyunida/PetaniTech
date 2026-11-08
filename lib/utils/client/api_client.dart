import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:petanitech_mobile/core/app_module.dart';
import 'package:petanitech_mobile/core/config.dart';
import 'package:petanitech_mobile/modules/auth/auth_module.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  final Dio dio = Dio();
  bool _isRefreshing = false;
  final List<Completer<void>> _pendingRequests = [];

  ApiClient() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          debugPrint(
            '[api_client] Request Interceptor: ${options.method} ${options.path}',
          );

          // Skip adding token for refresh endpoint to avoid loops
          if (options.path.endsWith('/auth/refresh')) {
            return handler.next(options);
          }

          final prefs = await SharedPreferences.getInstance();
          String? accessToken = prefs.getString('access_token');

          options.headers['Authorization'] = 'Bearer $accessToken';

          handler.next(options);
        },
        onError: (DioException e, handler) async {
          debugPrint('[api_client] Error Interceptor: ${e.message}');

          // Don't intercept errors for the refresh endpoint
          if (e.requestOptions.path.endsWith('/auth/refresh')) {
            return handler.reject(e);
          }

          if (e.response?.statusCode == 401 && !_isRefreshing) {
            _isRefreshing = true;
            debugPrint('[api_client] Attempting token refresh...');

            try {
              final completer = Completer<void>();
              _pendingRequests.add(completer);

              final success = await _refreshToken();

              if (success) {
                debugPrint('[api_client] Token refresh successful');
                final prefs = await SharedPreferences.getInstance();
                final newAccessToken = prefs.getString('access_token');

                // Retry all pending requests with new token
                for (var pending in _pendingRequests) {
                  if (!pending.isCompleted) {
                    pending.complete();
                  }
                }

                e.requestOptions.headers['Authorization'] =
                    'Bearer $newAccessToken';
                final response = await dio.fetch(e.requestOptions);
                return handler.resolve(response);
              } else {
                debugPrint('[api_client] Token refresh failed - logging out');
                await clearTokens();
                Modular.to.navigate(
                  AppModule.authRoute + AuthModule.loginRoute,
                );
                return handler.reject(e);
              }
            } catch (refreshError) {
              debugPrint('[api_client] Error during refresh: $refreshError');
              await clearTokens();
              Modular.to.navigate(AppModule.authRoute + AuthModule.loginRoute);
              return handler.reject(e);
            } finally {
              _isRefreshing = false;
              _pendingRequests.clear();
            }
          }

          return handler.reject(e);
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString('refresh_token');

    if (refreshToken?.isEmpty ?? true) {
      return false;
    }

    try {
      // Buat request manual tanpa melalui interceptor
      final response = await dio.fetch(
        RequestOptions(
          path: '$appUrl/auth/refresh',
          method: 'POST',
          data: {'refresh_token': refreshToken},
          // Tambahkan ini untuk bypass interceptor
          extra: {'dio-request_bypass_interceptor': true},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        await prefs.setString('access_token', data['access_token']);
        await prefs.setString('refresh_token', data['refresh_token']);
        return true;
      }
    } catch (e) {
      debugPrint('Refresh token error: $e');
    }
    return false;
  }

  static Future<void> saveTokens(
    String accessToken,
    String refreshToken,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  static String getAsset(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final clean = path.startsWith('/') ? path.substring(1) : path;
    return '$appUrl/assets/$clean';
  }
}
