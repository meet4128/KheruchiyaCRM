import 'package:json_annotation/json_annotation.dart';

import 'unverified_payments_data.dart';

part 'unverified_payments_response.g.dart';

/// Envelope for `GET /api/v1/payments/unverified` — `{ status, data }`.
@JsonSerializable(explicitToJson: true)
class UnverifiedPaymentsResponse {
  const UnverifiedPaymentsResponse({
    required this.status,
    required this.data,
  });

  factory UnverifiedPaymentsResponse.fromJson(Map<String, dynamic> json) =>
      _$UnverifiedPaymentsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UnverifiedPaymentsResponseToJson(this);

  final String status;
  final UnverifiedPaymentsData data;
}
