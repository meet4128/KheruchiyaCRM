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

final class InquiryManagementFiltersChanged extends InquiryManagementEvent {
  InquiryManagementFiltersChanged({
    this.typeOfBooking,
    this.typeOfClient,
    this.status,
  });

  final String? typeOfBooking;
  final String? typeOfClient;
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
