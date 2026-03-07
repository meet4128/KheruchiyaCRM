import 'package:json_annotation/json_annotation.dart';

import 'flight_segment_request.dart';

part 'air_ticket_request.g.dart';

@JsonSerializable(explicitToJson: true)
class AirTicketRequest {
  const AirTicketRequest({
    required this.bookingType,
    required this.flightSegments,
    required this.typeOfVisa,
    required this.remark,
  });

  factory AirTicketRequest.fromJson(Map<String, dynamic> json) =>
      _$AirTicketRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AirTicketRequestToJson(this);

  final String bookingType;
  final List<FlightSegmentRequest> flightSegments;
  final String typeOfVisa;
  final String remark;
}
