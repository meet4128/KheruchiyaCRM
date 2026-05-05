import 'package:json_annotation/json_annotation.dart';

import 'list_members_item.dart';

part 'list_members_data.g.dart';

@JsonSerializable(explicitToJson: true)
class ListMembersData {
  const ListMembersData({
    this.items = const [],
    this.page = 1,
    this.limit = 10,
    this.totalItems = 0,
    this.totalPages = 0,
  });

  factory ListMembersData.fromJson(Map<String, dynamic> json) => _$ListMembersDataFromJson(
        _normalize(json),
      );

  Map<String, dynamic> toJson() => _$ListMembersDataToJson(this);

  @JsonKey(defaultValue: [])
  final List<ListMembersItem> items;
  @JsonKey(defaultValue: 1)
  final int page;
  @JsonKey(defaultValue: 10)
  final int limit;
  @JsonKey(defaultValue: 0)
  final int totalItems;
  @JsonKey(defaultValue: 0)
  final int totalPages;

  static Map<String, dynamic> _normalize(Map<String, dynamic> input) {
    final out = Map<String, dynamic>.from(input);
    out['items'] = out['items'] ?? out['docs'] ?? out['results'] ?? const [];
    out['totalItems'] = out['totalItems'] ?? out['totalDocs'] ?? out['count'] ?? 0;
    out['totalPages'] = out['totalPages'] ?? out['pages'] ?? 0;
    return out;
  }
}
