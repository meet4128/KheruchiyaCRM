import 'package:json_annotation/json_annotation.dart';

part 'payment_air_ticket_dtos.g.dart';

/// An airport reference (`{ code, city }`) on a flight segment.
@JsonSerializable()
class PaymentAirportDto {
  const PaymentAirportDto({this.code, this.city});

  factory PaymentAirportDto.fromJson(Map<String, dynamic> json) =>
      _$PaymentAirportDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentAirportDtoToJson(this);

  final String? code;
  final String? city;
}

/// A single leg of the contact's air-ticket booking.
@JsonSerializable(explicitToJson: true)
class PaymentFlightSegmentDto {
  const PaymentFlightSegmentDto({
    this.from,
    this.to,
    this.departureDate,
    this.travellerCount,
    this.travelClass,
  });

  factory PaymentFlightSegmentDto.fromJson(Map<String, dynamic> json) =>
      _$PaymentFlightSegmentDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentFlightSegmentDtoToJson(this);

  final PaymentAirportDto? from;
  final PaymentAirportDto? to;
  final DateTime? departureDate;
  final int? travellerCount;
  final String? travelClass;
}

/// The contact's air-ticket snapshot (`contact.airTicket`), used to render the
/// "Flight: AMD-DEL" route line in the payments table.
@JsonSerializable(explicitToJson: true)
class PaymentAirTicketDto {
  const PaymentAirTicketDto({
    this.bookingType,
    this.flightSegments = const [],
  });

  factory PaymentAirTicketDto.fromJson(Map<String, dynamic> json) =>
      _$PaymentAirTicketDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentAirTicketDtoToJson(this);

  final String? bookingType;

  @JsonKey(defaultValue: [])
  final List<PaymentFlightSegmentDto> flightSegments;
}
