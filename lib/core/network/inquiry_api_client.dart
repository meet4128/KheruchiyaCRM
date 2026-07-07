import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:travel_crm/data/models/amendment/amendment_detail_dto.dart';
import 'package:travel_crm/data/models/amendment/amendment_notes_response.dart';
import 'package:travel_crm/data/models/amendment/amendment_search_response.dart';
import 'package:travel_crm/data/models/calendar/calendar_events_response.dart';
import 'package:travel_crm/data/models/calendar/create_reminder_request.dart';
import 'package:travel_crm/data/models/calendar/create_reminder_response.dart';
import 'package:travel_crm/data/models/amendment/finalize_amendment_request.dart';
import 'package:travel_crm/data/models/amendment/finalize_amendment_response.dart';
import 'package:travel_crm/data/models/amendment/send_whatsapp_message_request.dart';
import 'package:travel_crm/data/models/amendment/session_messages_response.dart';
import 'package:travel_crm/data/models/amendment/session_note_request.dart';
import 'package:travel_crm/data/models/amendment/upload_session_file_data.dart';
import 'package:travel_crm/data/models/inquiry/inquiry_by_phone_response.dart';
import 'package:travel_crm/data/models/inquiry/inquiry_detail_response.dart';
import 'package:travel_crm/data/models/inquiry/list_inquiries_response.dart';
import 'package:travel_crm/data/models/inquiry/payment_plan_response.dart';
import 'package:travel_crm/data/models/inquiry/payment_proof_upload_response.dart';
import 'package:travel_crm/data/models/inquiry/update_payment_plan_request.dart';
import 'package:travel_crm/data/models/members/create_member_request.dart';
import 'package:travel_crm/data/models/members/create_member_response.dart';
import 'package:travel_crm/data/models/members/list_members_response.dart';
import 'package:travel_crm/data/models/members/member_directory_response.dart';
import 'package:travel_crm/data/models/members/delete_member_response.dart';
import 'package:travel_crm/data/models/members/get_member_response.dart';
import 'package:travel_crm/data/models/members/resend_invite_response.dart';
import 'package:travel_crm/data/models/members/update_member_request.dart';
import 'package:travel_crm/data/models/members/update_member_response.dart';
import 'package:travel_crm/data/models/purchase_chat/open_purchase_chat_request.dart';
import 'package:travel_crm/data/models/purchase_chat/open_purchase_chat_response.dart';
import 'package:travel_crm/data/models/purchase_chat/purchase_chat_inbox_response.dart';
import 'package:travel_crm/data/models/purchase_chat/purchase_chat_messages_response.dart';
import 'package:travel_crm/data/models/purchase_chat/send_purchase_chat_message_request.dart';
import 'package:travel_crm/data/models/purchase_chat/send_purchase_chat_message_response.dart';
import 'package:travel_crm/data/models/purchase_chat/upload_purchase_chat_file_data.dart';

import '../models/inquiry/create_inquiry_request.dart';
import 'apis.dart';

part 'inquiry_api_client.g.dart';

class ListInquiriesQuery {
  const ListInquiriesQuery({
    required this.page,
    required this.limit,
    this.typeOfBooking,
    this.typeOfClient,
    this.status,
    this.search,
    this.sort,
  });

  final int page;
  final int limit;
  final String? typeOfBooking;
  final String? typeOfClient;
  final String? status;
  final String? search;
  final String? sort;

  Map<String, dynamic> toQuery() {
    final queries = <String, dynamic>{
      'page': page,
      'limit': limit,
      'typeOfBooking': typeOfBooking,
      'typeOfClient': typeOfClient,
      'status': status,
      'search': search,
      'sort': sort,
    };
    queries.removeWhere((key, value) => value == null);
    return queries;
  }
}

/// Query params for `GET /inquiries/by-phone` (phone-number auto-fill lookup).
class InquiryByPhoneQuery {
  const InquiryByPhoneQuery({
    required this.number,
    this.countryCode,
    this.page = 1,
    this.limit = 20,
    this.sort = '-createdAt',
  });

  /// Digits-only phone number, e.g. `9876543210`.
  final String number;

  /// Dial code, e.g. `+91`. Omitted from the query when null/empty.
  final String? countryCode;
  final int page;
  final int limit;

  /// Newest first by default so auto-fill uses the most recent inquiry.
  final String? sort;

  Map<String, dynamic> toQuery() {
    final queries = <String, dynamic>{
      'number': number,
      'countryCode': (countryCode != null && countryCode!.isNotEmpty)
          ? countryCode
          : null,
      'page': page,
      'limit': limit,
      'sort': sort,
    };
    queries.removeWhere((key, value) => value == null);
    return queries;
  }
}

class MemberDirectoryQuery {
  const MemberDirectoryQuery({
    required this.department,
    this.role,
    this.page = 1,
    this.limit = 50,
    this.employmentStatus = 'active',
    this.search,
  });

  final String department;
  final String? role;
  final int page;
  final int limit;
  final String? employmentStatus;
  final String? search;

