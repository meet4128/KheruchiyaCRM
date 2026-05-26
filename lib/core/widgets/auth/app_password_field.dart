import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/font_constant.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/widgets/auth/auth_field_decoration.dart';

/// Reusable password input with a built-in show/hide eye toggle. Used by the
/// Set-Password (×2 fields), Reset-Password (×2 fields), and Forgot-Password
/// → not-applicable; we still keep it general enough to drop into the login
/// screen later if we ever migrate that off the bespoke implementation.
///
/// The visibility state is **internal** to this widget so the parent bloc
/// doesn't need to track an `obscureX` flag per field — fewer events, less
/// state. If a screen ever needs to coordinate visibility externally (e.g.
/// "show both fields at once"), promote it to the parent then.
class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.enabled = true,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.autofillHints,
    this.textInputAction,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final bool enabled;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscure = true;

  void _toggle() => setState(() => _obscure = !_obscure);

  @override
  Widget build(BuildContext context) {
    final labelStyle = FontConstant.interNormal(
      color: ColorConstant.whiteColor.withValues(alpha: 0.9),
      fontSize: 12,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null && widget.label!.isNotEmpty) ...[
          Text(widget.label!, style: labelStyle),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: widget.controller,
          enabled: widget.enabled,
          obscureText: _obscure,
          autofillHints: widget.autofillHints,
          textInputAction: widget.textInputAction,
          focusNode: widget.focusNode,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          style: FontConstant.interNormal(
            color: ColorConstant.whiteColor,
            fontSize: 14,
          ),
          cursorColor: ColorConstant.whiteColor,
          decoration: authFieldDecoration(
            hintText: widget.hint,
            errorText: widget.errorText,
            suffixIcon: IconButton(
              tooltip: _obscure
                  ? StringConstant.loginTooltipShowPassword
                  : StringConstant.loginTooltipHidePassword,
              onPressed: widget.enabled ? _toggle : null,
              icon: Icon(
                _obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: ColorConstant.whiteColor.withValues(alpha: 0.75),
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
