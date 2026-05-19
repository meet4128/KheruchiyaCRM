import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';

/// MODEL
class StatusItem {
  final String label;
  final int count;
  final Color circleColor, contentColor;

  StatusItem({
    required this.label,
    required this.count,
    required this.circleColor,
    this.contentColor = Colors.white,
  });
}

/// STATUS BAR — controlled by parent (counts + selection from loaded amendments).
class StatusBar extends StatelessWidget {
  const StatusBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<StatusItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(items.length, (index) {
        final item = items[index];
        return _statusNode(
          label: item.label,
          count: item.count,
          circleColor: item.circleColor,
          contentColor: item.contentColor,
          isSelected: selectedIndex == index,
          onTap: () => onSelected(index),
        );
      }),
    );
  }

  /// SINGLE NODE
  Widget _statusNode({
    required String label,
    required int count,
    required Color circleColor,
    required Color contentColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DimensionConstant.d14,
            vertical: DimensionConstant.d16,
          ),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [ColorConstant.purple, ColorConstant.indigo],
                  )
                : null,
            color: isSelected ? null : Colors.black,
            border: Border.all(color: Colors.white.withValues(alpha: DimensionConstant.d0_15)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: DimensionConstant.i1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: DimensionConstant.d13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                height: DimensionConstant.d28,
                width: DimensionConstant.d28,
                alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, color: circleColor),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: contentColor,
                    fontSize: DimensionConstant.d12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
