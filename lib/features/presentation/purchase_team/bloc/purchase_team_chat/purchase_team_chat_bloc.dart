import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:travel_crm/core/utils/inquiry_media_url.dart';
import 'package:travel_crm/data/models/purchase_chat/send_purchase_chat_message_request.dart';
import 'package:travel_crm/data/repositories/purchase_chat_repository.dart';
import 'package:travel_crm/features/presentation/inquiry_management/mappers/session_message_mapper.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/qna_chat_message.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/qna_chat_pending_attachment.dart';
import 'package:travel_crm/features/presentation/purchase_team/bloc/purchase_team_chat/purchase_team_chat_event.dart';
import 'package:travel_crm/features/presentation/purchase_team/bloc/purchase_team_chat/purchase_team_chat_state.dart';
import 'package:travel_crm/features/presentation/purchase_team/mappers/purchase_chat_message_mapper.dart';

class PurchaseTeamChatBloc extends Bloc<PurchaseTeamChatEvent, PurchaseTeamChatState> {
  PurchaseTeamChatBloc({required PurchaseChatRepository repository})
      : _repository = repository,
        super(const PurchaseTeamChatState()) {
    on<PurchaseTeamChatMemberSelected>(_onMemberSelected);
    on<PurchaseTeamChatCleared>(_onCleared);
    on<PurchaseTeamChatMessageDraftChanged>(_onMessageDraftChanged);
    on<PurchaseTeamChatSendPressed>(_onSendPressed);
    on<PurchaseTeamChatRefreshRequested>(_onRefreshRequested);
    on<PurchaseTeamChatPollTick>(_onPollTick);
    on<PurchaseTeamChatScrollToBottomHandled>(_onScrollToBottomHandled);
    on<PurchaseTeamChatAttachmentPicked>(_onAttachmentPicked);
    on<PurchaseTeamChatAttachmentCleared>(_onAttachmentCleared);
  }

