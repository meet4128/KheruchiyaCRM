import 'package:dio/dio.dart' hide Headers;

import '../constants/string_constants.dart';

class ServerError implements Exception {
  final int _errorCode = 0;
  static String _errorMessage = StringConstant.somethingWentWrong;

  ServerError.withError({required DioException error}) {
    handleError(error);
  }

  int get errorCode {
    return _errorCode;
  }

  static Future<String> handleError(DioException error) async {
    // Suppress 404 errors - return empty string to prevent snackbar messages
    if (error.response?.statusCode == 404) {
      return '';
    }

    switch (error.type) {
      case DioExceptionType.cancel:
        _errorMessage = StringConstant.connectionTimeout;
        break;
      case DioExceptionType.connectionTimeout:
        _errorMessage = StringConstant.connectionTimeout;
        break;
      case DioExceptionType.unknown:
        if (error.response != null) {
          _errorMessage = error.response?.statusMessage ?? '';
        }
        break;
      case DioExceptionType.receiveTimeout:
        _errorMessage = StringConstant.connectionTimeout;
        break;
      case DioExceptionType.badResponse:
        if (error.response != null) {
          _errorMessage = StringConstant.badResponse;
        }
        break;
      case DioExceptionType.sendTimeout:
        _errorMessage = StringConstant.connectionTimeout;
        break;
      case DioExceptionType.badCertificate:
        _errorMessage = StringConstant.somethingWentWrong;
        break;
      case DioExceptionType.connectionError:
        _errorMessage = StringConstant.somethingWentWrong;
        break;
    }
    if (_errorMessage.isEmpty) {
      _errorMessage = StringConstant.somethingWentWrong;
    }
    return _errorMessage;
  }
}
