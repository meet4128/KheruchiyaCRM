import 'package:dio/dio.dart';
import 'package:travel_crm/core/network/apis.dart';
import 'package:travel_crm/data/models/auth/auth_tokens_response.dart';

/// Thrown when [login] fails (network, HTTP error, or invalid payload).
class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Inquiry-server authentication ([Apis.inquiryBaseUrl]).
///
/// Uses a dedicated [Dio] instance (same approach as [DioClient] recovery login):
/// base URL is the inquiry host, not [Apis.baseUrl].
///
/// Request body combines the portal **email/password** fields with the
/// `userId` / `role` fields described in [Authorization.md]. If your backend
/// expects a different JSON contract, adjust [_loginBody] only.
class AuthRepository {
  AuthRepository();

  Future<AuthTokensResponse> login({
    required String email,
    required String password,
    required bool isAdmin,
  }) async {
    final dio = Dio(
      BaseOptions(
        baseUrl: Apis.inquiryBaseUrl,
        contentType: Headers.jsonContentType,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    try {
      final response = await dio.post<Map<String, dynamic>>(
        Apis.inquiryAuthLoginPath,
        data: _loginBody(email, password,isAdmin),
      );

      final body = response.data;
      if (body == null) {
        throw AuthException('Empty response from server');
      }

      final parsed = AuthTokensResponse.fromJson(body);
      if (parsed.data.accessToken.trim().isEmpty) {
        throw AuthException('Invalid token response');
      }
      return parsed;
    } on DioException catch (e) {
      throw AuthException(_messageFromDio(e));
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  Map<String, dynamic> _loginBody(String email, String password, bool isAdmin) {
    final trimmed = email.trim();
    return <String, dynamic>{
      'email': trimmed,
      'password': password,
      'userId': _userIdFromEmail(trimmed),
      'role': isAdmin?'admin':'user',
    };
  }
}

String _userIdFromEmail(String email) {
  final at = email.indexOf('@');
  if (at <= 0) return 'user';
  return email.substring(0, at);
}

String _messageFromDio(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Request timed out. Check your connection and try again.';
    case DioExceptionType.connectionError:
      return 'Could not reach the server. Check the address or your network.';
    case DioExceptionType.cancel:
      return 'Request was cancelled.';
    case DioExceptionType.badCertificate:
      return 'Secure connection failed.';
    case DioExceptionType.badResponse:
    case DioExceptionType.unknown:
      break;
  }

  final status = e.response?.statusCode;
  final data = e.response?.data;

  if (data is Map) {
    final fromMap = _messageFromErrorMap(data);
    if (fromMap != null && fromMap.isNotEmpty) return fromMap;
  }
  if (data is String && data.trim().isNotEmpty) {
    final t = data.trim();
    if (t.length < 400) return t;
    return '${t.substring(0, 397)}…';
  }

  if (status != null) {
    return switch (status) {
      401 => 'Invalid email or password.',
      403 => 'Access denied.',
      404 => 'Login service not found.',
      422 => 'Invalid login data.',
      >= 500 => 'Server error ($status). Please try again later.',
      _ => 'Login failed ($status)',
    };
  }

  if (e.message != null && e.message!.trim().isNotEmpty) {
    return e.message!.trim();
  }
  return 'Login failed. Please try again.';
}

/// Picks a human-readable message from common API error JSON shapes.
String? _messageFromErrorMap(Map<dynamic, dynamic> data) {
  for (final key in ['message', 'error', 'detail', 'title', 'description']) {
    final v = data[key];
    if (v is String && v.trim().isNotEmpty) return v.trim();
  }
  final errors = data['errors'];
  if (errors is List && errors.isNotEmpty) {
    final first = errors.first;
    if (first is String && first.trim().isNotEmpty) return first.trim();
    if (first is Map) return _messageFromErrorMap(first);
  }
  if (errors is Map && errors.isNotEmpty) {
    final firstVal = errors.values.first;
    if (firstVal is List && firstVal.isNotEmpty) {
      final el = firstVal.first;
      if (el is String) return el;
      return el.toString();
    }
    return firstVal.toString();
  }
  return null;
}
