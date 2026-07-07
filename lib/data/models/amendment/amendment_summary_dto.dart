import 'package:json_annotation/json_annotation.dart';

part 'amendment_summary_dto.g.dart';

@JsonSerializable()
class AmendmentSummaryDto {
  const AmendmentSummaryDto({
    this.id,
    this.inquiryId,
    this.amendmentId,
    this.amendmentType,
    this.status,
    this.amountCharged,
    this.sessionId,
    this.createdBy,
    this.processedAt,
    this.chatLockedAt,
    this.createdAt,
  });

  factory AmendmentSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$AmendmentSummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AmendmentSummaryDtoToJson(this);

  @JsonKey(name: '_id')
  final String? id;

  /// Parent inquiry id — present on `GET /amendments/search` rows so the table
  /// can deep-link into the inquiry detail. Absent on inquiry-scoped summaries.
  final String? inquiryId;

  final String? amendmentId;
  final String? amendmentType;
  final String? status;
  final double? amountCharged;
  final String? sessionId;
  final String? createdBy;
  final String? processedAt;
  final String? chatLockedAt;
  final String? createdAt;
}
