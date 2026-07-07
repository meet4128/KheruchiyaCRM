import 'package:intl/intl.dart';
import 'package:travel_crm/data/models/calendar/calendar_event_dto.dart';
import 'package:travel_crm/features/presentation/calendar/models/calendar_event_ui.dart';

final DateFormat _timeFmt = DateFormat('h:mm a');

/// Maps a calendar reminder DTO to the UI model. Reminders have no `type` in the
/// API, so every calendar event is treated as a follow-up (the `Payment` tab
/// stays empty until the backend distinguishes payment reminders). Events
/// without a parseable time are dropped — see [calendarEventsFromDtos].
CalendarEventUi? calendarEventFromDto(CalendarEventDto dto) {
  final start = _parseLocal(dto.effectiveAt);
  if (start == null) return null;

  final note = dto.note?.trim() ?? '';
  return CalendarEventUi(
    id: (dto.reminderId?.isNotEmpty ?? false) ? dto.reminderId! : (dto.id ?? ''),
    type: 'follow_up',
    title: note.isNotEmpty ? note : 'Reminder',
    note: note,
    start: start,
    status: dto.status,
    priority: dto.priority,
    inquiryId: dto.inquiryId,
    assignedToName: dto.agent?.fullName,
    timeRangeLabel: _timeFmt.format(start),
  );
}

List<CalendarEventUi> calendarEventsFromDtos(List<CalendarEventDto> dtos) =>
    dtos.map(calendarEventFromDto).whereType<CalendarEventUi>().toList();

DateTime? _parseLocal(String? iso) {
  if (iso == null || iso.trim().isEmpty) return null;
  return DateTime.tryParse(iso)?.toLocal();
}
