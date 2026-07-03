import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable multi-select pill-shaped selector widget.
/// Mirrors [AppPillSelector] visually, but supports selecting multiple items.
/// Used for room views, amenities, and transfer options.
class AppMultiPillSelector<T> extends StatelessWidget {
  const AppMultiPillSelector({
    super.key,
    required this.items,
    required this.itemLabel,
    required this.onToggle,
    this.selectedValues = const {},
    this.errorText,
    this.enabled = true,
    this.showCheckmark = true,
    this.spacing = 12,
  });

  /// List of selectable items.
  final List<T> items;

  /// Function to get label text from an item.
  final String Function(T) itemLabel;

  /// Callback when an item is toggled (add/remove).
  final ValueChanged<T> onToggle;

  /// Currently selected values.
  final Set<T> selectedValues;

  /// Error text to display below the selector.
  final String? errorText;

  /// Whether the selector is enabled.
  final bool enabled;

  /// Whether to show checkmark icon on selected items.
  final bool showCheckmark;

  /// Spacing between pills.
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items.map((item) {
            final isSelected = selectedValues.contains(item);
            return _MultiPillButton(
              label: itemLabel(item),
              isSelected: isSelected,
              enabled: enabled,
              showCheckmark: showCheckmark,
              onTap: () {
                if (enabled) onToggle(item);
              },
            );
          }).toList(),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: textStyles.formError.copyWith(color: colors.error),
          ),
        ],
      ],
    );
  }
}

/// Individual pill button widget for multi-select.
class _MultiPillButton extends StatelessWidget {
  const _MultiPillButton({
    required this.label,
    required this.isSelected,
    required this.enabled,
    required this.showCheckmark,
    required this.onTap,
  });

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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.secondary.withOpacity(0.25)
              : colors.inputBackground.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colors.secondary.withOpacity(0.8)
                : colors.borderSecondary.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showCheckmark && isSelected) ...[
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: colors.secondary.withOpacity(0.9),
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.secondary, width: 1),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.check, size: 12, color: colors.textOnPrimary),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: textStyles.labelLarge.copyWith(
                color: isSelected
                    ? colors.textPrimary
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
