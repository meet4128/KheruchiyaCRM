import 'package:json_annotation/json_annotation.dart';

part 'update_inquiry_status_request.g.dart';

/// Body for `PATCH /inquiries/{id}/status`. [status] must be one of the allowed
/// enum values (`PENDING`, `IN_PROGRESS`, `COMPLETED`, `CANCELLED`); the backend
/// trims and validates it (invalid → 422).
@JsonSerializable()
class UpdateInquiryStatusRequest {
  const UpdateInquiryStatusRequest({required this.status});

  factory UpdateInquiryStatusRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateInquiryStatusRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateInquiryStatusRequestToJson(this);

  final String status;
}
