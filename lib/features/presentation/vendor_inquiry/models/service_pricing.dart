/// Service pricing options for the vendor company details form (single-select).
enum ServicePricing {
  bestPrice('Best Price'),
  competitive('Competitive'),
  premium('Premium'),
  economy('Economy');

  const ServicePricing(this.label);
  final String label;
}
