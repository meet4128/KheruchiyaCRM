import 'package:json_annotation/json_annotation.dart';

import 'inquiry_by_phone_data.dart';

part 'inquiry_by_phone_response.g.dart';

/// Response envelope for `GET /inquiries/by-phone`.
///
/// A `200` with `data.items == []` means "no existing inquiry for this phone"
/// (a new client) — the form should not auto-fill in that case.
@JsonSerializable(explicitToJson: true)
class InquiryByPhoneResponse {
  const InquiryByPhoneResponse({
    required this.status,
    required this.data,
  });

  factory InquiryByPhoneResponse.fromJson(Map<String, dynamic> json) =>
      _$InquiryByPhoneResponseFromJson(json);

  Map<String, dynamic> toJson() => _$InquiryByPhoneResponseToJson(this);

  final String status;
  final InquiryByPhoneData data;
}
