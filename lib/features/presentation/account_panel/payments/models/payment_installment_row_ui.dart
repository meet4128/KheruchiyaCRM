import 'package:equatable/equatable.dart';

/// One installment line shown inside an expanded payment row so the accountant
/// can verify each part of a split payment (e.g. ₹7,500 cash + ₹7,500 UPI).
///
/// All display strings are resolved by the mapper; the widget stays dumb.
class PaymentInstallmentRowUi extends Equatable {
  const PaymentInstallmentRowUi({
    required this.label,
    required this.paymentId,
    required this.amount,
    required this.mode,
    required this.receivedOn,
    required this.dueOn,
    required this.status,
    required this.paymentProofUrl,
    required this.verificationStatus,
  });

  /// e.g. `Installment 1`.
  final String label;

  /// Backend installment id (`_id`), used to verify this single installment.
  final String paymentId;

  /// Formatted amount for this installment — e.g. `₹ 7,500`.
  final String amount;

  /// Payment mode label — e.g. `Cash`, `UPI`, or `—`.
  final String mode;

  /// Received date (e.g. `2 Aug 2026`) or `—` when not yet received.
  final String receivedOn;

  /// Due date (e.g. `2 Aug 2026`) or `—` when none.
  final String dueOn;

  /// Status label — e.g. `On Time`, `Late`, or `Pending`.
  final String status;

  /// Absolute URL to this installment's proof image, or empty when none.
  final String paymentProofUrl;

  /// Verification state from the API: `PENDING` or `VERIFIED`.
  final String verificationStatus;

  bool get hasProof => paymentProofUrl.isNotEmpty;

  bool get isVerified => verificationStatus == 'VERIFIED';

  /// Received installments are the ones an accountant can actually verify.
  bool get isReceived => receivedOn != '—';

  /// A row is verifiable when it has been received and isn't already verified.
  bool get canVerify => isReceived && !isVerified && paymentId.isNotEmpty;

  @override
  List<Object?> get props => [
        label,
        paymentId,
        amount,
        mode,
        receivedOn,
        dueOn,
        status,
        paymentProofUrl,
        verificationStatus,
      ];
}
