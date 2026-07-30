import 'package:equatable/equatable.dart';

class QnaChatInstallmentRow extends Equatable {
  const QnaChatInstallmentRow({
    required this.id,
    this.paymentId,
    this.amountText = '',
    this.dueDate,
    this.receivedDate,
    this.mode,
    this.status,
    this.paymentProofUrl,
    this.verificationStatus,
    this.isAuto = false,
    this.isUploadingProof = false,
  });

  final String id;

  /// Backend installment id (`_id`). Present for rows already persisted; sent
  /// back on save so the server merges by row, and used to verify one row.
  final String? paymentId;

  final String amountText;
  final DateTime? dueDate;
  final DateTime? receivedDate;
  final String? mode;

  /// Persisted status returned by the API (e.g. `On Time` / `Late`).
  final String? status;

  /// Relative URL of the uploaded payment proof, e.g.
  /// `/uploads/payment-proofs/<inquiry>/<file>.jpg`.
  final String? paymentProofUrl;

  /// Per-installment verification state from the API: `PENDING` or `VERIFIED`
  /// (null when the row has never been submitted).
  final String? verificationStatus;

  /// When true this row's amount is the auto-computed remainder
  /// (total − leading rows) and is not user-editable.
  final bool isAuto;

  /// True while a payment proof upload is in flight for this row.
  final bool isUploadingProof;

  bool get isLate =>
      receivedDate != null && dueDate != null && receivedDate!.isAfter(dueDate!);

  bool get hasProof => paymentProofUrl != null && paymentProofUrl!.isNotEmpty;

  bool get isVerified => verificationStatus == 'VERIFIED';
  bool get isPending => verificationStatus == 'PENDING';

  /// A row can be logged (submitted for verification) only once it has a real
  /// amount, a received date and a mode — plus proof for non-Cash payments.
  bool get isComplete {
    final hasAmount = amountText.trim().isNotEmpty;
    final hasMode = mode != null && mode!.trim().isNotEmpty && mode != '-';
    final needsProof = mode != 'Cash';
    final proofOk = !needsProof || hasProof;
    return hasAmount && receivedDate != null && hasMode && proofOk;
  }

  QnaChatInstallmentRow copyWith({
    String? paymentId,
    String? amountText,
    DateTime? dueDate,
    DateTime? receivedDate,
    String? mode,
    String? status,
    String? paymentProofUrl,
    String? verificationStatus,
    bool clearPaymentProofUrl = false,
    bool? isAuto,
    bool? isUploadingProof,
  }) {
    return QnaChatInstallmentRow(
      id: id,
      paymentId: paymentId ?? this.paymentId,
      amountText: amountText ?? this.amountText,
      dueDate: dueDate ?? this.dueDate,
      receivedDate: receivedDate ?? this.receivedDate,
      mode: mode ?? this.mode,
      status: status ?? this.status,
      paymentProofUrl:
          clearPaymentProofUrl ? null : (paymentProofUrl ?? this.paymentProofUrl),
      verificationStatus: verificationStatus ?? this.verificationStatus,
      isAuto: isAuto ?? this.isAuto,
      isUploadingProof: isUploadingProof ?? this.isUploadingProof,
    );
  }

  @override
  List<Object?> get props => [
        id,
        paymentId,
        amountText,
        dueDate,
        receivedDate,
        mode,
        status,
        paymentProofUrl,
        verificationStatus,
        isAuto,
        isUploadingProof,
      ];
}