  Map<String, dynamic> toQuery() {
    final queries = <String, dynamic>{
      'department': department,
      'role': role,
      'page': page,
      'limit': limit,
      'employmentStatus': employmentStatus,
      'search': search,
    };
    queries.removeWhere((key, value) => value == null);
    return queries;
  }
}

class ListMembersQuery {
  const ListMembersQuery({
    required this.page,
    required this.limit,
    this.sort,
    this.employmentStatus,
  });

  final int page;
  final int limit;
  final String? sort;
  final String? employmentStatus;

  Map<String, dynamic> toQuery() {
    final queries = <String, dynamic>{
      'page': page,
      'limit': limit,
      'sort': sort,
      'employmentStatus': employmentStatus,
    };
    queries.removeWhere((key, value) => value == null);
    return queries;
  }
}

/// Query params for `GET /amendments/search` (Manage Amendment screen).
///
/// Only these fields are server-side filters today: [amendmentType], [status],
/// [processedFrom], [processedTo] plus paging/sort. Other visual filters on the
/// screen (amendment id, journey/fare/channel type, order-type tabs) have no
/// backend param yet and are intentionally not modelled here.
class AmendmentSearchQuery {
  const AmendmentSearchQuery({
    this.amendmentType,
    this.status,
    this.processedFrom,
    this.processedTo,
    this.page = 1,
    this.limit = 10,
    this.sort = '-createdAt',
  });

  /// e.g. `re_issue`, `correction`, `full_refund`.
  final String? amendmentType;

  /// e.g. `pending`, `in_progress`, `success`, `pending_with_supplier`.
  final String? status;

  /// Inclusive lower bound for `processedAt` — `yyyy-MM-dd`.
  final String? processedFrom;

  /// Inclusive upper bound for `processedAt` — `yyyy-MM-dd`.
  final String? processedTo;

  final int page;
  final int limit;
  final String? sort;

  Map<String, dynamic> toQuery() {
    final queries = <String, dynamic>{
      'amendmentType': amendmentType,
      'status': status,
      'processedFrom': processedFrom,
      'processedTo': processedTo,
      'page': page,
      'limit': limit,
      'sort': sort,
    };
    queries.removeWhere((key, value) => value == null);
    return queries;
  }
}

/// Query params for `GET /calendar/events` (Calendar screen). Matches the live
/// spec: `from`/`to` (date-time, required), optional `agent` and `status`.
class CalendarEventsQuery {
  const CalendarEventsQuery({
    required this.from,
    required this.to,
    this.agent,
    this.status,
  });

  /// Inclusive window bounds — ISO 8601 date-time.
  final String from;
  final String to;

  /// Member id to filter by assigned agent.
  final String? agent;

  /// `pending` | `completed` | `dismissed` | `snoozed`.
  final String? status;

  Map<String, dynamic> toQuery() {
    final queries = <String, dynamic>{
      'from': from,
      'to': to,
      'agent': agent,
      'status': status,
    };
    queries.removeWhere((key, value) => value == null);
    return queries;
  }
}

@RestApi(baseUrl: Apis.inquiryBaseUrl)
abstract class InquiryApiClient {
  factory InquiryApiClient(Dio dio, {String baseUrl}) = _InquiryApiClient;

  @POST('/inquiries')
  Future<InquiryDetailResponse> createInquiry(@Body() CreateInquiryRequest body);

  @GET('/inquiries')
  Future<ListInquiriesResponse> listInquiries(
    @Queries() Map<String, dynamic> queries,
  );

  @GET('/inquiries/by-phone')
  Future<InquiryByPhoneResponse> getInquiriesByPhone(
    @Queries() Map<String, dynamic> queries,
  );

  @POST('/members')
  Future<CreateMemberResponse> createMember(@Body() CreateMemberRequest body);

  @PATCH('/members/{id}')
  Future<UpdateMemberResponse> updateMember(
    @Path('id') String id,
    @Body() UpdateMemberRequest body,
  );

  @DELETE('/members/{id}')
  Future<DeleteMemberResponse> deleteMember(@Path('id') String id);

  @GET('/members/{id}')
  Future<GetMemberResponse> getMember(@Path('id') String id);

  @POST('/members/{id}/invitations/resend')
  Future<ResendInviteResponse> resendMemberInvite(@Path('id') String id);

  @GET('/members')
  Future<ListMembersResponse> listMembers(
    @Queries() Map<String, dynamic> queries,
  );

  @GET('/inquiries/{id}')
  Future<InquiryDetailResponse> getInquiryDetail(@Path('id') String id);

  @GET('/amendments/search')
  Future<AmendmentSearchResponse> searchAmendments(
    @Queries() Map<String, dynamic> queries,
  );

  @GET('/calendar/events')
  Future<CalendarEventsResponse> listCalendarEvents(
    @Queries() Map<String, dynamic> queries,
  );

  @POST('/inquiries/{inquiryId}/amendments/{amendmentId}/reminders')
  Future<CreateReminderResponse> createAmendmentReminder(
    @Path('inquiryId') String inquiryId,
    @Path('amendmentId') String amendmentId,
    @Body() CreateReminderRequest body,
  );

