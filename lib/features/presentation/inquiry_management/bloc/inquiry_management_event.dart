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
