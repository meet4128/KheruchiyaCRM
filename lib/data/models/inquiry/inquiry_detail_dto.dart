import 'package:json_annotation/json_annotation.dart';
import 'package:travel_crm/data/models/amendment/amendment_summary_dto.dart';
import 'package:travel_crm/data/models/inquiry/inquiry_checklist_item.dart';
import 'package:travel_crm/data/models/inquiry/inquiry_user_dto.dart';
import 'package:travel_crm/data/models/inquiry/phone_number_dto.dart';

part 'inquiry_detail_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class InquiryDetailDto {
  const InquiryDetailDto({
    this.id,
    this.inquiryNumber,
    this.title,
    this.fullName,
    this.phoneNumber,
    this.email,
    this.address,
    this.referenceNumber,
    this.referenceName,
    this.status,
    this.typeOfBooking,
    this.typeOfClient,
    this.createdAt,
    this.checklist = const [],
    this.amendments = const [],
    this.user,
    this.assignedTo,
  });

  factory InquiryDetailDto.fromJson(Map<String, dynamic> json) =>
      _$InquiryDetailDtoFromJson(json);

  Map<String, dynamic> toJson() => _$InquiryDetailDtoToJson(this);

  @JsonKey(name: '_id')
  final String? id;

  /// Backend-generated business number, e.g. `FT/2627/001`. Null on legacy
  /// inquiries (callers fall back to an `_id`-derived number).
  final String? inquiryNumber;

  final String? title;
  final String? fullName;
  final PhoneNumberDto? phoneNumber;
  final String? email;
  final String? address;
  final PhoneNumberDto? referenceNumber;
  final String? referenceName;
  final String? status;
  final String? typeOfBooking;
  final String? typeOfClient;
  final String? createdAt;

  @JsonKey(defaultValue: [])
  final List<InquiryChecklistItem> checklist;

  @JsonKey(defaultValue: [])
  final List<AmendmentSummaryDto> amendments;

  final String? user;

  /// Root inquiry assignee (`PATCH /inquiries/{id}/assign`). Single member
  /// snapshot or null when unassigned.
  final InquiryUserDto? assignedTo;
}
