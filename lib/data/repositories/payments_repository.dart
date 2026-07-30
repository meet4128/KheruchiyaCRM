import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:travel_crm/core/network/inquiry_api_client.dart';
import 'package:travel_crm/data/models/inquiry/payment_plan_response.dart';
import 'package:travel_crm/data/models/payments/unverified_payments_response.dart';
import 'package:travel_crm/data/models/payments/verify_payment_request.dart';

/// Data access for the Accounting → Unverified Payments screen
/// (`GET /payments/unverified`).
///
/// Mirrors the `DioException` → typed-exception contract used by
/// [AmendmentRepository] so the BLoC layer never touches Dio directly.
class PaymentsRepository {
  PaymentsRepository(this._apiClient);

  final InquiryApiClient _apiClient;

  /// Lists sales-submitted payment plans awaiting verification. Paginated;
  /// search is applied client-side by the BLoC, not here.
  Future<UnverifiedPaymentsResponse> listUnverifiedPayments({
    int page = 1,
    int limit = 15,
    String sort = '-submittedAt',
  }) async {
    try {
      return await _apiClient.listUnverifiedPayments(
        UnverifiedPaymentsQuery(
          page: page,
          limit: limit,
          sort: sort,
        ).toQuery(),
      );
    } on DioException catch (e) {
      _handleDio(e, 'PaymentsRepository.listUnverifiedPayments');
      rethrow;
    }
  }

  /// Marks a payment plan verified (or sends it back to the Unverified queue
  /// when [verified] is false) via `PATCH /payments/{inquiryId}/verify`.
  Future<PaymentPlanResponse> verifyPayment({
    required String inquiryId,
    bool verified = true,
  }) async {
    try {
      return await _apiClient.verifyPayment(
        inquiryId,
        VerifyPaymentRequest(verified: verified),
      );
    } on DioException catch (e) {
      _handleDio(e, 'PaymentsRepository.verifyPayment');
      rethrow;
    }
  }

  void _handleDio(DioException e, String logName) {
    final status = e.response?.statusCode;
    final body = e.response?.data;
    if (status == 401) {
      developer.log('401 Unauthorized', name: logName);
      throw PaymentsUnauthorizedException();
    }
    if (status == 422 && body != null) {
      developer.log('422 response: $body', name: logName);
      throw PaymentsApiException(_parseError(body));
    }
    if (status == 400 && body != null) {
      developer.log('400 response: $body', name: logName);
      throw PaymentsApiException(_parseError(body));
    }
    throw PaymentsApiException(
      e.message?.isNotEmpty == true
          ? e.message!
          : 'Could not reach the server. Try again.',
    );
  }

  /// Extracts a human message from the backend error envelope. Handles the
  /// documented `422` shape (`data.errors[] = {field, message}`) as well as the
  /// simpler `{message}` / `{data: {message}}` variants.
  static String _parseError(dynamic data) {
    if (data is String) return data.isNotEmpty ? data : 'Request failed';
    if (data is! Map) return 'Request failed';

    final inner = data['data'];
    final scope = inner is Map ? inner : data;

    final errors = scope['errors'];
    if (errors is List && errors.isNotEmpty) {
      final parts = <String>[];
      for (final item in errors) {
        if (item is Map) {
          final field = item['field']?.toString();
          final message = item['message']?.toString() ?? '';
          parts.add(
            field != null && field.isNotEmpty ? '$field: $message' : message,
          );
        } else {
          parts.add(item.toString());
        }
      }
      final joined = parts.where((p) => p.trim().isNotEmpty).join(' • ');
      if (joined.isNotEmpty) return joined;
    }

    for (final key in ['message', 'error', 'detail', 'reason']) {
      final v = scope[key];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }

    return 'Something went wrong. Please try again.';
  }
}

class PaymentsUnauthorizedException implements Exception {
  @override
  String toString() => 'Session expired or invalid. Please log in again.';
}

class PaymentsApiException implements Exception {
  PaymentsApiException(this.message);
  final String message;
  @override
  String toString() => message;
}
