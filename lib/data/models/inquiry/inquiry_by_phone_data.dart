import 'package:json_annotation/json_annotation.dart';

import 'inquiry_by_phone_item.dart';

part 'inquiry_by_phone_data.g.dart';

/// Paginated `data` envelope for `GET /inquiries/by-phone`.
@JsonSerializable(explicitToJson: true)
class InquiryByPhoneData {
  const InquiryByPhoneData({
    this.items = const [],
    this.page = 1,
    this.limit = 20,
    this.totalItems = 0,
    this.totalPages = 0,
  });

  factory InquiryByPhoneData.fromJson(Map<String, dynamic> json) =>
      _$InquiryByPhoneDataFromJson(json);

  Map<String, dynamic> toJson() => _$InquiryByPhoneDataToJson(this);

  @JsonKey(defaultValue: [])
  final List<InquiryByPhoneItem> items;

  final int page;
  final int limit;
  final int totalItems;
  final int totalPages;
}
