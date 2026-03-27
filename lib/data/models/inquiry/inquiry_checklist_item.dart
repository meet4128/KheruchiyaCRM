import 'package:json_annotation/json_annotation.dart';

part 'inquiry_checklist_item.g.dart';

/// Checklist entry from inquiry list/detail GET responses.
/// Matches POST shape: user, dueDate, priority, category (no inLoop/repeat in API).
@JsonSerializable()
class InquiryChecklistItem {
  const InquiryChecklistItem({
    this.user,
    this.dueDate,
    this.priority,
    this.category,
  });

  factory InquiryChecklistItem.fromJson(Map<String, dynamic> json) =>
      _$InquiryChecklistItemFromJson(json);

  Map<String, dynamic> toJson() => _$InquiryChecklistItemToJson(this);

  final String? user;
  final String? dueDate;
  final String? priority;
  final String? category;
}
