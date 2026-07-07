import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/theme/app_colors.dart';
import 'package:travel_crm/core/theme/app_theme.dart';

import '../bloc/calendar_bloc.dart';
import '../bloc/calendar_state.dart';
import '../models/calendar_event_ui.dart';

/// Left-hand "Upcoming Events" list — the next events from now in the loaded
/// window (category-filtered).
class CalendarUpcomingPanel extends StatelessWidget {
  const CalendarUpcomingPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return BlocBuilder<CalendarBloc, CalendarState>(
      builder: (context, state) {
        final events = state.upcomingEvents();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming Events',
              style: textStyles.heading5.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: 2),
            Text(
              "Don't Miss Scheduled Events",
              style: textStyles.bodySmall.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: 16),
            if (state.isLoading && events.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (events.isEmpty)
              Text(
                'No upcoming events.',
                style: textStyles.bodySmall.copyWith(color: colors.textTertiary),
              )
            else
              for (final event in events)
                _UpcomingCard(event: event, colors: colors),
          ],
        );
      },
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({required this.event, required this.colors});

  final CalendarEventUi event;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final accent = event.isPayment ? colors.warning : colors.success;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.backgroundMedium,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.borderPrimary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              ),
              Text(
                event.timeRangeLabel,
                style: TextStyle(color: colors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            event.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (event.note.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              event.note,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.textTertiary, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
