import 'dart:async';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/constants/whatsapp_constants.dart';
import 'package:travel_crm/core/utils/inquiry_media_url.dart';
import 'package:travel_crm/core/utils/whatsapp_media_url.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/qna_chat_installment_row.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/qna_chat_message.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/qna_chat_pending_attachment.dart';
import 'package:travel_crm/data/models/amendment/send_whatsapp_message_request.dart';
import 'package:travel_crm/data/models/amendment/session_message_item.dart';
import 'package:travel_crm/data/models/amendment/whatsapp_template_payload.dart';
import 'package:travel_crm/data/models/inquiry/payment_plan_dto.dart';
import 'package:travel_crm/data/models/inquiry/payment_plan_installment_dto.dart';
import 'package:travel_crm/data/models/inquiry/update_payment_plan_request.dart';
import 'package:travel_crm/data/repositories/inquiry_repository.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/qna_chat/qna_chat_event.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/qna_chat/qna_chat_state.dart';
import 'package:travel_crm/features/presentation/inquiry_management/mappers/amendment_mapper.dart';
import 'package:travel_crm/features/presentation/inquiry_management/mappers/session_message_mapper.dart';

class QnaChatBloc extends Bloc<QnaChatEvent, QnaChatState> {
  QnaChatBloc({required InquiryRepository inquiryRepository})
      : _repository = inquiryRepository,
        super(const QnaChatState()) {
    on<QnaChatStarted>(_onStarted);
    on<QnaChatSessionIdUpdated>(_onSessionIdUpdated);
    on<QnaChatSectionExpansionToggled>(_onSectionExpansionToggled);
    on<QnaChatInnerExpansionToggled>(_onInnerExpansionToggled);
    on<QnaChatMessageDraftChanged>(_onMessageDraftChanged);
    on<QnaChatSendPressed>(_onSendPressed);
    on<QnaChatRefreshRequested>(_onRefreshRequested);
    on<QnaChatPollTick>(_onPollTick);
    on<QnaChatAmendmentTypeChanged>(_onAmendmentTypeChanged);
    on<QnaChatScrollToBottomHandled>(_onScrollToBottomHandled);
    on<QnaChatAddNoteRequested>(_onAddNoteRequested);
    on<QnaChatAttachmentPicked>(_onAttachmentPicked);
    on<QnaChatAttachmentCleared>(_onAttachmentCleared);
    on<QnaChatDocumentUploadRequested>(_onDocumentUploadRequested);
    on<QnaChatPaymentStatusChanged>(_onPaymentStatusChanged);
    on<QnaChatTravelDateChanged>(_onTravelDateChanged);
    on<QnaChatTravelTimeChanged>(_onTravelTimeChanged);
    on<QnaChatTotalAmountChanged>(_onTotalAmountChanged);
    on<QnaChatInstallmentCountChanged>(_onInstallmentCountChanged);
    on<QnaChatInstallmentRowAmountChanged>(_onInstallmentRowAmountChanged);
    on<QnaChatInstallmentRowDateChanged>(_onInstallmentRowDateChanged);
    on<QnaChatInstallmentRowModeChanged>(_onInstallmentRowModeChanged);
    on<QnaChatPaymentPlanLoadRequested>(_onPaymentPlanLoadRequested);
    on<QnaChatPaymentTermsSaveRequested>(_onPaymentTermsSaveRequested);
    on<QnaChatInstallmentLogPaymentRequested>(_onInstallmentLogPaymentRequested);
    on<QnaChatInstallmentProofUploadRequested>(_onInstallmentProofUploadRequested);
  }

