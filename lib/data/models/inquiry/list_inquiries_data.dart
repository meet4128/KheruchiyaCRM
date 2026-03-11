import 'package:json_annotation/json_annotation.dart';

import 'list_inquiry_item.dart';

part 'list_inquiries_data.g.dart';

@JsonSerializable(explicitToJson: true)
class ListInquiriesData {
  const ListInquiriesData({
    required this.items,
    required this.page,
    required this.limit,
    required this.totalItems,
    required this.totalPages,
  });

  factory ListInquiriesData.fromJson(Map<String, dynamic> json) =>
      _$ListInquiriesDataFromJson(json);

  Map<String, dynamic> toJson() => _$ListInquiriesDataToJson(this);

  @JsonKey(defaultValue: [])
  final List<ListInquiryItem> items;

  final int page;
  final int limit;
  final int totalItems;
  final int totalPages;
}