  final PurchaseChatRepository _repository;
  final _uuid = const Uuid();
  Timer? _pollTimer;

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }

  Future<void> _onMemberSelected(
    PurchaseTeamChatMemberSelected event,
    Emitter<PurchaseTeamChatState> emit,
  ) async {
    _pollTimer?.cancel();
    emit(
      PurchaseTeamChatState(
        inquiryId: event.inquiryId,
        member: event.member,
        loadStatus: PurchaseTeamChatStatus.loading,
      ),
    );

    try {
      await _openThreadIfNeeded(event.inquiryId, event.member.purchaseTeamMemberId);
      await _fetchMessages(emit, silent: false);
      _startPolling();
    } catch (e) {
      emit(
        state.copyWith(
          loadStatus: PurchaseTeamChatStatus.failure,
          errorMessage: _userFacingError(e),
        ),
      );
    }
  }

  void _onCleared(PurchaseTeamChatCleared event, Emitter<PurchaseTeamChatState> emit) {
    _pollTimer?.cancel();
    emit(const PurchaseTeamChatState());
  }

  void _onMessageDraftChanged(
    PurchaseTeamChatMessageDraftChanged event,
    Emitter<PurchaseTeamChatState> emit,
  ) {
    emit(
      state.copyWith(
        messageDraft: event.text,
        clearSendErrorMessage: true,
        sendStatus: PurchaseTeamChatSendStatus.idle,
      ),
    );
  }

  void _onAttachmentPicked(
    PurchaseTeamChatAttachmentPicked event,
    Emitter<PurchaseTeamChatState> emit,
  ) {
    emit(
      state.copyWith(
        pendingAttachment: QnaChatPendingAttachment(
          fileName: event.fileName,
          filePath: event.filePath,
          bytes: event.bytes,
        ),
        clearSendErrorMessage: true,
        sendStatus: PurchaseTeamChatSendStatus.idle,
      ),
    );
  }

  void _onAttachmentCleared(
    PurchaseTeamChatAttachmentCleared event,
    Emitter<PurchaseTeamChatState> emit,
  ) {
    emit(state.copyWith(clearPendingAttachment: true));
  }

  Future<void> _onSendPressed(
    PurchaseTeamChatSendPressed event,
    Emitter<PurchaseTeamChatState> emit,
  ) async {
    if (state.sendStatus == PurchaseTeamChatSendStatus.sending) return;
    if (!state.hasMember || state.inquiryId == null || state.inquiryId!.isEmpty) return;

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
        sendStatus: PurchaseTeamChatSendStatus.sending,
        clearSendErrorMessage: true,
      ),
    );

    try {
      await _repository.sendMessage(
        inquiryId: state.inquiryId!,
        purchaseTeamMemberId: state.member!.purchaseTeamMemberId,
        request: SendPurchaseChatMessageRequest(
          text: draft,
          type: 'text',
        ),
      );

      emit(
        state.copyWith(
          messageDraft: '',
          sendStatus: PurchaseTeamChatSendStatus.idle,
        ),
      );

      await _fetchMessages(emit, silent: false);
    } catch (e) {
      emit(
        state.copyWith(
          sendStatus: PurchaseTeamChatSendStatus.failure,
          sendErrorMessage: _userFacingError(e),
        ),
      );
    }
  }

  Future<void> _sendDocument(
    Emitter<PurchaseTeamChatState> emit, {
    required String fileName,
    String? filePath,
    List<int>? bytes,
    String? caption,
  }) async {
    if (state.sendStatus == PurchaseTeamChatSendStatus.sending) return;
    if (!state.hasMember || state.inquiryId == null) return;

    emit(
      state.copyWith(
        sendStatus: PurchaseTeamChatSendStatus.sending,
        clearSendErrorMessage: true,
      ),
    );

    try {
      final multipart = await _multipartFromPick(
        fileName: fileName,
        filePath: filePath,
        bytes: bytes,
      );

      final upload = await _repository.uploadFile(
        inquiryId: state.inquiryId!,
        purchaseTeamMemberId: state.member!.purchaseTeamMemberId,
        file: multipart,
      );

      final mime = upload.data.mimeType?.toLowerCase() ?? '';
      final messageType = mime.startsWith('image/') ? 'image' : 'document';
      final trimmedCaption = caption?.trim() ?? '';

      await _repository.sendMessage(
        inquiryId: state.inquiryId!,
        purchaseTeamMemberId: state.member!.purchaseTeamMemberId,
        request: SendPurchaseChatMessageRequest(
          type: messageType,
          mediaUrl: upload.data.mediaUrl,
          fileName: upload.data.fileName,
          mimeType: upload.data.mimeType,
          text: trimmedCaption.isEmpty ? null : trimmedCaption,
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
        body: trimmedCaption.isEmpty ? displayName : trimmedCaption,
        createdAt: DateTime.now(),
        fileName: displayName,
        mimeType: upload.data.mimeType,
        mediaUrl: buildInquiryMediaUrl(upload.data.mediaUrl),
        caption: trimmedCaption.isEmpty ? null : trimmedCaption,
      );

      emit(
        state.copyWith(
          sendStatus: PurchaseTeamChatSendStatus.idle,
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
          sendStatus: PurchaseTeamChatSendStatus.failure,
          sendErrorMessage: _userFacingError(e),
        ),
      );
    }
  }

  Future<void> _openThreadIfNeeded(String inquiryId, String memberId) async {
    try {
      await _repository.openThread(
        inquiryId: inquiryId,
        purchaseTeamMemberId: memberId,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode != 409) rethrow;
    }
  }

  Future<void> _onRefreshRequested(
    PurchaseTeamChatRefreshRequested event,
    Emitter<PurchaseTeamChatState> emit,
  ) async {
    if (!state.hasMember) return;
    await _fetchMessages(emit, silent: event.silent);
  }

  Future<void> _onPollTick(
    PurchaseTeamChatPollTick event,
    Emitter<PurchaseTeamChatState> emit,
  ) async {
    if (!state.hasMember) return;
    await _fetchMessages(emit, silent: true);
  }

  Future<void> _fetchMessages(
    Emitter<PurchaseTeamChatState> emit, {
    required bool silent,
  }) async {
    final inquiryId = state.inquiryId;
    final member = state.member;
    if (inquiryId == null || inquiryId.isEmpty || member == null) return;

    if (!silent) {
      emit(
        state.copyWith(
          loadStatus:
              state.messages.isEmpty ? PurchaseTeamChatStatus.loading : state.loadStatus,
          isRefreshing: state.messages.isNotEmpty,
          clearErrorMessage: true,
        ),
      );
    }

    try {
      final response = await _repository.listMessages(
        inquiryId: inquiryId,
        purchaseTeamMemberId: member.purchaseTeamMemberId,
      );
      final fromServer = qnaMessagesFromPurchaseChatItems(response.data.items)
          .where((message) => message.isDocument || message.body != '—')
          .toList();
      final messages = mergeQnaChatMessages(state.messages, fromServer);

      emit(
        state.copyWith(
          messages: messages,
          loadStatus: PurchaseTeamChatStatus.success,
          isRefreshing: false,
          scrollToBottom: !silent,
          clearErrorMessage: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loadStatus: state.messages.isEmpty
              ? PurchaseTeamChatStatus.failure
              : state.loadStatus,
          isRefreshing: false,
          errorMessage: _userFacingError(e),
        ),
      );
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      add(const PurchaseTeamChatPollTick());
    });
  }

  void _onScrollToBottomHandled(
    PurchaseTeamChatScrollToBottomHandled event,
    Emitter<PurchaseTeamChatState> emit,
  ) {
    if (state.scrollToBottom) {
      emit(state.copyWith(scrollToBottom: false));
    }
  }

  Future<MultipartFile> _multipartFromPick({
    required String fileName,
    String? filePath,
    List<int>? bytes,
  }) async {
    if (bytes != null && bytes.isNotEmpty) {
      return MultipartFile.fromBytes(bytes, filename: fileName);
    }

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

  String _userFacingError(Object error) {
    if (error is Exception) {
      return error.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
    }
    final text = error.toString();
    if (text.contains('DioException')) {
      return 'Could not complete the request. Please try again.';
    }
    return text;
  }
}
