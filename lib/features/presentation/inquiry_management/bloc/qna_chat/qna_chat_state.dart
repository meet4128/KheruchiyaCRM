import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/constants/whatsapp_constants.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/qna_chat_installment_row.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/qna_chat_message.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/qna_chat_pending_attachment.dart';
import 'package:travel_crm/features/presentation/inquiry_management/utils/whatsapp_session_utils.dart';

enum QnaChatStatus { idle, loading, success, failure }

enum QnaChatSendStatus { idle, sending, failure }

enum QnaChatPaymentSaveStatus { idle, saving, success, failure }

class QnaChatState extends Equatable {
  const QnaChatState({
    this.inquiryId = '',
    this.peerPhone = '',
    this.customerName = '',
    this.bookingType,
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
    this.paymentStatus,
    this.travelDate,
    this.travelTime,
    this.totalAmount = '',
    this.installmentCount = 1,
    this.installmentRows = const [],
    this.installmentAmountErrorRemaining,
    this.installmentAmountErrorToken = 0,
    this.paymentSaveStatus = QnaChatPaymentSaveStatus.idle,
    this.paymentSaveError,
    this.paymentSaveResultToken = 0,
  });

  final String inquiryId;
  final String peerPhone;
  final String customerName;
  final String? bookingType;
  final String? sessionId;

  /// Short display form of [inquiryId] (last 8 chars), e.g. `1add3d4e`.
  String get shortInquiryId => inquiryId.length > 8
      ? inquiryId.substring(inquiryId.length - 8)
      : inquiryId;
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
  final String? paymentStatus;
  final DateTime? travelDate;
  final TimeOfDay? travelTime;
  final String totalAmount;
  final int installmentCount;
  final List<QnaChatInstallmentRow> installmentRows;
  final int? installmentAmountErrorRemaining;
  final int installmentAmountErrorToken;
  final QnaChatPaymentSaveStatus paymentSaveStatus;
  final String? paymentSaveError;

  /// Bumped each time a save attempt resolves (success or failure) so the UI
  /// can surface a one-shot snackbar without re-triggering on rebuilds.
  final int paymentSaveResultToken;

  bool get isPaymentSaving => paymentSaveStatus == QnaChatPaymentSaveStatus.saving;

  bool get isInstallmentPayment => paymentStatus == StringConstant.qnaChatPaymentStatusInstallment;
  int get effectiveInstallmentCount => isInstallmentPayment ? installmentCount : 1;
  int get paymentReceivedTillNow => installmentRows
      .where((row) => row.receivedDate != null)
      .fold(0, (sum, row) => sum + (int.tryParse(row.amountText) ?? 0));

  /// Won can only be finalized once the full amount has been received, i.e.
  /// "Payment Received Till Now" matches the "Total Amount to be received".
  bool get canMarkWon {
    final total = int.tryParse(totalAmount.trim());
    return total != null && total > 0 && paymentReceivedTillNow >= total;
  }

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
    String? bookingType,
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
    String? paymentStatus,
    bool clearPaymentStatus = false,
    DateTime? travelDate,
    TimeOfDay? travelTime,
    String? totalAmount,
    int? installmentCount,
    List<QnaChatInstallmentRow>? installmentRows,
    int? installmentAmountErrorRemaining,
    bool clearInstallmentAmountErrorRemaining = false,
    int? installmentAmountErrorToken,
    QnaChatPaymentSaveStatus? paymentSaveStatus,
    String? paymentSaveError,
    bool clearPaymentSaveError = false,
    int? paymentSaveResultToken,
  }) {
    return QnaChatState(
      inquiryId: inquiryId ?? this.inquiryId,
      peerPhone: peerPhone ?? this.peerPhone,
      customerName: customerName ?? this.customerName,
      bookingType: bookingType ?? this.bookingType,
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
      paymentStatus: clearPaymentStatus ? null : (paymentStatus ?? this.paymentStatus),
      travelDate: travelDate ?? this.travelDate,
      travelTime: travelTime ?? this.travelTime,
      totalAmount: totalAmount ?? this.totalAmount,
      installmentCount: installmentCount ?? this.installmentCount,
      installmentRows: installmentRows ?? this.installmentRows,
      installmentAmountErrorRemaining: clearInstallmentAmountErrorRemaining
          ? null
          : (installmentAmountErrorRemaining ?? this.installmentAmountErrorRemaining),
      installmentAmountErrorToken: installmentAmountErrorToken ?? this.installmentAmountErrorToken,
      paymentSaveStatus: paymentSaveStatus ?? this.paymentSaveStatus,
      paymentSaveError:
          clearPaymentSaveError ? null : (paymentSaveError ?? this.paymentSaveError),
      paymentSaveResultToken: paymentSaveResultToken ?? this.paymentSaveResultToken,
    );
  }

  @override
  List<Object?> get props => [
        inquiryId,
        peerPhone,
        customerName,
        bookingType,
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
        paymentStatus,
        travelDate,
        travelTime,
        totalAmount,
        installmentCount,
        installmentRows,
        installmentAmountErrorRemaining,
        installmentAmountErrorToken,
        paymentSaveStatus,
        paymentSaveError,
        paymentSaveResultToken,
      ];
}
