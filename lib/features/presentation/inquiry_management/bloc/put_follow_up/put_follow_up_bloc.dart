import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/data/models/amendment/finalize_amendment_request.dart';
import 'package:travel_crm/data/repositories/inquiry_repository.dart';
import 'package:travel_crm/data/repositories/purchase_chat_repository.dart';

import 'put_follow_up_event.dart';
import 'put_follow_up_state.dart';

class PutFollowUpBloc extends Bloc<PutFollowUpEvent, PutFollowUpState> {
  PutFollowUpBloc({
    required InquiryRepository inquiryRepository,
    required PurchaseChatRepository purchaseChatRepository,
  })  : _inquiryRepository = inquiryRepository,
        _purchaseChatRepository = purchaseChatRepository,
        super(const PutFollowUpState()) {
    on<PutFollowUpDialogOpened>(_onDialogOpened);
    on<PutFollowUpDialogClosed>(_onDialogClosed);
    on<PutFollowUpNoteChanged>(_onNoteChanged);
    on<PutFollowUpDateChanged>(_onDateChanged);
    on<PutFollowUpTimeChanged>(_onTimeChanged);
    on<PutFollowUpAgentChanged>(_onAgentChanged);
    on<PutFollowUpRepeatToggled>(_onRepeatToggled);
    on<PutFollowUpChecklistUsersChanged>(_onChecklistUsersChanged);
    on<PutFollowUpChecklistPriorityChanged>(_onChecklistPriorityChanged);
    on<PutFollowUpChecklistAttachmentPicked>(_onAttachmentPicked);
    on<PutFollowUpInLoopUsersChanged>(_onInLoopUsersChanged);
    on<PutFollowUpMemberDirectoryRequested>(_onMemberDirectoryRequested);
    on<PutFollowUpFormClearRequested>(_onFormClearRequested);
    on<PutFollowUpSavePressed>(_onSavePressed);
  }

  final InquiryRepository _inquiryRepository;
  final PurchaseChatRepository _purchaseChatRepository;

  String? _openedInquiryId;
  String? _openedSessionId;
  String? _openedAmendmentTypeApi;

  Future<void> _onDialogOpened(
    PutFollowUpDialogOpened event,
    Emitter<PutFollowUpState> emit,
  ) async {
    _openedInquiryId = event.inquiryId.trim();
    _openedSessionId = event.sessionId.trim();
    _openedAmendmentTypeApi = event.amendmentTypeApi.trim();

    emit(
      PutFollowUpState(
        inquiryId: _openedInquiryId!,
        sessionId: _openedSessionId!,
        amendmentTypeApi: _openedAmendmentTypeApi!,
        reminderDate: DateTime.now(),
      ),
    );

    add(const PutFollowUpMemberDirectoryRequested());
  }

  void _onDialogClosed(
    PutFollowUpDialogClosed event,
    Emitter<PutFollowUpState> emit,
  ) {
    emit(const PutFollowUpState());
    _openedInquiryId = null;
    _openedSessionId = null;
    _openedAmendmentTypeApi = null;
  }

  void _onNoteChanged(
    PutFollowUpNoteChanged event,
    Emitter<PutFollowUpState> emit,
  ) {
    emit(
      state.copyWith(
        note: event.note,
        clearNoteError: true,
        clearSubmitErrorMessage: true,
        submitStatus: PutFollowUpSubmitStatus.idle,
      ),
    );
  }

  void _onDateChanged(
    PutFollowUpDateChanged event,
    Emitter<PutFollowUpState> emit,
  ) {
    emit(
      state.copyWith(
        reminderDate: event.date,
        clearReminderDate: event.date == null,
        clearSubmitErrorMessage: true,
        submitStatus: PutFollowUpSubmitStatus.idle,
      ),
    );
  }

  void _onTimeChanged(
    PutFollowUpTimeChanged event,
    Emitter<PutFollowUpState> emit,
  ) {
    emit(
      state.copyWith(
        reminderTime: event.time,
        clearReminderTime: event.time == null,
        clearSubmitErrorMessage: true,
        submitStatus: PutFollowUpSubmitStatus.idle,
      ),
    );
  }

  void _onAgentChanged(
    PutFollowUpAgentChanged event,
    Emitter<PutFollowUpState> emit,
  ) {
    emit(
      state.copyWith(
        selectedAgent: event.agent,
        clearAgentError: true,
        clearSubmitErrorMessage: true,
        submitStatus: PutFollowUpSubmitStatus.idle,
      ),
    );
  }

  void _onRepeatToggled(
    PutFollowUpRepeatToggled event,
    Emitter<PutFollowUpState> emit,
  ) {
    emit(state.copyWith(isRepeatEnabled: event.value));
  }

