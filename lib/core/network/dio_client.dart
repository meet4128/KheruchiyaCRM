import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../utils/shared_pref_utils.dart';
import 'apis.dart';

class DioClient {
  static final Dio _dio = Dio(BaseOptions(baseUrl: Apis.baseUrl));
  static const String contentType = 'application/json';


  /// Dev fallback token for Create Inquiry API when user is not logged in. Remove when auth is wired.
  static const String _devAccessToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImRldi11c2VyIiwiZW1haWwiOiJtZWV0QGV4YW1wbGUuY29tIiwicm9sZSI6InVzZXIiLCJpYXQiOjE3NzMyMTY0OTEsImV4cCI6MTc3MzMwMjg5MX0.XfiX5easfDDI6F1x9i0IIpJnyAYla-gpSTj_ylEoMAQ';

  static Completer<void>? _refreshLock;

  static Dio getInstance() {
    _initializeInterceptors();
    return _dio;
  }

  /// True if this request should send Authorization Bearer (excludes login, forgotPassword, refresh).
  static bool _needsAuth(String uri) {
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
            var token =
                SharedPrefUtils.getValue(SharedPrefUtilsKeys.userToken, '');
            if (token.isEmpty) token = _devAccessToken;
            if (token.isNotEmpty) {
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
            final refreshed = await _refreshAccessToken();
            if (refreshed) {
              final token = SharedPrefUtils.getValue(
                  SharedPrefUtilsKeys.userToken, '');
              final headers = Map<String, dynamic>.from(e.requestOptions.headers);
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

  /// Calls refresh API, saves new access + refresh tokens. Returns true if successful.
  /// Uses a lock so only one refresh runs at a time; concurrent 401s wait for the same refresh.
  static Future<bool> _refreshAccessToken() async {
    if (_refreshLock != null && !_refreshLock!.isCompleted) {
      await _refreshLock!.future;
      final token =
          SharedPrefUtils.getValue(SharedPrefUtilsKeys.userToken, '');
      return token.isNotEmpty && token != _devAccessToken;
    }
    _refreshLock = Completer<void>();
    try {
      final refreshTokenValue =
          SharedPrefUtils.getValue(SharedPrefUtilsKeys.refreshToken, '')
              .toString();
      if (refreshTokenValue.isEmpty) {
        _refreshLock!.complete();
        _refreshLock = null;
        return false;
      }
      // Use a plain Dio so we don't add Bearer or trigger our interceptors
      final dio = Dio(BaseOptions(baseUrl: Apis.baseUrl));
      dio.options.headers['Content-Type'] = contentType;
      final path = Apis.refreshTokenUrl.replaceFirst(Apis.baseUrl, '');
      final response = await dio.post<Map<String, dynamic>>(
        path.isEmpty ? '/account/refresh' : path,
        data: {'refreshToken': refreshTokenValue},
      );
      if (response.data == null) {
        _refreshLock!.complete();
        _refreshLock = null;
        return false;
      }
      final data = response.data!;
      // Adjust keys if your backend uses different names (e.g. 'token', 'access_token')
      final accessToken = data['accessToken'] as String? ??
          data['token'] as String? ??
          data['access_token'] as String?;
      final newRefreshToken = data['refreshToken'] as String? ??
          data['refresh_token'] as String?;
      if (accessToken != null && accessToken.isNotEmpty) {
        SharedPrefUtils.setValue(SharedPrefUtilsKeys.userToken, accessToken);
        if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
          SharedPrefUtils.setValue(
              SharedPrefUtilsKeys.refreshToken, newRefreshToken);
        }
        _refreshLock!.complete();
        _refreshLock = null;
        return true;
      }
    } catch (e) {
      log('Token refresh failed: $e');
      // Optionally clear tokens to force re-login:
      // SharedPrefUtils.removeValue(SharedPrefUtilsKeys.userToken);
      // SharedPrefUtils.removeValue(SharedPrefUtilsKeys.refreshToken);
    }
    _refreshLock!.complete();
    _refreshLock = null;
    return false;
  }
}
