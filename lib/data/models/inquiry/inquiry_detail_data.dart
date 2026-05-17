import 'package:json_annotation/json_annotation.dart';
import 'package:travel_crm/data/models/inquiry/inquiry_detail_dto.dart';

part 'inquiry_detail_data.g.dart';

@JsonSerializable(explicitToJson: true)
class InquiryDetailData {
  const InquiryDetailData({required this.inquiry});

  factory InquiryDetailData.fromJson(Map<String, dynamic> json) =>
      _$InquiryDetailDataFromJson(json);

  Map<String, dynamic> toJson() => _$InquiryDetailDataToJson(this);

  final InquiryDetailDto inquiry;
}
