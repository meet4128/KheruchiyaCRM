import 'package:json_annotation/json_annotation.dart';

import 'amendment_summary_dto.dart';

part 'amendment_search_data.g.dart';

/// `data` payload of `GET /api/v1/amendments/search`.
///
/// Tolerant of the common pagination key variations (`items`/`docs`/`results`,
/// `totalItems`/`totalDocs`/`count`, `totalPages`/`pages`) — same normalization
/// contract as `ListMembersData` so the UI can rely on a stable shape.
@JsonSerializable(explicitToJson: true)
class AmendmentSearchData {
  const AmendmentSearchData({
    this.items = const [],
    this.page = 1,
    this.limit = 10,
    this.totalItems = 0,
    this.totalPages = 0,
  });

  factory AmendmentSearchData.fromJson(Map<String, dynamic> json) =>
      _$AmendmentSearchDataFromJson(_normalize(json));

  Map<String, dynamic> toJson() => _$AmendmentSearchDataToJson(this);

  @JsonKey(defaultValue: [])
  final List<AmendmentSummaryDto> items;
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
