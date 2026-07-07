import 'package:equatable/equatable.dart';

import '../models/calendar_category.dart';
import '../models/calendar_event_ui.dart';
import '../models/calendar_view_mode.dart';

enum CalendarStatus { initial, loading, success, failure }

class CalendarState extends Equatable {
  CalendarState({
    this.status = CalendarStatus.initial,
    DateTime? focusedDate,
    this.viewMode = CalendarViewMode.month,
    this.category = CalendarCategory.all,
    this.events = const [],
    this.errorMessage,
  }) : focusedDate = focusedDate ?? DateTime.now();

  final CalendarStatus status;

  /// Anchor date for the visible period.
  final DateTime focusedDate;
  final CalendarViewMode viewMode;
  final CalendarCategory category;

  /// All events fetched for the current window (every category).
  final List<CalendarEventUi> events;
  final String? errorMessage;

  bool get isLoading => status == CalendarStatus.loading;

  /// Events after applying the selected category tab.
  List<CalendarEventUi> get visibleEvents =>
      events.where((e) => category.matches(e.type)).toList();

  /// Events on [day] (category-filtered), sorted by start time.
  List<CalendarEventUi> eventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    final list = visibleEvents.where((e) => e.dayKey == key).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    return list;
  }

  /// Next events from now (category-filtered) for the "Upcoming Events" panel.
  List<CalendarEventUi> upcomingEvents({int limit = 6}) {
    final now = DateTime.now();
    final list = visibleEvents.where((e) => !e.start.isBefore(now)).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    return list.length > limit ? list.sublist(0, limit) : list;
  }

  /// Count per tab, computed client-side (the API returns no per-tab counts).
  int countFor(CalendarCategory category) =>
      events.where((e) => category.matches(e.type)).length;

  CalendarState copyWith({
    CalendarStatus? status,
    DateTime? focusedDate,
    CalendarViewMode? viewMode,
    CalendarCategory? category,
    List<CalendarEventUi>? events,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CalendarState(
      status: status ?? this.status,
      focusedDate: focusedDate ?? this.focusedDate,
      viewMode: viewMode ?? this.viewMode,
      category: category ?? this.category,
      events: events ?? this.events,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        focusedDate,
        viewMode,
        category,
        events,
        errorMessage,
      ];
}
