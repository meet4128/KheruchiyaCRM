import 'package:json_annotation/json_annotation.dart';

import 'air_ticket_request.dart';
import 'phone_number_model.dart';

part 'create_inquiry_request.g.dart';

@JsonSerializable(explicitToJson: true)
class CreateInquiryRequest {
  const CreateInquiryRequest({
    required this.title,
    required this.phoneNumber,
    required this.fullName,
    required this.email,
    this.typeOfClient = '',
    required this.address,
    required this.referenceNumber,
    required this.referenceName,
    required this.clientBehaviour,
    required this.typeOfBooking,
    required this.status,
    required this.airTicket,
    required this.checklist,
  });

  factory CreateInquiryRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateInquiryRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateInquiryRequestToJson(this);

  final String title;
  final PhoneNumberModel phoneNumber;
  final String fullName;
  final String email;
  final String typeOfClient;
  final String address;
  final PhoneNumberModel referenceNumber;
  final String referenceName;
  final String clientBehaviour;
  final String typeOfBooking;
  final String status;
  final AirTicketRequest airTicket;
  final List<dynamic> checklist;
}
