/// The top category tabs (All Events / Follow Up / Payment). [all] shows every
/// event; the others filter by the event's `type`. Client-side filter over the
/// fetched window; badge counts come from the API `counts` block.
enum CalendarCategory {
  all('All Events', null),
  followUp('Follow Up', 'follow_up'),
  payment('Payment', 'payment');

  const CalendarCategory(this.label, this.apiType);

  final String label;

  /// The event `type` this tab matches, or null for [all].
  final String? apiType;

  bool matches(String? eventType) => apiType == null || eventType == apiType;
}
