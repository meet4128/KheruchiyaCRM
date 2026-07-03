import 'package:flutter/material.dart';
import 'package:travel_crm/core/widgets/app_multi_pill_selector.dart';
import '../models/amenity.dart';

/// Multi-select pill selector for amenities.
class AmenitiesSelector extends StatelessWidget {
  const AmenitiesSelector({
    super.key,
    required this.selectedAmenities,
    required this.onToggle,
  });

  final Set<Amenity> selectedAmenities;
  final ValueChanged<Amenity> onToggle;

  @override
  Widget build(BuildContext context) {
    return AppMultiPillSelector<Amenity>(
      items: Amenity.values,
      itemLabel: (amenity) => amenity.label,
      selectedValues: selectedAmenities,
      onToggle: onToggle,
      showCheckmark: true,
      spacing: 12,
    );
  }
}
