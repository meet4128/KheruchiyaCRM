import 'package:json_annotation/json_annotation.dart';
import 'package:travel_crm/data/models/amendment/amendment_summary_dto.dart';

part 'finalize_amendment_response.g.dart';

@JsonSerializable(explicitToJson: true)
class FinalizeAmendmentData {
  const FinalizeAmendmentData({required this.amendment});

  factory FinalizeAmendmentData.fromJson(Map<String, dynamic> json) =>
      _$FinalizeAmendmentDataFromJson(json);

  Map<String, dynamic> toJson() => _$FinalizeAmendmentDataToJson(this);

  final AmendmentSummaryDto amendment;
}

@JsonSerializable(explicitToJson: true)
class FinalizeAmendmentResponse {
  const FinalizeAmendmentResponse({
    required this.status,
    required this.data,
  });

  factory FinalizeAmendmentResponse.fromJson(Map<String, dynamic> json) =>
      _$FinalizeAmendmentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FinalizeAmendmentResponseToJson(this);

  final String status;
  final FinalizeAmendmentData data;
}
