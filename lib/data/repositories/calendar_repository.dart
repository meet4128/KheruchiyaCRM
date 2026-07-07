import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:travel_crm/core/network/inquiry_api_client.dart';
import 'package:travel_crm/data/models/calendar/calendar_events_response.dart';

/// Data access for the Calendar screen (`GET /calendar/events`, Calendar tag).
/// Mirrors the `DioException` → typed-exception contract used across the app.
class CalendarRepository {
  CalendarRepository(this._apiClient);

  final InquiryApiClient _apiClient;

  /// Lists reminder occurrences within [from]..[to] (ISO 8601 date-time).
  Future<CalendarEventsResponse> listEvents({
    required String from,
    required String to,
    String? agent,
    String? status,
  }) async {
    try {
      return await _apiClient.listCalendarEvents(
        CalendarEventsQuery(
          from: from,
          to: to,
          agent: agent,
          status: status,
        ).toQuery(),
      );
    } on DioException catch (e) {
      _handleDio(e, 'CalendarRepository.listEvents');
      rethrow;
    }
  }

  void _handleDio(DioException e, String logName) {
    final status = e.response?.statusCode;
    final body = e.response?.data;
    if (status == 401) {
      developer.log('401 Unauthorized', name: logName);
      throw CalendarUnauthorizedException();
    }
    if (status == 422 && body != null) {
      developer.log('422 response: $body', name: logName);
      throw CalendarValidationException(_parseValidationError(body));
    }
    if (status == 400 && body != null) {
      developer.log('400 response: $body', name: logName);
      throw CalendarApiException(_parseValidationError(body));
    }
    throw CalendarApiException(
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

    return 'Validation failed. Check the details and try again.';
  }
}

class CalendarUnauthorizedException implements Exception {
  @override
  String toString() => 'Session expired or invalid. Please log in again.';
}

class CalendarValidationException implements Exception {
  CalendarValidationException(this.message);
  final String message;
  @override
  String toString() => message;
}

class CalendarApiException implements Exception {
  CalendarApiException(this.message);
  final String message;
  @override
  String toString() => message;
}
