import 'package:json_annotation/json_annotation.dart';

import 'inquiry_checklist_item.dart';
import 'phone_number_dto.dart';

part 'list_inquiry_item.g.dart';

@JsonSerializable(explicitToJson: true)
class ListInquiryItem {
  const ListInquiryItem({
    this.id,
    this.title,
    this.fullName,
    this.typeOfBooking,
    this.typeOfClient,
    this.status,
    this.createdAt,
    this.checklist = const [],
    this.user,
    this.assignedTo,
    this.phoneNumber,
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

  @JsonKey(defaultValue: [])
  final List<InquiryChecklistItem> checklist;

  /// Inquiry assignee(s) from GET — may be comma-separated or `"A & B"` style.
  final String? user;

  /// Alternative key some APIs use for assignee display string.
  final String? assignedTo;

  /// Structured phone (`{countryCode, number}`) returned per list item.
  /// Used for phone-number search in the vendor list.
  final PhoneNumberDto? phoneNumber;
}
