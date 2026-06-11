import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/widgets/app_dropdown.dart';
import 'package:travel_crm/core/widgets/form_field_wrapper.dart';
import '../models/traveller_breakdown.dart';

/// Traveller and class selector widget (legacy row layout).
class TravellerClassSelector extends StatelessWidget {
  const TravellerClassSelector({
    super.key,
    required this.breakdown,
    required this.classType,
    this.travellerCountError,
    required this.onClassTypeChanged,
  });

  final TravellerBreakdown breakdown;
  final String classType;
  final String? travellerCountError;
  final ValueChanged<String> onClassTypeChanged;

  static const List<String> classTypes = [
    StringConstant.economy,
    StringConstant.business,
    StringConstant.first,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FormFieldWrapper(
            label: StringConstant.travellerAndClass,
            isRequired: true,
            child: Text(
              breakdown.displayLabelWithClass(null),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
        const SizedBox(width: 22),
        Expanded(
          child: FormFieldWrapper(
            label: '',
            child: AppDropdown<String>(
              hintText: StringConstant.selectClass,
              items: classTypes,
              itemLabel: (type) => type,
              value: classType.isEmpty ? null : classType,
              onChanged: (value) {
                if (value != null) {
                  onClassTypeChanged(value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
