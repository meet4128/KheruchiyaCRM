import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:travel_crm/core/models/inquiry/create_inquiry_request.dart';
import 'package:travel_crm/core/network/inquiry_api_client.dart';

/// Repository for create-inquiry API. Handles API communication only; no UI logic.
class InquiryRepository {
  InquiryRepository(this.apiClient);

  final InquiryApiClient apiClient;

  Future<void> createInquiry(CreateInquiryRequest request) async {
    try {
      await apiClient.createInquiry(request);
    } on DioException catch (e) {
      // Surface server validation message from 422 response body
      if (e.response?.statusCode == 422 && e.response?.data != null) {
        final data = e.response!.data;
        developer.log('CreateInquiry 422 response: $data', name: 'InquiryRepository');
        final message = _parseValidationError(data);
        throw _ValidationException(message);
      }
      rethrow;
    }
  }

  /// Parses 422 body into a single user-facing message. Handles common API shapes.
  static String _parseValidationError(dynamic data) {
    if (data is String) return data.isNotEmpty ? data : 'Validation failed';
    if (data is! Map) return 'Validation failed';
    final map = data as Map;

    // Try common message keys (any case)
    final msgKeys = ['message', 'error', 'msg', 'detail', 'reason'];
    for (final key in msgKeys) {
      final v = map[key];
      if (v is String && v.trim().isNotEmpty) return v.trim();
      if (v is List && v.isNotEmpty) return v.map((e) => e.toString()).join('; ');
    }

    // Try common errors keys
    final errors = map['errors'] ?? map['error'] ?? map['details'] ?? map['validationErrors'] ?? map['field_errors'];
    if (errors is Map && errors.isNotEmpty) {
      final parts = <String>[];
      for (final entry in errors.entries) {
        final key = entry.key.toString();
        final val = entry.value is List ? (entry.value as List).join(', ') : entry.value.toString();
        parts.add('$key: $val');
      }
      return parts.join(' • ');
    }
    if (errors is List && errors.isNotEmpty) {
      return errors.map((e) => e.toString()).join(' • ');
    }

    return 'Validation failed. Check the form and try again.';
  }
}

/// Thrown when the server returns 422; message is shown to the user (no "Exception:" prefix).
class _ValidationException implements Exception {
  _ValidationException(this.message);
  final String message;
  @override
  String toString() => message;
}
