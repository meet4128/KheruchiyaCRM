import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/theme/app_theme.dart';

import '../bloc/manage_amendment_bloc.dart';
import '../bloc/manage_amendment_event.dart';
import '../bloc/manage_amendment_state.dart';
import '../models/amendment_filter_options.dart';

/// Header row above the results table: "Results (x of y …)", client-side tabs
/// (All / Pending With Supplier / Full Refund / Correction) with counts, and a
/// Refresh action that replays the last search.
class AmendmentResultTabs extends StatelessWidget {
  const AmendmentResultTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return BlocBuilder<ManageAmendmentBloc, ManageAmendmentState>(
      builder: (context, state) {
        final shown = state.visibleRows.length;
        return Row(
          children: [
            Text(
              'Results ($shown of ${state.rows.length} results shown)',
              style: textStyles.bodyMedium.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final tab in AmendmentResultTab.values)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _TabChip(
                          label: _labelFor(tab, state),
                          selected: state.selectedTab == tab,
                          onTap: () => context
                              .read<ManageAmendmentBloc>()
                              .add(AmendmentResultTabChanged(tab)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: state.lastFilter == null
                  ? null
                  : () => context
                      .read<ManageAmendmentBloc>()
                      .add(const AmendmentSearchRefreshed()),
              icon: Icon(Icons.refresh, size: 18, color: colors.secondaryLight),
              label: Text(
                'Refresh',
                style: textStyles.bodySmall.copyWith(color: colors.secondaryLight),
              ),
            ),
          ],
        );
      },
    );
  }

  String _labelFor(AmendmentResultTab tab, ManageAmendmentState state) {
    if (tab == AmendmentResultTab.all) return tab.label;
    return '${tab.label} (${state.countFor(tab)})';
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? colors.secondary : colors.backgroundLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? colors.secondary : colors.borderPrimary,
          ),
        ),
        child: Text(
          label,
          style: textStyles.bodySmall.copyWith(
            color: selected ? colors.textOnPrimary : colors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
