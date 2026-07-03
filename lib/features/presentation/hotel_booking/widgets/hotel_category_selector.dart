import 'package:flutter/material.dart';
import 'package:travel_crm/core/widgets/app_multi_pill_selector.dart';
import '../models/hotel_category.dart';

/// Multi-select pill selector for hotel star-rating category.
class HotelCategorySelector extends StatelessWidget {
  const HotelCategorySelector({
    super.key,
    required this.selectedCategories,
    required this.onToggle,
    this.errorText,
  });

  final Set<HotelCategory> selectedCategories;
  final ValueChanged<HotelCategory> onToggle;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return AppMultiPillSelector<HotelCategory>(
      items: HotelCategory.values,
      itemLabel: (category) => category.label,
      selectedValues: selectedCategories,
      onToggle: onToggle,
      errorText: errorText,
      showCheckmark: true,
      spacing: 12,
    );
  }
}
