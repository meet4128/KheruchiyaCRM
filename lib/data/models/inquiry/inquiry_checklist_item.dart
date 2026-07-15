import 'package:json_annotation/json_annotation.dart';

import 'inquiry_user_dto.dart';

part 'inquiry_checklist_item.g.dart';

/// Checklist entry from inquiry list/detail GET responses.
/// Matches POST shape: user, dueDate, priority, category (no inLoop/repeat in API).
@JsonSerializable()
class InquiryChecklistItem {
  const InquiryChecklistItem({
    this.user = const [],
    this.dueDate,
    this.priority,
    this.category,
  });

  factory InquiryChecklistItem.fromJson(Map<String, dynamic> json) =>
      _$InquiryChecklistItemFromJson(json);

  Map<String, dynamic> toJson() => _$InquiryChecklistItemToJson(this);

  /// Assigned members. The API returns `user` as an array of member objects;
  /// [_usersFromJson] also tolerates a single object or a legacy name string.
  @JsonKey(fromJson: _usersFromJson, toJson: _usersToJson)
  final List<InquiryUserDto> user;

  final String? dueDate;
  final String? priority;
  final String? category;

  /// Display names of the assigned members (empty entries dropped).
  List<String> get userNames => user
      .map((u) => u.displayName)
      .where((s) => s.trim().isNotEmpty)
      .toList();
}

/// Coerces the `user` field into a list of [InquiryUserDto], tolerating the new
/// array shape, a single object, or a legacy comma/`&`-separated name string.
List<InquiryUserDto> _usersFromJson(dynamic raw) {
  if (raw is List) {
    return raw
        .whereType<Map>()
        .map((e) => InquiryUserDto.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
  if (raw is Map) {
    return [InquiryUserDto.fromJson(Map<String, dynamic>.from(raw))];
  }
  if (raw is String && raw.trim().isNotEmpty) {
    return raw
        .split(RegExp(r',|&'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .map((name) => InquiryUserDto(fullName: name))
        .toList();
  }
  return const [];
}

List<Map<String, dynamic>> _usersToJson(List<InquiryUserDto> users) =>
    users.map((u) => u.toJson()).toList();
