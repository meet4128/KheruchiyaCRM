import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Reusable text field widget with consistent styling and validation
/// Uses theme-based styling and supports prefix/suffix icons
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.initialValue,
    this.value,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.prefixWidget,
    this.suffixWidget,
    this.inputFormatters,
    this.focusNode,
    this.onTap,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.showCounter = false,
    this.obscuringCharacter = '•',
    this.autocorrect = true,
    this.enableSuggestions = true,
  });

  /// Controller for the text field
  final TextEditingController? controller;

  /// Label text displayed above the field
  final String? label;

  /// Hint text displayed inside the field when empty
  final String? hint;

  /// Initial value (only used if controller is null)
  final String? initialValue;

  /// Current value (for controlled components)
  final String? value;

  /// Callback when text changes
  final ValueChanged<String>? onChanged;

  /// Callback when field is submitted
  final ValueChanged<String>? onSubmitted;

  /// Validator function for form validation
  final String? Function(String?)? validator;

  /// Error text to display (takes precedence over validator)
  final String? errorText;

  /// Keyboard type
  final TextInputType? keyboardType;

  /// Text input action
  final TextInputAction? textInputAction;

  /// Whether to obscure text (for passwords)
  final bool obscureText;

  /// Maximum number of lines
  final int maxLines;

  /// Minimum number of lines
  final int? minLines;

  /// Maximum character length
  final int? maxLength;

  /// Whether the field is enabled
  final bool enabled;

  /// Whether the field is read-only
  final bool readOnly;

  /// Whether to autofocus the field
  final bool autofocus;

  /// Prefix icon
  final IconData? prefixIcon;

  /// Suffix icon
  final IconData? suffixIcon;

  /// Prefix text
  final String? prefixText;

  /// Suffix text
  final String? suffixText;

  /// Custom prefix widget
  final Widget? prefixWidget;

  /// Custom suffix widget
  final Widget? suffixWidget;

  /// Input formatters
  final List<TextInputFormatter>? inputFormatters;

  /// Focus node
  final FocusNode? focusNode;

  /// On tap callback
  final VoidCallback? onTap;

  /// Text capitalization
  final TextCapitalization textCapitalization;

  /// Text alignment
  final TextAlign textAlign;

  /// Show character counter
  final bool showCounter;

  /// Character used for obscuring text
  final String obscuringCharacter;

  /// Enable autocorrect
  final bool autocorrect;

  /// Enable suggestions
  final bool enableSuggestions;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    // Use the provided controller only.
    // Do NOT create a new controller from [value] on every build, as that
    // breaks typing when the parent rebuilds (e.g. with BLoC state updates).
    final effectiveController = controller;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (label != null) ...[
          Text(
            label!,
            style: textStyles.formLabel,
          ),
          const SizedBox(height: 8),
        ],

        // Text Field
        TextFormField(
          controller: effectiveController,
          // When no controller is provided, use initialValue/value only once.
          // Subsequent changes should come from the field itself via onChanged.
          initialValue:
              effectiveController == null ? (initialValue ?? value) : null,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          obscuringCharacter: obscuringCharacter,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          enabled: enabled,
          readOnly: readOnly,
          autofocus: autofocus,
          focusNode: focusNode,
          onTap: onTap,
          textCapitalization: textCapitalization,
          textAlign: textAlign,
          autocorrect: autocorrect,
          enableSuggestions: enableSuggestions,
          inputFormatters: inputFormatters,
          style: textStyles.formInput,
          cursorColor: colors.inputBorderFocused,
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            prefixIcon: _buildPrefix(context, colors),
            prefixIconConstraints: prefixWidget != null
                ? const BoxConstraints(minWidth: 0, minHeight: 0)
                : null,
            suffixIcon: _buildSuffix(context, colors),
            suffixIconConstraints: suffixWidget != null || suffixIcon != null
                ? const BoxConstraints(minWidth: 0, minHeight: 0)
                : null,
            prefixText: prefixText,
            suffixText: suffixText,
            counterText: showCounter ? null : '',
            // Use theme's input decoration as base
            filled: true,
            fillColor: colors.inputBackground,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 12.0 : 16.0,
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
            labelStyle: textStyles.formLabel,
            prefixStyle: textStyles.formInput.copyWith(
              color: colors.textSecondary,
            ),
            suffixStyle: textStyles.formInput.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  /// Build prefix widget (icon or custom widget)
  /// Supports custom widgets like country code pickers
  Widget? _buildPrefix(BuildContext context, AppColors colors) {
    if (prefixWidget != null) {
      // For custom widgets (like country code), return as-is
      return Padding(
        padding: const EdgeInsets.only(left: 12),
        child: prefixWidget,
      );
    }
    if (prefixIcon != null) {
      return Icon(
        prefixIcon,
        color: colors.textSecondary,
        size: 20,
      );
    }
    return null;
  }

  /// Build suffix widget (icon or custom widget)
  /// Supports suffix icons for actions like clear, visibility toggle, etc.
  Widget? _buildSuffix(BuildContext context, AppColors colors) {
    if (suffixWidget != null) {
      // For custom widgets, return as-is
      return Padding(
        padding: const EdgeInsets.only(right: 12),
        child: suffixWidget,
      );
    }
    if (suffixIcon != null) {
      return Icon(
        suffixIcon,
        color: colors.textSecondary,
        size: 20,
      );
    }
    return null;
  }
}

