import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../utils/shared_pref_utils.dart';
import 'apis.dart';

class DioClient {
  static final Dio _dio = Dio(BaseOptions(baseUrl: Apis.baseUrl));
  static const String contentType = 'application/json';

  static Completer<void>? _loginLock;

  static Dio getInstance() {
    _initializeInterceptors();
    return _dio;
  }

  /// True if this request should send Authorization Bearer (excludes login, forgotPassword, refresh).
  static bool _needsAuth(String uri) {
    // Exclude inquiry-auth login too (no Bearer for this call).
    if (uri.contains(Apis.inquiryAuthLoginPath)) return false;
    return uri != Apis.login &&
        uri != Apis.forgotPassword &&
        uri != Apis.refreshTokenUrl;
  }

  static _initializeInterceptors() {
    // 1. Auth + refresh: add Bearer on request; on 401 try refresh and retry
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          debugPrint('URL:: ${options.uri.toString()}');

          final headers = <String, dynamic>{
            'Content-Type': contentType,
          };
          if (_needsAuth(options.uri.toString())) {
            final token =
                SharedPrefUtils.getValue(SharedPrefUtilsKeys.userToken, '');
            if (token.toString().trim().isNotEmpty) {
              headers['Authorization'] = 'Bearer $token';
            }
          }
          options.headers = headers;
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          final requestUri = e.requestOptions.uri.toString();
          if (e.response?.statusCode == 401 && _needsAuth(requestUri)) {
            final relogged = await _loginAndStoreAccessToken();
            if (relogged) {
              final token =
                  SharedPrefUtils.getValue(SharedPrefUtilsKeys.userToken, '');
              if (token.toString().trim().isNotEmpty) {
                final headers =
                    Map<String, dynamic>.from(e.requestOptions.headers);
                headers['Authorization'] = 'Bearer $token';
                final opts = e.requestOptions.copyWith(headers: headers);
                try {
                  final response = await _dio.fetch(opts);
                  return handler.resolve(response);
                } catch (retryError) {
                  return handler.next(retryError is DioException
                      ? retryError
                      : DioException(
                          requestOptions: e.requestOptions,
                          error: retryError,
                        ));
                }
              }
            }
          }
          return handler.next(e);
        },
      ),
    );
    // 2. Logging
    _dio.interceptors.add(LogInterceptor(
      responseBody: true,
      requestBody: true,
      logPrint: (object) => log(object.toString()),
    ));
  }

  /// Calls inquiry-auth login API, saves new access token. Returns true if successful.
  /// Uses a lock so only one login runs at a time; concurrent 401s wait for the same login.
  static Future<bool> _loginAndStoreAccessToken() async {
    if (_loginLock != null && !_loginLock!.isCompleted) {
      await _loginLock!.future;
      final token =
          SharedPrefUtils.getValue(SharedPrefUtilsKeys.userToken, '');
      return token.toString().trim().isNotEmpty;
    }

    _loginLock = Completer<void>();
    try {
      // Use a plain Dio so we don't add Bearer or trigger our interceptors
      final dio = Dio(BaseOptions(baseUrl: Apis.inquiryBaseUrl));
      dio.options.headers['Content-Type'] = contentType;

      final response = await dio.post<Map<String, dynamic>>(
        Apis.inquiryAuthLoginPath,
        data: const {
          'userId': 'dev-user',
          'email': 'meet@example.com',
          'role': 'user',
        },
      );

      final body = response.data;
      if (body == null) return false;

      String? token;
      // Common response shapes
      token = body['accessToken'] as String? ??
          body['token'] as String? ??
          body['access_token'] as String?;
      if (token == null && body['data'] is Map) {
        final data = body['data'] as Map;
        token = data['accessToken'] as String? ??
            data['token'] as String? ??
            data['access_token'] as String?;
      }
      if (token != null && token.trim().isNotEmpty) {
        SharedPrefUtils.setValue(SharedPrefUtilsKeys.userToken, token.trim());
        return true;
      }
      return false;
    } catch (e) {
      log('Login failed: $e');
      return false;
    } finally {
      _loginLock?.complete();
      _loginLock = null;
    }
  }
}
