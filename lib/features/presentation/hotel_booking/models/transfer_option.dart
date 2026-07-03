/// Transfer options for hotel booking (multi-select).
enum TransferOption {
  airport('Airport Transfers'),
  railway('Railway Station Transfer'),
  sightSeeing('Sight Seeing Transfers');

  const TransferOption(this.label);
  final String label;
}
