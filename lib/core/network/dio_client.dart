import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../utils/shared_pref_utils.dart';
import 'apis.dart';

class DioClient {
  static final Dio _dio = Dio();
  static const String contentType = 'application/json';

  static Dio getInstance() {
    _initializeInterceptors();
    return _dio;
  }

  static _initializeInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {

          debugPrint('URL:: ${options.uri.toString()}');

          Map<String, dynamic> header = {
            'Content-Type': contentType,
          };
          // Add authorization token only where needed
          if (options.uri.toString() != Apis.login ||
              options.uri.toString() != Apis.forgotPassword) {
            var token = SharedPrefUtils.getValue(SharedPrefUtilsKeys.userToken, '');
            if (token.isNotEmpty) {
              header.addAll(
                {
                  'Authorization': 'Bearer $token',
                },
              );
            }
          }
          options.headers = header;
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          return handler.next(e);
        },
      ),
    );
    _dio.interceptors.add(LogInterceptor(
      responseBody: true,
      requestBody: true,
      logPrint: (object) => log(object.toString()),
    ));
  }
}
