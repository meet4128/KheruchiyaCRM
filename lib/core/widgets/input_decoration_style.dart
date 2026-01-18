import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';

/// Reusable input decoration style for form fields
/// This decoration provides consistent styling across the application
class InputDecorationStyle {
  static InputDecoration get defaultDecoration => const InputDecoration(
        filled: true,
        fillColor: Color(0xFF161424),
        hintStyle: TextStyle(color: Colors.white54),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(DimensionConstant.d12)),
          borderSide: BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(DimensionConstant.d12)),
          borderSide: BorderSide(color: Color(0xFFB753F4), width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(DimensionConstant.d12)),
          borderSide: BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(DimensionConstant.d12)),
          borderSide: BorderSide(color: Colors.redAccent, width: 1.4),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: DimensionConstant.d14,
          vertical: DimensionConstant.d16,
        ),
      );
}














