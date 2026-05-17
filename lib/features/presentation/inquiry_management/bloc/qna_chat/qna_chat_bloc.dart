import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:travel_crm/core/utils/whatsapp_media_url.dart';
import 'package:travel_crm/data/models/amendment/send_whatsapp_message_request.dart';
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
        sessionId: event.sessionId,
        messages: const [],
        loadStatus: QnaChatStatus.success,
        clearErrorMessage: true,
      ),
    );
    if (event.sessionId != null && event.sessionId!.isNotEmpty) {
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
      _startPolling();
    }
    if (!state.hasSession) {
      _pollTimer?.cancel();
      emit(state.copyWith(messages: const []));
    }
  }

  void _onSectionExpansionToggled(
    QnaChatSectionExpansionToggled event,
    Emitter<QnaChatState> emit,
  ) {
    final expanded = !state.isSectionExpanded;
    emit(state.copyWith(isSectionExpanded: expanded));
    if (expanded && state.hasSession) {
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

  Future<void> _onSendPressed(QnaChatSendPressed event, Emitter<QnaChatState> emit) async {
    final draft = state.messageDraft.trim();
    if (draft.isEmpty || state.sendStatus == QnaChatSendStatus.sending) return;
    if (!state.hasValidPeerPhone) {
      emit(
        state.copyWith(
          sendStatus: QnaChatSendStatus.failure,
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

  Future<void> _onDocumentUploadRequested(
    QnaChatDocumentUploadRequested event,
    Emitter<QnaChatState> emit,
  ) async {
    if (state.sendStatus == QnaChatSendStatus.sending) return;

    if (!state.hasSession) {
      emit(
        state.copyWith(
          sendErrorMessage: 'Send a message first to start the chat session.',
        ),
      );
      return;
    }

    if (!state.hasValidPeerPhone) {
      emit(
        state.copyWith(
          sendErrorMessage: 'Customer phone is not available.',
        ),
      );
      return;
    }

    final sessionId = state.sessionId;
    if (sessionId == null || sessionId.isEmpty) return;

    emit(
      state.copyWith(
        sendStatus: QnaChatSendStatus.sending,
        clearSendErrorMessage: true,
      ),
    );

    try {
      final multipart = await _multipartFromPick(
        fileName: event.fileName,
        filePath: event.filePath,
        bytes: event.bytes,
      );

      final upload = await _repository.uploadSessionFile(
        inquiryId: state.inquiryId,
        sessionId: sessionId,
        file: multipart,
      );

      final publicUrl = buildWhatsappMediaUrl(upload.data.mediaUrl);
      final caption = (event.caption?.trim().isNotEmpty ?? false)
          ? event.caption!.trim()
          : state.messageDraft.trim();

      await _repository.sendWhatsappMessage(
        SendWhatsappMessageRequest(
          to: state.peerPhone,
          sessionId: sessionId,
          inquiryId: state.inquiryId,
          type: 'document',
          text: caption.isEmpty ? event.fileName : caption,
          mediaUrl: publicUrl,
          fileName: upload.data.fileName,
        ),
      );

      emit(
        state.copyWith(
          sendStatus: QnaChatSendStatus.idle,
          messageDraft: '',
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
      return MultipartFile.fromBytes(bytes, filename: fileName);
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
    if (!state.hasSession) return;
    await _fetchMessages(emit, silent: event.silent);
  }

  Future<void> _onPollTick(QnaChatPollTick event, Emitter<QnaChatState> emit) async {
    if (!state.hasSession || !state.isSectionExpanded) return;
    await _fetchMessages(emit, silent: true);
  }

  Future<void> _fetchMessages(Emitter<QnaChatState> emit, {required bool silent}) async {
    final sessionId = state.sessionId;
    if (sessionId == null || sessionId.isEmpty || state.inquiryId.isEmpty) return;

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
      final response = await _repository.listSessionMessages(
        inquiryId: state.inquiryId,
        sessionId: sessionId,
      );
      final messages = qnaMessagesFromSessionItems(response.data.items);
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
