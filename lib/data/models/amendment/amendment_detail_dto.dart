import 'package:json_annotation/json_annotation.dart';
import 'package:travel_crm/data/models/inquiry/inquiry_checklist_item.dart';

part 'amendment_detail_dto.g.dart';

@JsonSerializable()
class AmendmentDetailDto {
  const AmendmentDetailDto({
    this.id,
    this.amendmentId,
    this.amendmentType,
    this.status,
    this.amountCharged,
    this.sessionId,
    this.createdBy,
    this.raisedBy,
    this.bookedBy,
    this.assignedStaff,
    this.assignedTo,
    this.amendmentInvoice,
    this.invoiceUrl,
    this.remarks,
    this.nextTravelDate,
    this.processedAt,
    this.chatLockedAt,
    this.createdAt,
    this.attachments,
    this.checklist = const [],
  });

  factory AmendmentDetailDto.fromJson(Map<String, dynamic> json) =>
      _$AmendmentDetailDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AmendmentDetailDtoToJson(this);

  @JsonKey(name: '_id')
  final String? id;

  final String? amendmentId;
  final String? amendmentType;
  final String? status;
  final double? amountCharged;
  final String? sessionId;
  final String? createdBy;
  final String? raisedBy;
  final String? bookedBy;
  final String? assignedStaff;
  final String? assignedTo;
  final String? amendmentInvoice;
  final String? invoiceUrl;
  final String? remarks;
  final String? nextTravelDate;
  final String? processedAt;
  final String? chatLockedAt;
  final String? createdAt;
  final List<dynamic>? attachments;

  @JsonKey(defaultValue: [])
  final List<InquiryChecklistItem> checklist;
}

@JsonSerializable(explicitToJson: true)
class AmendmentDetailData {
  const AmendmentDetailData({required this.amendment});

  factory AmendmentDetailData.fromJson(Map<String, dynamic> json) =>
      _$AmendmentDetailDataFromJson(json);

  Map<String, dynamic> toJson() => _$AmendmentDetailDataToJson(this);

  final AmendmentDetailDto amendment;
}

@JsonSerializable(explicitToJson: true)
class AmendmentDetailResponse {
  const AmendmentDetailResponse({
    required this.status,
    required this.data,
  });

  factory AmendmentDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$AmendmentDetailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AmendmentDetailResponseToJson(this);

  final String status;
  final AmendmentDetailData data;
}