  void _onChecklistUsersChanged(
    PutFollowUpChecklistUsersChanged event,
    Emitter<PutFollowUpState> emit,
  ) {
    emit(state.copyWith(checklistUsers: event.users));
  }

  void _onChecklistPriorityChanged(
    PutFollowUpChecklistPriorityChanged event,
    Emitter<PutFollowUpState> emit,
  ) {
    emit(
      state.copyWith(
        checklistPriority: event.priority,
        clearChecklistPriority: event.priority == null,
      ),
    );
  }

  void _onAttachmentPicked(
    PutFollowUpChecklistAttachmentPicked event,
    Emitter<PutFollowUpState> emit,
  ) {
    emit(
      state.copyWith(
        attachmentFileName: event.fileName,
        clearAttachmentFileName: event.fileName == null,
      ),
    );
  }

  void _onInLoopUsersChanged(
    PutFollowUpInLoopUsersChanged event,
    Emitter<PutFollowUpState> emit,
  ) {
    emit(state.copyWith(inLoopUsers: event.users));
  }

  Future<void> _onMemberDirectoryRequested(
    PutFollowUpMemberDirectoryRequested event,
    Emitter<PutFollowUpState> emit,
  ) async {
    emit(
      state.copyWith(
        directoryStatus: PutFollowUpDirectoryStatus.loading,
        clearDirectoryErrorMessage: true,
      ),
    );

    try {
      final response = await _purchaseChatRepository.getMemberDirectory(
        department: 'Sales',
        limit: 100,
      );
      emit(
        state.copyWith(
          directoryStatus: PutFollowUpDirectoryStatus.success,
          agents: response.data.items,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          directoryStatus: PutFollowUpDirectoryStatus.failure,
          directoryErrorMessage: StringConstant.putFollowUpAgentsLoadFailed,
        ),
      );
    }
  }

  void _onFormClearRequested(
    PutFollowUpFormClearRequested event,
    Emitter<PutFollowUpState> emit,
  ) {
    if (_openedInquiryId == null ||
        _openedSessionId == null ||
        _openedAmendmentTypeApi == null) {
      return;
    }

    emit(
      PutFollowUpState(
        inquiryId: _openedInquiryId!,
        sessionId: _openedSessionId!,
        amendmentTypeApi: _openedAmendmentTypeApi!,
        reminderDate: DateTime.now(),
        directoryStatus: state.directoryStatus,
        agents: state.agents,
      ),
    );
  }

  Future<void> _onSavePressed(
    PutFollowUpSavePressed event,
    Emitter<PutFollowUpState> emit,
  ) async {
    final note = state.note.trim();
    final agent = state.selectedAgent;

    String? noteError;
    String? agentError;
    if (note.isEmpty) {
      noteError = StringConstant.putFollowUpNoteRequired;
    }
    if (agent == null) {
      agentError = StringConstant.putFollowUpAgentRequired;
    }
    if (noteError != null || agentError != null) {
      emit(
        state.copyWith(
          noteError: noteError,
          agentError: agentError,
          clearNoteError: noteError == null,
          clearAgentError: agentError == null,
        ),
      );
      return;
    }

    if (state.inquiryId.isEmpty || state.amendmentTypeApi.isEmpty) {
      emit(
        state.copyWith(
          submitStatus: PutFollowUpSubmitStatus.failure,
          submitErrorMessage: StringConstant.putFollowUpSaveErrorGeneric,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        submitStatus: PutFollowUpSubmitStatus.submitting,
        clearSubmitErrorMessage: true,
        clearNoteError: true,
        clearAgentError: true,
      ),
    );

    try {
      await _inquiryRepository.finalizeAmendment(
        inquiryId: state.inquiryId,
        request: FinalizeAmendmentRequest(
          action: 'put_follow_up',
          amendmentType: state.amendmentTypeApi,
          sessionId: state.sessionId.isNotEmpty ? state.sessionId : null,
        ),
      );

      if (note.isNotEmpty && state.sessionId.isNotEmpty) {
        try {
          await _inquiryRepository.addSessionNote(
            inquiryId: state.inquiryId,
            sessionId: state.sessionId,
            text: note,
          );
        } catch (_) {
          // Finalize succeeded; note persistence is best-effort.
        }
      }

      emit(state.copyWith(submitStatus: PutFollowUpSubmitStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          submitStatus: PutFollowUpSubmitStatus.failure,
          submitErrorMessage: _mapError(e),
        ),
      );
    }
  }

  static String _mapError(Object e) {
    if (e is InquiryValidationException) return e.message;
    if (e is InquiryForbiddenException) return e.message;
    if (e is InquiryServiceUnavailableException) return e.message;
    if (e is InquiryUnauthorizedException) return e.toString();
    final text = e.toString().trim();
    if (text.isNotEmpty) return text;
    return StringConstant.putFollowUpSaveErrorGeneric;
  }
}
