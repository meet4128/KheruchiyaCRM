import 'package:json_annotation/json_annotation.dart';

import 'amendment_search_data.dart';

part 'amendment_search_response.g.dart';

/// Envelope for `GET /api/v1/amendments/search` — `{ status, data }`.
@JsonSerializable(explicitToJson: true)
class AmendmentSearchResponse {
  const AmendmentSearchResponse({
    required this.status,
    required this.data,
  });

  factory AmendmentSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$AmendmentSearchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AmendmentSearchResponseToJson(this);

  final String status;
  final AmendmentSearchData data;
}
