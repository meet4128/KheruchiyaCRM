import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:travel_crm/data/models/members/member_directory_item.dart';
import 'package:travel_crm/features/presentation/air_ticket/models/checklist_priority.dart';

enum PutFollowUpSubmitStatus { idle, submitting, success, failure }

enum PutFollowUpDirectoryStatus { idle, loading, success, failure }

class PutFollowUpState extends Equatable {
  const PutFollowUpState({
    this.inquiryId = '',
    this.sessionId = '',
    this.amendmentTypeApi = '',
    this.note = '',
    this.reminderDate,
    this.reminderTime,
    this.selectedAgent,
    this.isRepeatEnabled = false,
    this.checklistUsers = const [],
    this.checklistPriority,
    this.attachmentFileName,
    this.inLoopUsers = const [],
    this.directoryStatus = PutFollowUpDirectoryStatus.idle,
    this.agents = const [],
    this.directoryErrorMessage,
    this.submitStatus = PutFollowUpSubmitStatus.idle,
    this.submitErrorMessage,
    this.noteError,
    this.agentError,
    this.redirectFocusDate,
  });

  final String inquiryId;
  final String sessionId;
  final String amendmentTypeApi;

  final String note;
  final DateTime? reminderDate;
  final TimeOfDay? reminderTime;
  final MemberDirectoryItem? selectedAgent;
  final bool isRepeatEnabled;

  final List<String> checklistUsers;
  final ChecklistPriority? checklistPriority;
  final String? attachmentFileName;
  final List<String> inLoopUsers;

  final PutFollowUpDirectoryStatus directoryStatus;
  final List<MemberDirectoryItem> agents;
  final String? directoryErrorMessage;

  final PutFollowUpSubmitStatus submitStatus;
  final String? submitErrorMessage;
  final String? noteError;
  final String? agentError;

  /// On a successful save, the local date of the created calendar event. The
  /// dialog pops this so the caller can redirect the Calendar to that month.
  /// Null when no calendar event was created (e.g. best-effort create failed).
  final DateTime? redirectFocusDate;

  bool get canSubmit =>
      note.trim().isNotEmpty &&
      selectedAgent != null &&
      submitStatus != PutFollowUpSubmitStatus.submitting;

  PutFollowUpState copyWith({
    String? inquiryId,
    String? sessionId,
    String? amendmentTypeApi,
    String? note,
    DateTime? reminderDate,
    TimeOfDay? reminderTime,
    bool clearReminderDate = false,
    bool clearReminderTime = false,
    MemberDirectoryItem? selectedAgent,
    bool clearSelectedAgent = false,
    bool? isRepeatEnabled,
    List<String>? checklistUsers,
    ChecklistPriority? checklistPriority,
    bool clearChecklistPriority = false,
    String? attachmentFileName,
    bool clearAttachmentFileName = false,
    List<String>? inLoopUsers,
    PutFollowUpDirectoryStatus? directoryStatus,
    List<MemberDirectoryItem>? agents,
    String? directoryErrorMessage,
    bool clearDirectoryErrorMessage = false,
    PutFollowUpSubmitStatus? submitStatus,
    String? submitErrorMessage,
    bool clearSubmitErrorMessage = false,
    String? noteError,
    bool clearNoteError = false,
    String? agentError,
    bool clearAgentError = false,
    DateTime? redirectFocusDate,
    bool clearRedirectFocusDate = false,
  }) {
    return PutFollowUpState(
      inquiryId: inquiryId ?? this.inquiryId,
      sessionId: sessionId ?? this.sessionId,
      amendmentTypeApi: amendmentTypeApi ?? this.amendmentTypeApi,
      note: note ?? this.note,
      reminderDate: clearReminderDate ? null : (reminderDate ?? this.reminderDate),
      reminderTime: clearReminderTime ? null : (reminderTime ?? this.reminderTime),
      selectedAgent: clearSelectedAgent ? null : (selectedAgent ?? this.selectedAgent),
      isRepeatEnabled: isRepeatEnabled ?? this.isRepeatEnabled,
      checklistUsers: checklistUsers ?? this.checklistUsers,
      checklistPriority:
          clearChecklistPriority ? null : (checklistPriority ?? this.checklistPriority),
      attachmentFileName: clearAttachmentFileName
          ? null
          : (attachmentFileName ?? this.attachmentFileName),
      inLoopUsers: inLoopUsers ?? this.inLoopUsers,
      directoryStatus: directoryStatus ?? this.directoryStatus,
      agents: agents ?? this.agents,
      directoryErrorMessage: clearDirectoryErrorMessage
          ? null
          : (directoryErrorMessage ?? this.directoryErrorMessage),
      submitStatus: submitStatus ?? this.submitStatus,
      submitErrorMessage: clearSubmitErrorMessage
          ? null
          : (submitErrorMessage ?? this.submitErrorMessage),
      noteError: clearNoteError ? null : (noteError ?? this.noteError),
      agentError: clearAgentError ? null : (agentError ?? this.agentError),
      redirectFocusDate: clearRedirectFocusDate
          ? null
          : (redirectFocusDate ?? this.redirectFocusDate),
    );
  }

  @override
  List<Object?> get props => [
        inquiryId,
        sessionId,
        amendmentTypeApi,
        note,
        reminderDate,
        reminderTime,
        selectedAgent,
        isRepeatEnabled,
        checklistUsers,
        checklistPriority,
        attachmentFileName,
        inLoopUsers,
        directoryStatus,
        agents,
        directoryErrorMessage,
        submitStatus,
        submitErrorMessage,
        noteError,
        agentError,
        redirectFocusDate,
      ];
}
