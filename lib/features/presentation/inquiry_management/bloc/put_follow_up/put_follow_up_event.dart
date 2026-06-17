import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:travel_crm/data/models/members/member_directory_item.dart';
import 'package:travel_crm/features/presentation/air_ticket/models/checklist_priority.dart';

sealed class PutFollowUpEvent extends Equatable {
  const PutFollowUpEvent();

  @override
  List<Object?> get props => [];
}

final class PutFollowUpDialogOpened extends PutFollowUpEvent {
  const PutFollowUpDialogOpened({
    required this.inquiryId,
    required this.sessionId,
    required this.amendmentTypeApi,
  });

  final String inquiryId;
  final String sessionId;
  final String amendmentTypeApi;

  @override
  List<Object?> get props => [inquiryId, sessionId, amendmentTypeApi];
}

final class PutFollowUpDialogClosed extends PutFollowUpEvent {
  const PutFollowUpDialogClosed();
}

final class PutFollowUpNoteChanged extends PutFollowUpEvent {
  const PutFollowUpNoteChanged(this.note);

  final String note;

  @override
  List<Object?> get props => [note];
}

final class PutFollowUpDateChanged extends PutFollowUpEvent {
  const PutFollowUpDateChanged(this.date);

  final DateTime? date;

  @override
  List<Object?> get props => [date];
}

final class PutFollowUpTimeChanged extends PutFollowUpEvent {
  const PutFollowUpTimeChanged(this.time);

  final TimeOfDay? time;

  @override
  List<Object?> get props => [time];
}

final class PutFollowUpAgentChanged extends PutFollowUpEvent {
  const PutFollowUpAgentChanged(this.agent);

  final MemberDirectoryItem agent;

  @override
  List<Object?> get props => [agent];
}

final class PutFollowUpRepeatToggled extends PutFollowUpEvent {
  const PutFollowUpRepeatToggled(this.value);

  final bool value;

  @override
  List<Object?> get props => [value];
}

final class PutFollowUpChecklistUsersChanged extends PutFollowUpEvent {
  const PutFollowUpChecklistUsersChanged(this.users);

  final List<String> users;

  @override
  List<Object?> get props => [users];
}

final class PutFollowUpChecklistPriorityChanged extends PutFollowUpEvent {
  const PutFollowUpChecklistPriorityChanged(this.priority);

  final ChecklistPriority? priority;

  @override
  List<Object?> get props => [priority];
}

final class PutFollowUpChecklistAttachmentPicked extends PutFollowUpEvent {
  const PutFollowUpChecklistAttachmentPicked(this.fileName);

  final String? fileName;

  @override
  List<Object?> get props => [fileName];
}

final class PutFollowUpInLoopUsersChanged extends PutFollowUpEvent {
  const PutFollowUpInLoopUsersChanged(this.users);

  final List<String> users;

  @override
  List<Object?> get props => [users];
}

final class PutFollowUpMemberDirectoryRequested extends PutFollowUpEvent {
  const PutFollowUpMemberDirectoryRequested();
}

final class PutFollowUpFormClearRequested extends PutFollowUpEvent {
  const PutFollowUpFormClearRequested();
}

final class PutFollowUpSavePressed extends PutFollowUpEvent {
  const PutFollowUpSavePressed();
}
