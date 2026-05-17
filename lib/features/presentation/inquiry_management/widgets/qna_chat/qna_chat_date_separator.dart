import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/font_constant.dart';

class QnaChatDateSeparator extends StatelessWidget {
  const QnaChatDateSeparator({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DimensionConstant.d12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DimensionConstant.d14,
            vertical: DimensionConstant.d6,
          ),
          decoration: BoxDecoration(
            color: ColorConstant.borderColorWhite30.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(DimensionConstant.d20),
          ),
          child: Text(
            label,
            style: FontConstant.interNormal(
              color: ColorConstant.whiteColor.withValues(alpha: 0.9),
              fontSize: DimensionConstant.d12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
