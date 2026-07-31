part of 'inquiry_management_bloc.dart';

@immutable
sealed class InquiryManagementEvent {}

final class InquiryManagementInitialized extends InquiryManagementEvent {
  InquiryManagementInitialized({
    required this.page,
    required this.limit,
  });

  final int page;
  final int limit;
}

final class InquiryManagementRefreshed extends InquiryManagementEvent {
  InquiryManagementRefreshed();
}

final class InquiryManagementLoadMoreRequested extends InquiryManagementEvent {
  InquiryManagementLoadMoreRequested();
}

final class InquiryManagementPageChanged extends InquiryManagementEvent {
  InquiryManagementPageChanged({
    required this.page,
  });

  final int page;
}

/// Summary chip tap: filters loaded [allItems] client-side (no API refetch).
final class InquiryManagementStatusChipChanged extends InquiryManagementEvent {
  InquiryManagementStatusChipChanged(this.status);

  /// `null` = All. Otherwise `IN_PROGRESS`, `PENDING`, `COMPLETED`, `CANCELLED`.
  final String? status;
}

final class InquiryManagementSearchChanged extends InquiryManagementEvent {
  InquiryManagementSearchChanged({
    required this.search,
  });

  final String search;
}

final class InquiryManagementSortChanged extends InquiryManagementEvent {
  InquiryManagementSortChanged({
    required this.sort,
  });

  final String sort;
}

/// Updates an inquiry's status via `PATCH /inquiries/{id}/status`, then refreshes
/// the list so the new status is reflected. Used by the "expand" action to move a
/// New In (`IN_PROGRESS`) inquiry to `PENDING`.
final class InquiryStatusUpdated extends InquiryManagementEvent {
  InquiryStatusUpdated({
    required this.inquiryId,
    required this.status,
  });

  final String inquiryId;

  /// Target enum value, e.g. `PENDING`.
  final String status;
}

/// Marks an inquiry's Q&A as read for the current user
/// (`POST /inquiries/{id}/qna/read`) when the row's "expand" action is tapped on
/// the vendor list. Best-effort and does not refetch on its own — the list is
/// refreshed on return from the detail, which picks up the cleared `unreadCount`
/// and removes the badge.
final class InquiryQnaMarkedRead extends InquiryManagementEvent {
  InquiryQnaMarkedRead({required this.inquiryId});

  final String inquiryId;
}

/// Assign an inquiry to a member via `PATCH /inquiries/{id}/assign`, then
/// refresh so the server re-scopes the list (the inquiry drops off other reps'
/// lists once assigned).
final class InquiryAssigned extends InquiryManagementEvent {
  InquiryAssigned({
    required this.inquiryId,
    required this.userId,
    required this.memberName,
  });

  final String inquiryId;
  final String userId;

  /// Display name used only for the success snackbar copy.
  final String memberName;
}
