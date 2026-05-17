import 'package:json_annotation/json_annotation.dart';
import 'package:travel_crm/data/models/inquiry/inquiry_detail_data.dart';

part 'inquiry_detail_response.g.dart';

@JsonSerializable(explicitToJson: true)
class InquiryDetailResponse {
  const InquiryDetailResponse({
    required this.status,
    required this.data,
  });

  factory InquiryDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$InquiryDetailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$InquiryDetailResponseToJson(this);

  final String status;
  final InquiryDetailData data;
}
