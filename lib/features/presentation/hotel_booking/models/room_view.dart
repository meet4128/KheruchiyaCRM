/// Room view options for hotel booking (multi-select).
enum RoomView {
  garden('Garden View'),
  sea('Sea View'),
  city('City View'),
  pool('Pool View'),
  river('River View');

  const RoomView(this.label);
  final String label;
}
