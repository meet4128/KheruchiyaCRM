import 'package:flutter/material.dart';
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
  });

  final String label;
  final String selectedCode;
  final String? numberError;
  final ValueChanged<String> onCodeChanged;
  final ValueChanged<String> onNumberChanged;

  static const _codes = ['+91', '+1', '+44', '+61', '+971'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.dark().textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 94,
              child: DropdownButtonFormField<String>(
                value: selectedCode,
                dropdownColor: AppColors.dark().backgroundMedium,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.dark().inputBackground,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.dark().inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.dark().inputBorderFocused),
                  ),
                ),
                iconEnabledColor: AppColors.dark().textSecondary,
                style: TextStyle(color: AppColors.dark().textPrimary, fontSize: 14),
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
                hint: '123456789',
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
