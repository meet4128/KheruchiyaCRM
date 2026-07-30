import 'package:json_annotation/json_annotation.dart';

import 'unverified_payment_item.dart';

part 'unverified_payments_data.g.dart';

/// `data` payload of `GET /api/v1/payments/unverified`.
///
/// Tolerant of the common pagination key variations (`items`/`docs`/`results`,
/// `totalItems`/`totalDocs`/`count`, `totalPages`/`pages`) — same normalization
/// contract as `AmendmentSearchData` so the UI can rely on a stable shape.
@JsonSerializable(explicitToJson: true)
class UnverifiedPaymentsData {
  const UnverifiedPaymentsData({
    this.items = const [],
    this.page = 1,
    this.limit = 15,
    this.totalItems = 0,
    this.totalPages = 0,
  });

  factory UnverifiedPaymentsData.fromJson(Map<String, dynamic> json) =>
      _$UnverifiedPaymentsDataFromJson(_normalize(json));

  Map<String, dynamic> toJson() => _$UnverifiedPaymentsDataToJson(this);

  @JsonKey(defaultValue: [])
  final List<UnverifiedPaymentItem> items;
  @JsonKey(defaultValue: 1)
  final int page;
  @JsonKey(defaultValue: 15)
  final int limit;
  @JsonKey(defaultValue: 0)
  final int totalItems;
  @JsonKey(defaultValue: 0)
  final int totalPages;

  static Map<String, dynamic> _normalize(Map<String, dynamic> input) {
    final out = Map<String, dynamic>.from(input);
    out['items'] = out['items'] ?? out['docs'] ?? out['results'] ?? const [];
    out['totalItems'] =
        out['totalItems'] ?? out['totalDocs'] ?? out['count'] ?? 0;
    out['totalPages'] = out['totalPages'] ?? out['pages'] ?? 0;
    return out;
  }
}
