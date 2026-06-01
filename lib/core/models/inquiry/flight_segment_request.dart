import 'package:json_annotation/json_annotation.dart';

import 'airport_code_model.dart';

part 'flight_segment_request.g.dart';

/// One leg in `airTicket.flightSegments` on `POST /api/v1/inquiries`.
///
/// Round-trip is modeled as **two** segments (outbound + return), not a single
/// segment with `returnDate`.
@JsonSerializable(explicitToJson: true)
class FlightSegmentRequest {
  const FlightSegmentRequest({
    required this.from,
    required this.to,
    required this.departureDate,
    required this.travellerCount,
    required this.travelClass,
  });

  factory FlightSegmentRequest.fromJson(Map<String, dynamic> json) =>
      _$FlightSegmentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$FlightSegmentRequestToJson(this);

  final AirportCodeModel from;
  final AirportCodeModel to;
  final String departureDate;
  final int travellerCount;
  final String travelClass;
}
