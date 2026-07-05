import 'package:travel_crm/core/constants/string_constants.dart';

/// Checklist priority — matches GET/POST `priority` (HIGH / MEDIUM / LOW).
enum ChecklistPriority {
  high(StringConstant.high, 'HIGH'),
  medium(StringConstant.medium, 'MEDIUM'),
  low(StringConstant.low, 'LOW');

  const ChecklistPriority(this.displayLabel, this.apiValue);

  /// Shown in the Set Priority dropdown.
  final String displayLabel;

  /// Value sent in the `checklist[].priority` field.
  final String apiValue;

  /// Due date & time are selectable for every priority. When left empty the
  /// backend applies its own default (High → +15 min, Medium → +8 hours).
  bool get allowsDueDate => true;
}
