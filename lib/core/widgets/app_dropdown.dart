import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable dropdown widget with consistent styling and theme integration
/// Generic type support for any data type
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.hintText,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.value,
    this.errorText,
    this.enabled = true,
    this.label,
    this.isRequired = false,
  });

  /// Hint text displayed when no value is selected
  final String hintText;

  /// List of items to display
  final List<T> items;

  /// Function to get label text from item
  final String Function(T) itemLabel;

  /// Callback when selection changes
  final ValueChanged<T?> onChanged;

  /// Currently selected value
  final T? value;

  /// Error text to display
  final String? errorText;

  /// Whether the dropdown is enabled
  final bool enabled;

  /// Optional label text displayed above the field
  final String? label;

  /// Whether the field is required (for label indicator)
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label with required indicator
        if (label != null) ...[
          Row(
            children: [
              Text(
                label!,
                style: textStyles.formLabel.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              if (isRequired) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: textStyles.formLabel.copyWith(
                    color: colors.error,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],

        // Dropdown
        DropdownButtonFormField<T>(
          value: value,
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            filled: true,
            fillColor: colors.inputBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colors.inputBorder,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colors.inputBorder,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colors.inputBorderFocused,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colors.borderSecondary,
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colors.inputErrorBorder,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colors.inputErrorBorder,
                width: 2,
              ),
            ),
            hintStyle: textStyles.formHint,
            errorStyle: textStyles.formError,
          ),
          dropdownColor: colors.surface,
          iconEnabledColor: colors.textSecondary,
          iconDisabledColor: colors.textTertiary,
          style: textStyles.formInput.copyWith(
            color: colors.textPrimary,
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    itemLabel(item),
                    style: textStyles.formInput.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: enabled ? onChanged : null,
          isExpanded: true,
        ),
      ],
    );
  }
}

