/// Checklist priority / status values (aligned with inquiry management statuses).
enum ChecklistPriority {
  inProgress('IN PROGRESS', 'IN_PROGRESS'),
  pending('PENDING', 'PENDING'),
  cancelled('CANCELLED', 'CANCELLED'),
  completed('COMPLETED', 'COMPLETED');

  const ChecklistPriority(this.displayLabel, this.apiValue);

  /// Shown in the dropdown UI.
  final String displayLabel;

  /// Value sent to the API on submit.
  final String apiValue;
}
