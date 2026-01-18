import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/widgets/app_dropdown.dart';
import 'package:travel_crm/core/widgets/form_field_wrapper.dart';

/// Traveller and class selector widget
class TravellerClassSelector extends StatelessWidget {
  const TravellerClassSelector({
    super.key,
    required this.travellerCount,
    required this.classType,
    this.travellerCountError,
    required this.onTravellerCountChanged,
    required this.onClassTypeChanged,
  });

  final int travellerCount;
  final String classType;
  final String? travellerCountError;
  final ValueChanged<int> onTravellerCountChanged;
  final ValueChanged<String> onClassTypeChanged;

  static const List<int> travellerCounts = [1, 2, 3, 4, 5, 6, 7, 8, 9];
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
            child: AppDropdown<int>(
              hintText: StringConstant.selectTravellerCount,
              items: travellerCounts,
              itemLabel: (count) => '$count Traveller${count > 1 ? 's' : ''}',
              value: travellerCount,
              errorText: travellerCountError,
              onChanged: (value) {
                if (value != null) {
                  onTravellerCountChanged(value);
                }
              },
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

