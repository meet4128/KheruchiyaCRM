part of 'inquiry_management_bloc.dart';

@immutable
sealed class InquiryManagementState {
  const InquiryManagementState();
}

enum InquiryManagementStatus {
  idle,
  loading,
  success,
  failure,
}

final class InquiryManagementLoaded extends InquiryManagementState {
  const InquiryManagementLoaded({
    required this.page,
    required this.limit,
    required this.total,
    this.typeOfBooking,
    this.typeOfClient,
    this.status,
    this.search,
    this.sort,
    required this.items,
    required this.requestStatus,
    this.errorMessage,
    this.isLoadingMore = false,
  });

  final int page;
  final int limit;
  final int total;

  final String? typeOfBooking;
  final String? typeOfClient;
  final String? status;
  final String? search;
  final String? sort;

  /// NOTE: This is intended to be `List<ListInquiryItem>` once the BLoC library
  /// imports `lib/data/models/inquiry/list_inquiry_item.dart`.
  final List<dynamic> items;

  final InquiryManagementStatus requestStatus;
  final String? errorMessage;
  final bool isLoadingMore;

  InquiryManagementLoaded copyWith({
    int? page,
    int? limit,
    int? total,
    String? typeOfBooking,
    String? typeOfClient,
    String? status,
    String? search,
    String? sort,
    List<dynamic>? items,
    InquiryManagementStatus? requestStatus,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? isLoadingMore,
  }) {
    return InquiryManagementLoaded(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      typeOfBooking: typeOfBooking ?? this.typeOfBooking,
      typeOfClient: typeOfClient ?? this.typeOfClient,
      status: status ?? this.status,
      search: search ?? this.search,
      sort: sort ?? this.sort,
      items: items ?? this.items,
      requestStatus: requestStatus ?? this.requestStatus,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final class InquiryManagementInitial extends InquiryManagementLoaded {
  InquiryManagementInitial()
      : super(
          page: 1,
          limit: 20,
          total: 0,
          items: const <dynamic>[],
          requestStatus: InquiryManagementStatus.idle,
          errorMessage: null,
          isLoadingMore: false,
        );
}
