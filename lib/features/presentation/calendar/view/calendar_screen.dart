import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/theme/app_theme.dart';
import 'package:travel_crm/data/repositories/calendar_repository.dart';
import 'package:travel_crm/di/injector.dart';

import '../bloc/calendar_bloc.dart';
import '../bloc/calendar_event.dart';
import '../bloc/calendar_state.dart';
import '../models/calendar_view_mode.dart';
import '../widgets/calendar_agenda_view.dart';
import '../widgets/calendar_category_tabs.dart';
import '../widgets/calendar_month_grid.dart';
import '../widgets/calendar_toolbar.dart';
import '../widgets/calendar_upcoming_panel.dart';

/// Calendar screen. Follows the feature/BLoC layout used across the app.
/// [focusDate] lets the follow-up flow land on the month of the new reminder.
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key, this.focusDate});

  final DateTime? focusDate;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CalendarBloc(sl<CalendarRepository>())..add(CalendarStarted(focusDate: focusDate)),
      child: const _CalendarView(),
    );
  }
}

class _CalendarView extends StatelessWidget {
  const _CalendarView();

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return Container(
      color: colors.backgroundDark,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Calendar',
                style: textStyles.heading4.copyWith(color: colors.textPrimary),
              ),
              TextButton.icon(
                onPressed: () =>
                    context.read<CalendarBloc>().add(const CalendarRefreshed()),
                icon: Icon(Icons.refresh, size: 18, color: colors.secondaryLight),
                label: Text(
                  'Refresh',
                  style: textStyles.bodyMedium.copyWith(color: colors.secondaryLight),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const CalendarCategoryTabs(),
          const SizedBox(height: 8),
          _ErrorBanner(),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 1000;
                final upcoming = const SizedBox(
                  width: 300,
                  child: SingleChildScrollView(child: CalendarUpcomingPanel()),
                );
                final main = const _CalendarBody();

                if (!wide) {
                  return SingleChildScrollView(
                    child: Column(
                      children: const [
                        CalendarUpcomingPanel(),
                        SizedBox(height: 20),
                        _CalendarBody(),
                      ],
                    ),
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    upcoming,
                    const SizedBox(width: 24),
                    Expanded(child: main),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarBody extends StatelessWidget {
  const _CalendarBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarBloc, CalendarState>(
      buildWhen: (p, c) =>
          p.viewMode != c.viewMode ||
          p.status != c.status ||
          p.focusedDate != c.focusedDate ||
          p.category != c.category ||
          p.events != c.events,
      builder: (context, state) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CalendarToolbar(),
              const SizedBox(height: 12),
              if (state.status == CalendarStatus.loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.viewMode == CalendarViewMode.month)
                const CalendarMonthGrid()
              else
                const CalendarAgendaView(),
            ],
          ),
        );
      },
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    return BlocBuilder<CalendarBloc, CalendarState>(
      buildWhen: (p, c) => p.errorMessage != c.errorMessage || p.status != c.status,
      builder: (context, state) {
        if (state.status != CalendarStatus.failure ||
            (state.errorMessage?.trim().isEmpty ?? true)) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Icon(Icons.error_outline, size: 16, color: colors.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.errorMessage!,
                  style: TextStyle(color: colors.error, fontSize: 12),
                ),
              ),
              TextButton(
                onPressed: () =>
                    context.read<CalendarBloc>().add(const CalendarRefreshed()),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      },
    );
  }
}
