import 'package:json_annotation/json_annotation.dart';

import 'phone_number_dto.dart';

part 'inquiry_by_phone_item.g.dart';

/// A single inquiry returned by `GET /inquiries/by-phone`.
///
/// Carries the full set of client-identity fields (unlike [ListInquiryItem])
/// so the inquiry form can be auto-filled from a phone-number match in a
/// single request.
@JsonSerializable(explicitToJson: true)
class InquiryByPhoneItem {
  const InquiryByPhoneItem({
    this.id,
    this.title,
    this.fullName,
    this.phoneNumber,
    this.email,
    this.address,
    this.referenceNumber,
    this.referenceName,
    this.clientBehaviour,
    this.typeOfBooking,
    this.typeOfClient,
    this.status,
    this.createdAt,
  });

  factory InquiryByPhoneItem.fromJson(Map<String, dynamic> json) =>
      _$InquiryByPhoneItemFromJson(json);

  Map<String, dynamic> toJson() => _$InquiryByPhoneItemToJson(this);

  @JsonKey(name: '_id')
  final String? id;

  final String? title;
  final String? fullName;
  final PhoneNumberDto? phoneNumber;
  final String? email;
  final String? address;
  final PhoneNumberDto? referenceNumber;
  final String? referenceName;
  final String? clientBehaviour;
  final String? typeOfBooking;
  final String? typeOfClient;
  final String? status;
  final String? createdAt;
}
