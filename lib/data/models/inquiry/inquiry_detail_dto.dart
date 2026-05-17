import 'package:json_annotation/json_annotation.dart';
import 'package:travel_crm/data/models/amendment/amendment_summary_dto.dart';
import 'package:travel_crm/data/models/inquiry/inquiry_checklist_item.dart';
import 'package:travel_crm/data/models/inquiry/phone_number_dto.dart';

part 'inquiry_detail_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class InquiryDetailDto {
  const InquiryDetailDto({
    this.id,
    this.title,
    this.fullName,
    this.phoneNumber,
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

  final String? title;
  final String? fullName;
  final PhoneNumberDto? phoneNumber;
  final String? status;
  final String? typeOfBooking;
  final String? typeOfClient;
  final String? createdAt;

  @JsonKey(defaultValue: [])
  final List<InquiryChecklistItem> checklist;

  @JsonKey(defaultValue: [])
  final List<AmendmentSummaryDto> amendments;

  final String? user;
  final String? assignedTo;
}
