import 'package:equatable/equatable.dart';

import '../models/unverified_payment_row_ui.dart';

/// - [loading]  → list fetch in flight.
/// - [success]  → rows loaded (may be empty → "no results" message).
/// - [failure]  → API error; [errorMessage] holds the copy.
enum UnverifiedPaymentsStatus { loading, success, failure }

class UnverifiedPaymentsState extends Equatable {
  const UnverifiedPaymentsState({
    this.status = UnverifiedPaymentsStatus.loading,
    this.rows = const [],
    this.search = '',
    this.page = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.errorMessage,
    this.expandedIds = const {},
  });

  final UnverifiedPaymentsStatus status;

  /// All rows fetched for the current page (unfiltered).
  final List<UnverifiedPaymentRowUi> rows;

  /// Client-side free-text filter applied over [rows] — never sent to the API.
  final String search;

  final int page;
  final int totalPages;
  final int totalItems;
  final String? errorMessage;

  /// Payment plan ids whose installment breakdown is currently expanded.
  final Set<String> expandedIds;

  bool get isLoading => status == UnverifiedPaymentsStatus.loading;
  bool get hasPrevPage => page > 1;
  bool get hasNextPage => page < totalPages;

  bool get isSearching => search.trim().isNotEmpty;

  /// Whether [paymentPlanId]'s installment breakdown is expanded.
  bool isExpanded(String paymentPlanId) => expandedIds.contains(paymentPlanId);

  /// [rows] filtered by [search] across the visible text columns. Case- and
  /// whitespace-insensitive; an empty query returns all rows.
  List<UnverifiedPaymentRowUi> get visibleRows {
    final query = search.trim().toLowerCase();
    if (query.isEmpty) return rows;
    return rows.where((r) {
      final haystack = [
        r.inquiryNumber,
        r.amount,
        r.paidOn,
        r.paidOnSub,
        r.creditAccount,
        r.contactName,
        r.contactRoute,
        r.contactPhone,
        r.assignedTo,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  UnverifiedPaymentsState copyWith({
    UnverifiedPaymentsStatus? status,
    List<UnverifiedPaymentRowUi>? rows,
    String? search,
    int? page,
    int? totalPages,
    int? totalItems,
    String? errorMessage,
    bool clearError = false,
    Set<String>? expandedIds,
  }) {
    return UnverifiedPaymentsState(
      status: status ?? this.status,
      rows: rows ?? this.rows,
      search: search ?? this.search,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      expandedIds: expandedIds ?? this.expandedIds,
    );
  }

  @override
  List<Object?> get props => [
        status,
        rows,
        search,
        page,
        totalPages,
        totalItems,
        errorMessage,
        expandedIds,
      ];
}
