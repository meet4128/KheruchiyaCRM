import 'package:equatable/equatable.dart';

import '../models/calendar_category.dart';
import '../models/calendar_view_mode.dart';

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object?> get props => [];
}

/// Initialises the screen. [focusDate] lets the follow-up flow land the calendar
/// on the month of the newly-scheduled reminder; null = today.
class CalendarStarted extends CalendarEvent {
  const CalendarStarted({this.focusDate});

  final DateTime? focusDate;

  @override
  List<Object?> get props => [focusDate];
}

/// Re-fetches the current window (Refresh button / retry).
class CalendarRefreshed extends CalendarEvent {
  const CalendarRefreshed();
}

class CalendarViewModeChanged extends CalendarEvent {
  const CalendarViewModeChanged(this.mode);

  final CalendarViewMode mode;

  @override
  List<Object?> get props => [mode];
}

/// Client-side category tab (All / Follow Up / Payment).
class CalendarCategoryChanged extends CalendarEvent {
  const CalendarCategoryChanged(this.category);

  final CalendarCategory category;

  @override
  List<Object?> get props => [category];
}

/// Step forward one period (month/week/day per the current view).
class CalendarNextPeriod extends CalendarEvent {
  const CalendarNextPeriod();
}

/// Step back one period.
class CalendarPreviousPeriod extends CalendarEvent {
  const CalendarPreviousPeriod();
}

/// Jump back to today's period.
class CalendarTodayPressed extends CalendarEvent {
  const CalendarTodayPressed();
}

/// Selects a specific day (day-cell tap); may switch the anchor date.
class CalendarFocusDateChanged extends CalendarEvent {
  const CalendarFocusDateChanged(this.date);

  final DateTime date;

  @override
  List<Object?> get props => [date];
}
