import 'package:json_annotation/json_annotation.dart';

import 'airport_code_model.dart';

part 'flight_segment_request.g.dart';

/// One leg in `airTicket.flightSegments` on `POST /api/v1/inquiries`.
///
/// Round-trip is modeled as **two** segments (outbound + return), not a single
/// segment with `returnDate`.
///
/// For One-Way and Multi-city, the traveller picks a **flexible travel window**
/// rather than a single day: [departureDate] is the window start and
/// [departureDateEnd] is the window end (the trip may be booked on any day in
/// between). [departureDateEnd] is omitted for round-trip and whenever no end
/// was chosen.
@JsonSerializable(explicitToJson: true)
class FlightSegmentRequest {
  const FlightSegmentRequest({
    required this.from,
    required this.to,
    required this.departureDate,
    this.departureDateEnd,
    required this.travellerCount,
    required this.travelClass,
  });

  factory FlightSegmentRequest.fromJson(Map<String, dynamic> json) =>
      _$FlightSegmentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$FlightSegmentRequestToJson(this);

  final AirportCodeModel from;
  final AirportCodeModel to;
  final String departureDate;

  /// End of the flexible travel window (ISO 8601). Null/omitted for round-trip
  /// and when the traveller picked a single day.
  @JsonKey(includeIfNull: false)
  final String? departureDateEnd;

  final int travellerCount;
  final String travelClass;
}
