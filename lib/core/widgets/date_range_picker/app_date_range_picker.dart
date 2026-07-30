import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/theme/app_theme.dart';

/// Shows the app's custom dark-themed date-range calendar and returns the
/// selected [DateTimeRange] (or null if dismissed).
///
/// Selection model (no OK/Cancel, matching the app's instant-tap dialogs):
/// 1st tap sets the start, 2nd tap sets the end and closes. Tapping a day
/// before the current start restarts from that day. Tapping the same day twice
/// yields a single-day (`start == end`) selection.
///
/// Shared by the Air Ticket (departure/return, flexible window) and Hotel
/// Booking (check-in/check-out) date fields so both behave identically.
Future<DateTimeRange?> showAppDateRangePicker(
  BuildContext context, {
  required DateTime? initialStart,
  required DateTime? initialEnd,
  required DateTime firstDate,
  DateTime? lastDate,
}) {
  final colors = AppTheme.colors(context);
  return showDialog<DateTimeRange>(
    context: context,
    builder: (dialogContext) {
      return Theme(
        data: Theme.of(dialogContext).copyWith(
          colorScheme: ColorScheme.dark(
            primary: colors.secondary,
            onPrimary: colors.textOnPrimary,
            surface: colors.surface,
            onSurface: colors.textPrimary,
          ),
          dialogBackgroundColor: colors.backgroundMedium,
        ),
        child: Dialog(
          backgroundColor: colors.backgroundMedium,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: _RangeCalendarDialog(
              initialStart: initialStart,
              initialEnd: initialEnd,
              firstDate: firstDate,
              lastDate: lastDate ?? DateTime(firstDate.year + 2, 12, 31),
            ),
          ),
        ),
      );
    },
  );
}

/// Compact date used when rendering a range, e.g. "07 Aug".
String formatAppDateCompact(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}';
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Custom dark-themed range calendar used by the flight & hotel date fields.
class _RangeCalendarDialog extends StatefulWidget {
  const _RangeCalendarDialog({
    required this.initialStart,
    required this.initialEnd,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTime? initialStart;
  final DateTime? initialEnd;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<_RangeCalendarDialog> createState() => _RangeCalendarDialogState();
}

class _RangeCalendarDialogState extends State<_RangeCalendarDialog> {
  static const List<String> _weekdayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  late DateTime _visibleMonth;
  DateTime? _start;
  DateTime? _end;

  @override
  void initState() {
    super.initState();
    _start = widget.initialStart == null ? null : _dateOnly(widget.initialStart!);
    _end = widget.initialEnd == null ? null : _dateOnly(widget.initialEnd!);
    final base = _start ?? _dateOnly(widget.firstDate);
    _visibleMonth = DateTime(base.year, base.month);
  }

  DateTime get _firstMonth =>
      DateTime(widget.firstDate.year, widget.firstDate.month);
  DateTime get _lastMonth =>
      DateTime(widget.lastDate.year, widget.lastDate.month);

  bool get _canGoPrev => _visibleMonth.isAfter(_firstMonth);
  bool get _canGoNext => _visibleMonth.isBefore(_lastMonth);

  void _goPrev() {
    if (!_canGoPrev) return;
    setState(() => _visibleMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month - 1));
  }

  void _goNext() {
    if (!_canGoNext) return;
    setState(() => _visibleMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1));
  }

  void _onDayTap(DateTime day) {
    if (_start == null || _end != null) {
      // Fresh selection.
      setState(() {
        _start = day;
        _end = null;
      });
      return;
    }
    // A start is set and end is not: pick the end (or restart if earlier).
    if (day.isBefore(_start!)) {
      setState(() => _start = day);
      return;
    }
    setState(() => _end = day);
    Navigator.pop(context, DateTimeRange(start: _start!, end: _end!));
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);
    final firstAllowed = _dateOnly(widget.firstDate);
    final lastAllowed = _dateOnly(widget.lastDate);

    final firstOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    // Sunday-first grid: Sun(7)%7=0 … Sat(6).
    final leadingBlanks = firstOfMonth.weekday % 7;

    final cells = <Widget>[];
    for (var i = 0; i < leadingBlanks; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(_visibleMonth.year, _visibleMonth.month, d);
      final disabled =
          date.isBefore(firstAllowed) || date.isAfter(lastAllowed);
      final isStart = _start != null && _isSameDay(date, _start!);
      final isEnd = _end != null && _isSameDay(date, _end!);
      final inRange = _start != null &&
          _end != null &&
          date.isAfter(_start!) &&
          date.isBefore(_end!);
      cells.add(
        _DayCell(
          day: d,
          isEndpoint: isStart || isEnd,
          inRange: inRange,
          disabled: disabled,
          onTap: disabled ? null : () => _onDayTap(date),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StringConstant.selectTravelDates,
            style: textStyles.heading3.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                onPressed: _canGoPrev ? _goPrev : null,
                icon: const Icon(Icons.chevron_left),
                color: colors.textPrimary,
                disabledColor: colors.textSecondary.withOpacity(0.4),
              ),
              Expanded(
                child: Text(
                  '${_monthNames[_visibleMonth.month - 1]} ${_visibleMonth.year}',
                  textAlign: TextAlign.center,
                  style: textStyles.formInput.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: _canGoNext ? _goNext : null,
                icon: const Icon(Icons.chevron_right),
                color: colors.textPrimary,
                disabledColor: colors.textSecondary.withOpacity(0.4),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: _weekdayLabels
                .map(
                  (w) => Expanded(
                    child: Center(
                      child: Text(
                        w,
                        style: textStyles.bodySmall.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 4),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: cells,
          ),
          const SizedBox(height: 8),
          Text(
            _start != null && _end == null
                ? 'Now tap the end date'
                : 'Tap start, then end date',
            style: textStyles.bodySmall.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// One tappable day in [_RangeCalendarDialog].
class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isEndpoint,
    required this.inRange,
    required this.disabled,
    required this.onTap,
  });

  final int day;
  final bool isEndpoint;
  final bool inRange;
  final bool disabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);

    final Color textColor;
    if (disabled) {
      textColor = colors.textSecondary.withOpacity(0.35);
    } else if (isEndpoint) {
      textColor = colors.textOnPrimary;
    } else {
      textColor = colors.textPrimary;
    }

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: inRange
            ? colors.secondary.withOpacity(0.22)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(inRange ? 4 : 20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            alignment: Alignment.center,
            decoration: isEndpoint
                ? BoxDecoration(
                    color: colors.secondary,
                    shape: BoxShape.circle,
                  )
                : null,
            child: Text(
              '$day',
              style: TextStyle(
                color: textColor,
                fontWeight: isEndpoint ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
