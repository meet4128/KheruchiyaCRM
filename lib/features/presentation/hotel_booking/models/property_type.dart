/// Property type enum for hotel booking.
enum HotelPropertyType {
  hotel('Hotel'),
  resort('Resort'),
  villa('Villa'),
  cottage('Cottage'),
  homestay('Homestay'),
  camp('Camp'),
  houseboat('Houseboat');

  const HotelPropertyType(this.label);
  final String label;
}
