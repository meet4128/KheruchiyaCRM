import 'package:json_annotation/json_annotation.dart';
import 'package:travel_crm/data/models/members/member_directory_item.dart';

part 'member_directory_data.g.dart';

@JsonSerializable(explicitToJson: true)
class MemberDirectoryData {
  const MemberDirectoryData({
    this.department,
    this.role,
    this.items = const [],
    this.page = 1,
    this.limit = 50,
    this.totalItems = 0,
    this.totalPages = 0,
  });

  factory MemberDirectoryData.fromJson(Map<String, dynamic> json) =>
      _$MemberDirectoryDataFromJson(json);

  Map<String, dynamic> toJson() => _$MemberDirectoryDataToJson(this);

  final String? department;
  final String? role;

  @JsonKey(defaultValue: [])
  final List<MemberDirectoryItem> items;

  @JsonKey(defaultValue: 1)
  final int page;

  @JsonKey(defaultValue: 50)
  final int limit;

  @JsonKey(defaultValue: 0)
  final int totalItems;

  @JsonKey(defaultValue: 0)
  final int totalPages;
}
