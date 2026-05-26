import 'package:dio/dio.dart';
import 'package:travel_crm/core/network/apis.dart';
import 'package:travel_crm/data/models/auth/auth_tokens_response.dart';
import 'package:travel_crm/data/models/auth/forgot_password_request.dart';
import 'package:travel_crm/data/models/auth/reset_password_request.dart';
import 'package:travel_crm/data/models/auth/set_password_request.dart';
import 'package:travel_crm/data/models/auth/token_purpose.dart';
import 'package:travel_crm/data/models/auth/token_validate_response.dart';

/// Thrown when [login] fails (network, HTTP error, or invalid payload).
class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 422 — per-field validation errors returned by the server. Used by login
/// (missing email / password fields) and any other endpoint where the API
/// returns `data.errors[]` with `{ field, message }` entries.
class AuthValidationException extends AuthException {
  AuthValidationException(super.message, this.fieldErrors);

  /// Field name (e.g. `email`, `password`) → server-provided message.
  final Map<String, String> fieldErrors;
}

/// 400 — server says the token doesn't exist / never existed / wrong purpose.
class TokenInvalidException extends AuthException {
  TokenInvalidException([super.message = 'This link is invalid.']);
}

/// 410 — token expired past its TTL window. Surface a "request a new link" CTA.
class TokenExpiredException extends AuthException {
  TokenExpiredException([super.message = 'This link has expired.']);
}

/// 410 — token was already consumed (single-use enforcement on the server).
class TokenAlreadyUsedException extends AuthException {
  TokenAlreadyUsedException([
    super.message = 'This link has already been used.',
  ]);
}

/// 422 — password failed the server-side policy (length / complexity).
/// Carries the exact server message so the page can render an inline error
/// under the password field instead of a generic banner.
class WeakPasswordException extends AuthException {
  WeakPasswordException(super.fieldMessage);
}

/// 422 (reset-password only) — user tried to set the same password they
/// already have on record. We never know the current password, only the
/// server can detect this.
class SamePasswordException extends AuthException {
  SamePasswordException([
    super.message =
        'Please choose a different password than your current one.',
  ]);
}

/// 429 — server-side rate limit kicked in. Caller should disable the submit
/// button for a moment and surface a "try again later" message.
class RateLimitedException extends AuthException {
  RateLimitedException([
    super.message = 'Too many attempts. Please try again later.',
  ]);
}

/// Inquiry-server authentication ([Apis.inquiryBaseUrl]).
///
/// Every method here uses a **fresh** [Dio] instance with no global interceptor
/// so that public flows (login, forgot/set/reset-password, token validate)
/// never accidentally carry a stale Bearer token from a previous session.
/// This is the same pattern the original [login] used; we just generalised it.
class AuthRepository {
  AuthRepository();

  // ────────────────────────────────────────────────────────────────────────
  // Login
  // ────────────────────────────────────────────────────────────────────────

