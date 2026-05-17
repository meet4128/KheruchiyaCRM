import 'package:equatable/equatable.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/qna_chat_message.dart';

enum QnaChatStatus { idle, loading, success, failure }

enum QnaChatSendStatus { idle, sending, failure }

class QnaChatState extends Equatable {
  const QnaChatState({
    this.inquiryId = '',
    this.peerPhone = '',
    this.sessionId,
    this.isSectionExpanded = true,
    this.isInnerExpanded = true,
    this.messages = const [],
    this.messageDraft = '',
    this.amendmentType,
    this.loadStatus = QnaChatStatus.idle,
    this.sendStatus = QnaChatSendStatus.idle,
    this.errorMessage,
    this.sendErrorMessage,
    this.scrollToBottom = false,
    this.isRefreshing = false,
  });

  final String inquiryId;
  final String peerPhone;
  final String? sessionId;
  final bool isSectionExpanded;
  final bool isInnerExpanded;
  final List<QnaChatMessage> messages;
  final String messageDraft;
  final String? amendmentType;
  final QnaChatStatus loadStatus;
  final QnaChatSendStatus sendStatus;
  final String? errorMessage;
  final String? sendErrorMessage;
  final bool scrollToBottom;
  final bool isRefreshing;

  bool get hasSession => sessionId != null && sessionId!.isNotEmpty;
  bool get hasValidPeerPhone => peerPhone.length >= 10;
  bool get showFinalizeBar => hasSession;

  List<QnaChatDateGroup> get groupedMessages => groupQnaChatMessagesByDate(messages);

  QnaChatState copyWith({
    String? inquiryId,
    String? peerPhone,
    String? sessionId,
    bool clearSessionId = false,
    bool? isSectionExpanded,
    bool? isInnerExpanded,
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
    bool? isRefreshing,
  }) {
    return QnaChatState(
      inquiryId: inquiryId ?? this.inquiryId,
      peerPhone: peerPhone ?? this.peerPhone,
      sessionId: clearSessionId ? null : (sessionId ?? this.sessionId),
      isSectionExpanded: isSectionExpanded ?? this.isSectionExpanded,
      isInnerExpanded: isInnerExpanded ?? this.isInnerExpanded,
      messages: messages ?? this.messages,
      messageDraft: messageDraft ?? this.messageDraft,
      amendmentType: clearAmendmentType ? null : (amendmentType ?? this.amendmentType),
      loadStatus: loadStatus ?? this.loadStatus,
      sendStatus: sendStatus ?? this.sendStatus,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      sendErrorMessage:
          clearSendErrorMessage ? null : (sendErrorMessage ?? this.sendErrorMessage),
      scrollToBottom: scrollToBottom ?? this.scrollToBottom,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
        inquiryId,
        peerPhone,
        sessionId,
        isSectionExpanded,
        isInnerExpanded,
        messages,
        messageDraft,
        amendmentType,
        loadStatus,
        sendStatus,
        errorMessage,
        sendErrorMessage,
        scrollToBottom,
        isRefreshing,
      ];
}
