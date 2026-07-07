import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:travel_crm/core/network/inquiry_api_client.dart';
import 'package:travel_crm/data/models/calendar/create_reminder_request.dart';
import 'package:travel_crm/data/models/calendar/create_reminder_response.dart';

/// Data access for the Reminders tag. v1 needs create only
/// (`POST /inquiries/{inquiryId}/amendments/{amendmentId}/reminders`).
class ReminderRepository {
  ReminderRepository(this._apiClient);

  final InquiryApiClient _apiClient;

  Future<CreateReminderResponse> createReminder({
    required String inquiryId,
    required String amendmentId,
    required CreateReminderRequest request,
  }) async {
    try {
      return await _apiClient.createAmendmentReminder(inquiryId, amendmentId, request);
    } on DioException catch (e) {
      _handleDio(e, 'ReminderRepository.createReminder');
      rethrow;
    }
  }

  void _handleDio(DioException e, String logName) {
    final status = e.response?.statusCode;
    final body = e.response?.data;
    if (status == 401) {
      developer.log('401 Unauthorized', name: logName);
      throw ReminderUnauthorizedException();
    }
    if (status == 422 && body != null) {
      developer.log('422 response: $body', name: logName);
      throw ReminderValidationException(_parseValidationError(body));
    }
    if (status == 400 && body != null) {
      developer.log('400 response: $body', name: logName);
      throw ReminderApiException(_parseValidationError(body));
    }
    throw ReminderApiException(
      e.message?.isNotEmpty == true
          ? e.message!
          : 'Could not reach the server. Try again.',
    );
  }

  static String _parseValidationError(dynamic data) {
    if (data is String) return data.isNotEmpty ? data : 'Validation failed';
    if (data is! Map) return 'Validation failed';

    final inner = data['data'];
    final scope = inner is Map ? inner : data;

    final errors = scope['errors'];
    if (errors is List && errors.isNotEmpty) {
      final parts = <String>[];
      for (final item in errors) {
        if (item is Map) {
          final field = item['field']?.toString();
          final message = item['message']?.toString() ?? '';
          parts.add(field != null && field.isNotEmpty ? '$field: $message' : message);
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
    return 'Validation failed. Check the details and try again.';
  }
}

class ReminderUnauthorizedException implements Exception {
  @override
  String toString() => 'Session expired or invalid. Please log in again.';
}

class ReminderValidationException implements Exception {
  ReminderValidationException(this.message);
  final String message;
  @override
  String toString() => message;
}

class ReminderApiException implements Exception {
  ReminderApiException(this.message);
  final String message;
  @override
  String toString() => message;
}
