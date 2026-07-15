import 'package:equatable/equatable.dart';

sealed class InquiryDetailEvent extends Equatable {
  const InquiryDetailEvent();

  @override
  List<Object?> get props => [];
}

final class InquiryDetailStarted extends InquiryDetailEvent {
  const InquiryDetailStarted({required this.inquiryId});

  final String inquiryId;

  @override
  List<Object?> get props => [inquiryId];
}

final class InquiryDetailRefreshRequested extends InquiryDetailEvent {
  const InquiryDetailRefreshRequested();
}

/// Requests a status change for the loaded inquiry via `PATCH /inquiries/{id}/status`.
/// [status] is the backend enum value (e.g. `PENDING`, `IN_PROGRESS`,
/// `FOLLOWUP`). Fired automatically by the detail flow (New In → Pending on open,
/// first Q&A message → Followup); failures are swallowed so they never disrupt
/// the screen.
final class InquiryDetailStatusUpdateRequested extends InquiryDetailEvent {
  const InquiryDetailStatusUpdateRequested(this.status);

  final String status;

  @override
  List<Object?> get props => [status];
}

final class InquiryDetailSessionIdAssigned extends InquiryDetailEvent {
  const InquiryDetailSessionIdAssigned(this.sessionId);

  final String sessionId;

  @override
  List<Object?> get props => [sessionId];
}

final class InquiryDetailSessionCleared extends InquiryDetailEvent {
  const InquiryDetailSessionCleared();
}

final class InquiryDetailFinalizeRequested extends InquiryDetailEvent {
  const InquiryDetailFinalizeRequested({
    required this.action,
    required this.amendmentTypeApi,
    this.amountCharged,
  });

  final String action;
  final String amendmentTypeApi;
  final double? amountCharged;

  @override
  List<Object?> get props => [action, amendmentTypeApi, amountCharged];
}
