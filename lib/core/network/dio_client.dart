import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:travel_crm/data/models/auth/auth_tokens_response.dart';
import '../utils/shared_pref_utils.dart';
import 'apis.dart';

class DioClient {
  static final Dio _dio = Dio(BaseOptions(baseUrl: Apis.baseUrl));
  static const String contentType = 'application/json';

  static Completer<void>? _refreshTokenLock;

  static Dio getInstance() {
    _initializeInterceptors();
    return _dio;
  }

  /// True if this request should send Authorization Bearer (excludes login, forgotPassword, refresh).
  static bool _needsAuth(String uri) {
    // Exclude inquiry-auth login too (no Bearer for this call).
    if (uri.contains(Apis.inquiryAuthLoginPath)) return false;
    if (uri.contains(Apis.inquiryAuthRefreshTokenPath)) return false;
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
            final refreshed = await _refreshTokenAndStoreAccessToken();
            if (refreshed) {
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

  /// Calls inquiry refresh-token API using stored refreshToken, saves new access token.
  /// Returns true if successful; false if refresh token is missing/invalid.
  static Future<bool> _refreshTokenAndStoreAccessToken() async {
    if (_refreshTokenLock != null && !_refreshTokenLock!.isCompleted) {
      await _refreshTokenLock!.future;
      final token =
          SharedPrefUtils.getValue(SharedPrefUtilsKeys.userToken, '');
      return token.toString().trim().isNotEmpty;
    }
    _refreshTokenLock = Completer<void>();
    try {
      final refreshToken = SharedPrefUtils.getValue(
          SharedPrefUtilsKeys.refreshToken, '');
      if (refreshToken.toString().trim().isEmpty) return false;

      final dio = Dio(BaseOptions(baseUrl: Apis.inquiryBaseUrl));
      dio.options.headers['Content-Type'] = contentType;

      final response = await dio.post<Map<String, dynamic>>(
        Apis.inquiryAuthRefreshTokenPath,
        data: {
          'refreshToken': refreshToken,
        },
      );

      final body = response.data;
      if (body == null) return false;
      final parsed = AuthTokensResponse.fromJson(body);
      final accessToken = parsed.data.accessToken.trim();
      final newRefreshToken = parsed.data.refreshToken.trim();
      if (accessToken.isEmpty) return false;
      SharedPrefUtils.setValue(SharedPrefUtilsKeys.userToken, accessToken);
      if (newRefreshToken.isNotEmpty) {
        SharedPrefUtils.setValue(SharedPrefUtilsKeys.refreshToken, newRefreshToken);
      }
      return true;
    } catch (e) {
      log('Refresh-token failed: $e');
      return false;
    } finally {
      _refreshTokenLock?.complete();
      _refreshTokenLock = null;
    }
  }
}
