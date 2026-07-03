/// Hotel star-rating category for hotel booking.
enum HotelCategory {
  threeStar('3 Star'),
  fourStar('4 Star'),
  fiveStar('5 Star');

  const HotelCategory(this.label);
  final String label;
}
