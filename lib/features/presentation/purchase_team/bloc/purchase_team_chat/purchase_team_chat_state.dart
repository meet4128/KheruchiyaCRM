import 'package:equatable/equatable.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/qna_chat_message.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/qna_chat_pending_attachment.dart';
import 'package:travel_crm/features/presentation/purchase_team/models/purchase_team_member_ui.dart';

enum PurchaseTeamChatStatus { idle, loading, success, failure }

enum PurchaseTeamChatSendStatus { idle, sending, failure }

class PurchaseTeamChatState extends Equatable {
  const PurchaseTeamChatState({
    this.inquiryId,
    this.member,
    this.messages = const [],
    this.messageDraft = '',
    this.pendingAttachment,
    this.loadStatus = PurchaseTeamChatStatus.idle,
    this.sendStatus = PurchaseTeamChatSendStatus.idle,
    this.errorMessage,
    this.sendErrorMessage,
    this.scrollToBottom = false,
    this.isRefreshing = false,
  });

  final String? inquiryId;
  final PurchaseTeamMemberUi? member;
  final List<QnaChatMessage> messages;
  final String messageDraft;
  final QnaChatPendingAttachment? pendingAttachment;
  final PurchaseTeamChatStatus loadStatus;
  final PurchaseTeamChatSendStatus sendStatus;
  final String? errorMessage;
  final String? sendErrorMessage;
  final bool scrollToBottom;
  final bool isRefreshing;

  bool get hasMember => member != null;
  bool get hasPendingAttachment => pendingAttachment != null;

  List<QnaChatDateGroup> get groupedMessages => groupQnaChatMessagesByDate(messages);

  PurchaseTeamChatState copyWith({
    String? inquiryId,
    PurchaseTeamMemberUi? member,
    bool clearMember = false,
    List<QnaChatMessage>? messages,
    String? messageDraft,
    QnaChatPendingAttachment? pendingAttachment,
    bool clearPendingAttachment = false,
    PurchaseTeamChatStatus? loadStatus,
    PurchaseTeamChatSendStatus? sendStatus,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? sendErrorMessage,
    bool clearSendErrorMessage = false,
    bool? scrollToBottom,
    bool? isRefreshing,
  }) {
    return PurchaseTeamChatState(
      inquiryId: inquiryId ?? this.inquiryId,
      member: clearMember ? null : (member ?? this.member),
      messages: messages ?? this.messages,
      messageDraft: messageDraft ?? this.messageDraft,
      pendingAttachment: clearPendingAttachment
          ? null
          : (pendingAttachment ?? this.pendingAttachment),
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
        member,
        messages,
        messageDraft,
        pendingAttachment,
        loadStatus,
        sendStatus,
        errorMessage,
        sendErrorMessage,
        scrollToBottom,
        isRefreshing,
      ];
}
