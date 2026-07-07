import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/theme/app_theme.dart';
import 'package:travel_crm/core/widgets/app_button.dart';
import 'package:travel_crm/core/widgets/app_date_picker.dart';
import 'package:travel_crm/core/widgets/app_dropdown.dart';
import 'package:travel_crm/core/widgets/app_form_card.dart';
import 'package:travel_crm/core/widgets/app_text_field.dart';

import '../bloc/manage_amendment_bloc.dart';
import '../bloc/manage_amendment_event.dart';
import '../models/amendment_filter_options.dart';
import '../models/amendment_search_filter.dart';

/// The top "Amendments" filter card. Only Type / Status / Processed From / To
/// are wired to the API; the remaining fields (Amendment ID, journey / fare /
/// channel type, from/to date) are rendered disabled as placeholders because
/// `/amendments/search` has no query param for them yet.
class AmendmentFilterForm extends StatefulWidget {
  const AmendmentFilterForm({super.key});

  @override
  State<AmendmentFilterForm> createState() => _AmendmentFilterFormState();
}

class _AmendmentFilterFormState extends State<AmendmentFilterForm> {
  AmendmentTypeOption? _type;
  AmendmentStatusOption? _status;
  DateTime? _processedFrom;
  DateTime? _processedTo;

  void _onSearch() {
    context.read<ManageAmendmentBloc>().add(
          AmendmentSearchSubmitted(
            AmendmentSearchFilter(
              type: _type,
              status: _status,
              processedFrom: _processedFrom,
              processedTo: _processedTo,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return AppFormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Amendments', style: textStyles.heading3),
          const SizedBox(height: 4),
          Text(
            'Fill in the form to search amendments',
            style: textStyles.bodySmall.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 16.0;
              final columns = constraints.maxWidth >= 900
                  ? 4
                  : constraints.maxWidth >= 560
                      ? 2
                      : 1;
              final itemWidth =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;

              Widget sized(Widget child) =>
                  SizedBox(width: itemWidth, child: child);

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  // Disabled placeholder — no backend param yet.
                  sized(
                    const AppTextField(
                      label: 'Amendment ID',
                      hint: 'Coming soon',
                      enabled: false,
                    ),
                  ),
                  sized(
                    AppDatePicker(
                      label: 'From Date',
                      hint: 'Coming soon',
                      enabled: false,
                      onChangedNullable: (_) {},
                    ),
                  ),
                  sized(
                    AppDatePicker(
                      label: 'To Date',
                      hint: 'Coming soon',
                      enabled: false,
                      onChangedNullable: (_) {},
                    ),
                  ),
                  // Wired field — Type → amendmentType.
                  sized(
                    AppDropdown<AmendmentTypeOption>(
                      label: 'Type',
                      hintText: 'Select Type',
                      value: _type,
                      items: AmendmentTypeOption.values,
                      itemLabel: (o) => o.label,
                      onChanged: (v) => setState(() => _type = v),
                    ),
                  ),
                  // Disabled placeholder.
                  sized(
                    const AppDropdown<String>(
                      label: 'Journey Type',
                      hintText: 'Coming soon',
                      value: null,
                      items: [],
                      itemLabel: _identity,
                      onChanged: _noop,
                      enabled: false,
                    ),
                  ),
                  // Wired field — Processed From → processedFrom.
                  sized(
                    AppDatePicker(
                      label: 'Processed From',
                      hint: 'Select date',
                      value: _processedFrom,
                      lastDate: _processedTo,
                      onChangedNullable: (v) => setState(() => _processedFrom = v),
                    ),
                  ),
                  // Wired field — Processed To → processedTo.
                  sized(
                    AppDatePicker(
                      label: 'Processed To',
                      hint: 'Select date',
                      value: _processedTo,
                      firstDate: _processedFrom,
                      onChangedNullable: (v) => setState(() => _processedTo = v),
                    ),
                  ),
                  // Disabled placeholder.
                  sized(
                    const AppDropdown<String>(
                      label: 'Fare Type',
                      hintText: 'Coming soon',
                      value: null,
                      items: [],
                      itemLabel: _identity,
                      onChanged: _noop,
                      enabled: false,
                    ),
                  ),
                  // Wired field — Status → status.
                  sized(
                    AppDropdown<AmendmentStatusOption>(
                      label: 'Status',
                      hintText: 'Select Status',
                      value: _status,
                      items: AmendmentStatusOption.values,
                      itemLabel: (o) => o.label,
                      onChanged: (v) => setState(() => _status = v),
                    ),
                  ),
                  // Disabled placeholder.
                  sized(
                    const AppDropdown<String>(
                      label: 'Channel Type',
                      hintText: 'Coming soon',
                      value: null,
                      items: [],
                      itemLabel: _identity,
                      onChanged: _noop,
                      enabled: false,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 220,
              child: AppButton(text: 'Search', onPressed: _onSearch),
            ),
          ),
        ],
      ),
    );
  }

  static String _identity(String value) => value;
  static void _noop(String? _) {}
}
