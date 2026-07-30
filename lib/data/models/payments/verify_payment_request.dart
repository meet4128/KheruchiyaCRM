import 'package:json_annotation/json_annotation.dart';

part 'verify_payment_request.g.dart';

/// Body for `PATCH /payments/{inquiryId}/verify`.
///
/// `verified: true` marks the plan verified; `false` sends it back to the
/// Unverified queue.
@JsonSerializable()
class VerifyPaymentRequest {
  const VerifyPaymentRequest({required this.verified});

  factory VerifyPaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyPaymentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyPaymentRequestToJson(this);

  final bool verified;
}
