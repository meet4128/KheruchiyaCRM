import 'package:intl/intl.dart';
import 'package:travel_crm/core/utils/inquiry_media_url.dart';
import 'package:travel_crm/data/models/inquiry/payment_plan_installment_dto.dart';
import 'package:travel_crm/data/models/payments/unverified_payment_item.dart';

import '../models/payment_installment_row_ui.dart';
import '../models/unverified_payment_row_ui.dart';

/// Maps a `/payments/unverified` DTO to the table row model. This is the single
/// place display decisions live, so tweaking a column (e.g. what "Inquiry
/// Number" shows) is a one-line change.
///
/// Notes on ambiguous mappings (mock vs. live payload):
///  - "Inquiry Number" → `inquiry.referenceNumber` (a `{countryCode, number}`
///    reference). The mock's `#85913` was placeholder data.
///  - "Paid on" → the most recent installment `receivedDate` (the mock's two
///    identical columns were collapsed to one).
///  - "Credit Account" → the paid installment's `mode`; the proof image is
///    `paymentProofUrl` (opened from the cell).
///  - "Assigned to" → the single `assignedTo` member (the mock showed several).
UnverifiedPaymentRowUi unverifiedPaymentRowFromDto(UnverifiedPaymentItem dto) {
  final paidInstallment = _mostRecentPaid(dto.installments);
  final receivedAt = paidInstallment?.receivedDate ?? dto.submittedAt;

  final route = _flightRoute(dto);

  return UnverifiedPaymentRowUi(
    paymentPlanId: dto.paymentPlanId ?? '',
    inquiryId: dto.inquiryId ?? '',
    inquiryNumber: _inquiryNumber(dto),
    amount: _formatAmount(dto.totalAmount),
    paidOn: _relativeFromNow(receivedAt),
    paidOnSub: _formatDate(receivedAt),
    creditAccount: _orDash(paidInstallment?.mode),
    paymentProofUrl: _proofUrl(paidInstallment?.paymentProofUrl),
    contactName: _orDash(dto.contact?.fullName),
    contactRoute: route,
    contactPhone: dto.contact?.phoneNumber?.display ?? '',
    assignedTo: _orDash(dto.assignedTo?.fullName),
    installments: _installmentRows(dto.installments),
  );
}

/// Maps every installment to its display row for the expanded view. Numbering
/// follows the payload order (`Installment 1`, `Installment 2`, …).
List<PaymentInstallmentRowUi> _installmentRows(
  List<PaymentPlanInstallmentDto> installments,
) {
  final rows = <PaymentInstallmentRowUi>[];
  for (var i = 0; i < installments.length; i++) {
    final dto = installments[i];
    rows.add(
      PaymentInstallmentRowUi(
        label: 'Installment ${i + 1}',
        paymentId: dto.id ?? '',
        amount: _formatAmount(dto.amount),
        mode: _orDash(dto.mode),
        receivedOn: _formatDateOrDash(dto.receivedDate),
        dueOn: _formatDateOrDash(dto.dueDate),
        status: _installmentStatus(dto),
        paymentProofUrl: _proofUrl(dto.paymentProofUrl),
        verificationStatus: dto.verificationStatus ?? '',
      ),
    );
  }
  return rows;
}

/// A received installment reports its `status` (`On Time` / `Late`); anything
/// without a received date is still `Pending`.
String _installmentStatus(PaymentPlanInstallmentDto dto) {
  if (dto.receivedDate == null) return 'Pending';
  final status = dto.status?.trim();
  return (status != null && status.isNotEmpty) ? status : 'Received';
}

List<UnverifiedPaymentRowUi> unverifiedPaymentRowsFromDtos(
  List<UnverifiedPaymentItem> dtos,
) =>
    dtos.map(unverifiedPaymentRowFromDto).toList();

/// The installment we treat as "the payment received" — latest `receivedDate`,
/// else the first with a proof, else the first.
PaymentPlanInstallmentDto? _mostRecentPaid(
  List<PaymentPlanInstallmentDto> installments,
) {
  if (installments.isEmpty) return null;
  final received = installments.where((i) => i.receivedDate != null).toList()
    ..sort((a, b) => b.receivedDate!.compareTo(a.receivedDate!));
  if (received.isNotEmpty) return received.first;
  final withProof = installments.where(
    (i) => (i.paymentProofUrl ?? '').trim().isNotEmpty,
  );
  return withProof.isNotEmpty ? withProof.first : installments.first;
}

String _inquiryNumber(UnverifiedPaymentItem dto) {
  final ref = dto.inquiry?.referenceNumber?.number;
  if (ref != null && ref.trim().isNotEmpty) return '#${ref.trim()}';
  final id = dto.inquiryId;
  if (id != null && id.length >= 5) return '#${id.substring(id.length - 5)}';
  return '—';
}

/// e.g. `AMD → DEL` from the first segment's origin to the last's destination.
String _flightRoute(UnverifiedPaymentItem dto) {
  final segments = dto.contact?.airTicket?.flightSegments ?? const [];
  if (segments.isEmpty) return '';
  final from = segments.first.from?.code?.trim();
  final to = segments.last.to?.code?.trim();
  if ((from == null || from.isEmpty) && (to == null || to.isEmpty)) return '';
  return 'Flight: ${from ?? '—'} → ${to ?? '—'}';
}

String _proofUrl(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '';
  return buildInquiryMediaUrl(raw);
}

final NumberFormat _rupees = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹ ',
  decimalDigits: 0,
);

String _formatAmount(num? amount) {
  if (amount == null) return '—';
  return _rupees.format(amount);
}

String _formatDate(DateTime? date) {
  if (date == null) return '';
  return DateFormat('d MMM yyyy').format(date.toLocal());
}

/// Like [_formatDate] but yields `—` (not empty) for a missing date, so the
/// expanded installment rows always render a placeholder.
String _formatDateOrDash(DateTime? date) {
  final formatted = _formatDate(date);
  return formatted.isEmpty ? '—' : formatted;
}

/// Coarse "x ago" label matching the mock (hours / days).
String _relativeFromNow(DateTime? date) {
  if (date == null) return '—';
  final diff = DateTime.now().difference(date.toLocal());
  if (diff.isNegative) return _formatDate(date);
  if (diff.inHours < 1) {
    final m = diff.inMinutes;
    return m <= 1 ? 'Just now' : '$m minutes ago';
  }
  if (diff.inHours < 24) {
    final h = diff.inHours;
    return h == 1 ? '1 hour ago' : '$h hours ago';
  }
  final d = diff.inDays;
  return d == 1 ? '1 day ago' : '$d days ago';
}

String _orDash(String? value) =>
    (value != null && value.trim().isNotEmpty) ? value.trim() : '—';
