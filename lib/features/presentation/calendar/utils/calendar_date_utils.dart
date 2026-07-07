import '../models/calendar_view_mode.dart';

/// Date math for the calendar. Weeks are Monday-first to match the grid header
/// (Mon … Sun).
class CalendarDateUtils {
  const CalendarDateUtils._();

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime firstDayOfMonth(DateTime d) => DateTime(d.year, d.month, 1);

  static DateTime lastDayOfMonth(DateTime d) => DateTime(d.year, d.month + 1, 0);

  /// Monday of [d]'s week.
  static DateTime startOfWeek(DateTime d) {
    final date = dateOnly(d);
    return date.subtract(Duration(days: date.weekday - DateTime.monday));
  }

  /// Sunday of [d]'s week.
  static DateTime endOfWeek(DateTime d) =>
      startOfWeek(d).add(const Duration(days: 6));

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Inclusive fetch window (from, to) for [mode] anchored at [focused].
  static ({DateTime from, DateTime to}) windowFor(
    CalendarViewMode mode,
    DateTime focused,
  ) {
    switch (mode) {
      case CalendarViewMode.month:
        return (from: firstDayOfMonth(focused), to: lastDayOfMonth(focused));
      case CalendarViewMode.week:
        return (from: startOfWeek(focused), to: endOfWeek(focused));
      case CalendarViewMode.day:
        final d = dateOnly(focused);
        return (from: d, to: d);
    }
  }

  /// Steps [focused] forward ([forward] true) or back by one period of [mode].
  static DateTime step(
    CalendarViewMode mode,
    DateTime focused, {
    required bool forward,
  }) {
    final sign = forward ? 1 : -1;
    switch (mode) {
      case CalendarViewMode.month:
        return DateTime(focused.year, focused.month + sign, 1);
      case CalendarViewMode.week:
        return dateOnly(focused).add(Duration(days: 7 * sign));
      case CalendarViewMode.day:
        return dateOnly(focused).add(Duration(days: sign));
    }
  }

  /// The Mon-first day cells for [focused]'s month, with leading/trailing nulls
  /// so day 1 aligns under its weekday and the grid is a whole number of weeks.
  static List<DateTime?> monthGridCells(DateTime focused) {
    final first = firstDayOfMonth(focused);
    final last = lastDayOfMonth(focused);
    final leading = first.weekday - DateTime.monday; // 0..6
    final cells = <DateTime?>[
      for (var i = 0; i < leading; i++) null,
      for (var day = 1; day <= last.day; day++)
        DateTime(focused.year, focused.month, day),
    ];
    // Pad to a full final week.
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    return cells;
  }
}
