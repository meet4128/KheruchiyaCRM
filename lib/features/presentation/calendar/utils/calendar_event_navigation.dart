import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_crm/core/constants/path_constants.dart';

import '../models/calendar_event_ui.dart';

/// Opens the Inquiry Management detail for a tapped calendar event.
///
/// Follow-up reminders carry the originating [CalendarEventUi.inquiryId] (and,
/// when the reminder is tied to a specific amendment, its
/// [CalendarEventUi.amendmentId]). We route on the inquiry id — the detail
/// screen loads the inquiry together with all of its amendments — mirroring the
/// vendor list → detail flow. The id is passed as `extra` so
/// `InquiryManagementScreen` can bootstrap the `InquiryDetailBloc` from just the
/// id (no `VendorInquiryRow` needed).
void openInquiryForCalendarEvent(BuildContext context, CalendarEventUi event) {
  final inquiryId = event.inquiryId?.trim() ?? '';
  if (inquiryId.isEmpty) return;
  context.push(PathConstant.inquiryManagementDetail, extra: inquiryId);
}
