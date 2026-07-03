import 'package:flutter/material.dart';
import 'package:travel_crm/core/widgets/app_multi_pill_selector.dart';
import '../models/room_view.dart';

/// Multi-select pill selector for room views.
class RoomViewSelector extends StatelessWidget {
  const RoomViewSelector({
    super.key,
    required this.selectedViews,
    required this.onToggle,
  });

  final Set<RoomView> selectedViews;
  final ValueChanged<RoomView> onToggle;

  @override
  Widget build(BuildContext context) {
    return AppMultiPillSelector<RoomView>(
      items: RoomView.values,
      itemLabel: (view) => view.label,
      selectedValues: selectedViews,
      onToggle: onToggle,
      showCheckmark: true,
      spacing: 12,
    );
  }
}
