import 'package:equatable/equatable.dart';

/// A calendar event ready for rendering: parsed timestamps, display strings, and
/// the raw `type` (used by the category filter and chip colour).
class CalendarEventUi extends Equatable {
  const CalendarEventUi({
    required this.id,
    required this.type,
    required this.title,
    required this.note,
    required this.start,
    this.end,
    this.allDay = false,
    this.status,
    this.priority,
    this.inquiryId,
    this.assignedToName,
    this.timeRangeLabel = '',
  });

  final String id;

  /// `follow_up` | `payment` | `custom`.
  final String type;
  final String title;
  final String note;

  /// Local-time start / end.
  final DateTime start;
  final DateTime? end;
  final bool allDay;

  final String? status;
  final String? priority;
  final String? inquiryId;
  final String? assignedToName;

  /// e.g. "9:00 AM - 6:30 PM" (or just the start time if no end).
  final String timeRangeLabel;

  /// Calendar-day key (midnight-local) used to bucket events into grid cells.
  DateTime get dayKey => DateTime(start.year, start.month, start.day);

  bool get isFollowUp => type == 'follow_up';
  bool get isPayment => type == 'payment';

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        note,
        start,
        end,
        allDay,
        status,
        priority,
        inquiryId,
        assignedToName,
        timeRangeLabel,
      ];
}
