import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:travel_crm/core/network/inquiry_api_client.dart';
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
    on<InquiryManagementFiltersChanged>(_onFiltersChanged);
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

  Future<void> _onFiltersChanged(
    InquiryManagementFiltersChanged event,
    Emitter<InquiryManagementState> emit,
  ) async {
    final current = _s;
    if (current.requestStatus == InquiryManagementStatus.loading ||
        current.isLoadingMore) {
      return;
    }
    emit(current.copyWith(
      page: 1,
      typeOfBooking: event.typeOfBooking,
      typeOfClient: event.typeOfClient,
      status: event.status,
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

  Future<void> _onSearchChanged(
    InquiryManagementSearchChanged event,
    Emitter<InquiryManagementState> emit,
  ) async {
    final current = _s;
    if (current.requestStatus == InquiryManagementStatus.loading ||
        current.isLoadingMore) {
      return;
    }
    emit(current.copyWith(
      page: 1,
      search: event.search,
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
    final loadedCount = current.items.length;
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
        status: current.status,
        search: current.search,
        sort: current.sort,
      );
      final response = await inquiryRepository.listInquiries(query);
      final data = response.data;

      final responseItems = data.items;
      final currentItems = current.items;
      final mergedItems = replace
          ? responseItems
          : <dynamic>[...currentItems, ...responseItems];

      emit(current.copyWith(
        page: data.page,
        limit: data.limit,
        total: data.totalItems,
        items: mergedItems,
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
