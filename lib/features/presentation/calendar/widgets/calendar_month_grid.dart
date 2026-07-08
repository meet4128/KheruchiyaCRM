import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/theme/app_theme.dart';

import '../bloc/calendar_bloc.dart';
import '../bloc/calendar_event.dart';
import '../bloc/calendar_state.dart';
import '../utils/calendar_date_utils.dart';
import '../utils/calendar_event_navigation.dart';
import 'calendar_event_chip.dart';

/// Month view — Mon-first weekday header + a grid of day cells. Each cell shows
/// up to [_maxChips] event chips then an "N More" affordance.
class CalendarMonthGrid extends StatelessWidget {
  const CalendarMonthGrid({super.key});

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _maxChips = 3;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);

    return BlocBuilder<CalendarBloc, CalendarState>(
      builder: (context, state) {
        final cells = CalendarDateUtils.monthGridCells(state.focusedDate);
        final weeks = <List<DateTime?>>[
          for (var i = 0; i < cells.length; i += 7) cells.sublist(i, i + 7),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                for (final day in _weekdays)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: colors.backgroundLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        day,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            for (final week in weeks)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final day in week)
                      Expanded(
                        child: _DayCell(day: day, state: state),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.state});

  final DateTime? day;
  final CalendarState state;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);

    if (day == null) {
      return Container(
        margin: const EdgeInsets.all(2),
        constraints: const BoxConstraints(minHeight: 104),
        decoration: BoxDecoration(
          color: colors.backgroundDark.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(6),
        ),
      );
    }

    final events = state.eventsForDay(day!);
    final isToday = CalendarDateUtils.isSameDay(day!, DateTime.now());
    final visible = events.length > CalendarMonthGrid._maxChips
        ? events.sublist(0, CalendarMonthGrid._maxChips)
        : events;
    final extra = events.length - visible.length;

    return InkWell(
      onTap: () =>
          context.read<CalendarBloc>().add(CalendarFocusDateChanged(day!)),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(6),
        constraints: const BoxConstraints(minHeight: 104),
        decoration: BoxDecoration(
          color: colors.backgroundMedium,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isToday ? colors.secondaryLight : colors.borderPrimary,
            width: isToday ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: isToday
                    ? BoxDecoration(
                        color: colors.textPrimary,
                        shape: BoxShape.circle,
                      )
                    : null,
                child: Text(
                  day!.day.toString().padLeft(2, '0'),
                  style: TextStyle(
                    color: isToday
                        ? colors.backgroundDark
                        : colors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            for (final e in visible)
              CalendarEventChip(
                event: e,
                onTap: () => openInquiryForCalendarEvent(context, e),
              ),
            if (extra > 0)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '$extra More',
                  style: TextStyle(color: colors.textTertiary, fontSize: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
