import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/theme/app_theme.dart';
import 'package:travel_crm/core/widgets/app_text_field.dart';

/// Budget range field: Min – Max numeric inputs with an optional error below.
class BudgetRangeField extends StatelessWidget {
  const BudgetRangeField({
    super.key,
    required this.min,
    required this.max,
    required this.onMinChanged,
    required this.onMaxChanged,
    this.errorText,
  });

  final String min;
  final String max;
  final ValueChanged<String> onMinChanged;
  final ValueChanged<String> onMaxChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: AppTextField(
                hint: StringConstant.budgetMin,
                value: min,
                onChanged: onMinChanged,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLines: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '—',
                style: textStyles.bodyLarge.copyWith(color: colors.textSecondary),
              ),
            ),
            Expanded(
              child: AppTextField(
                hint: StringConstant.budgetMax,
                value: max,
                onChanged: onMaxChanged,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLines: 1,
              ),
            ),
          ],
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
