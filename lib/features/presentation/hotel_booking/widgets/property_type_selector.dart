import 'package:flutter/material.dart';
import 'package:travel_crm/core/widgets/app_multi_pill_selector.dart';
import '../models/property_type.dart';

/// Multi-select pill selector for hotel property type.
class PropertyTypeSelector extends StatelessWidget {
  const PropertyTypeSelector({
    super.key,
    required this.selectedTypes,
    required this.onToggle,
    this.errorText,
  });

  final Set<HotelPropertyType> selectedTypes;
  final ValueChanged<HotelPropertyType> onToggle;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return AppMultiPillSelector<HotelPropertyType>(
      items: HotelPropertyType.values,
      itemLabel: (type) => type.label,
      selectedValues: selectedTypes,
      onToggle: onToggle,
      errorText: errorText,
      showCheckmark: true,
      spacing: 12,
    );
  }
}
