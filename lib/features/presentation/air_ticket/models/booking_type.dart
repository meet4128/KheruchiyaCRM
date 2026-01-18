/// Booking type enum for air ticket booking
enum AirTicketBookingType {
  oneWay('One Way'),
  roundTrip('Round Trip'),
  multiCity('Multi City');

  const AirTicketBookingType(this.label);
  final String label;
}






