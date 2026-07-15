import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:travel_crm/core/models/inquiry/create_inquiry_request.dart';
import 'package:travel_crm/core/network/inquiry_api_client.dart';
import 'package:travel_crm/data/models/amendment/amendment_detail_dto.dart';
import 'package:travel_crm/data/models/amendment/amendment_notes_response.dart';
import 'package:travel_crm/data/models/amendment/finalize_amendment_request.dart';
import 'package:travel_crm/data/models/amendment/finalize_amendment_response.dart';
import 'package:travel_crm/data/models/amendment/send_whatsapp_message_request.dart';
import 'package:travel_crm/data/models/amendment/session_messages_response.dart';
import 'package:travel_crm/data/models/amendment/session_note_request.dart';
import 'package:travel_crm/data/models/amendment/upload_session_file_data.dart';
import 'package:travel_crm/data/models/inquiry/assign_inquiry_request.dart';
import 'package:travel_crm/data/models/inquiry/inquiry_by_phone_response.dart';
import 'package:travel_crm/data/models/inquiry/inquiry_detail_response.dart';
import 'package:travel_crm/data/models/inquiry/list_inquiries_response.dart';
import 'package:travel_crm/data/models/inquiry/payment_plan_response.dart';
import 'package:travel_crm/data/models/inquiry/payment_proof_upload_response.dart';
import 'package:travel_crm/data/models/inquiry/update_payment_plan_request.dart';
import 'package:travel_crm/data/repositories/inquiry_repository_exceptions.dart';

export 'inquiry_repository_exceptions.dart';

/// Repository for inquiry APIs. Handles API communication only; no UI logic.
class InquiryRepository {
  InquiryRepository(this.apiClient);

  final InquiryApiClient apiClient;

  Future<InquiryDetailResponse> createInquiry(CreateInquiryRequest request) async {
    try {
      return await apiClient.createInquiry(request);
    } on DioException catch (e) {
      throw _mapDioException(e, logTag: 'CreateInquiry');
    }
  }

  Future<ListInquiriesResponse> listInquiries(ListInquiriesQuery query) async {
    try {
      return await apiClient.listInquiries(query.toQuery());
    } on DioException catch (e) {
      throw _mapDioException(e, logTag: 'ListInquiries');
    }
  }

  /// Assigns [inquiryId] to member [userId] (`PATCH /inquiries/{id}/assign`).
  /// Admin/sales only — a `403` maps to [InquiryForbiddenException], `422` to
  /// [InquiryValidationException]. Returns the updated inquiry.
  Future<InquiryDetailResponse> assignInquiry(
    String inquiryId,
    String userId,
  ) async {
    try {
      return await apiClient.assignInquiry(
        inquiryId,
        AssignInquiryRequest(userId: userId),
      );
    } on DioException catch (e) {
      throw _mapDioException(e, logTag: 'AssignInquiry');
    }
  }

  /// Looks up existing inquiries by phone number for form auto-fill.
  /// Returns an empty `items` list (not an error) when no inquiry matches.
  Future<InquiryByPhoneResponse> searchInquiriesByPhone(
    InquiryByPhoneQuery query,
  ) async {
    try {
      return await apiClient.getInquiriesByPhone(query.toQuery());
    } on DioException catch (e) {
      throw _mapDioException(e, logTag: 'SearchInquiriesByPhone');
    }
  }

  Future<InquiryDetailResponse> getInquiryDetail(String inquiryId) async {
    try {
      return await apiClient.getInquiryDetail(inquiryId);
    } on DioException catch (e) {
      throw _mapDioException(e, logTag: 'GetInquiryDetail');
    }
  }

  Future<SessionMessagesResponse> listSessionMessages({
    required String inquiryId,
    required String sessionId,
    int page = 1,
    int limit = 50,
    String sort = 'createdAt',
  }) async {
    try {
      return await apiClient.listSessionMessages(
        inquiryId,
        sessionId,
        {'page': page, 'limit': limit, 'sort': sort},
      );
    } on DioException catch (e) {
      throw _mapDioException(e, logTag: 'ListSessionMessages');
    }
  }

  Future<AmendmentDetailResponse> getAmendmentDetail({
    required String inquiryId,
    required String amendmentId,
  }) async {
    try {
      return await apiClient.getAmendmentDetail(inquiryId, amendmentId);
    } on DioException catch (e) {
      throw _mapDioException(e, logTag: 'GetAmendmentDetail');
    }
  }

  Future<AmendmentNotesResponse> listAmendmentNotes({
    required String inquiryId,
    required String amendmentId,
  }) async {
    try {
      return await apiClient.listAmendmentNotes(inquiryId, amendmentId);
    } on DioException catch (e) {
      throw _mapDioException(e, logTag: 'ListAmendmentNotes');
    }
  }

  Future<SessionMessagesResponse> listAmendmentMessages({
    required String inquiryId,
    required String amendmentId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      return await apiClient.listAmendmentMessages(
        inquiryId,
        amendmentId,
        {'page': page, 'limit': limit},
      );
    } on DioException catch (e) {
      throw _mapDioException(e, logTag: 'ListAmendmentMessages');
    }
  }

