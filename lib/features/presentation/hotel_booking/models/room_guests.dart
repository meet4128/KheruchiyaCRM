import 'package:equatable/equatable.dart';

/// Rooms + adults count for hotel booking (top search summary bar).
class RoomGuests extends Equatable {
  const RoomGuests({
    this.rooms = 1,
    this.adults = 1,
  });

  static const int maxRooms = 30;
  static const int maxAdults = 99;

  final int rooms;
  final int adults;

  bool get isValid => rooms >= 1 && adults >= 1;

  RoomGuests copyWith({
    int? rooms,
    int? adults,
  }) {
    return RoomGuests(
      rooms: rooms ?? this.rooms,
      adults: adults ?? this.adults,
    );
  }

  /// Compact label for the summary bar, e.g. "2 Rooms, 4 Adults".
  static String displayLabel({required int rooms, required int adults}) {
    final roomsLabel = '$rooms Room${rooms == 1 ? '' : 's'}';
    final adultsLabel = '$adults Adult${adults == 1 ? '' : 's'}';
    return '$roomsLabel, $adultsLabel';
  }

  String get label => displayLabel(rooms: rooms, adults: adults);

  @override
  List<Object?> get props => [rooms, adults];
}