  @GET('/inquiries/{inquiryId}/amendments/session/{sessionId}/messages')
  Future<SessionMessagesResponse> listSessionMessages(
    @Path('inquiryId') String inquiryId,
    @Path('sessionId') String sessionId,
    @Queries() Map<String, dynamic> queries,
  );

  @GET('/inquiries/{inquiryId}/amendments/{amendmentId}')
  Future<AmendmentDetailResponse> getAmendmentDetail(
    @Path('inquiryId') String inquiryId,
    @Path('amendmentId') String amendmentId,
  );

  @GET('/inquiries/{inquiryId}/amendments/{amendmentId}/messages')
  Future<SessionMessagesResponse> listAmendmentMessages(
    @Path('inquiryId') String inquiryId,
    @Path('amendmentId') String amendmentId,
    @Queries() Map<String, dynamic> queries,
  );

  @GET('/inquiries/{inquiryId}/amendments/{amendmentId}/notes')
  Future<AmendmentNotesResponse> listAmendmentNotes(
    @Path('inquiryId') String inquiryId,
    @Path('amendmentId') String amendmentId,
  );

  @POST('/whatsapp/send')
  Future<void> sendWhatsappMessage(@Body() SendWhatsappMessageRequest body);

  @GET('/whatsapp/conversations/{peerPhone}/messages')
  Future<SessionMessagesResponse> listWhatsappMessages(
    @Path('peerPhone') String peerPhone,
    @Queries() Map<String, dynamic> queries,
  );

  @POST('/inquiries/{inquiryId}/amendments/finalize')
  Future<FinalizeAmendmentResponse> finalizeAmendment(
    @Path('inquiryId') String inquiryId,
    @Body() FinalizeAmendmentRequest body,
  );

  @POST('/inquiries/{inquiryId}/amendments/session/{sessionId}/notes')
  Future<void> addSessionNote(
    @Path('inquiryId') String inquiryId,
    @Path('sessionId') String sessionId,
    @Body() SessionNoteRequest body,
  );

  @POST('/inquiries/{inquiryId}/amendments/session/{sessionId}/uploads')
  @MultiPart()
  Future<UploadSessionFileResponse> uploadSessionFile(
    @Path('inquiryId') String inquiryId,
    @Path('sessionId') String sessionId,
    @Part(name: 'file') MultipartFile file,
  );

  @GET('/members/directory')
  Future<MemberDirectoryResponse> getMemberDirectory(
    @Queries() Map<String, dynamic> queries,
  );

  @POST('/inquiries/{inquiryId}/purchase-chats')
  Future<OpenPurchaseChatResponse> openPurchaseChat(
    @Path('inquiryId') String inquiryId,
    @Body() OpenPurchaseChatRequest body,
  );

  @GET('/inquiries/{inquiryId}/purchase-chats')
  Future<PurchaseChatInboxResponse> listPurchaseChats(
    @Path('inquiryId') String inquiryId,
    @Query('purchaseTeamMemberId') String? purchaseTeamMemberId,
  );

  @GET('/inquiries/{inquiryId}/purchase-chats/{purchaseTeamMemberId}/messages')
  Future<PurchaseChatMessagesResponse> listPurchaseChatMessages(
    @Path('inquiryId') String inquiryId,
    @Path('purchaseTeamMemberId') String purchaseTeamMemberId,
    @Queries() Map<String, dynamic> queries,
  );

  @POST('/inquiries/{inquiryId}/purchase-chats/{purchaseTeamMemberId}/messages')
  Future<SendPurchaseChatMessageResponse> sendPurchaseChatMessage(
    @Path('inquiryId') String inquiryId,
    @Path('purchaseTeamMemberId') String purchaseTeamMemberId,
    @Body() SendPurchaseChatMessageRequest body,
  );

  @POST('/inquiries/{inquiryId}/purchase-chats/{purchaseTeamMemberId}/uploads')
  @MultiPart()
  Future<UploadPurchaseChatFileResponse> uploadPurchaseChatFile(
    @Path('inquiryId') String inquiryId,
    @Path('purchaseTeamMemberId') String purchaseTeamMemberId,
    @Part(name: 'file') MultipartFile file,
  );

  @GET('/inquiries/{inquiryId}/payment-plan')
  Future<PaymentPlanResponse> getPaymentPlan(@Path('inquiryId') String inquiryId);

  @PUT('/inquiries/{inquiryId}/payment-plan')
  Future<PaymentPlanResponse> updatePaymentPlan(
    @Path('inquiryId') String inquiryId,
    @Body() UpdatePaymentPlanRequest body,
  );

  @POST('/inquiries/{inquiryId}/payment-plan/uploads')
  @MultiPart()
  Future<PaymentProofUploadResponse> uploadPaymentProof(
    @Path('inquiryId') String inquiryId,
    @Part(name: 'file') MultipartFile file,
  );
}