  Future<void> sendWhatsappMessage(SendWhatsappMessageRequest request) async {
    try {
      await apiClient.sendWhatsappMessage(request);
    } on DioException catch (e) {
      throw _mapDioException(e, logTag: 'SendWhatsappMessage');
    }
  }

  Future<SessionMessagesResponse> listWhatsappMessages({
    required String peerPhone,
    int page = 1,
    int limit = 50,
    String sort = 'createdAt',
  }) async {
    try {
      return await apiClient.listWhatsappMessages(
        peerPhone,
        {'page': page, 'limit': limit, 'sort': sort},
      );
    } on DioException catch (e) {
      throw _mapDioException(e, logTag: 'ListWhatsappMessages');
    }
  }

  Future<FinalizeAmendmentResponse> finalizeAmendment({
    required String inquiryId,
    required FinalizeAmendmentRequest request,
  }) async {
    try {
      return await apiClient.finalizeAmendment(inquiryId, request);
    } on DioException catch (e) {
      throw _mapDioException(e, logTag: 'FinalizeAmendment');
    }
  }

  Future<void> addSessionNote({
    required String inquiryId,
    required String sessionId,
    required String text,
  }) async {
    try {
      await apiClient.addSessionNote(
        inquiryId,
        sessionId,
        SessionNoteRequest(text: text),
      );
    } on DioException catch (e) {
      throw _mapDioException(e, logTag: 'AddSessionNote');
    }
  }

  Future<UploadSessionFileResponse> uploadSessionFile({
    required String inquiryId,
    required String sessionId,
    required MultipartFile file,
  }) async {
    try {
      return await apiClient.uploadSessionFile(inquiryId, sessionId, file);
    } on DioException catch (e) {
      throw _mapDioException(e, logTag: 'UploadSessionFile');
    }
  }

  Future<PaymentPlanResponse> getPaymentPlan(String inquiryId) async {
    try {
      return await apiClient.getPaymentPlan(inquiryId);
    } on DioException catch (e) {
      throw _mapDioException(e, logTag: 'GetPaymentPlan');
    }
  }

  Future<PaymentPlanResponse> updatePaymentPlan({
    required String inquiryId,
    required UpdatePaymentPlanRequest request,
  }) async {
    try {
      return await apiClient.updatePaymentPlan(inquiryId, request);
    } on DioException catch (e) {
      throw _mapDioException(e, logTag: 'UpdatePaymentPlan');
    }
  }

  Future<PaymentProofUploadResponse> uploadPaymentProof({
    required String inquiryId,
    required MultipartFile file,
  }) async {
    try {
      return await apiClient.uploadPaymentProof(inquiryId, file);
    } on DioException catch (e) {
      throw _mapDioException(e, logTag: 'UploadPaymentProof');
    }
  }

  Exception _mapDioException(DioException e, {required String logTag}) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    developer.log('$logTag error $status: $data', name: 'InquiryRepository');

    if (status == 401) return InquiryUnauthorizedException();
    if (status == 403) {
      return InquiryForbiddenException(
        _parseApiMessage(data) ?? 'Sales or admin access required for WhatsApp messaging.',
      );
    }
    if (status == 502) {
      return InquiryServiceUnavailableException(
        _parseMessage(data) ?? 'WhatsApp service unavailable.',
      );
    }
    if (status == 422 && data != null) {
      return InquiryValidationException(_parseValidationError(data));
    }
  return e;
  }

  static String _parseValidationError(dynamic data) {
    if (data is String) return data.isNotEmpty ? data : 'Validation failed';
    if (data is! Map) return 'Validation failed';
    final map = Map<String, dynamic>.from(data);

    final msg = _parseMessage(map);
    if (msg != null) return msg;

    final errors = map['errors'] ??
        map['error'] ??
        map['details'] ??
        map['validationErrors'] ??
        map['field_errors'];
    if (errors is Map && errors.isNotEmpty) {
      final parts = <String>[];
      for (final entry in errors.entries) {
        final key = entry.key.toString();
        final val =
            entry.value is List ? (entry.value as List).join(', ') : entry.value.toString();
        parts.add('$key: $val');
      }
      return parts.join(' • ');
    }
    if (errors is List && errors.isNotEmpty) {
      return errors.map((e) => e.toString()).join(' • ');
    }

    final nested = map['data'];
    if (nested is Map) {
      final nestedMsg = _parseMessage(Map<String, dynamic>.from(nested));
      if (nestedMsg != null) return nestedMsg;
    }

    return 'Validation failed. Check the form and try again.';
  }

  static String? _parseApiMessage(dynamic data) {
    if (data is String && data.trim().isNotEmpty) return data.trim();
    if (data is! Map) return null;
    final map = Map<String, dynamic>.from(data);
    final msg = _parseMessage(map);
    if (msg != null) return msg;
    final nested = map['data'];
    if (nested is Map) {
      return _parseMessage(Map<String, dynamic>.from(nested));
    }
    return null;
  }

  static String? _parseMessage(Map<String, dynamic> map) {
    for (final key in ['message', 'error', 'msg', 'detail', 'reason']) {
      final v = map[key];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    return null;
  }
}
