import 'package:equatable/equatable.dart';

sealed class PurchaseTeamDirectoryEvent extends Equatable {
  const PurchaseTeamDirectoryEvent();

  @override
  List<Object?> get props => [];
}

final class PurchaseTeamDirectoryStarted extends PurchaseTeamDirectoryEvent {
  const PurchaseTeamDirectoryStarted({this.inquiryId});

  final String? inquiryId;

  @override
  List<Object?> get props => [inquiryId];
}

final class PurchaseTeamDirectorySearchChanged extends PurchaseTeamDirectoryEvent {
  const PurchaseTeamDirectorySearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class PurchaseTeamDirectoryMemberSelected extends PurchaseTeamDirectoryEvent {
  const PurchaseTeamDirectoryMemberSelected(this.memberId);

  final String memberId;

  @override
  List<Object?> get props => [memberId];
}

final class PurchaseTeamDirectoryRefreshRequested extends PurchaseTeamDirectoryEvent {
  const PurchaseTeamDirectoryRefreshRequested();
}
