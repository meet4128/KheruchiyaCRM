import 'package:equatable/equatable.dart';

sealed class QnaChatEvent extends Equatable {
  const QnaChatEvent();

  @override
  List<Object?> get props => [];
}

final class QnaChatStarted extends QnaChatEvent {
  const QnaChatStarted({required this.inquiryId});

  final String inquiryId;

  @override
  List<Object?> get props => [inquiryId];
}

final class QnaChatSectionExpansionToggled extends QnaChatEvent {
  const QnaChatSectionExpansionToggled();
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
  const QnaChatRefreshRequested();
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
