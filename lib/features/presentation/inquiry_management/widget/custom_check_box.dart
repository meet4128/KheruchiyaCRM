import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';

class CustomOutlineCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double size;
  final double borderRadius;
  final Color borderColor;
  final Color checkColor;

  const CustomOutlineCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = DimensionConstant.d18,
    this.borderRadius = DimensionConstant.d6,
    this.borderColor = Colors.white,
    this.checkColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(borderRadius),
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor, width: 1.5),
          color: value ? borderColor.withValues(alpha: 0.15) : Colors.transparent,
        ),
        child: value
            ? Center(
                child: Icon(Icons.check, size: size * 0.65, color: checkColor),
              )
            : null,
      ),
    );
  }
}
