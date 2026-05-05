import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/theme/app_colors.dart';
import 'package:travel_crm/core/widgets/app_text_field.dart';

class AddMemberPhoneField extends StatelessWidget {
  const AddMemberPhoneField({
    super.key,
    required this.label,
    required this.selectedCode,
    required this.numberError,
    required this.onCodeChanged,
    required this.onNumberChanged,
    this.requiredField = false,
    this.allottedNote,
    this.numberHint = '123456789',
  });

  final String label;
  final String selectedCode;
  final String? numberError;
  final ValueChanged<String> onCodeChanged;
  final ValueChanged<String> onNumberChanged;
  final bool requiredField;
  final String? allottedNote;
  final String numberHint;

  static const _codes = ['+91', '+1', '+44', '+61', '+971'];

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.dark();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (requiredField)
                    Text(
                      StringConstant.asterisk,
                      style: TextStyle(
                        color: colors.error,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),
            if (allottedNote != null && allottedNote!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  allottedNote!,
                  style: TextStyle(
                    color: colors.textTertiary,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 94,
              child: DropdownButtonFormField<String>(
                value: selectedCode,
                dropdownColor: colors.backgroundMedium,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: colors.inputBackground,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colors.inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colors.inputBorderFocused),
                  ),
                ),
                iconEnabledColor: colors.textSecondary,
                style: TextStyle(color: colors.textPrimary, fontSize: 14),
                items: _codes
                    .map((code) => DropdownMenuItem(value: code, child: Text(code)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) onCodeChanged(value);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppTextField(
                hint: numberHint,
                keyboardType: TextInputType.phone,
                errorText: numberError,
                onChanged: onNumberChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
