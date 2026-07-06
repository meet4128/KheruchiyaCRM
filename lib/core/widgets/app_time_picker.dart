import 'package:flutter/material.dart';
import '../constants/string_constants.dart';
import '../theme/app_theme.dart';
import 'app_text_field.dart';

/// Reusable time picker field widget
/// Displays formatted time and opens a time picker on tap.
/// Mirrors [AppDatePicker] so date + time fields look and behave consistently.
class AppTimePicker extends StatelessWidget {
  const AppTimePicker({
    super.key,
    this.label,
    this.hint,
    this.value,
    this.onChanged,
    this.onChangedNullable,
    this.errorText,
    this.enabled = true,
    this.isRequired = false,
    this.timeFormat,
  });

  /// Label text displayed above the field
  final String? label;

  /// Hint text displayed when no time is selected
  final String? hint;

  /// Selected time value
  final TimeOfDay? value;

  /// Callback when time is selected
  final ValueChanged<TimeOfDay>? onChanged;

  /// Optional callback for nullable time changes (fires null when cancelled)
  final ValueChanged<TimeOfDay?>? onChangedNullable;

  /// Error text to display
  final String? errorText;

  /// Whether the field is enabled
  final bool enabled;

  /// Whether the field is required (for label indicator)
  final bool isRequired;

  /// Custom time format function (defaults to "hh:mm AM/PM" via [MaterialLocalizations])
  final String Function(TimeOfDay)? timeFormat;

  Future<void> _selectTime(BuildContext context) async {
    if (!enabled || (onChanged == null && onChangedNullable == null)) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: value ?? TimeOfDay.now(),
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

    if (pickedTime != null) {
      onChanged?.call(pickedTime);
      onChangedNullable?.call(pickedTime);
    } else {
      // If user cancels, call nullable callback with null (for optional fields)
      onChangedNullable?.call(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedTime = value != null
        ? (timeFormat != null
            ? timeFormat!(value!)
            : value!.format(context))
        : null;

    return AppTextField(
      key: ValueKey<String?>(formattedTime),
      label: label,
      hint: hint ?? StringConstant.selectTime,
      value: formattedTime,
      errorText: errorText,
      enabled: enabled,
      readOnly: true,
      onTap: () => _selectTime(context),
      suffixIcon: Icons.access_time,
    );
  }
}
