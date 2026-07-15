import 'package:json_annotation/json_annotation.dart';

part 'inquiry_user_dto.g.dart';

/// A member object returned inside `checklist[].user` by the inquiry GET
/// endpoints (`/inquiries`, `/inquiries/:id`, `/inquiries/by-phone`). The API
/// returns `user` as an array of these objects.
@JsonSerializable()
class InquiryUserDto {
  const InquiryUserDto({
    this.id,
    this.fullName,
    this.firstName,
    this.lastName,
    this.employeeId,
  });

  factory InquiryUserDto.fromJson(Map<String, dynamic> json) {
    // Some endpoints return Mongo `_id`, others a plain `id` alias.
    final normalized = Map<String, dynamic>.from(json);
    if (normalized['_id'] == null && normalized['id'] != null) {
      normalized['_id'] = normalized['id'];
    }
    return _$InquiryUserDtoFromJson(normalized);
  }

  Map<String, dynamic> toJson() => _$InquiryUserDtoToJson(this);

  @JsonKey(name: '_id')
  final String? id;
  final String? fullName;
  final String? firstName;
  final String? lastName;
  final String? employeeId;

  /// Display label: fullName → firstName+lastName → employeeId.
  String get displayName {
    final full = fullName?.trim();
    if (full != null && full.isNotEmpty) return full;
    final parts = [firstName, lastName]
        .where((s) => s != null && s.trim().isNotEmpty)
        .map((s) => s!.trim())
        .toList();
    if (parts.isNotEmpty) return parts.join(' ');
    return employeeId?.trim() ?? '';
  }
}
