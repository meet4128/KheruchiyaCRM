import 'package:equatable/equatable.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/qna_chat_message.dart';

enum QnaChatStatus { idle, loading, success, failure }

enum QnaChatSendStatus { idle, sending, failure }

class QnaChatState extends Equatable {
  const QnaChatState({
    this.inquiryId = '',
    this.isSectionExpanded = true,
    this.messages = const [],
    this.messageDraft = '',
    this.amendmentType,
    this.loadStatus = QnaChatStatus.idle,
    this.sendStatus = QnaChatSendStatus.idle,
    this.errorMessage,
    this.sendErrorMessage,
    this.scrollToBottom = false,
  });

  final String inquiryId;
  final bool isSectionExpanded;
  final List<QnaChatMessage> messages;
  final String messageDraft;
  final String? amendmentType;
  final QnaChatStatus loadStatus;
  final QnaChatSendStatus sendStatus;
  final String? errorMessage;
  final String? sendErrorMessage;
  final bool scrollToBottom;

  List<QnaChatDateGroup> get groupedMessages => groupQnaChatMessagesByDate(messages);

  QnaChatState copyWith({
    String? inquiryId,
    bool? isSectionExpanded,
    List<QnaChatMessage>? messages,
    String? messageDraft,
    String? amendmentType,
    bool clearAmendmentType = false,
    QnaChatStatus? loadStatus,
    QnaChatSendStatus? sendStatus,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? sendErrorMessage,
    bool clearSendErrorMessage = false,
    bool? scrollToBottom,
  }) {
    return QnaChatState(
      inquiryId: inquiryId ?? this.inquiryId,
      isSectionExpanded: isSectionExpanded ?? this.isSectionExpanded,
      messages: messages ?? this.messages,
      messageDraft: messageDraft ?? this.messageDraft,
      amendmentType: clearAmendmentType ? null : (amendmentType ?? this.amendmentType),
      loadStatus: loadStatus ?? this.loadStatus,
      sendStatus: sendStatus ?? this.sendStatus,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      sendErrorMessage:
          clearSendErrorMessage ? null : (sendErrorMessage ?? this.sendErrorMessage),
      scrollToBottom: scrollToBottom ?? this.scrollToBottom,
    );
  }

  @override
  List<Object?> get props => [
        inquiryId,
        isSectionExpanded,
        messages,
        messageDraft,
        amendmentType,
        loadStatus,
        sendStatus,
        errorMessage,
        sendErrorMessage,
        scrollToBottom,
      ];
}
