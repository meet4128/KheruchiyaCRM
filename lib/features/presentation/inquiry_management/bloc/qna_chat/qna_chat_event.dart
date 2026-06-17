import 'package:equatable/equatable.dart';

sealed class QnaChatEvent extends Equatable {
  const QnaChatEvent();

  @override
  List<Object?> get props => [];
}

final class QnaChatStarted extends QnaChatEvent {
  const QnaChatStarted({
    required this.inquiryId,
    required this.peerPhone,
    this.sessionId,
    this.customerName = '',
  });

  final String inquiryId;
  final String peerPhone;
  final String? sessionId;
  final String customerName;

  @override
  List<Object?> get props => [inquiryId, peerPhone, sessionId, customerName];
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
