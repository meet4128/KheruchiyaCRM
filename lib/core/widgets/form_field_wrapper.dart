import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';

/// Reusable form field wrapper widget
/// Provides consistent label styling with optional required indicator
/// Can be used across different screens for form field labels
class FormFieldWrapper extends StatelessWidget {
  const FormFieldWrapper({
    super.key,
    required this.label,
    required this.child,
    this.isRequired = false,
    this.labelStyle,
    this.requiredIndicatorColor,
    this.spacing,
  });

  final String label;
  final Widget child;
  final bool isRequired;
  final TextStyle? labelStyle;
  final Color? requiredIndicatorColor;
  final double? spacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: labelStyle ??
                theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
            children: [
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: requiredIndicatorColor ?? Colors.redAccent,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: spacing ?? DimensionConstant.d8),
        child,
      ],
    );
  }
}














