import 'package:json_annotation/json_annotation.dart';

part 'list_inquiry_item.g.dart';

@JsonSerializable()
class ListInquiryItem {
  const ListInquiryItem({
    this.id,
    this.title,
    this.fullName,
    this.typeOfBooking,
    this.typeOfClient,
    this.status,
    this.createdAt,
  });

  factory ListInquiryItem.fromJson(Map<String, dynamic> json) =>
      _$ListInquiryItemFromJson(json);

  Map<String, dynamic> toJson() => _$ListInquiryItemToJson(this);

  @JsonKey(name: '_id')
  final String? id;

  final String? title;
  final String? fullName;
  final String? typeOfBooking;
  final String? typeOfClient;
  final String? status;
  final String? createdAt;
}