/// Reusable validation functions for common use cases
class AppTextFieldValidators {
  /// Required field validator
  static String? required(String? value, {String? message}) {
    if (value == null || value.trim().isEmpty) {
      return message ?? 'This field is required';
    }
    return null;
  }

  /// Email validator
  static String? email(String? value, {String? message}) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return message ?? 'Please enter a valid email address';
    }
    return null;
  }

  /// Phone number validator
  static String? phone(String? value, {String? message}) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^[+]?[(]?[0-9]{1,4}[)]?[-\s.]?[(]?[0-9]{1,4}[)]?[-\s.]?[0-9]{1,9}$');
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return message ?? 'Please enter a valid phone number';
    }
    return null;
  }

  /// Minimum length validator
  static String? minLength(String? value, int minLength, {String? message}) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    if (value.length < minLength) {
      return message ?? 'Must be at least $minLength characters';
    }
    return null;
  }

  /// Maximum length validator
  static String? maxLength(String? value, int maxLength, {String? message}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Allow empty, use required validator if needed
    }
    if (value.length > maxLength) {
      return message ?? 'Must be at most $maxLength characters';
    }
    return null;
  }

  /// Length range validator
  static String? lengthRange(String? value, int min, int max, {String? message}) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    if (value.length < min || value.length > max) {
      return message ?? 'Must be between $min and $max characters';
    }
    return null;
  }

  /// Numeric validator
  static String? numeric(String? value, {String? message}) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    if (double.tryParse(value) == null) {
      return message ?? 'Please enter a valid number';
    }
    return null;
  }

  /// URL validator
  static String? url(String? value, {String? message}) {
    if (value == null || value.trim().isEmpty) {
      return 'URL is required';
    }
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    if (!urlRegex.hasMatch(value)) {
      return message ?? 'Please enter a valid URL';
    }
    return null;
  }

  /// Password strength validator
  static String? passwordStrength(String? value, {int minLength = 8}) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    // Check for at least one uppercase, one lowercase, and one number
    final hasUpper = value.contains(RegExp(r'[A-Z]'));
    final hasLower = value.contains(RegExp(r'[a-z]'));
    final hasDigit = value.contains(RegExp(r'[0-9]'));
    
    if (!hasUpper || !hasLower || !hasDigit) {
      return 'Password must contain uppercase, lowercase, and numbers';
    }
    return null;
  }

  /// Invite / reset-password policy validator.
  ///
  /// Looser than [passwordStrength] — matches the **backend contract** exactly
  /// (8–128 chars, at least one letter + one digit, no upper/lower split).
  /// Using the stricter validator here would silently reject passwords the
  /// server would have accepted, which is a worse UX bug than being too lax.
  static String? invitePasswordPolicy(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters.';
    if (value.length > 128) return 'Password must be at most 128 characters.';
    final hasLetter = value.contains(RegExp(r'[A-Za-z]'));
    final hasDigit = value.contains(RegExp(r'[0-9]'));
    if (!hasLetter || !hasDigit) {
      return 'Password must contain at least one letter and one digit.';
    }
    return null;
  }

  /// Combine multiple validators
  static String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) {
          return error;
        }
      }
      return null;
    };
  }
}

