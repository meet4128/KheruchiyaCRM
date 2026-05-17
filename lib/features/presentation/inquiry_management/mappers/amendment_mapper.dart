import 'package:intl/intl.dart';
import 'package:travel_crm/data/models/amendment/amendment_summary_dto.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/amendment_card_ui.dart';

String amendmentTypeLabel(String? apiValue) {
  switch (apiValue?.toLowerCase()) {
    case 're_issue':
      return 'Re Issue';
    case 'cancelation':
      return 'Cancellation';
    case 'booking':
      return 'Booking';
    case 'baggage':
      return 'Baggage';
    default:
      if (apiValue == null || apiValue.trim().isEmpty) return '—';
      return apiValue;
  }
}

/// Display label → API enum for finalize/send.
String? amendmentTypeApiValue(String? displayLabel) {
  if (displayLabel == null) return null;
  switch (displayLabel) {
    case 'Re Issue':
      return 're_issue';
    case 'Cancellation':
      return 'cancelation';
    case 'Booking':
      return 'booking';
    case 'Baggage':
      return 'baggage';
    default:
      return displayLabel.toLowerCase().replaceAll(' ', '_');
  }
}

String amendmentStatusLabel(String? status) {
  switch (status?.toLowerCase()) {
    case 'pending':
      return 'Pending';
    case 'followup':
      return 'Follow Up';
    case 'loss':
      return 'Loss';
    case 'completed':
      return 'Completed';
    default:
      if (status == null || status.trim().isEmpty) return '—';
      return status;
  }
}

bool amendmentStatusIsSuccess(String? status) {
  final s = status?.toLowerCase();
  return s == 'completed' || s == 'won';
}

String formatAmountCharged(double? amount) {
  if (amount == null) return 'N/A';
  final fmt = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
  return '${fmt.format(amount)}/-';
}

AmendmentCardUi amendmentCardFromDto(AmendmentSummaryDto dto) {
  return AmendmentCardUi(
    mongoId: dto.id ?? '',
    amendmentId: dto.amendmentId ?? '',
    amendmentType: dto.amendmentType ?? '',
    amendmentTypeLabel: amendmentTypeLabel(dto.amendmentType),
    status: dto.status ?? '',
    statusLabel: amendmentStatusLabel(dto.status),
    amountCharged: dto.amountCharged,
    amountChargedDisplay: formatAmountCharged(dto.amountCharged),
    sessionId: dto.sessionId,
    chatLockedAt: _parseDate(dto.chatLockedAt),
    processedAt: _parseDate(dto.processedAt),
    createdAt: _parseDate(dto.createdAt),
    isReadOnly: dto.chatLockedAt != null && dto.chatLockedAt!.trim().isNotEmpty,
  );
}

DateTime? _parseDate(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  try {
    return DateTime.parse(raw).toLocal();
  } catch (_) {
    return null;
  }
}
