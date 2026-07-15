import 'package:json_annotation/json_annotation.dart';

part 'assign_inquiry_request.g.dart';

/// Body for `PATCH /inquiries/{id}/assign`. [userId] is the 24-hex member id
/// the inquiry should be assigned to.
@JsonSerializable()
class AssignInquiryRequest {
  const AssignInquiryRequest({required this.userId});

  factory AssignInquiryRequest.fromJson(Map<String, dynamic> json) =>
      _$AssignInquiryRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AssignInquiryRequestToJson(this);

  final String userId;
}
