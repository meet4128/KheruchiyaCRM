import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:travel_crm/data/models/auth/auth_tokens_response.dart';
import '../utils/shared_pref_utils.dart';
import 'apis.dart';

/// Bumps every time a refresh-token attempt fails (or the retry that
/// followed a successful refresh still came back 401). The router watches
/// this via [GoRouter.refreshListenable] so it can bounce to `/login`
/// without each caller having to special-case session expiry.
///
/// Implementation detail: a [ValueNotifier<int>] keeps things trivially
/// listenable from GoRouter while avoiding stream wiring.
final ValueNotifier<int> sessionExpiredNotifier = ValueNotifier<int>(0);

class DioClient {
  static final Dio _dio = Dio(BaseOptions(baseUrl: Apis.inquiryBaseUrl));
  static const String contentType = 'application/json';

  static Completer<void>? _refreshTokenLock;

  static Dio getInstance() {
    _initializeInterceptors();
    return _dio;
  }

  /// True if this request should send Authorization Bearer.
  ///
  /// Public flows that must NEVER carry a stale Bearer (would let the server
  /// short-circuit anti-enumeration / rate-limit logic incorrectly):
  /// - login / refresh-token (existing)
  /// - forgot-password / token validate / set-password / reset-password
  ///
  /// Note: [AuthRepository] uses a fresh `Dio` instance for the public auth
  /// flows, so in practice these paths never hit this interceptor — the
  /// whitelist below is defensive in case someone wires a public endpoint
  /// through the global client by mistake.
  static bool _needsAuth(String uri) {
    if (uri.contains(Apis.inquiryAuthLoginPath)) return false;
    if (uri.contains(Apis.inquiryAuthRefreshTokenPath)) return false;
    if (uri.contains(Apis.inquiryAuthForgotPasswordPath)) return false;
    if (uri.contains(Apis.inquiryAuthTokenValidatePath)) return false;
    if (uri.contains(Apis.inquiryAuthSetPasswordPath)) return false;
    if (uri.contains(Apis.inquiryAuthResetPasswordPath)) return false;
    return true;
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
                } on DioException catch (retryError) {
                  // Refresh succeeded but the retried request is still 401
                  // → backend has invalidated this session (most likely a
                  // tokenVersion bump from a forced reset). Treat exactly
                  // like a refresh failure: drop the session.
                  if (retryError.response?.statusCode == 401) {
                    await _clearSession();
                    sessionExpiredNotifier.value++;
                  }
                  return handler.next(retryError);
                } catch (retryError) {
                  return handler.next(DioException(
                    requestOptions: e.requestOptions,
                    error: retryError,
                  ));
                }
              }
            }
            // Refresh-token call itself failed or returned no usable token
            // → session is dead. Wipe local creds and signal the router so
            // it can bounce to /login on the next redirect tick.
            await _clearSession();
            sessionExpiredNotifier.value++;
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

  /// Wipes locally cached auth state on a confirmed session-expiry signal.
  /// Keeps non-auth prefs alive (theme, etc.) by removing keys individually
  /// instead of `clearSharedPref()` so the app doesn't lose unrelated state.
  static Future<void> _clearSession() async {
    SharedPrefUtils.removeValue(SharedPrefUtilsKeys.userToken);
    SharedPrefUtils.removeValue(SharedPrefUtilsKeys.refreshToken);
    SharedPrefUtils.removeValue(SharedPrefUtilsKeys.userRole);
    SharedPrefUtils.removeValue(SharedPrefUtilsKeys.tokenVersion);
    SharedPrefUtils.removeValue(SharedPrefUtilsKeys.isLoggedIn);
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
