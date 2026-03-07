import 'package:flutter/material.dart';
import '../constants/string_constants.dart';
import '../theme/app_theme.dart';
import 'app_text_field.dart';

/// Reusable date picker field widget
/// Displays formatted date and opens date picker on tap
class AppDatePicker extends StatelessWidget {
  const AppDatePicker({
    super.key,
    this.label,
    this.hint,
    this.value,
    this.onChanged,
    this.onChangedNullable,
    this.errorText,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
    this.isRequired = false,
    this.dateFormat,
  });

  /// Label text displayed above the field
  final String? label;

  /// Hint text displayed when no date is selected
  final String? hint;

  /// Selected date value
  final DateTime? value;

  /// Callback when date is selected
  /// Can accept both nullable and non-nullable DateTime callbacks
  final ValueChanged<DateTime>? onChanged;
  
  /// Optional callback for nullable date changes (for return dates, etc.)
  final ValueChanged<DateTime?>? onChangedNullable;

  /// Error text to display
  final String? errorText;

  /// First selectable date (defaults to today)
  final DateTime? firstDate;

  /// Last selectable date
  final DateTime? lastDate;

  /// Whether the field is enabled
  final bool enabled;

  /// Whether the field is required (for label indicator)
  final bool isRequired;

  /// Custom date format function (defaults to "EEE, dd MMM" format)
  final String Function(DateTime)? dateFormat;

  /// Default date formatter: "THU, 20 NOV"
  static String defaultDateFormat(DateTime date) {
    const weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC'
    ];

    final weekday = weekdays[date.weekday - 1];
    final day = date.day;
    final month = months[date.month - 1];

    return '$weekday, $day $month';
  }

  Future<void> _selectDate(BuildContext context) async {
    if (!enabled || (onChanged == null && onChangedNullable == null)) return;

    final now = DateTime.now();
    final firstSelectableDate = firstDate ?? now;
    // lastDate is required by showDatePicker, so use a far future date if not provided
    final lastSelectableDate = lastDate ?? DateTime(now.year + 100, 12, 31);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: firstSelectableDate,
      lastDate: lastSelectableDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.colors(context).secondary,
              onPrimary: AppTheme.colors(context).textOnPrimary,
              surface: AppTheme.colors(context).surface,
              onSurface: AppTheme.colors(context).textPrimary,
            ),
            dialogBackgroundColor: AppTheme.colors(context).backgroundMedium,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      onChanged?.call(pickedDate);
      onChangedNullable?.call(pickedDate);
    } else {
      // If user cancels, call nullable callback with null (for optional fields)
      onChangedNullable?.call(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    final formattedDate = value != null
        ? (dateFormat ?? defaultDateFormat)(value!)
        : null;

    return AppTextField(
      key: ValueKey<String?>(formattedDate),
      label: label,
      hint: hint ?? StringConstant.selectDate,
      value: formattedDate,
      errorText: errorText,
      enabled: enabled,
      readOnly: true,
      onTap: () => _selectDate(context),
      suffixIcon: Icons.calendar_today,
    );
  }
}

