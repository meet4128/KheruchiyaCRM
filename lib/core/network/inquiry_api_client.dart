import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:travel_crm/data/models/inquiry/list_inquiries_response.dart';

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

@RestApi(baseUrl: Apis.inquiryBaseUrl)
abstract class InquiryApiClient {
  factory InquiryApiClient(Dio dio, {String baseUrl}) = _InquiryApiClient;

  @POST('/api/v1/inquiries')
  Future<void> createInquiry(@Body() CreateInquiryRequest body);

  @GET('/api/v1/inquiries')
  Future<ListInquiriesResponse> listInquiries(
    @Queries() Map<String, dynamic> queries,
  );
}
