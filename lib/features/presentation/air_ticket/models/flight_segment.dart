import 'package:equatable/equatable.dart';
import 'package:travel_crm/core/constants/string_constants.dart';

/// One flight segment (From, To, Departure, Return) for multi-city support.
class FlightSegment extends Equatable {
  const FlightSegment({
    this.from = '',
    this.to = '',
    this.departureDate,
    this.returnDate,
  });

  final String from;
  final String to;
  final DateTime? departureDate;
  final DateTime? returnDate;

  FlightSegment copyWith({
    String? from,
    String? to,
    DateTime? departureDate,
    DateTime? returnDate,
  }) {
    return FlightSegment(
      from: from ?? this.from,
      to: to ?? this.to,
      departureDate: departureDate ?? this.departureDate,
      returnDate: returnDate ?? this.returnDate,
    );
  }

  /// New empty segment for "Add another City".
  static FlightSegment get defaultSegment => const FlightSegment();

  @override
  List<Object?> get props => [from, to, departureDate, returnDate];
}
