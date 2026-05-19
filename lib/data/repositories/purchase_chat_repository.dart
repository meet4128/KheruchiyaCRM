import 'package:dio/dio.dart';
import 'package:travel_crm/core/network/inquiry_api_client.dart';
import 'package:travel_crm/data/models/members/member_directory_response.dart';
import 'package:travel_crm/data/models/purchase_chat/open_purchase_chat_request.dart';
import 'package:travel_crm/data/models/purchase_chat/open_purchase_chat_response.dart';
import 'package:travel_crm/data/models/purchase_chat/purchase_chat_inbox_response.dart';
import 'package:travel_crm/data/models/purchase_chat/purchase_chat_messages_response.dart';
import 'package:travel_crm/data/models/purchase_chat/send_purchase_chat_message_request.dart';
import 'package:travel_crm/data/models/purchase_chat/send_purchase_chat_message_response.dart';
import 'package:travel_crm/data/models/purchase_chat/upload_purchase_chat_file_data.dart';
import 'package:travel_crm/data/repositories/inquiry_repository_exceptions.dart';

/// Purchase team directory + inquiry-scoped purchase chat APIs.
class PurchaseChatRepository {
  PurchaseChatRepository(this._apiClient);

  final InquiryApiClient _apiClient;

  Future<MemberDirectoryResponse> getMemberDirectory({
    String department = 'Purchase',
    String? role,
    int page = 1,
    int limit = 50,
    String? employmentStatus = 'active',
    String? search,
  }) async {
    try {
      return await _apiClient.getMemberDirectory(
        MemberDirectoryQuery(
          department: department,
          role: role,
          page: page,
          limit: limit,
          employmentStatus: employmentStatus,
          search: search,
        ).toQuery(),
      );
    } on DioException catch (e) {
      throw _mapDio(e, 'GetMemberDirectory');
    }
  }

  Future<OpenPurchaseChatResponse> openThread({
    required String inquiryId,
    required String purchaseTeamMemberId,
  }) async {
    try {
      return await _apiClient.openPurchaseChat(
        inquiryId,
        OpenPurchaseChatRequest(purchaseTeamMemberId: purchaseTeamMemberId),
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 409) {
        rethrow;
      }
      throw _mapDio(e, 'OpenPurchaseChat');
    }
  }

  Future<PurchaseChatInboxResponse> listPurchaseChats({
    required String inquiryId,
    String? purchaseTeamMemberId,
  }) async {
    try {
      return await _apiClient.listPurchaseChats(inquiryId, purchaseTeamMemberId);
    } on DioException catch (e) {
      throw _mapDio(e, 'ListPurchaseChats');
    }
  }

  Future<PurchaseChatMessagesResponse> listMessages({
    required String inquiryId,
    required String purchaseTeamMemberId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      return await _apiClient.listPurchaseChatMessages(
        inquiryId,
        purchaseTeamMemberId,
        {'page': page, 'limit': limit},
      );
    } on DioException catch (e) {
      throw _mapDio(e, 'ListPurchaseChatMessages');
    }
  }

  Future<SendPurchaseChatMessageResponse> sendMessage({
    required String inquiryId,
    required String purchaseTeamMemberId,
    required SendPurchaseChatMessageRequest request,
  }) async {
    try {
      return await _apiClient.sendPurchaseChatMessage(
        inquiryId,
        purchaseTeamMemberId,
        request,
      );
    } on DioException catch (e) {
      throw _mapDio(e, 'SendPurchaseChatMessage');
    }
  }

  Future<UploadPurchaseChatFileResponse> uploadFile({
    required String inquiryId,
    required String purchaseTeamMemberId,
    required MultipartFile file,
  }) async {
    try {
      return await _apiClient.uploadPurchaseChatFile(
        inquiryId,
        purchaseTeamMemberId,
        file,
      );
    } on DioException catch (e) {
      throw _mapDio(e, 'UploadPurchaseChatFile');
    }
  }

  Exception _mapDio(DioException e, String tag) {
    final status = e.response?.statusCode;
    final data = e.response?.data;

    if (status == 401) return InquiryUnauthorizedException();
    if (status == 403) {
      return InquiryForbiddenException(
        _parseMessage(data) ?? 'You do not have permission to perform this action.',
      );
    }
    if (status == 422 && data != null) {
      return InquiryValidationException(_parseValidationError(data));
    }
    if (status == 502) {
      return InquiryServiceUnavailableException(
        _parseMessage(data) ?? 'Service unavailable.',
      );
    }
    return e;
  }

  static String? _parseMessage(dynamic data) {
    if (data is String && data.trim().isNotEmpty) return data.trim();
    if (data is! Map) return null;
    final map = Map<String, dynamic>.from(data);
    for (final key in ['message', 'error', 'msg', 'detail']) {
      final v = map[key];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    final nested = map['data'];
    if (nested is Map) return _parseMessage(nested);
    return null;
  }

  static String _parseValidationError(dynamic data) {
    final msg = _parseMessage(data);
    if (msg != null) return msg;
    return 'Validation failed.';
  }
}
