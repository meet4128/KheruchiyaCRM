import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/font_constant.dart';

/// Translucent-dark text-field skin used by every auth card.
///
/// The auth surface has its own decoration (vs. the generic [AppTextField]
/// which uses theme colours) because the form sits on top of a dark image
/// pane and needs to keep contrast — white text on a 45%-black fill with a
/// 22%-white border.
InputDecoration authFieldDecoration({
  String? hintText,
  String? errorText,
  Widget? suffixIcon,
}) {
  final border = Colors.white.withValues(alpha: 0.22);
  final fieldFill = Colors.black.withValues(alpha: 0.45);

  return InputDecoration(
    isDense: true,
    filled: true,
    fillColor: fieldFill,
    hintText: hintText,
    hintStyle: FontConstant.interNormal(
      color: ColorConstant.whiteColor.withValues(alpha: 0.55),
      fontSize: 14,
    ),
    errorText: errorText,
    errorMaxLines: 2,
    errorStyle: FontConstant.interNormal(
      color: ColorConstant.redColor,
      fontSize: 11,
    ),
    suffixIcon: suffixIcon,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: DimensionConstant.d14,
      vertical: DimensionConstant.d14,
    ),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide:
          BorderSide(color: ColorConstant.whiteColor.withValues(alpha: 0.5)),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: ColorConstant.redColor),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: ColorConstant.redColor),
    ),
  );
}
