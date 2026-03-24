/// Priority for the air ticket form (High / Medium / Low / Urgent).
/// Checklist uses [ChecklistPriority] instead.
enum Priority {
  low('Low'),
  medium('Medium'),
  high('High'),
  urgent('Urgent');

  const Priority(this.label);
  final String label;
}






