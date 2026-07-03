/// Amenity options for hotel booking (multi-select).
enum Amenity {
  swimmingPool('Swimming Pool'),
  wifi('Wifi'),
  spa('Spa'),
  restaurant('Restaurant'),
  parking('Parking'),
  bonfire('Bonfire'),
  bar('Bar'),
  balconyTerrace('Balcony Terrace'),
  kitchen('Kitchen'),
  caretaker('Caretaker'),
  lift('Lift');

  const Amenity(this.label);
  final String label;
}
