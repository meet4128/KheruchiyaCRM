import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:travel_crm/core/network/inquiry_api_client.dart';
import 'package:travel_crm/data/models/members/create_member_request.dart';
import 'package:travel_crm/data/models/members/update_member_request.dart';

class MembersRepository {
  MembersRepository(this._apiClient);

  final InquiryApiClient _apiClient;

  Future<void> createMember(CreateMemberRequest request) async {
    try {
      await _apiClient.createMember(request);
    } on DioException catch (e) {
      _handleDio(e, 'MembersRepository.createMember');
    }
  }

  Future<void> updateMember(String id, UpdateMemberRequest request) async {
    try {
      await _apiClient.updateMember(id, request);
    } on DioException catch (e) {
      _handleDio(e, 'MembersRepository.updateMember');
    }
  }

  void _handleDio(DioException e, String logName) {
    if (e.response?.statusCode == 401) {
      developer.log('401 Unauthorized', name: logName);
      throw MembersUnauthorizedException();
    }
    if (e.response?.statusCode == 422 && e.response?.data != null) {
      final data = e.response!.data;
      developer.log('422 response: $data', name: logName);
      throw MembersValidationException(_parseValidationError(data));
    }
    throw MembersApiException(
      e.message?.isNotEmpty == true ? e.message! : 'Could not reach the server. Try again.',
    );
  }

  static String _parseValidationError(dynamic data) {
    if (data is String) return data.isNotEmpty ? data : 'Validation failed';
    if (data is! Map) return 'Validation failed';
    final map = data;

    final msgKeys = ['message', 'error', 'msg', 'detail', 'reason'];
    for (final key in msgKeys) {
      final v = map[key];
      if (v is String && v.trim().isNotEmpty) return v.trim();
      if (v is List && v.isNotEmpty) return v.map((e) => e.toString()).join('; ');
    }

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

class MembersUnauthorizedException implements Exception {
  @override
  String toString() => 'Session expired or invalid. Please log in again.';
}

class MembersValidationException implements Exception {
  MembersValidationException(this.message);
  final String message;
  @override
  String toString() => message;
}

class MembersApiException implements Exception {
  MembersApiException(this.message);
  final String message;
  @override
  String toString() => message;
}
