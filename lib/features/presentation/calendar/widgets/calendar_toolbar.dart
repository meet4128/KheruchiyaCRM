import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:travel_crm/core/theme/app_theme.dart';

import '../bloc/calendar_bloc.dart';
import '../bloc/calendar_event.dart';
import '../bloc/calendar_state.dart';
import '../models/calendar_view_mode.dart';

/// Toolbar above the grid: focused-date label, Month/Week/Day switch, period
/// navigation (‹ Today ›), the current time, and Add Event.
class CalendarToolbar extends StatelessWidget {
  const CalendarToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return BlocBuilder<CalendarBloc, CalendarState>(
      builder: (context, state) {
        final bloc = context.read<CalendarBloc>();
        return Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('d MMMM yyyy').format(state.focusedDate),
                  style: textStyles.heading5.copyWith(color: colors.textPrimary),
                ),
                const SizedBox(width: 16),
                _ViewModeSwitch(current: state.viewMode),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => bloc.add(const CalendarPreviousPeriod()),
                  icon: Icon(Icons.chevron_left, color: colors.textSecondary),
                ),
                TextButton(
                  onPressed: () => bloc.add(const CalendarTodayPressed()),
                  child: Text(
                    'Today',
                    style: textStyles.bodyMedium.copyWith(color: colors.textPrimary),
                  ),
                ),
                IconButton(
                  onPressed: () => bloc.add(const CalendarNextPeriod()),
                  icon: Icon(Icons.chevron_right, color: colors.textSecondary),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('h:mm a').format(DateTime.now()),
                  style: textStyles.bodyMedium.copyWith(color: colors.textSecondary),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add Event — coming soon')),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Event'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.textPrimary,
                    side: BorderSide(color: colors.borderPrimary),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ViewModeSwitch extends StatelessWidget {
  const _ViewModeSwitch({required this.current});

  final CalendarViewMode current;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.backgroundMedium,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.borderPrimary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final mode in CalendarViewMode.values)
            InkWell(
              onTap: () => context.read<CalendarBloc>().add(CalendarViewModeChanged(mode)),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: mode == current ? colors.secondary : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  mode.label,
                  style: textStyles.bodySmall.copyWith(
                    color: mode == current ? colors.textOnPrimary : colors.textSecondary,
                    fontWeight: mode == current ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
