/// The Month / Week / Day toggle in the calendar toolbar. Month is fully built
/// in v1; Week and Day are scaffolded.
enum CalendarViewMode {
  month('Month'),
  week('Week'),
  day('Day');

  const CalendarViewMode(this.label);

  final String label;
}
