import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:travel_crm/core/constants/whatsapp_constants.dart';
import 'package:travel_crm/core/utils/inquiry_media_url.dart';
import 'package:travel_crm/core/utils/whatsapp_media_url.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/qna_chat_message.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/qna_chat_pending_attachment.dart';
import 'package:travel_crm/data/models/amendment/send_whatsapp_message_request.dart';
import 'package:travel_crm/data/models/amendment/whatsapp_template_payload.dart';
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
    emit(
      state.copyWith(
        inquiryId: event.inquiryId,
        peerPhone: event.peerPhone,
        customerName: event.customerName,
        sessionId: event.sessionId,
        messages: const [],
        loadStatus: QnaChatStatus.success,
        clearErrorMessage: true,
      ),
    );
    if (state.hasValidPeerPhone) {
      add(const QnaChatRefreshRequested());
      _startPolling();
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
      if (state.hasValidPeerPhone) _startPolling();
    }
    if (!state.hasSession) {
      _pollTimer?.cancel();
    }
  }

  void _onSectionExpansionToggled(
    QnaChatSectionExpansionToggled event,
    Emitter<QnaChatState> emit,
  ) {
    final expanded = !state.isSectionExpanded;
    emit(state.copyWith(isSectionExpanded: expanded));
    if (expanded && state.hasValidPeerPhone) {
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

      emit(state.copyWith(sendStatus: QnaChatSendStatus.idle));
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
    if (!state.hasValidPeerPhone) return;
    await _fetchMessages(emit, silent: event.silent);
  }

  Future<void> _onPollTick(QnaChatPollTick event, Emitter<QnaChatState> emit) async {
    if (!state.hasValidPeerPhone || !state.isSectionExpanded) return;
    await _fetchMessages(emit, silent: true);
  }

  Future<void> _fetchMessages(Emitter<QnaChatState> emit, {required bool silent}) async {
    if (!state.hasValidPeerPhone) return;

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
      final response = await _repository.listWhatsappMessages(
        peerPhone: state.peerPhone,
      );
      final fromServer = qnaMessagesFromSessionItems(response.data.items);
      final messages = mergeQnaChatMessages(state.messages, fromServer);
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
    _pollTimer = Timer.periodic(const Duration(seconds: 20), (_) {
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
}
