import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:travel_crm/core/theme/app_colors.dart';
import 'package:travel_crm/core/theme/app_theme.dart';

import '../bloc/calendar_bloc.dart';
import '../bloc/calendar_state.dart';
import '../models/calendar_event_ui.dart';
import '../models/calendar_view_mode.dart';
import '../utils/calendar_date_utils.dart';
import '../utils/calendar_event_navigation.dart';

/// Scaffolded Week / Day view — a simple day-grouped agenda over the current
/// window. (Month is the fully-designed view in v1; this keeps Week/Day usable.)
class CalendarAgendaView extends StatelessWidget {
  const CalendarAgendaView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return BlocBuilder<CalendarBloc, CalendarState>(
      builder: (context, state) {
        final window = CalendarDateUtils.windowFor(
          state.viewMode,
          state.focusedDate,
        );
        final days = <DateTime>[];
        for (
          var d = window.from;
          !d.isAfter(window.to);
          d = d.add(const Duration(days: 1))
        ) {
          days.add(d);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final day in days) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  DateFormat(
                    state.viewMode == CalendarViewMode.day
                        ? 'EEEE, d MMMM'
                        : 'EEE, d MMM',
                  ).format(day),
                  style: textStyles.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ..._eventsFor(context, state, day, colors),
              Divider(color: colors.borderPrimary, height: 16),
            ],
          ],
        );
      },
    );
  }

  List<Widget> _eventsFor(
    BuildContext context,
    CalendarState state,
    DateTime day,
    AppColors colors,
  ) {
    final events = state.eventsForDay(day);
    if (events.isEmpty) {
      return [
        Text(
          'No events',
          style: TextStyle(color: colors.textTertiary, fontSize: 12),
        ),
      ];
    }
    return [
      for (final CalendarEventUi e in events)
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: InkWell(
            onTap: () => openInquiryForCalendarEvent(context, e),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colors.backgroundMedium,
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(
                    color: e.isPayment ? colors.warning : colors.success,
                    width: 3,
                  ),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 130,
                    child: Text(
                      e.timeRangeLabel,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      e.title,
                      style: TextStyle(color: colors.textPrimary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    ];
  }
}
