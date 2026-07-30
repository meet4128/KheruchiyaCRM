import 'package:equatable/equatable.dart';

import 'payment_installment_row_ui.dart';

/// A single row rendered in the Accounting → Unverified Payments table.
///
/// All display strings are resolved once by the mapper so the table widget
/// stays dumb. `*Raw` fields keep values needed for actions (ids, proof URL).
/// Columns with no value fall back to `'—'`.
class UnverifiedPaymentRowUi extends Equatable {
  const UnverifiedPaymentRowUi({
    required this.paymentPlanId,
    required this.inquiryId,
    required this.inquiryNumber,
    required this.amount,
    required this.paidOn,
    required this.paidOnSub,
    required this.creditAccount,
    required this.paymentProofUrl,
    required this.contactName,
    required this.contactRoute,
    required this.contactPhone,
    required this.assignedTo,
    required this.installments,
  });

  /// Identity — used by the (future) Verify action and inquiry deep-link.
  final String paymentPlanId;
  final String inquiryId;

  /// "Inquiry Number" column. Sourced from `inquiry.referenceNumber`.
  final String inquiryNumber;

  /// "Amount" column — e.g. `₹ 25,000`.
  final String amount;

  /// "Paid on" column — relative time (e.g. `16 hours ago`) …
  final String paidOn;

  /// … and the absolute-date subline (e.g. `2 Aug 2026`). Empty hides it.
  final String paidOnSub;

  /// "Credit Account" column — payment mode label (proof opens [paymentProofUrl]).
  final String creditAccount;

  /// Absolute URL to the payment proof image, or empty when none.
  final String paymentProofUrl;

  /// "Contact" column pieces.
  final String contactName;
  final String contactRoute;
  final String contactPhone;

  /// "Assigned to" column — member full name.
  final String assignedTo;

  /// Per-installment breakdown shown in the expanded view so the accountant can
  /// verify each part of a split payment individually.
  final List<PaymentInstallmentRowUi> installments;

  bool get hasProof => paymentProofUrl.isNotEmpty;

  /// Number of installments this payment plan is split into.
  int get installmentCount => installments.length;

  /// True when the plan is split across more than one installment.
  bool get isSplit => installments.length > 1;

  @override
  List<Object?> get props => [
        paymentPlanId,
        inquiryId,
        inquiryNumber,
        amount,
        paidOn,
        paidOnSub,
        creditAccount,
        paymentProofUrl,
        contactName,
        contactRoute,
        contactPhone,
        assignedTo,
        installments,
      ];
}
