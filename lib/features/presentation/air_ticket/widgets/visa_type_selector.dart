import 'package:flutter/material.dart';
import 'package:travel_crm/core/widgets/app_pill_selector.dart';
import '../models/visa_type.dart';

/// Visa type selector widget
/// Displays pill-shaped buttons for Visitor Visa, Student Visa, PR, Work Permit
class VisaTypeSelector extends StatelessWidget {
  const VisaTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
    this.errorText,
  });

  final VisaType? selectedType;
  final ValueChanged<VisaType> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return AppPillSelector<VisaType>(
      items: VisaType.values,
      itemLabel: (type) => type.label,
      selectedValue: selectedType,
      onChanged: onChanged,
      errorText: errorText,
      showCheckmark: true,
      spacing: 12,
    );
  }
}