  /// Logs in with the new contract: body is strictly `{ email, password }`.
  /// The server derives the user's role from the member record and returns
  /// it on `response.data.user.role`. The Flutter side never tells the server
  /// what role to assume.
  Future<AuthTokensResponse> login({
    required String email,
    required String password,
  }) async {
    final dio = _publicDio();

    try {
      final response = await dio.post<Map<String, dynamic>>(
        Apis.inquiryAuthLoginPath,
        data: <String, dynamic>{
          'email': email.trim(),
          'password': password,
        },
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
      throw _translateLoginDioException(e);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // Forgot password — public, always 200 (anti-enumeration)
  // ────────────────────────────────────────────────────────────────────────

  /// Requests a password-reset email. The backend always returns 200 even
  /// when the email doesn't match an active member — so the caller should
  /// emit a `success` state regardless of "did this email exist?" and show
  /// the universal "If an account exists…" copy.
  ///
  /// The only exceptions worth surfacing are network failures and 429.
  Future<void> forgotPassword({required String email}) async {
    final dio = _publicDio();

    try {
      await dio.post<Map<String, dynamic>>(
        Apis.inquiryAuthForgotPasswordPath,
        data: ForgotPasswordRequest(email: email.trim()).toJson(),
      );
    } on DioException catch (e) {
      throw _translateTokenDioException(e);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // Token validation — used by Set / Reset Password pages on mount
  // ────────────────────────────────────────────────────────────────────────

  /// Verifies an invite / reset token before the page shows the form. Throws
  /// a specific [TokenInvalidException] / [TokenExpiredException] /
  /// [TokenAlreadyUsedException] so the page can render a precise error
  /// screen instead of a generic banner.
  Future<TokenValidateResponse> validateToken({
    required String token,
    required TokenPurpose purpose,
  }) async {
    final dio = _publicDio();

    try {
      final response = await dio.get<Map<String, dynamic>>(
        Apis.inquiryAuthTokenValidatePath,
        queryParameters: <String, dynamic>{
          'token': token,
          'purpose': purpose.wireValue,
        },
      );

      final body = response.data;
      if (body == null) throw TokenInvalidException();
      return TokenValidateResponse.fromJson(body);
    } on DioException catch (e) {
      throw _translateTokenDioException(e);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // Set Password — consume an `invite` token
  // ────────────────────────────────────────────────────────────────────────

  /// Submits the new password for a newly-invited member. On success the
  /// backend marks the member active, invalidates the token, and the caller
  /// should route to `/login`.
  Future<void> setPassword({
    required String token,
    required String password,
  }) async {
    final dio = _publicDio();

    try {
      await dio.post<Map<String, dynamic>>(
        Apis.inquiryAuthSetPasswordPath,
        data: SetPasswordRequest(token: token, password: password).toJson(),
      );
    } on DioException catch (e) {
      throw _translateTokenDioException(e);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // Reset Password — consume a `reset` token
  // ────────────────────────────────────────────────────────────────────────

  /// Submits the new password during a forgot-password flow. Distinct from
  /// [setPassword] because the server may surface [SamePasswordException]
  /// here ("don't reuse the current password").
  Future<void> resetPassword({
    required String token,
    required String password,
  }) async {
    final dio = _publicDio();

    try {
      await dio.post<Map<String, dynamic>>(
        Apis.inquiryAuthResetPasswordPath,
        data: ResetPasswordRequest(token: token, password: password).toJson(),
      );
    } on DioException catch (e) {
      throw _translateTokenDioException(e);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // Helpers
  // ────────────────────────────────────────────────────────────────────────

  /// Creates a fresh [Dio] instance that bypasses the global [DioClient]
  /// interceptor. Used by every method in this repository because all the
  /// flows here are public — they must never carry a stale Bearer token.
  Dio _publicDio() => Dio(
        BaseOptions(
          baseUrl: Apis.inquiryBaseUrl,
          contentType: Headers.jsonContentType,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
}

// ────────────────────────────────────────────────────────────────────────────
// Error translation — login vs token endpoints
// ────────────────────────────────────────────────────────────────────────────

/// Login-specific [DioException] → [AuthException] mapping.
///
/// Key contract points:
/// - 401 ⇒ always the literal `'Invalid email or password.'` (anti-enumeration).
/// - 422 ⇒ [AuthValidationException] carrying per-field errors so the bloc
///   can route them to `emailError` / `passwordError` instead of a banner.
/// - 429 ⇒ [RateLimitedException] with the server message.
AuthException _translateLoginDioException(DioException e) {
  final transport = _transportFailure(e);
  if (transport != null) return AuthException(transport);

  final status = e.response?.statusCode;
  final data = e.response?.data;

  switch (status) {
    case 401:
      return AuthException('Invalid email or password.');
    case 422:
      return _validationExceptionFrom(data);
    case 429:
      return RateLimitedException(
        _stringFromData(data) ??
            'Too many login attempts, please try again later.',
      );
  }

  return AuthException(_fallbackMessage(data, status, e));
}

/// Mapping for token-based endpoints — validate, set-password, reset-password,
/// forgot-password. Distinguishes between 400 (invalid), 410 (expired/used),
/// 422 (weak password / same-as-current), 429 (rate-limited).
AuthException _translateTokenDioException(DioException e) {
  final transport = _transportFailure(e);
  if (transport != null) return AuthException(transport);

  final status = e.response?.statusCode;
  final data = e.response?.data;
  final message = _stringFromData(data);

  switch (status) {
    case 400:
      return TokenInvalidException(message ?? 'This link is invalid.');
    case 410:
      // Server tells us which 410 it is via the message body — sniff for
      // "used" / "already" first, fall back to the expired variant.
      final lower = (message ?? '').toLowerCase();
      if (lower.contains('used') || lower.contains('already')) {
        return TokenAlreadyUsedException(message!);
      }
      return TokenExpiredException(message ?? 'This link has expired.');
    case 422:
      // Could be a weak password OR a same-as-current message on reset.
      final lower = (message ?? '').toLowerCase();
      if (lower.contains('different') || lower.contains('current password')) {
        return SamePasswordException(message!);
      }
      // Try to extract a field-level message (e.g. errors[0].field == 'password').
      final fieldMessage = _firstFieldErrorMessage(data, 'password');
      return WeakPasswordException(
        fieldMessage ?? message ?? 'Password is too weak.',
      );
    case 429:
      return RateLimitedException(
        message ?? 'Too many attempts. Please try again later.',
      );
  }

  return AuthException(_fallbackMessage(data, status, e));
}

// ────────────────────────────────────────────────────────────────────────────
// Low-level decoders
// ────────────────────────────────────────────────────────────────────────────

/// Returns a transport-layer error message (timeout / connection failure /
/// cancel / cert error), or `null` if the failure is an HTTP response we
/// should decode further.
String? _transportFailure(DioException e) {
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
      return null;
  }
}

/// Last-resort message when no specific status branch matched.
String _fallbackMessage(dynamic data, int? status, DioException e) {
  final fromBody = _stringFromData(data);
  if (fromBody != null && fromBody.isNotEmpty) return fromBody;
  if (status != null) {
    return switch (status) {
      403 => 'Access denied.',
      404 => 'Service not found.',
      >= 500 => 'Server error ($status). Please try again later.',
      _ => 'Request failed ($status).',
    };
  }
  if (e.message != null && e.message!.trim().isNotEmpty) {
    return e.message!.trim();
  }
  return 'Request failed. Please try again.';
}

/// Best-effort extraction of a human message from a typical error JSON body.
String? _stringFromData(dynamic data) {
  if (data is Map) {
    final fromMap = _messageFromErrorMap(data);
    if (fromMap != null && fromMap.trim().isNotEmpty) return fromMap.trim();
  }
  if (data is String && data.trim().isNotEmpty) {
    final t = data.trim();
    return t.length < 400 ? t : '${t.substring(0, 397)}…';
  }
  return null;
}

/// Parses a 422 body shaped as
/// `{ status, data: { message, errors: [{ field, message }] } }`
/// into an [AuthValidationException] with the per-field map populated.
AuthValidationException _validationExceptionFrom(dynamic data) {
  final fieldErrors = <String, String>{};
  final topMessage = _stringFromData(data) ?? 'Validation failed.';

  if (data is Map) {
    final dataNode = data['data'];
    final errors = dataNode is Map ? dataNode['errors'] : data['errors'];
    if (errors is List) {
      for (final entry in errors) {
        if (entry is Map) {
          final field = entry['field'];
          final msg = entry['message'];
          if (field is String && msg is String) {
            fieldErrors[field] = msg;
          }
        }
      }
    }
  }

  return AuthValidationException(topMessage, fieldErrors);
}

/// Extracts the message of the first `errors[]` entry whose `field` matches
/// [fieldName], or `null` if no such entry exists. Used to surface
/// password-specific 422 details on set/reset endpoints.
String? _firstFieldErrorMessage(dynamic data, String fieldName) {
  if (data is! Map) return null;
  final dataNode = data['data'];
  final errors = dataNode is Map ? dataNode['errors'] : data['errors'];
  if (errors is List) {
    for (final entry in errors) {
      if (entry is Map &&
          entry['field'] == fieldName &&
          entry['message'] is String) {
        return (entry['message'] as String).trim();
      }
    }
  }
  return null;
}

/// Picks a human-readable message from common API error JSON shapes.
String? _messageFromErrorMap(Map<dynamic, dynamic> data) {
  // Drill into `data` envelope first if present (the inquiry server wraps
  // most error bodies as `{ status, data: { message, errors } }`).
  final inner = data['data'];
  if (inner is Map) {
    final fromInner = _messageFromErrorMap(inner);
    if (fromInner != null && fromInner.isNotEmpty) return fromInner;
  }

  for (final key in ['message', 'error', 'detail', 'title', 'description']) {
    final v = data[key];
    if (v is String && v.trim().isNotEmpty) return v.trim();
  }
  final errors = data['errors'];
  if (errors is List && errors.isNotEmpty) {
    final first = errors.first;
    if (first is String && first.trim().isNotEmpty) return first.trim();
    if (first is Map) {
      final msg = first['message'];
      if (msg is String && msg.trim().isNotEmpty) return msg.trim();
      return _messageFromErrorMap(first);
    }
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
