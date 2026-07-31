import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show TimeOfDay;

sealed class QnaChatEvent extends Equatable {
  const QnaChatEvent();

  @override
  List<Object?> get props => [];
}

final class QnaChatStarted extends QnaChatEvent {
  const QnaChatStarted({
    required this.inquiryId,
    required this.peerPhone,
    this.inquiryDisplayNo = '',
    this.sessionId,
    this.customerName = '',
    this.bookingType,
  });

  final String inquiryId;
  final String inquiryDisplayNo;
  final String peerPhone;
  final String? sessionId;
  final String customerName;
  final String? bookingType;

  @override
  List<Object?> get props =>
      [inquiryId, inquiryDisplayNo, peerPhone, sessionId, customerName, bookingType];
}

final class QnaChatSessionIdUpdated extends QnaChatEvent {
  const QnaChatSessionIdUpdated(this.sessionId);

  final String? sessionId;

  @override
  List<Object?> get props => [sessionId];
}

final class QnaChatSectionExpansionToggled extends QnaChatEvent {
  const QnaChatSectionExpansionToggled();
}

final class QnaChatInnerExpansionToggled extends QnaChatEvent {
  const QnaChatInnerExpansionToggled();
}

final class QnaChatMessageDraftChanged extends QnaChatEvent {
  const QnaChatMessageDraftChanged(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}

final class QnaChatSendPressed extends QnaChatEvent {
  const QnaChatSendPressed();
}

final class QnaChatRefreshRequested extends QnaChatEvent {
  const QnaChatRefreshRequested({this.silent = false});

  final bool silent;

  @override
  List<Object?> get props => [silent];
}

final class QnaChatPollTick extends QnaChatEvent {
  const QnaChatPollTick();
}

final class QnaChatAmendmentTypeChanged extends QnaChatEvent {
  const QnaChatAmendmentTypeChanged(this.amendmentType);

  final String? amendmentType;

  @override
  List<Object?> get props => [amendmentType];
}

final class QnaChatScrollToBottomHandled extends QnaChatEvent {
  const QnaChatScrollToBottomHandled();
}

final class QnaChatAddNoteRequested extends QnaChatEvent {
  const QnaChatAddNoteRequested(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}

/// User picked a file via + — stage above composer until send.
final class QnaChatAttachmentPicked extends QnaChatEvent {
  const QnaChatAttachmentPicked({
    required this.fileName,
    this.filePath,
    this.bytes,
  });

  final String fileName;
  final String? filePath;
  final List<int>? bytes;

  @override
  List<Object?> get props => [fileName, filePath, bytes];
}

final class QnaChatAttachmentCleared extends QnaChatEvent {
  const QnaChatAttachmentCleared();
}

/// Upload + WhatsApp document send (used from send or legacy direct dispatch).
final class QnaChatDocumentUploadRequested extends QnaChatEvent {
  const QnaChatDocumentUploadRequested({
    required this.fileName,
    this.filePath,
    this.bytes,
    this.caption,
  });

  final String fileName;
  final String? filePath;
  final List<int>? bytes;
  final String? caption;

  @override
  List<Object?> get props => [fileName, filePath, bytes, caption];
}

final class QnaChatPaymentStatusChanged extends QnaChatEvent {
  const QnaChatPaymentStatusChanged(this.paymentStatus);

  final String? paymentStatus;

  @override
  List<Object?> get props => [paymentStatus];
}

final class QnaChatTravelDateChanged extends QnaChatEvent {
  const QnaChatTravelDateChanged(this.date);

  final DateTime date;

  @override
  List<Object?> get props => [date];
}

final class QnaChatTravelTimeChanged extends QnaChatEvent {
  const QnaChatTravelTimeChanged(this.time);

  final TimeOfDay time;

  @override
  List<Object?> get props => [time];
}

final class QnaChatTotalAmountChanged extends QnaChatEvent {
  const QnaChatTotalAmountChanged(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}

final class QnaChatInstallmentCountChanged extends QnaChatEvent {
  const QnaChatInstallmentCountChanged(this.count);

  final int count;

  @override
  List<Object?> get props => [count];
}

final class QnaChatInstallmentRowAmountChanged extends QnaChatEvent {
  const QnaChatInstallmentRowAmountChanged({required this.rowId, required this.text});

  final String rowId;
  final String text;

  @override
  List<Object?> get props => [rowId, text];
}

final class QnaChatInstallmentRowDateChanged extends QnaChatEvent {
  const QnaChatInstallmentRowDateChanged({
    required this.rowId,
    required this.isDueDate,
    required this.date,
  });

  final String rowId;
  final bool isDueDate;
  final DateTime date;

  @override
  List<Object?> get props => [rowId, isDueDate, date];
}

final class QnaChatInstallmentRowModeChanged extends QnaChatEvent {
  const QnaChatInstallmentRowModeChanged({required this.rowId, required this.mode});

  final String rowId;
  final String mode;

  @override
  List<Object?> get props => [rowId, mode];
}

/// Loads the saved payment plan for the inquiry and prefills the form.
final class QnaChatPaymentPlanLoadRequested extends QnaChatEvent {
  const QnaChatPaymentPlanLoadRequested();
}

/// Persists the current payment terms form (travel date/time, total amount,
/// installments and their rows) for the inquiry.
final class QnaChatPaymentTermsSaveRequested extends QnaChatEvent {
  const QnaChatPaymentTermsSaveRequested();
}

/// Logs (submits for verification) a single installment [rowId]. Persists the
/// whole plan via the merge PUT — the edited row becomes PENDING server-side.
/// Only valid once that row is complete (amount + received date + mode + proof).
final class QnaChatInstallmentLogPaymentRequested extends QnaChatEvent {
  const QnaChatInstallmentLogPaymentRequested(this.rowId);

  final String rowId;

  @override
  List<Object?> get props => [rowId];
}

/// Uploads a payment proof file for the installment [rowId].
final class QnaChatInstallmentProofUploadRequested extends QnaChatEvent {
  const QnaChatInstallmentProofUploadRequested({
    required this.rowId,
    required this.fileName,
    this.filePath,
    this.bytes,
  });

  final String rowId;
  final String fileName;
  final String? filePath;
  final List<int>? bytes;

  @override
  List<Object?> get props => [rowId, fileName, filePath, bytes];
}