  final InquiryRepository _repository;
  final _uuid = const Uuid();
  Timer? _pollTimer;

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }

  void _onStarted(QnaChatStarted event, Emitter<QnaChatState> emit) {
    _pollTimer?.cancel();
    // The payment terms are keyed to a single inquiry. When this bloc is reused
    // for another inquiry (e.g. the same customer/phone booking a new inquiry),
    // wipe the previous inquiry's payment form so its plan never bleeds through.
    // The fresh plan for [event.inquiryId] is then loaded below via
    // [QnaChatPaymentPlanLoadRequested]; a new inquiry with no saved plan simply
    // keeps this cleared state.
    emit(
      _resetPaymentForm(
        state.copyWith(
          inquiryId: event.inquiryId,
          inquiryDisplayNo: event.inquiryDisplayNo,
          peerPhone: event.peerPhone,
          customerName: event.customerName,
          bookingType: event.bookingType,
          sessionId: event.sessionId,
          messages: const [],
          messageDraft: '',
          greetingTemplateSent: false,
          loadStatus: QnaChatStatus.success,
          clearErrorMessage: true,
        ),
      ),
    );
    if (state.hasValidPeerPhone || state.hasSession) {
      add(const QnaChatRefreshRequested());
      _startPolling();
    }
    if (event.inquiryId.isNotEmpty) {
      add(const QnaChatPaymentPlanLoadRequested());
    }
  }

  void _onSessionIdUpdated(QnaChatSessionIdUpdated event, Emitter<QnaChatState> emit) {
    final hadSession = state.hasSession;
    emit(
      state.copyWith(
        sessionId: event.sessionId,
        clearSessionId: event.sessionId == null || event.sessionId!.isEmpty,
      ),
    );
    if (!hadSession && state.hasSession) {
      add(const QnaChatRefreshRequested());
    }
    if (!state.hasValidPeerPhone) {
      _pollTimer?.cancel();
    } else if (state.isSectionExpanded) {
      _startPolling();
    }
  }

  void _onSectionExpansionToggled(
    QnaChatSectionExpansionToggled event,
    Emitter<QnaChatState> emit,
  ) {
    final expanded = !state.isSectionExpanded;
    emit(state.copyWith(isSectionExpanded: expanded));
    if (expanded && (state.hasValidPeerPhone || state.hasSession)) {
      _startPolling();
    } else {
      _pollTimer?.cancel();
    }
  }

  void _onInnerExpansionToggled(
    QnaChatInnerExpansionToggled event,
    Emitter<QnaChatState> emit,
  ) {
    emit(state.copyWith(isInnerExpanded: !state.isInnerExpanded));
  }

  void _onMessageDraftChanged(
    QnaChatMessageDraftChanged event,
    Emitter<QnaChatState> emit,
  ) {
    emit(
      state.copyWith(
        messageDraft: event.text,
        clearSendErrorMessage: true,
        sendStatus: QnaChatSendStatus.idle,
      ),
    );
  }

  void _onAttachmentPicked(
    QnaChatAttachmentPicked event,
    Emitter<QnaChatState> emit,
  ) {
    emit(
      state.copyWith(
        pendingAttachment: QnaChatPendingAttachment(
          fileName: event.fileName,
          filePath: event.filePath,
          bytes: event.bytes,
        ),
        clearSendErrorMessage: true,
        sendStatus: QnaChatSendStatus.idle,
      ),
    );
  }

  void _onAttachmentCleared(
    QnaChatAttachmentCleared event,
    Emitter<QnaChatState> emit,
  ) {
    emit(state.copyWith(clearPendingAttachment: true));
  }

  Future<void> _onSendPressed(QnaChatSendPressed event, Emitter<QnaChatState> emit) async {
    if (state.sendStatus == QnaChatSendStatus.sending) return;

    if (!state.hasValidPeerPhone) {
      emit(
        state.copyWith(
          sendStatus: QnaChatSendStatus.failure,
          sendErrorMessage: 'Customer phone is not available.',
        ),
      );
      return;
    }

    if (state.showTemplateComposer) {
      await _sendTemplate(emit);
      return;
    }

    final pending = state.pendingAttachment;
    if (pending != null) {
      await _sendDocument(
        emit,
        fileName: pending.fileName,
        filePath: pending.filePath,
        bytes: pending.bytes,
        caption: state.messageDraft.trim().isEmpty ? null : state.messageDraft.trim(),
      );
      return;
    }

    final draft = state.messageDraft.trim();
    if (draft.isEmpty) return;

    emit(
      state.copyWith(
        sendStatus: QnaChatSendStatus.sending,
        clearSendErrorMessage: true,
      ),
    );

    try {
      final sessionId = await _ensureSessionId(emit);
      if (sessionId == null) return;

      await _repository.sendWhatsappMessage(
        SendWhatsappMessageRequest(
          to: state.peerPhone,
          sessionId: sessionId,
          inquiryId: state.inquiryId,
          type: 'text',
          text: draft,
        ),
      );

      emit(
        state.copyWith(
          messageDraft: '',
          sendStatus: QnaChatSendStatus.idle,
        ),
      );

      await _fetchMessages(emit, silent: false);
    } catch (e) {
      emit(
        state.copyWith(
          sendStatus: QnaChatSendStatus.failure,
          sendErrorMessage: _userFacingError(e),
        ),
      );
    }
  }

  Future<void> _sendTemplate(Emitter<QnaChatState> emit) async {
    emit(
      state.copyWith(
        sendStatus: QnaChatSendStatus.sending,
        clearSendErrorMessage: true,
      ),
    );

    try {
      final sessionId = await _ensureSessionId(emit);
      if (sessionId == null) return;

      final customerName = state.customerName.trim().isEmpty
          ? 'there'
          : state.customerName.trim();

      final previewText = WhatsappConstants.templatePreview(customerName);

      await _repository.sendWhatsappMessage(
        SendWhatsappMessageRequest(
          to: state.peerPhone,
          sessionId: sessionId,
          inquiryId: state.inquiryId,
          type: 'template',
          template: WhatsappTemplatePayload(
            name: WhatsappConstants.templateName,
            language: WhatsappConstants.templateLanguage,
            bodyParams: [customerName],
          ),
        ),
      );

      final optimistic = QnaChatMessage(
        id: 'local-template-${_uuid.v4()}',
        kind: QnaChatMessageKind.answer,
        contentType: QnaChatMessageContentType.text,
        body: previewText,
        createdAt: DateTime.now(),
      );

      emit(
        state.copyWith(
          sendStatus: QnaChatSendStatus.idle,
          messageDraft: '',
          greetingTemplateSent: true,
          messages: [...state.messages, optimistic],
          scrollToBottom: true,
        ),
      );
      await _fetchMessages(emit, silent: false);
    } catch (e) {
      emit(
        state.copyWith(
          sendStatus: QnaChatSendStatus.failure,
          sendErrorMessage: _userFacingError(e),
        ),
      );
    }
  }

  Future<void> _onDocumentUploadRequested(
    QnaChatDocumentUploadRequested event,
    Emitter<QnaChatState> emit,
  ) async {
    await _sendDocument(
      emit,
      fileName: event.fileName,
      filePath: event.filePath,
      bytes: event.bytes,
      caption: event.caption,
    );
  }

  Future<void> _sendDocument(
    Emitter<QnaChatState> emit, {
    required String fileName,
    String? filePath,
    List<int>? bytes,
    String? caption,
  }) async {
    if (state.sendStatus == QnaChatSendStatus.sending) return;

    if (!state.hasValidPeerPhone) {
      emit(
        state.copyWith(
          sendErrorMessage: 'Customer phone is not available.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        sendStatus: QnaChatSendStatus.sending,
        clearSendErrorMessage: true,
      ),
    );

    try {
      final sessionId = await _ensureSessionId(emit);
      if (sessionId == null) return;

      final multipart = await _multipartFromPick(
        fileName: fileName,
        filePath: filePath,
        bytes: bytes,
      );

      final upload = await _repository.uploadSessionFile(
        inquiryId: state.inquiryId,
        sessionId: sessionId,
        file: multipart,
      );

      final publicUrl = buildWhatsappMediaUrl(upload.data.mediaUrl);
      final trimmedCaption = caption?.trim() ?? '';
      final effectiveCaption = trimmedCaption.isNotEmpty ? trimmedCaption : '';

      await _repository.sendWhatsappMessage(
        SendWhatsappMessageRequest(
          to: state.peerPhone,
          sessionId: sessionId,
          inquiryId: state.inquiryId,
          type: 'document',
          text: effectiveCaption.isEmpty ? fileName : effectiveCaption,
          mediaUrl: publicUrl,
          fileName: upload.data.fileName,
        ),
      );

      final displayName = upload.data.fileName.trim().isNotEmpty
          ? upload.data.fileName.trim()
          : fileName;
      final optimistic = QnaChatMessage(
        id: 'local-doc-${_uuid.v4()}',
        kind: QnaChatMessageKind.answer,
        messageType: QnaChatMessageType.document,
        contentType: QnaChatMessageContentType.structured,
        body: effectiveCaption.isEmpty ? displayName : effectiveCaption,
        createdAt: DateTime.now(),
        fileName: displayName,
        mimeType: upload.data.mimeType,
        mediaUrl: buildInquiryMediaUrl(upload.data.mediaUrl),
        caption: effectiveCaption.isEmpty ? null : effectiveCaption,
      );

      emit(
        state.copyWith(
          sendStatus: QnaChatSendStatus.idle,
          messageDraft: '',
          clearPendingAttachment: true,
          messages: [...state.messages, optimistic],
          scrollToBottom: true,
        ),
      );

      await _fetchMessages(emit, silent: false);
    } catch (e) {
      emit(
        state.copyWith(
          sendStatus: QnaChatSendStatus.failure,
          sendErrorMessage: _userFacingError(e),
        ),
      );
    }
  }

  String _userFacingError(Object error) {
    if (error is Exception) {
      return error.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
    }
    final text = error.toString();
    if (text.contains('DioException')) {
      return 'Could not send the message. Please try again.';
    }
    return text;
  }

  Future<String?> _ensureSessionId(Emitter<QnaChatState> emit) async {
    var sessionId = state.sessionId;
    if (sessionId == null || sessionId.isEmpty) {
      sessionId = _uuid.v4();
      emit(state.copyWith(sessionId: sessionId));
      _startPolling();
    }
    return sessionId;
  }

  Future<MultipartFile> _multipartFromPick({
    required String fileName,
    String? filePath,
    List<int>? bytes,
  }) async {
    if (bytes != null && bytes.isNotEmpty) {
      return MultipartFile.fromBytes(
        bytes,
        filename: fileName,
      );
    }

    // Web has no real file path — bytes are required.
    if (kIsWeb) {
      throw Exception(
        'Could not read the selected file in the browser. '
        'Try a smaller PDF or image.',
      );
    }

    if (filePath != null && filePath.isNotEmpty) {
      return MultipartFile.fromFile(filePath, filename: fileName);
    }

    throw Exception('Could not read the selected file.');
  }

  Future<void> _onRefreshRequested(
    QnaChatRefreshRequested event,
    Emitter<QnaChatState> emit,
  ) async {
    if (!state.hasValidPeerPhone && !state.hasSession) return;
    await _fetchMessages(emit, silent: event.silent);
  }

  Future<void> _onPollTick(QnaChatPollTick event, Emitter<QnaChatState> emit) async {
    if ((!state.hasValidPeerPhone && !state.hasSession) ||
        !state.isSectionExpanded ||
        !state.isInnerExpanded) {
      return;
    }
    await _fetchMessages(emit, silent: true);
  }

  Future<void> _fetchMessages(Emitter<QnaChatState> emit, {required bool silent}) async {
    if (!state.hasValidPeerPhone && !state.hasSession) return;

    if (!silent) {
      emit(
        state.copyWith(
          loadStatus: state.messages.isEmpty ? QnaChatStatus.loading : state.loadStatus,
          isRefreshing: state.messages.isNotEmpty,
          clearErrorMessage: true,
        ),
      );
    }

    try {
      final sessionId = state.sessionId;
      final serverLists = <List<QnaChatMessage>>[];
      Object? lastError;

      // Inbound customer replies are stored on the WhatsApp conversation feed,
      // which is keyed only by phone. We send `inquiryId` so the server scopes
      // the thread to this inquiry, and [_itemsForCurrentInquiry] strictly keeps
      // only this inquiry's messages as a guard, so a customer's other inquiries
      // on the same number never leak their conversation here.
      if (state.hasValidPeerPhone) {
        try {
          final response = await _repository.listWhatsappMessages(
            peerPhone: state.peerPhone,
            inquiryId: state.inquiryId,
          );
          final scopedItems = _itemsForCurrentInquiry(response.data.items);
          final mapped = qnaMessagesFromSessionItems(scopedItems);
          serverLists.add(mapped);
          _logMessageFeed(
            source: 'whatsapp',
            peerPhone: state.peerPhone,
            rawCount: scopedItems.length,
            mapped: mapped,
          );
        } catch (e) {
          lastError = e;
          developer.log('WhatsApp messages fetch failed: $e', name: 'QnaChatBloc');
        }
      }

      // Outbound agent messages (template, text, docs) are on the session feed.
      if (sessionId != null &&
          sessionId.isNotEmpty &&
          state.inquiryId.isNotEmpty) {
        try {
          final response = await _repository.listSessionMessages(
            inquiryId: state.inquiryId,
            sessionId: sessionId,
          );
          final mapped = qnaMessagesFromSessionItems(response.data.items);
          serverLists.add(mapped);
          _logMessageFeed(
            source: 'session',
            peerPhone: state.peerPhone,
            rawCount: response.data.items.length,
            mapped: mapped,
          );
        } catch (e) {
          lastError = e;
          developer.log('Session messages fetch failed: $e', name: 'QnaChatBloc');
        }
      }

      if (serverLists.isEmpty) {
        throw lastError ?? Exception('Could not load messages.');
      }

      final fromServer = mergeServerMessageLists(serverLists);
      final messages = deduplicateQnaChatMessages(
        mergeQnaChatMessages(state.messages, fromServer),
      );
      emit(
        state.copyWith(
          messages: messages,
          loadStatus: QnaChatStatus.success,
          isRefreshing: false,
          scrollToBottom: !silent,
          clearErrorMessage: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loadStatus: state.messages.isEmpty ? QnaChatStatus.failure : state.loadStatus,
          isRefreshing: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      add(const QnaChatPollTick());
    });
  }

  void _onAmendmentTypeChanged(
    QnaChatAmendmentTypeChanged event,
    Emitter<QnaChatState> emit,
  ) {
    emit(
      state.copyWith(
        amendmentType: event.amendmentType,
        clearAmendmentType: event.amendmentType == null,
      ),
    );
  }

  void _onScrollToBottomHandled(
    QnaChatScrollToBottomHandled event,
    Emitter<QnaChatState> emit,
  ) {
    if (state.scrollToBottom) {
      emit(state.copyWith(scrollToBottom: false));
    }
  }

  Future<void> _onAddNoteRequested(
    QnaChatAddNoteRequested event,
    Emitter<QnaChatState> emit,
  ) async {
    final sessionId = state.sessionId;
    final text = event.text.trim();
    if (sessionId == null || text.isEmpty || state.inquiryId.isEmpty) return;

    try {
      await _repository.addSessionNote(
        inquiryId: state.inquiryId,
        sessionId: sessionId,
        text: text,
      );
    } catch (e) {
      emit(state.copyWith(sendErrorMessage: _userFacingError(e)));
    }
  }

  /// API value for finalize from selected amendment type label.
  String? get amendmentTypeApi => amendmentTypeApiValue(state.amendmentType);

  /// Stable id for the auto-computed remainder row so its controller and
  /// table position stay consistent as it appears/disappears.
  static const String _autoRowId = '__auto_remainder__';

  int get _totalAmountValue => int.tryParse(state.totalAmount) ?? 0;

  /// Rebuilds the installment rows so the final row always reflects the
  /// outstanding (`total` − received installments) amount as a non-editable
  /// auto row.
  ///
  /// The leading `count - 1` rows are user-editable; the last slot is the auto
  /// remainder. Only rows whose received date is set count towards the total,
  /// so the remainder updates (and the auto row is dropped or reappears) once a
  /// received date is added or a received amount is changed.
  List<QnaChatInstallmentRow> _normalizeInstallmentRows({
    required List<QnaChatInstallmentRow> rows,
    required int count,
    required int total,
  }) {
    QnaChatInstallmentRow? existingAuto;
    final manual = <QnaChatInstallmentRow>[];
    for (final row in rows) {
      if (row.isAuto) {
        existingAuto = row;
      } else {
        manual.add(row);
      }
    }
    while (manual.length < count) {
      manual.add(QnaChatInstallmentRow(id: _uuid.v4()));
    }

    // No total entered yet — keep `count` plain editable rows.
    if (total <= 0) {
      return manual.take(count).toList();
    }

    final leading = manual.take(count - 1).toList();
    // Only installments with a received date reduce the outstanding remainder.
    final receivedSum = leading
        .where((row) => row.receivedDate != null)
        .fold<int>(0, (sum, row) => sum + (int.tryParse(row.amountText) ?? 0));
    final remaining = total - receivedSum;

    // Received installments cover the full total — drop the remainder row.
    if (remaining <= 0) return leading;

    // Preserve the auto row's own date/mode while refreshing its amount.
    final autoRow = (existingAuto ?? const QnaChatInstallmentRow(id: _autoRowId))
        .copyWith(amountText: '$remaining', isAuto: true);
    return [...leading, autoRow];
  }

  void _onPaymentStatusChanged(
    QnaChatPaymentStatusChanged event,
    Emitter<QnaChatState> emit,
  ) {
    final isInstallment = event.paymentStatus == StringConstant.qnaChatPaymentStatusInstallment;
    emit(
      state.copyWith(
        paymentStatus: event.paymentStatus,
        clearPaymentStatus: event.paymentStatus == null,
        installmentRows: _normalizeInstallmentRows(
          rows: const [],
          count: isInstallment ? state.installmentCount : 1,
          total: _totalAmountValue,
        ),
      ),
    );
  }

  void _onTravelDateChanged(QnaChatTravelDateChanged event, Emitter<QnaChatState> emit) {
    emit(state.copyWith(travelDate: event.date));
  }

  void _onTravelTimeChanged(QnaChatTravelTimeChanged event, Emitter<QnaChatState> emit) {
    emit(state.copyWith(travelTime: event.time));
  }

  void _onTotalAmountChanged(QnaChatTotalAmountChanged event, Emitter<QnaChatState> emit) {
    final total = int.tryParse(event.text) ?? 0;
    emit(
      state.copyWith(
        totalAmount: event.text,
        installmentRows: _normalizeInstallmentRows(
          rows: state.installmentRows,
          count: state.effectiveInstallmentCount,
          total: total,
        ),
      ),
    );
  }

  void _onInstallmentCountChanged(
    QnaChatInstallmentCountChanged event,
    Emitter<QnaChatState> emit,
  ) {
    emit(
      state.copyWith(
        installmentCount: event.count,
        installmentRows: _normalizeInstallmentRows(
          rows: const [],
          count: event.count,
          total: _totalAmountValue,
        ),
      ),
    );
  }

  void _onInstallmentRowAmountChanged(
    QnaChatInstallmentRowAmountChanged event,
    Emitter<QnaChatState> emit,
  ) {
    // The auto remainder row is computed, never edited directly.
    if (event.rowId == _autoRowId) return;

    final total = int.tryParse(state.totalAmount) ?? 0;
    final othersTotal = state.installmentRows
        .where((row) => row.id != event.rowId && !row.isAuto)
        .fold<int>(0, (sum, row) => sum + (int.tryParse(row.amountText) ?? 0));
    final maxForRow = total - othersTotal;
    final newAmount = int.tryParse(event.text) ?? 0;

    // Keep leading rows from exceeding the total; surface the remaining amount.
    if (total > 0 && newAmount > maxForRow) {
      emit(
        state.copyWith(
          installmentAmountErrorRemaining: maxForRow < 0 ? 0 : maxForRow,
          installmentAmountErrorToken: state.installmentAmountErrorToken + 1,
        ),
      );
      return;
    }

    final updated = [
      for (final row in state.installmentRows)
        row.id == event.rowId ? row.copyWith(amountText: event.text) : row,
    ];
    emit(
      state.copyWith(
        installmentRows: _normalizeInstallmentRows(
          rows: updated,
          count: state.effectiveInstallmentCount,
          total: total,
        ),
      ),
    );
  }

  void _onInstallmentRowDateChanged(
    QnaChatInstallmentRowDateChanged event,
    Emitter<QnaChatState> emit,
  ) {
    final updated = [
      for (final row in state.installmentRows)
        if (row.id == event.rowId)
          event.isDueDate
              ? row.copyWith(dueDate: event.date)
              : row.copyWith(receivedDate: event.date)
        else
          row,
    ];
    emit(
      state.copyWith(
        // Setting a received date may change the outstanding remainder, so
        // recompute the auto row (drop/reappear/resize) accordingly.
        installmentRows: _normalizeInstallmentRows(
          rows: updated,
          count: state.effectiveInstallmentCount,
          total: _totalAmountValue,
        ),
      ),
    );
  }

  void _onInstallmentRowModeChanged(
    QnaChatInstallmentRowModeChanged event,
    Emitter<QnaChatState> emit,
  ) {
    emit(
      state.copyWith(
        installmentRows: [
          for (final row in state.installmentRows)
            row.id == event.rowId ? row.copyWith(mode: event.mode) : row,
        ],
      ),
    );
  }

  Future<void> _onPaymentPlanLoadRequested(
    QnaChatPaymentPlanLoadRequested event,
    Emitter<QnaChatState> emit,
  ) async {
    if (state.inquiryId.isEmpty) return;
    try {
      final response = await _repository.getPaymentPlan(state.inquiryId);
      final plan = response.data.paymentPlan;
      if (plan == null) {
        // This inquiry has no saved plan — ensure the form shows empty rather
        // than any plan left over from a previously loaded inquiry.
        emit(_resetPaymentForm(state));
        return;
      }
      _applyPaymentPlan(plan, emit);
    } on Object catch (error) {
      // A missing plan (404) is expected for new inquiries — log and ignore.
      if (kDebugMode) {
        developer.log('Load payment plan failed: $error', name: 'QnaChatBloc');
      }
    }
  }

  /// Clears every payment-terms field back to its default so no part of one
  /// inquiry's payment plan can linger when the form is shown for another
  /// inquiry. Non-payment state (messages, session, etc.) on [base] is kept.
  QnaChatState _resetPaymentForm(QnaChatState base) {
    return base.copyWith(
      clearPaymentStatus: true,
      clearTravelDate: true,
      clearTravelTime: true,
      totalAmount: '',
      installmentCount: 1,
      installmentRows: const [],
      clearInstallmentAmountErrorRemaining: true,
      paymentSaveStatus: QnaChatPaymentSaveStatus.idle,
      clearPaymentSaveError: true,
      isPaymentVerified: false,
    );
  }

  void _applyPaymentPlan(PaymentPlanDto plan, Emitter<QnaChatState> emit) {
    final travel = plan.travelDate;
    final installmentCount = plan.numberOfInstallments ?? plan.installments.length;
    final isInstallment = installmentCount > 1;
    final rows = [
      for (final dto in plan.installments)
        QnaChatInstallmentRow(
          id: _uuid.v4(),
          paymentId: dto.id,
          amountText: dto.amount == null ? '' : _amountToText(dto.amount!),
          dueDate: dto.dueDate,
          receivedDate: dto.receivedDate,
          mode: dto.mode,
          status: dto.status,
          paymentProofUrl: dto.paymentProofUrl,
          verificationStatus: dto.verificationStatus,
        ),
    ];
    final planInquiryNo = plan.inquiryNumber?.trim();
    emit(
      state.copyWith(
        // Prefer the number the widget already passed in; fall back to the
        // plan's own so the header stays correct even without a vendor row.
        inquiryDisplayNo: state.inquiryDisplayNo.trim().isNotEmpty
            ? state.inquiryDisplayNo
            : (planInquiryNo == null || planInquiryNo.isEmpty
                ? state.inquiryDisplayNo
                : planInquiryNo),
        paymentStatus: isInstallment
            ? StringConstant.qnaChatPaymentStatusInstallment
            : StringConstant.qnaChatPaymentStatusOneTime,
        isPaymentVerified: plan.verified ?? false,
        bookingType: plan.bookingType ?? state.bookingType,
        travelDate: travel == null
            ? null
            : DateTime(travel.year, travel.month, travel.day),
        travelTime:
            travel == null ? null : TimeOfDay(hour: travel.hour, minute: travel.minute),
        totalAmount: plan.totalAmount == null ? '' : _amountToText(plan.totalAmount!),
        installmentCount: installmentCount < 1 ? 1 : installmentCount,
        installmentRows: rows,
      ),
    );
  }

  Future<void> _onPaymentTermsSaveRequested(
    QnaChatPaymentTermsSaveRequested event,
    Emitter<QnaChatState> emit,
  ) async {
    await _savePaymentPlan(emit);
  }

  /// Logs one installment for verification. Guards that the specific row is
  /// complete, then persists the whole plan (merge PUT) so that row lands as
  /// PENDING server-side.
  Future<void> _onInstallmentLogPaymentRequested(
    QnaChatInstallmentLogPaymentRequested event,
    Emitter<QnaChatState> emit,
  ) async {
    QnaChatInstallmentRow? target;
    for (final row in state.installmentRows) {
      if (row.id == event.rowId) {
        target = row;
        break;
      }
    }
    if (target == null || target.isVerified) return;
    if (!target.isComplete) {
      emit(
        state.copyWith(
          paymentSaveStatus: QnaChatPaymentSaveStatus.failure,
          paymentSaveError:
              'Add amount, received date, mode and proof before logging this installment.',
          paymentSaveResultToken: state.paymentSaveResultToken + 1,
        ),
      );
      return;
    }
    await _savePaymentPlan(emit);
  }

  Future<void> _savePaymentPlan(Emitter<QnaChatState> emit) async {
    if (state.isPaymentSaving) return;
    // A verified plan is locked — accounts have signed off, so block any save
    // even if a stale button somehow dispatches this.
    if (state.isPaymentVerified) {
      emit(
        state.copyWith(
          paymentSaveStatus: QnaChatPaymentSaveStatus.failure,
          paymentSaveError: 'This payment is verified and can no longer be updated.',
          paymentSaveResultToken: state.paymentSaveResultToken + 1,
        ),
      );
      return;
    }
    if (state.inquiryId.isEmpty) {
      emit(
        state.copyWith(
          paymentSaveStatus: QnaChatPaymentSaveStatus.failure,
          paymentSaveError: 'Inquiry is not available.',
          paymentSaveResultToken: state.paymentSaveResultToken + 1,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        paymentSaveStatus: QnaChatPaymentSaveStatus.saving,
        clearPaymentSaveError: true,
      ),
    );

    final request = UpdatePaymentPlanRequest(
      inquiryNumber:
          state.inquiryDisplayNo.trim().isEmpty ? null : state.inquiryDisplayNo.trim(),
      travelDate: _combinedTravelDateTime(),
      bookingType: state.bookingType,
      totalAmount: num.tryParse(state.totalAmount.trim()),
      numberOfInstallments: state.effectiveInstallmentCount,
      paymentReceivedTillNow: state.paymentReceivedTillNow,
      installments: [
        for (final row in state.installmentRows)
          PaymentPlanInstallmentDto(
            id: row.paymentId,
            amount: num.tryParse(row.amountText.trim()),
            dueDate: row.dueDate,
            receivedDate: row.receivedDate,
            mode: row.mode,
            status: _apiStatusFor(row),
            paymentProofUrl: row.hasProof ? row.paymentProofUrl : null,
          ),
      ],
    );

    try {
      final response = await _repository.updatePaymentPlan(
        inquiryId: state.inquiryId,
        request: request,
      );
      final plan = response.data.paymentPlan;
      if (plan != null) {
        _applyPaymentPlan(plan, emit);
      }
      emit(
        state.copyWith(
          paymentSaveStatus: QnaChatPaymentSaveStatus.success,
          clearPaymentSaveError: true,
          paymentSaveResultToken: state.paymentSaveResultToken + 1,
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          paymentSaveStatus: QnaChatPaymentSaveStatus.failure,
          paymentSaveError: error.toString(),
          paymentSaveResultToken: state.paymentSaveResultToken + 1,
        ),
      );
    }
  }

  Future<void> _onInstallmentProofUploadRequested(
    QnaChatInstallmentProofUploadRequested event,
    Emitter<QnaChatState> emit,
  ) async {
    final exists = state.installmentRows.any((row) => row.id == event.rowId);
    if (!exists || state.inquiryId.isEmpty) return;

    emit(state.copyWith(installmentRows: _setRowUploading(event.rowId, true)));

    try {
      final multipart = await _multipartFromPick(
        fileName: event.fileName,
        filePath: event.filePath,
        bytes: event.bytes,
      );
      final upload = await _repository.uploadPaymentProof(
        inquiryId: state.inquiryId,
        file: multipart,
      );
      emit(
        state.copyWith(
          installmentRows: [
            for (final row in state.installmentRows)
              row.id == event.rowId
                  ? row.copyWith(
                      paymentProofUrl: upload.data.paymentProofUrl,
                      isUploadingProof: false,
                    )
                  : row,
          ],
        ),
      );
    } on Object catch (error) {
      if (kDebugMode) {
        developer.log('Upload payment proof failed: $error', name: 'QnaChatBloc');
      }
      emit(
        state.copyWith(
          installmentRows: _setRowUploading(event.rowId, false),
          paymentSaveStatus: QnaChatPaymentSaveStatus.failure,
          paymentSaveError: error.toString(),
          paymentSaveResultToken: state.paymentSaveResultToken + 1,
        ),
      );
    }
  }

  List<QnaChatInstallmentRow> _setRowUploading(String rowId, bool uploading) {
    return [
      for (final row in state.installmentRows)
        row.id == rowId ? row.copyWith(isUploadingProof: uploading) : row,
    ];
  }

  /// Combines the picked travel date and time into a single datetime for the API.
  DateTime? _combinedTravelDateTime() {
    final date = state.travelDate;
    if (date == null) return null;
    final time = state.travelTime;
    return DateTime(date.year, date.month, date.day, time?.hour ?? 0, time?.minute ?? 0);
  }

  /// API-facing status: only set once a payment has been received.
  String? _apiStatusFor(QnaChatInstallmentRow row) {
    if (row.receivedDate == null) return null;
    return row.isLate ? 'Late' : 'On Time';
  }

  String _amountToText(num amount) =>
      amount == amount.roundToDouble() ? amount.toInt().toString() : amount.toString();

  /// Per-inquiry isolation for the phone-keyed WhatsApp feed.
  ///
  /// The backend now scopes the response by the `inquiryId` query param and
  /// stamps every message with its `inquiryId`/`sessionId` (whatsapp_chat.md
  /// §2.3 + §2.6 / backend_whatsapp_change.md). The server response is therefore
  /// already limited to this inquiry; this client filter is a strict guard on
  /// top of it so a shared phone number can never leak another inquiry's thread:
  ///  - keep an item stamped with this inquiry's `inquiryId`;
  ///  - drop an item stamped with a *different* inquiry;
  ///  - for an untagged legacy/edge item (no `inquiryId`), keep it only when it
  ///    carries this inquiry's active `sessionId` — a session maps to exactly
  ///    one inquiry — otherwise drop it.
  List<SessionMessageItem> _itemsForCurrentInquiry(List<SessionMessageItem> items) {
    final inquiryId = state.inquiryId;
    if (inquiryId.isEmpty) return items;
    final sessionId = state.sessionId;
    return items.where((item) {
      final itemInquiryId = item.inquiryId;
      if (itemInquiryId != null && itemInquiryId.isNotEmpty) {
        return itemInquiryId == inquiryId;
      }
      final itemSessionId = item.sessionId;
      return sessionId != null &&
          sessionId.isNotEmpty &&
          itemSessionId != null &&
          itemSessionId == sessionId;
    }).toList();
  }

  void _logMessageFeed({
    required String source,
    required String peerPhone,
    required int rawCount,
    required List<QnaChatMessage> mapped,
  }) {
    if (!kDebugMode) return;
    final inbound = mapped.where((m) => m.kind == QnaChatMessageKind.question).length;
    final outbound = mapped.where((m) => m.kind == QnaChatMessageKind.answer).length;
    developer.log(
      '$source feed peerPhone=$peerPhone raw=$rawCount mapped=${mapped.length} '
      'inbound=$inbound outbound=$outbound',
      name: 'QnaChatBloc',
    );
  }
}
