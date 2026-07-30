import 'package:json_annotation/json_annotation.dart';

import 'payment_air_ticket_dtos.dart';

part 'payment_party_dtos.g.dart';

/// A `{ countryCode, number }` pair. Used for both `inquiry.referenceNumber`
/// and `contact.phoneNumber` on the unverified-payments row.
@JsonSerializable()
class PaymentPhoneDto {
  const PaymentPhoneDto({this.countryCode, this.number});

  factory PaymentPhoneDto.fromJson(Map<String, dynamic> json) =>
      _$PaymentPhoneDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentPhoneDtoToJson(this);

  final String? countryCode;
  final String? number;

  /// e.g. `+91 9812345678`. Empty when nothing is set.
  String get display {
    final parts = <String>[
      if (countryCode != null && countryCode!.trim().isNotEmpty)
        countryCode!.trim(),
      if (number != null && number!.trim().isNotEmpty) number!.trim(),
    ];
    return parts.join(' ');
  }
}

/// Joined inquiry summary on the payments row (`item.inquiry`).
@JsonSerializable(explicitToJson: true)
class PaymentInquiryRefDto {
  const PaymentInquiryRefDto({this.referenceNumber, this.title});

  factory PaymentInquiryRefDto.fromJson(Map<String, dynamic> json) =>
      _$PaymentInquiryRefDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentInquiryRefDtoToJson(this);

  final PaymentPhoneDto? referenceNumber;
  final String? title;
}

/// Joined contact summary on the payments row (`item.contact`).
@JsonSerializable(explicitToJson: true)
class PaymentContactDto {
  const PaymentContactDto({this.fullName, this.phoneNumber, this.airTicket});

  factory PaymentContactDto.fromJson(Map<String, dynamic> json) =>
      _$PaymentContactDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentContactDtoToJson(this);

  final String? fullName;
  final PaymentPhoneDto? phoneNumber;
  final PaymentAirTicketDto? airTicket;
}

/// Assigned member snapshot on the payments row (`item.assignedTo`).
///
/// The live response returns a single member object; if the backend later
/// switches to an array, add a converter here rather than in the widgets.
@JsonSerializable()
class PaymentAssigneeDto {
  const PaymentAssigneeDto({
    this.id,
    this.fullName,
    this.firstName,
    this.lastName,
    this.employeeId,
  });

  factory PaymentAssigneeDto.fromJson(Map<String, dynamic> json) =>
      _$PaymentAssigneeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentAssigneeDtoToJson(this);

  @JsonKey(name: '_id')
  final String? id;
  final String? fullName;
  final String? firstName;
  final String? lastName;
  final String? employeeId;
}
