import 'package:equatable/equatable.dart';
import 'package:travel_crm/features/presentation/purchase_team/models/purchase_team_member_ui.dart';

sealed class PurchaseTeamChatEvent extends Equatable {
  const PurchaseTeamChatEvent();

  @override
  List<Object?> get props => [];
}

final class PurchaseTeamChatMemberSelected extends PurchaseTeamChatEvent {
  const PurchaseTeamChatMemberSelected({
    required this.inquiryId,
    required this.member,
  });

  final String inquiryId;
  final PurchaseTeamMemberUi member;

  @override
  List<Object?> get props => [inquiryId, member];
}

final class PurchaseTeamChatCleared extends PurchaseTeamChatEvent {
  const PurchaseTeamChatCleared();
}

final class PurchaseTeamChatMessageDraftChanged extends PurchaseTeamChatEvent {
  const PurchaseTeamChatMessageDraftChanged(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}

final class PurchaseTeamChatSendPressed extends PurchaseTeamChatEvent {
  const PurchaseTeamChatSendPressed();
}

final class PurchaseTeamChatRefreshRequested extends PurchaseTeamChatEvent {
  const PurchaseTeamChatRefreshRequested({this.silent = false});

  final bool silent;

  @override
  List<Object?> get props => [silent];
}

final class PurchaseTeamChatPollTick extends PurchaseTeamChatEvent {
  const PurchaseTeamChatPollTick();
}

final class PurchaseTeamChatScrollToBottomHandled extends PurchaseTeamChatEvent {
  const PurchaseTeamChatScrollToBottomHandled();
}

final class PurchaseTeamChatAttachmentPicked extends PurchaseTeamChatEvent {
  const PurchaseTeamChatAttachmentPicked({
    required this.fileName,
    this.filePath,
    this.bytes,
  });

  final String fileName;
  final String? filePath;
  final List<int>? bytes;

  @override
  List<Object?> get props => [fileName, filePath, bytes];
}

final class PurchaseTeamChatAttachmentCleared extends PurchaseTeamChatEvent {
  const PurchaseTeamChatAttachmentCleared();
}
