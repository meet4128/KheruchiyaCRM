import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/inquiry/create_inquiry_request.dart';
import 'apis.dart';

part 'inquiry_api_client.g.dart';

@RestApi(baseUrl: Apis.inquiryBaseUrl)
abstract class InquiryApiClient {
  factory InquiryApiClient(Dio dio, {String baseUrl}) = _InquiryApiClient;

  @POST('/api/v1/inquiries')
  Future<void> createInquiry(@Body() CreateInquiryRequest body);
}
