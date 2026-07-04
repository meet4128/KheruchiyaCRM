/// Service rating options for the vendor company details form (single-select).
enum ServiceRating {
  poor('1 Poor'),
  fair('2 Fair'),
  average('3 Average'),
  good('4 Good'),
  excellent('5 Excellent');

  const ServiceRating(this.label);
  final String label;
}
