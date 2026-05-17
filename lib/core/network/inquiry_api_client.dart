import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:travel_crm/data/models/amendment/amendment_detail_dto.dart';
import 'package:travel_crm/data/models/amendment/amendment_notes_response.dart';
import 'package:travel_crm/data/models/amendment/finalize_amendment_request.dart';
import 'package:travel_crm/data/models/amendment/finalize_amendment_response.dart';
import 'package:travel_crm/data/models/amendment/send_whatsapp_message_request.dart';
import 'package:travel_crm/data/models/amendment/session_messages_response.dart';
import 'package:travel_crm/data/models/amendment/session_note_request.dart';
import 'package:travel_crm/data/models/amendment/upload_session_file_data.dart';
import 'package:travel_crm/data/models/inquiry/inquiry_detail_response.dart';
import 'package:travel_crm/data/models/inquiry/list_inquiries_response.dart';
import 'package:travel_crm/data/models/members/create_member_request.dart';
import 'package:travel_crm/data/models/members/list_members_response.dart';
import 'package:travel_crm/data/models/members/update_member_request.dart';

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

@RestApi(baseUrl: Apis.inquiryBaseUrl)
abstract class InquiryApiClient {
  factory InquiryApiClient(Dio dio, {String baseUrl}) = _InquiryApiClient;

  @POST('/api/v1/inquiries')
  Future<void> createInquiry(@Body() CreateInquiryRequest body);

  @GET('/api/v1/inquiries')
  Future<ListInquiriesResponse> listInquiries(
    @Queries() Map<String, dynamic> queries,
  );

  @POST('/api/v1/members')
  Future<void> createMember(@Body() CreateMemberRequest body);

  @PATCH('/api/v1/members/{id}')
  Future<void> updateMember(
    @Path('id') String id,
    @Body() UpdateMemberRequest body,
  );

  @GET('/api/v1/members')
  Future<ListMembersResponse> listMembers(
    @Queries() Map<String, dynamic> queries,
  );

  @GET('/api/v1/inquiries/{id}')
  Future<InquiryDetailResponse> getInquiryDetail(@Path('id') String id);

  @GET('/api/v1/inquiries/{inquiryId}/amendments/session/{sessionId}/messages')
  Future<SessionMessagesResponse> listSessionMessages(
    @Path('inquiryId') String inquiryId,
    @Path('sessionId') String sessionId,
    @Queries() Map<String, dynamic> queries,
  );

  @GET('/api/v1/inquiries/{inquiryId}/amendments/{amendmentId}')
  Future<AmendmentDetailResponse> getAmendmentDetail(
    @Path('inquiryId') String inquiryId,
    @Path('amendmentId') String amendmentId,
  );

  @GET('/api/v1/inquiries/{inquiryId}/amendments/{amendmentId}/messages')
  Future<SessionMessagesResponse> listAmendmentMessages(
    @Path('inquiryId') String inquiryId,
    @Path('amendmentId') String amendmentId,
    @Queries() Map<String, dynamic> queries,
  );

  @GET('/api/v1/inquiries/{inquiryId}/amendments/{amendmentId}/notes')
  Future<AmendmentNotesResponse> listAmendmentNotes(
    @Path('inquiryId') String inquiryId,
    @Path('amendmentId') String amendmentId,
  );

  @POST('/api/v1/whatsapp/send')
  Future<void> sendWhatsappMessage(@Body() SendWhatsappMessageRequest body);

  @POST('/api/v1/inquiries/{inquiryId}/amendments/finalize')
  Future<FinalizeAmendmentResponse> finalizeAmendment(
    @Path('inquiryId') String inquiryId,
    @Body() FinalizeAmendmentRequest body,
  );

  @POST('/api/v1/inquiries/{inquiryId}/amendments/session/{sessionId}/notes')
  Future<void> addSessionNote(
    @Path('inquiryId') String inquiryId,
    @Path('sessionId') String sessionId,
    @Body() SessionNoteRequest body,
  );

  @POST('/api/v1/inquiries/{inquiryId}/amendments/session/{sessionId}/uploads')
  @MultiPart()
  Future<UploadSessionFileResponse> uploadSessionFile(
    @Path('inquiryId') String inquiryId,
    @Path('sessionId') String sessionId,
    @Part(name: 'file') MultipartFile file,
  );
}
