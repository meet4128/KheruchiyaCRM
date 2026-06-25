import 'package:equatable/equatable.dart';

class QnaChatInstallmentRow extends Equatable {
  const QnaChatInstallmentRow({
    required this.id,
    this.amountText = '',
    this.dueDate,
    this.receivedDate,
    this.mode,
    this.isAuto = false,
  });

  final String id;
  final String amountText;
  final DateTime? dueDate;
  final DateTime? receivedDate;
  final String? mode;

  /// When true this row's amount is the auto-computed remainder
  /// (total − leading rows) and is not user-editable.
  final bool isAuto;

  bool get isLate =>
      receivedDate != null && dueDate != null && receivedDate!.isAfter(dueDate!);

  QnaChatInstallmentRow copyWith({
    String? amountText,
    DateTime? dueDate,
    DateTime? receivedDate,
    String? mode,
    bool? isAuto,
  }) {
    return QnaChatInstallmentRow(
      id: id,
      amountText: amountText ?? this.amountText,
      dueDate: dueDate ?? this.dueDate,
      receivedDate: receivedDate ?? this.receivedDate,
      mode: mode ?? this.mode,
      isAuto: isAuto ?? this.isAuto,
    );
  }

  @override
  List<Object?> get props => [id, amountText, dueDate, receivedDate, mode, isAuto];
}
