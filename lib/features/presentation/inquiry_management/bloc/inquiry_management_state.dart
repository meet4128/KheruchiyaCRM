part of 'inquiry_management_bloc.dart';

@immutable
sealed class InquiryManagementState {
  const InquiryManagementState();
}

enum InquiryManagementStatus { idle, loading, success, failure }

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
    required this.allItems,
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

  /// Summary chip filter: `IN_PROGRESS`, `PENDING`, `COMPLETED`, `CANCELLED`, or null for All.
  final String? status;
  final String? search;
  final String? sort;

  /// Raw items from API (all pages loaded). Not filtered by chip or search.
  final List<dynamic> allItems;

  /// Filtered for display: [allItems] plus optional [status] chip and [search] filters.
  final List<dynamic> items;

  final InquiryManagementStatus requestStatus;
  final String? errorMessage;
  final bool isLoadingMore;

  /// Max cards shown in the "High Priority Leads" row.
  static const int maxHighPriorityLeads = 5;

  /// All loaded items typed as [ListInquiryItem] (skips any non-inquiry entries).
  List<ListInquiryItem> get inquiries =>
      allItems.whereType<ListInquiryItem>().toList();

  /// Total loaded inquiries (drives the "All" summary chip).
  int get totalInquiryCount => inquiries.length;

  /// Count of loaded inquiries whose API status equals [apiStatus]
  /// (case-insensitive) — used by the summary chips.
  int inquiryCountByStatus(String apiStatus) {
    final f = apiStatus.toLowerCase();
    return inquiries.where((e) => (e.status ?? '').toLowerCase() == f).length;
  }

  /// Inquiries whose first non-empty checklist priority is HIGH, newest first
  /// (by `createdAt`), capped at [maxHighPriorityLeads]. Derived from
  /// [allItems] so it is independent of the search/status-chip filters.
  List<ListInquiryItem> get highPriorityLeads {
    final high = inquiries.where(_isHighPriorityInquiry).toList();
    high.sort((a, b) {
      final da = _parseCreatedAt(a.createdAt);
      final db = _parseCreatedAt(b.createdAt);
      if (da == null && db == null) return 0;
      if (da == null) return 1; // nulls last
      if (db == null) return -1;
      return db.compareTo(da); // newest first
    });
    return high.take(maxHighPriorityLeads).toList();
  }

  /// The most recently created inquiry across all loaded items (newest by
  /// `createdAt`, nulls last), or null when none are loaded. Drives the
  /// "New Follow Up" quick action on the vendor list.
  ListInquiryItem? get latestCreatedInquiry {
    final list = inquiries;
    if (list.isEmpty) return null;
    final sorted = [...list]
      ..sort((a, b) {
        final da = _parseCreatedAt(a.createdAt);
        final db = _parseCreatedAt(b.createdAt);
        if (da == null && db == null) return 0;
        if (da == null) return 1; // nulls last
        if (db == null) return -1;
        return db.compareTo(da); // newest first
      });
    return sorted.first;
  }

  /// True when the inquiry's first non-empty checklist priority is HIGH.
  /// Mirrors the "first non-empty priority wins" rule used by VendorInquiryRow.
  static bool _isHighPriorityInquiry(ListInquiryItem e) {
    for (final c in e.checklist) {
      final p = c.priority?.trim();
      if (p == null || p.isEmpty) continue;
      return p.toUpperCase() == 'HIGH';
    }
    return false;
  }

  static DateTime? _parseCreatedAt(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return null;
    }
  }

  InquiryManagementLoaded copyWith({
    int? page,
    int? limit,
    int? total,
    String? typeOfBooking,
    String? typeOfClient,
    String? status,
    bool replaceStatus = false,
    String? search,
    String? sort,
    List<dynamic>? allItems,
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
      status: replaceStatus ? status : (status ?? this.status),
      search: search ?? this.search,
      sort: sort ?? this.sort,
      allItems: allItems ?? this.allItems,
      items: items ?? this.items,
      requestStatus: requestStatus ?? this.requestStatus,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
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
        allItems: const <dynamic>[],
        items: const <dynamic>[],
        requestStatus: InquiryManagementStatus.idle,
        errorMessage: null,
        isLoadingMore: false,
      );
}
