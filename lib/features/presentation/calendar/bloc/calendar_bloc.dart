import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/data/repositories/calendar_repository.dart';

import '../mappers/calendar_event_mapper.dart';
import '../utils/calendar_date_utils.dart';
import 'calendar_event.dart';
import 'calendar_state.dart';

/// Loads and paginates the calendar window, applies the client-side category
/// tab, and moves between periods. Fetches every category (no `type` filter) so
/// the tab badge counts stay accurate.
class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  CalendarBloc(this._repository) : super(CalendarState()) {
    on<CalendarStarted>(_onStarted);
    on<CalendarRefreshed>(_onRefreshed);
    on<CalendarViewModeChanged>(_onViewModeChanged);
    on<CalendarCategoryChanged>(_onCategoryChanged);
    on<CalendarNextPeriod>(_onNextPeriod);
    on<CalendarPreviousPeriod>(_onPreviousPeriod);
    on<CalendarTodayPressed>(_onTodayPressed);
    on<CalendarFocusDateChanged>(_onFocusDateChanged);
  }

  final CalendarRepository _repository;

  /// `from`/`to` are `date-time` in the spec — send full-day ISO 8601 bounds.
  static String _fromIso(DateTime d) =>
      DateTime(d.year, d.month, d.day).toUtc().toIso8601String();
  static String _toIso(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59, 999).toUtc().toIso8601String();

  Future<void> _onStarted(CalendarStarted event, Emitter<CalendarState> emit) async {
    final focused = event.focusDate ?? DateTime.now();
    emit(state.copyWith(focusedDate: focused));
    await _load(emit, focused: focused);
  }

  Future<void> _onRefreshed(CalendarRefreshed event, Emitter<CalendarState> emit) =>
      _load(emit, focused: state.focusedDate);

  Future<void> _onViewModeChanged(
    CalendarViewModeChanged event,
    Emitter<CalendarState> emit,
  ) async {
    if (event.mode == state.viewMode) return;
    emit(state.copyWith(viewMode: event.mode));
    await _load(emit, focused: state.focusedDate);
  }

  void _onCategoryChanged(
    CalendarCategoryChanged event,
    Emitter<CalendarState> emit,
  ) {
    emit(state.copyWith(category: event.category));
  }

  Future<void> _onNextPeriod(CalendarNextPeriod event, Emitter<CalendarState> emit) async {
    final next = CalendarDateUtils.step(state.viewMode, state.focusedDate, forward: true);
    emit(state.copyWith(focusedDate: next));
    await _load(emit, focused: next);
  }

  Future<void> _onPreviousPeriod(
    CalendarPreviousPeriod event,
    Emitter<CalendarState> emit,
  ) async {
    final prev = CalendarDateUtils.step(state.viewMode, state.focusedDate, forward: false);
    emit(state.copyWith(focusedDate: prev));
    await _load(emit, focused: prev);
  }

  Future<void> _onTodayPressed(CalendarTodayPressed event, Emitter<CalendarState> emit) async {
    final today = DateTime.now();
    emit(state.copyWith(focusedDate: today));
    await _load(emit, focused: today);
  }

  Future<void> _onFocusDateChanged(
    CalendarFocusDateChanged event,
    Emitter<CalendarState> emit,
  ) async {
    // Re-fetch only when the target lies outside the current window.
    final window = CalendarDateUtils.windowFor(state.viewMode, state.focusedDate);
    final target = CalendarDateUtils.dateOnly(event.date);
    final outside = target.isBefore(window.from) || target.isAfter(window.to);
    emit(state.copyWith(focusedDate: event.date));
    if (outside) {
      await _load(emit, focused: event.date);
    }
  }

  Future<void> _load(Emitter<CalendarState> emit, {required DateTime focused}) async {
    final window = CalendarDateUtils.windowFor(state.viewMode, focused);
    emit(state.copyWith(status: CalendarStatus.loading, clearError: true));

    try {
      final response = await _repository.listEvents(
        from: _fromIso(window.from),
        to: _toIso(window.to),
      );
      emit(
        state.copyWith(
          status: CalendarStatus.success,
          events: calendarEventsFromDtos(response.data.items),
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CalendarStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
