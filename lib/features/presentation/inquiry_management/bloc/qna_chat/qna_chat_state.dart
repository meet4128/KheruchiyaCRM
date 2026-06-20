import 'package:equatable/equatable.dart';
import 'package:travel_crm/core/constants/whatsapp_constants.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/qna_chat_message.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/qna_chat_pending_attachment.dart';
import 'package:travel_crm/features/presentation/inquiry_management/utils/whatsapp_session_utils.dart';

enum QnaChatStatus { idle, loading, success, failure }

enum QnaChatSendStatus { idle, sending, failure }

class QnaChatState extends Equatable {
  const QnaChatState({
    this.inquiryId = '',
    this.peerPhone = '',
    this.customerName = '',
    this.sessionId,
    this.isSectionExpanded = true,
    this.isInnerExpanded = true,
    this.messages = const [],
    this.messageDraft = '',
    this.pendingAttachment,
    this.amendmentType,
    this.loadStatus = QnaChatStatus.idle,
    this.sendStatus = QnaChatSendStatus.idle,
    this.errorMessage,
    this.sendErrorMessage,
    this.scrollToBottom = false,
    this.isRefreshing = false,
    this.greetingTemplateSent = false,
  });

  final String inquiryId;
  final String peerPhone;
  final String customerName;
  final String? sessionId;
  final bool isSectionExpanded;
  final bool isInnerExpanded;
  final List<QnaChatMessage> messages;
  final String messageDraft;
  final QnaChatPendingAttachment? pendingAttachment;
  final String? amendmentType;

  bool get hasPendingAttachment => pendingAttachment != null;
  final QnaChatStatus loadStatus;
  final QnaChatSendStatus sendStatus;
  final String? errorMessage;
  final String? sendErrorMessage;
  final bool scrollToBottom;
  final bool isRefreshing;
  final bool greetingTemplateSent;

  bool get hasSession => sessionId != null && sessionId!.isNotEmpty;
  bool get hasValidPeerPhone => peerPhone.length >= 10;
  bool get showFinalizeBar => hasSession;
  bool get hasActiveWhatsappSession => computeHasActiveWhatsappSession(messages);
  bool get greetingTemplateDelivered =>
      greetingTemplateSent || computeHasOutboundMessage(messages);
  bool get hasInboundMessages =>
      messages.any((message) => message.kind == QnaChatMessageKind.question);
  bool get showAwaitingCustomerReplyHint =>
      hasValidPeerPhone && greetingTemplateDelivered && !hasInboundMessages;
  bool get showTemplateComposer =>
      hasValidPeerPhone && !hasActiveWhatsappSession && !greetingTemplateDelivered;
  String get templatePreviewText => WhatsappConstants.templatePreview(customerName);

  List<QnaChatDateGroup> get groupedMessages => groupQnaChatMessagesByDate(messages);

  QnaChatState copyWith({
    String? inquiryId,
    String? peerPhone,
    String? customerName,
    String? sessionId,
    bool clearSessionId = false,
    bool? isSectionExpanded,
    bool? isInnerExpanded,
    List<QnaChatMessage>? messages,
    String? messageDraft,
    QnaChatPendingAttachment? pendingAttachment,
    bool clearPendingAttachment = false,
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
    bool? greetingTemplateSent,
  }) {
    return QnaChatState(
      inquiryId: inquiryId ?? this.inquiryId,
      peerPhone: peerPhone ?? this.peerPhone,
      customerName: customerName ?? this.customerName,
      sessionId: clearSessionId ? null : (sessionId ?? this.sessionId),
      isSectionExpanded: isSectionExpanded ?? this.isSectionExpanded,
      isInnerExpanded: isInnerExpanded ?? this.isInnerExpanded,
      messages: messages ?? this.messages,
      messageDraft: messageDraft ?? this.messageDraft,
      pendingAttachment: clearPendingAttachment
          ? null
          : (pendingAttachment ?? this.pendingAttachment),
      amendmentType: clearAmendmentType ? null : (amendmentType ?? this.amendmentType),
      loadStatus: loadStatus ?? this.loadStatus,
      sendStatus: sendStatus ?? this.sendStatus,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      sendErrorMessage:
          clearSendErrorMessage ? null : (sendErrorMessage ?? this.sendErrorMessage),
      scrollToBottom: scrollToBottom ?? this.scrollToBottom,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      greetingTemplateSent: greetingTemplateSent ?? this.greetingTemplateSent,
    );
  }

  @override
  List<Object?> get props => [
        inquiryId,
        peerPhone,
        customerName,
        sessionId,
        isSectionExpanded,
        isInnerExpanded,
        messages,
        messageDraft,
        pendingAttachment,
        amendmentType,
        loadStatus,
        sendStatus,
        errorMessage,
        sendErrorMessage,
        scrollToBottom,
        isRefreshing,
        greetingTemplateSent,
      ];
}
