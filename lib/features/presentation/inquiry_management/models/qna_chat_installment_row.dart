import 'package:equatable/equatable.dart';

class QnaChatInstallmentRow extends Equatable {
  const QnaChatInstallmentRow({
    required this.id,
    this.amountText = '',
    this.dueDate,
    this.receivedDate,
    this.mode,
    this.status,
    this.paymentProofUrl,
    this.isAuto = false,
    this.isUploadingProof = false,
  });

  final String id;
  final String amountText;
  final DateTime? dueDate;
  final DateTime? receivedDate;
  final String? mode;

  /// Persisted status returned by the API (e.g. `On Time` / `Late`).
  final String? status;

  /// Relative URL of the uploaded payment proof, e.g.
  /// `/uploads/payment-proofs/<inquiry>/<file>.jpg`.
  final String? paymentProofUrl;

  /// When true this row's amount is the auto-computed remainder
  /// (total − leading rows) and is not user-editable.
  final bool isAuto;

  /// True while a payment proof upload is in flight for this row.
  final bool isUploadingProof;

  bool get isLate =>
      receivedDate != null && dueDate != null && receivedDate!.isAfter(dueDate!);

  bool get hasProof => paymentProofUrl != null && paymentProofUrl!.isNotEmpty;

  QnaChatInstallmentRow copyWith({
    String? amountText,
    DateTime? dueDate,
    DateTime? receivedDate,
    String? mode,
    String? status,
    String? paymentProofUrl,
    bool clearPaymentProofUrl = false,
    bool? isAuto,
    bool? isUploadingProof,
  }) {
    return QnaChatInstallmentRow(
      id: id,
      amountText: amountText ?? this.amountText,
      dueDate: dueDate ?? this.dueDate,
      receivedDate: receivedDate ?? this.receivedDate,
      mode: mode ?? this.mode,
      status: status ?? this.status,
      paymentProofUrl:
          clearPaymentProofUrl ? null : (paymentProofUrl ?? this.paymentProofUrl),
      isAuto: isAuto ?? this.isAuto,
      isUploadingProof: isUploadingProof ?? this.isUploadingProof,
    );
  }

  @override
  List<Object?> get props =>
      [id, amountText, dueDate, receivedDate, mode, status, paymentProofUrl, isAuto, isUploadingProof];
}
