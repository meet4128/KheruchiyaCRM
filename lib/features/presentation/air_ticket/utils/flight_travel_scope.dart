import 'package:travel_crm/features/presentation/air_ticket/models/flight_segment.dart';

/// Decides whether the air ticket flow should show visa fields based on
/// airport selections (same country = domestic / national; different = international).
///
/// Picker stores: CODE - City|Airport name|Country as the raw field value.
/// Legacy strings without a third segment are treated as domestic (visa hidden).
class FlightTravelScope {
  FlightTravelScope._();

  /// True when any segment crosses country boundaries (international travel).
  static bool requiresVisaSelection({
    required String from,
    required String to,
    required List<FlightSegment> flightSegments,
  }) {
    if (_isInternationalPair(from, to)) return true;
    for (final seg in flightSegments) {
      if (_isInternationalPair(seg.from, seg.to)) return true;
    }
    return false;
  }

  static bool _isInternationalPair(String fromRaw, String toRaw) {
    final c1 = countryFromAirportField(fromRaw);
    final c2 = countryFromAirportField(toRaw);
    if (c1 == null || c2 == null) return false;
    if (c1.isEmpty || c2.isEmpty) return false;
    return _normalize(c1) != _normalize(c2);
  }

  /// Third pipe segment after `CODE - City|Airport name`, if present.
  static String? countryFromAirportField(String raw) {
    if (raw.isEmpty) return null;
    final parts = raw.split('|');
    if (parts.length < 3) return null;
    return parts[2].trim();
  }

  static String _normalize(String country) => country.toLowerCase().trim();
}
