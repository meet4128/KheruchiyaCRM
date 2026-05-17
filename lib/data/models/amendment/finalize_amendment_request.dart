import 'package:json_annotation/json_annotation.dart';

part 'finalize_amendment_request.g.dart';

@JsonSerializable(includeIfNull: false)
class FinalizeAmendmentRequest {
  const FinalizeAmendmentRequest({
    required this.action,
    required this.amendmentType,
    this.sessionId,
    this.amountCharged,
  });

  factory FinalizeAmendmentRequest.fromJson(Map<String, dynamic> json) =>
      _$FinalizeAmendmentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$FinalizeAmendmentRequestToJson(this);

  final String action;
  final String amendmentType;
  final String? sessionId;
  final double? amountCharged;
}
