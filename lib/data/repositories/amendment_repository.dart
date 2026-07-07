import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:travel_crm/core/network/inquiry_api_client.dart';
import 'package:travel_crm/data/models/amendment/amendment_search_response.dart';

/// Data access for the Manage Amendment screen (`GET /amendments/search`).
///
/// Mirrors the `DioException` → typed-exception contract used by
/// [MembersRepository] so the BLoC layer never touches Dio directly.
class AmendmentRepository {
  AmendmentRepository(this._apiClient);

  final InquiryApiClient _apiClient;

  /// Search amendments with the server-supported filters. All args are optional;
  /// null/empty values are dropped from the query string by [AmendmentSearchQuery].
  Future<AmendmentSearchResponse> searchAmendments({
    String? amendmentType,
    String? status,
    String? processedFrom,
    String? processedTo,
    int page = 1,
    int limit = 10,
    String sort = '-createdAt',
  }) async {
    try {
      return await _apiClient.searchAmendments(
        AmendmentSearchQuery(
          amendmentType: amendmentType,
          status: status,
          processedFrom: processedFrom,
          processedTo: processedTo,
          page: page,
          limit: limit,
          sort: sort,
        ).toQuery(),
      );
    } on DioException catch (e) {
      _handleDio(e, 'AmendmentRepository.searchAmendments');
      rethrow;
    }
  }

  void _handleDio(DioException e, String logName) {
    final status = e.response?.statusCode;
    final body = e.response?.data;
    if (status == 401) {
      developer.log('401 Unauthorized', name: logName);
      throw AmendmentUnauthorizedException();
    }
    if (status == 422 && body != null) {
      developer.log('422 response: $body', name: logName);
      throw AmendmentValidationException(_parseValidationError(body));
    }
    if (status == 400 && body != null) {
      developer.log('400 response: $body', name: logName);
      throw AmendmentApiException(_parseValidationError(body));
    }
    throw AmendmentApiException(
      e.message?.isNotEmpty == true
          ? e.message!
          : 'Could not reach the server. Try again.',
    );
  }

  /// Extracts a human message from the backend error envelope. Handles the
  /// documented `422` shape (`data.errors[] = {field, message}`) as well as the
  /// simpler `{message}` / `{data: {message}}` variants.
  static String _parseValidationError(dynamic data) {
    if (data is String) return data.isNotEmpty ? data : 'Validation failed';
    if (data is! Map) return 'Validation failed';

    // Documented shape: { status: fail, data: { message, errors: [...] } }.
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

    return 'Validation failed. Check the filters and try again.';
  }
}

class AmendmentUnauthorizedException implements Exception {
  @override
  String toString() => 'Session expired or invalid. Please log in again.';
}

/// 422 from `/amendments/search` — surfaces `data.errors[].message`
/// (e.g. "End date must be on or after the start date").
class AmendmentValidationException implements Exception {
  AmendmentValidationException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AmendmentApiException implements Exception {
  AmendmentApiException(this.message);
  final String message;
  @override
  String toString() => message;
}
