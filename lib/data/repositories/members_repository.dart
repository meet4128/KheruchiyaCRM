import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:travel_crm/core/network/inquiry_api_client.dart';
import 'package:travel_crm/data/models/members/create_member_request.dart';
import 'package:travel_crm/data/models/members/create_member_response.dart';
import 'package:travel_crm/data/models/members/list_members_response.dart';
import 'package:travel_crm/data/models/members/resend_invite_response.dart';
import 'package:travel_crm/data/models/members/update_member_request.dart';

class MembersRepository {
  MembersRepository(this._apiClient);

  final InquiryApiClient _apiClient;

  /// Creates a new member and (depending on [CreateMemberRequest.sendInvite])
  /// triggers the invite email. The returned envelope carries both the new
  /// member record and the [InviteResultDto] describing the email outcome —
  /// the caller surfaces "Invite sent to …" / "Member created, click resend"
  /// snackbars based on `response.data.invite.sent`.
  Future<CreateMemberResponse> createMember(CreateMemberRequest request) async {
    try {
      return await _apiClient.createMember(request);
    } on DioException catch (e) {
      _handleDio(e, 'MembersRepository.createMember');
      rethrow;
    }
  }

  Future<void> updateMember(String id, UpdateMemberRequest request) async {
    try {
      await _apiClient.updateMember(id, request);
    } on DioException catch (e) {
      _handleDio(e, 'MembersRepository.updateMember');
    }
  }

  /// Re-issues the invite token for [memberId] and emails the new link via
  /// the backend's configured email provider. Throws the same typed
  /// exceptions as create (`409 already-active`, `429 rate-limited`,
  /// `404 not-found`) so the team-list UI can render specific copy.
  Future<ResendInviteResponse> resendInvite(String memberId) async {
    try {
      return await _apiClient.resendMemberInvite(memberId);
    } on DioException catch (e) {
      _handleResendInviteDio(e);
      rethrow;
    }
  }

  Future<ListMembersResponse> listMembers({
    int page = 1,
    int limit = 10,
    String sort = '-createdAt',
    String? employmentStatus = 'active',
  }) async {
    try {
      return await _apiClient.listMembers(
        ListMembersQuery(
          page: page,
          limit: limit,
          sort: sort,
          employmentStatus: employmentStatus,
        ).toQuery(),
      );
    } on DioException catch (e) {
      _handleDio(e, 'MembersRepository.listMembers');
      rethrow;
    }
  }

  void _handleDio(DioException e, String logName) {
    final status = e.response?.statusCode;
    final body = e.response?.data;
    if (status == 401) {
      developer.log('401 Unauthorized', name: logName);
      throw MembersUnauthorizedException();
    }
    if (status == 409) {
      developer.log('409 Conflict: $body', name: logName);
      throw MembersConflictException(_parseValidationError(body));
    }
    if (status == 422 && body != null) {
      developer.log('422 response: $body', name: logName);
      throw MembersValidationException(_parseValidationError(body));
    }
    if (status == 400 && body != null) {
      developer.log('400 response: $body', name: logName);
      throw MembersApiException(_parseValidationError(body));
    }
    throw MembersApiException(
      e.message?.isNotEmpty == true ? e.message! : 'Could not reach the server. Try again.',
    );
  }

  /// Resend-invite has a richer error contract than the rest (409 / 429 /
  /// 404 each map to specific UX), so it gets its own translator.
  void _handleResendInviteDio(DioException e) {
    const logName = 'MembersRepository.resendInvite';
    final status = e.response?.statusCode;
    final body = e.response?.data;
    switch (status) {
      case 401:
        developer.log('401 Unauthorized', name: logName);
        throw MembersUnauthorizedException();
      case 403:
        throw MembersUnauthorizedException();
      case 404:
        throw MembersNotFoundException();
      case 400:
        throw MembersApiException(_parseValidationError(body));
      case 409:
        throw MembersAlreadyActiveException(
          _parseValidationError(body),
        );
      case 422:
        throw MembersValidationException(_parseValidationError(body));
      case 429:
        throw MembersRateLimitedException();
      default:
        throw MembersApiException(
          e.message?.isNotEmpty == true
              ? e.message!
              : 'Could not reach the server. Try again.',
        );
    }
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

/// 409 from `POST /members` — duplicate `employeeId` or `personalEmail`.
class MembersConflictException implements Exception {
  MembersConflictException(this.message);
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

/// 409 from `POST /members/:id/invitations/resend` — the member already
/// activated their account via a previous invite. Surface as
/// "This member already set their password."
class MembersAlreadyActiveException implements Exception {
  MembersAlreadyActiveException([
    this.message = 'This member already set their password.',
  ]);
  final String message;
  @override
  String toString() => message;
}

/// 429 from `POST /members/:id/invitations/resend` — admin tripped the
/// per-member / per-IP resend rate limit. Disable the icon briefly and
/// show a quiet "wait a moment" message.
class MembersRateLimitedException implements Exception {
  MembersRateLimitedException([
    this.message = 'Wait a moment before resending again.',
  ]);
  final String message;
  @override
  String toString() => message;
}

/// 404 from a member-scoped endpoint — id no longer maps to a record.
/// (Could happen if the list cache is stale.)
class MembersNotFoundException implements Exception {
  MembersNotFoundException([
    this.message = 'Member not found. Refresh and try again.',
  ]);
  final String message;
  @override
  String toString() => message;
}
