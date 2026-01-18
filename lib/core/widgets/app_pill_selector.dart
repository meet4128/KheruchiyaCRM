import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable pill-shaped selector widget
/// Used for booking type, visa type, and similar single-choice selections
class AppPillSelector<T> extends StatelessWidget {
  const AppPillSelector({
    super.key,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.selectedValue,
    this.errorText,
    this.enabled = true,
    this.showCheckmark = true,
    this.spacing = 12,
  });

  /// List of selectable items
  final List<T> items;

  /// Function to get label text from item
  final String Function(T) itemLabel;

  /// Callback when selection changes
  final ValueChanged<T> onChanged;

  /// Currently selected value
  final T? selectedValue;

  /// Error text to display below the selector
  final String? errorText;

  /// Whether the selector is enabled
  final bool enabled;

  /// Whether to show checkmark icon on selected items
  final bool showCheckmark;

  /// Spacing between pills
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pill buttons
        Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items.map((item) {
            final isSelected = selectedValue == item;
            final itemText = itemLabel(item);

            return _PillButton<T>(
              item: item,
              label: itemText,
              isSelected: isSelected,
              enabled: enabled,
              showCheckmark: showCheckmark,
              onTap: () {
                if (enabled) {
                  onChanged(item);
                }
              },
            );
          }).toList(),
        ),

        // Error text
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: textStyles.formError.copyWith(
              color: colors.error,
            ),
          ),
        ],
      ],
    );
  }
}

/// Individual pill button widget
class _PillButton<T> extends StatelessWidget {
  const _PillButton({
    required this.item,
    required this.label,
    required this.isSelected,
    required this.enabled,
    required this.showCheckmark,
    required this.onTap,
  });

  final T item;
  final String label;
  final bool isSelected;
  final bool enabled;
  final bool showCheckmark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.secondary
              : colors.inputBackground.withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? colors.secondary
                : colors.borderSecondary.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showCheckmark && isSelected) ...[
              Icon(
                Icons.check,
                size: 18,
                color: colors.textOnPrimary,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: textStyles.labelLarge.copyWith(
                color: isSelected
                    ? colors.textOnPrimary
                    : (enabled ? colors.textPrimary : colors.textTertiary),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}






