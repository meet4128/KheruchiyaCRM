import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:travel_crm/core/network/inquiry_api_client.dart';
import 'package:travel_crm/data/models/inquiry/list_inquiry_item.dart';
import 'package:travel_crm/data/repositories/inquiry_repository.dart';

part 'inquiry_management_event.dart';

part 'inquiry_management_state.dart';

class InquiryManagementBloc extends Bloc<InquiryManagementEvent, InquiryManagementState> {
  InquiryManagementBloc({
    required this.inquiryRepository,
  }) : super(InquiryManagementInitial()) {
    on<InquiryManagementInitialized>(_onInitialized);
    on<InquiryManagementRefreshed>(_onRefreshed);
    on<InquiryManagementPageChanged>(_onPageChanged);
    on<InquiryManagementStatusChipChanged>(_onStatusChipChanged);
    on<InquiryManagementSearchChanged>(_onSearchChanged);
    on<InquiryManagementSortChanged>(_onSortChanged);
    on<InquiryManagementLoadMoreRequested>(_onLoadMoreRequested);
  }

  final InquiryRepository inquiryRepository;

  InquiryManagementLoaded get _s => state as InquiryManagementLoaded;

  Future<void> _onInitialized(
    InquiryManagementInitialized event,
    Emitter<InquiryManagementState> emit,
  ) async {
    final current = _s;
    // Prevent duplicate init calls while loading.
    if (current.requestStatus == InquiryManagementStatus.loading) return;
    emit(current.copyWith(
      page: 1,
      limit: 20,
      requestStatus: InquiryManagementStatus.loading,
      clearErrorMessage: true,
      isLoadingMore: false,
    ));
    await _fetchPage(
      emit,
      page: 1,
      limit: 20,
      replace: true,
    );
  }

  Future<void> _onRefreshed(
    InquiryManagementRefreshed event,
    Emitter<InquiryManagementState> emit,
  ) async {
    final current = _s;
    if (current.requestStatus == InquiryManagementStatus.loading) return;
    emit(current.copyWith(
      page: 1,
      requestStatus: InquiryManagementStatus.loading,
      clearErrorMessage: true,
      isLoadingMore: false,
    ));
    await _fetchPage(
      emit,
      page: 1,
      limit: current.limit,
      replace: true,
    );
  }

  Future<void> _onPageChanged(
    InquiryManagementPageChanged event,
    Emitter<InquiryManagementState> emit,
  ) async {
    final current = _s;
    if (event.page == current.page) return;
    if (current.requestStatus == InquiryManagementStatus.loading ||
        current.isLoadingMore) {
      return;
    }
    emit(current.copyWith(
      page: event.page,
      requestStatus: InquiryManagementStatus.loading,
      clearErrorMessage: true,
      isLoadingMore: false,
    ));
    await _fetchPage(
      emit,
      page: event.page,
      limit: current.limit,
      replace: true,
    );
  }

  void _onStatusChipChanged(
    InquiryManagementStatusChipChanged event,
    Emitter<InquiryManagementState> emit,
  ) {
    final current = _s;
    emit(current.copyWith(
      status: event.status,
      replaceStatus: true,
      items: _visibleItems(current.allItems, current.search, event.status),
      requestStatus: InquiryManagementStatus.success,
      clearErrorMessage: true,
    ));
  }

  List<dynamic> _visibleItems(
    List<dynamic> allItems,
    String? search,
    String? statusFilter,
  ) {
    Iterable<dynamic> list = allItems;
    if (statusFilter != null && statusFilter.isNotEmpty) {
      final f = statusFilter.toLowerCase();
      list = list.where((e) {
        if (e is! ListInquiryItem) return false;
        return (e.status ?? '').toLowerCase() == f;
      });
    }
    return _filterItemsBySearch(list.toList(), search);
  }

  void _onSearchChanged(
    InquiryManagementSearchChanged event,
    Emitter<InquiryManagementState> emit,
  ) {
    final current = _s;
    final search = event.search.trim().isEmpty ? null : event.search.trim();
    final filtered = _visibleItems(current.allItems, search, current.status);
    emit(current.copyWith(
      search: search,
      items: filtered,
      requestStatus: InquiryManagementStatus.success,
      clearErrorMessage: true,
    ));
  }

  List<dynamic> _filterItemsBySearch(List<dynamic> allItems, String? search) {
    if (search == null || search.trim().isEmpty) return allItems;
    final term = search.trim().toLowerCase();
    return allItems.where((e) {
      if (e is! ListInquiryItem) return true;
      final id = e.id ?? '';
      final inquiryNo = id.length > 8 ? id.substring(id.length - 8) : id;
      return (e.fullName?.toLowerCase().contains(term) ?? false) ||
          (e.title?.toLowerCase().contains(term) ?? false) ||
          (e.status?.toLowerCase().contains(term) ?? false) ||
          (e.typeOfBooking?.toLowerCase().contains(term) ?? false) ||
          id.toLowerCase().contains(term) ||
          inquiryNo.toLowerCase().contains(term);
    }).toList();
  }

  Future<void> _onSortChanged(
    InquiryManagementSortChanged event,
    Emitter<InquiryManagementState> emit,
  ) async {
    final current = _s;
    if (current.requestStatus == InquiryManagementStatus.loading ||
        current.isLoadingMore) {
      return;
    }
    emit(current.copyWith(
      page: 1,
      sort: event.sort,
      requestStatus: InquiryManagementStatus.loading,
      clearErrorMessage: true,
      isLoadingMore: false,
    ));
    await _fetchPage(
      emit,
      page: 1,
      limit: current.limit,
      replace: true,
    );
  }

  Future<void> _onLoadMoreRequested(
    InquiryManagementLoadMoreRequested event,
    Emitter<InquiryManagementState> emit,
  ) async {
    final current = _s;
    // Prevent duplicate pagination calls.
    if (current.isLoadingMore ||
        current.requestStatus == InquiryManagementStatus.loading) {
      return;
    }

    // If total is known and we've already loaded all, do nothing.
    final loadedCount = current.allItems.length;
    if (current.total > 0 && loadedCount >= current.total) return;

    final nextPage = current.page + 1;
    emit(current.copyWith(
      isLoadingMore: true,
      clearErrorMessage: true,
    ));

    await _fetchPage(
      emit,
      page: nextPage,
      limit: current.limit,
      replace: false,
    );
  }

  Future<void> _fetchPage(
    Emitter<InquiryManagementState> emit, {
    required int page,
    required int limit,
    required bool replace,
  }) async {
    try {
      final current = _s;
      final query = ListInquiriesQuery(
        page: page,
        limit: limit,
        typeOfBooking: current.typeOfBooking,
        typeOfClient: current.typeOfClient,
        sort: current.sort,
      );
      final response = await inquiryRepository.listInquiries(query);
      final data = response.data;

      final responseItems = data.items;
      final currentAllItems = current.allItems;
      final mergedAllItems = replace
          ? responseItems
          : <dynamic>[...currentAllItems, ...responseItems];
      final filteredItems = _visibleItems(mergedAllItems, current.search, current.status);

      emit(current.copyWith(
        page: data.page,
        limit: data.limit,
        total: data.totalItems,
        allItems: mergedAllItems,
        items: filteredItems,
        requestStatus: InquiryManagementStatus.success,
        clearErrorMessage: true,
        isLoadingMore: false,
      ));
    } catch (e) {
      final current = _s;
      emit(current.copyWith(
        requestStatus: InquiryManagementStatus.failure,
        errorMessage: e.toString(),
        isLoadingMore: false,
      ));
    }
  }
}
