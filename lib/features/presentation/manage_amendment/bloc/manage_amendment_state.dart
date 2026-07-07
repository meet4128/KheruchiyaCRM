import 'package:equatable/equatable.dart';

import '../models/amendment_filter_options.dart';
import '../models/amendment_row_ui.dart';
import '../models/amendment_search_filter.dart';

/// - [initial]  → no search run yet. Results area stays blank (per design).
/// - [loading]  → search in flight.
/// - [success]  → results loaded (may be empty → "no results" message).
/// - [failure]  → API/validation error; [errorMessage] holds the copy.
enum ManageAmendmentStatus { initial, loading, success, failure }

class ManageAmendmentState extends Equatable {
  const ManageAmendmentState({
    this.status = ManageAmendmentStatus.initial,
    this.rows = const [],
    this.selectedTab = AmendmentResultTab.all,
    this.lastFilter,
    this.page = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.errorMessage,
  });

  final ManageAmendmentStatus status;

  /// All rows returned by the last successful search (current page).
  final List<AmendmentRowUi> rows;

  final AmendmentResultTab selectedTab;

  /// The filter used for the last search — replayed for refresh / pagination.
  final AmendmentSearchFilter? lastFilter;

  final int page;
  final int totalPages;
  final int totalItems;
  final String? errorMessage;

  bool get hasSearched => status != ManageAmendmentStatus.initial;
  bool get isLoading => status == ManageAmendmentStatus.loading;
  bool get hasMorePages => page < totalPages;

  /// Rows after applying the client-side result tab.
  List<AmendmentRowUi> get visibleRows => rows
      .where((r) => selectedTab.matches(amendmentType: r.amendmentType, status: r.status))
      .toList();

  /// Row count per tab, for the "Pending With Supplier (1)" style chips.
  int countFor(AmendmentResultTab tab) => rows
      .where((r) => tab.matches(amendmentType: r.amendmentType, status: r.status))
      .length;

  ManageAmendmentState copyWith({
    ManageAmendmentStatus? status,
    List<AmendmentRowUi>? rows,
    AmendmentResultTab? selectedTab,
    AmendmentSearchFilter? lastFilter,
    int? page,
    int? totalPages,
    int? totalItems,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ManageAmendmentState(
      status: status ?? this.status,
      rows: rows ?? this.rows,
      selectedTab: selectedTab ?? this.selectedTab,
      lastFilter: lastFilter ?? this.lastFilter,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        rows,
        selectedTab,
        lastFilter,
        page,
        totalPages,
        totalItems,
        errorMessage,
      ];
}
