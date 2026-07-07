import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/data/repositories/amendment_repository.dart';

import '../mappers/amendment_row_mapper.dart';
import '../models/amendment_search_filter.dart';
import 'manage_amendment_event.dart';
import 'manage_amendment_state.dart';

/// Drives the Manage Amendment screen: runs `/amendments/search`, holds the
/// result rows, and applies the client-side result tab. Starts [initial] so the
/// results table is blank until the user searches.
class ManageAmendmentBloc extends Bloc<ManageAmendmentEvent, ManageAmendmentState> {
  ManageAmendmentBloc(this._repository) : super(const ManageAmendmentState()) {
    on<AmendmentSearchSubmitted>(_onSubmitted);
    on<AmendmentSearchRefreshed>(_onRefreshed);
    on<AmendmentSearchPageRequested>(_onPageRequested);
    on<AmendmentResultTabChanged>(_onTabChanged);
    on<AmendmentSearchCleared>(_onCleared);
  }

  final AmendmentRepository _repository;

  /// `processedFrom`/`processedTo` are `date-time` in the API — send full ISO
  /// 8601 (UTC) spanning the day so a single picked date still matches.
  static String _startOfDayIso(DateTime d) =>
      DateTime(d.year, d.month, d.day).toUtc().toIso8601String();
  static String _endOfDayIso(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59, 999).toUtc().toIso8601String();

  Future<void> _onSubmitted(
    AmendmentSearchSubmitted event,
    Emitter<ManageAmendmentState> emit,
  ) =>
      _runSearch(emit, filter: event.filter, page: 1);

  Future<void> _onRefreshed(
    AmendmentSearchRefreshed event,
    Emitter<ManageAmendmentState> emit,
  ) async {
    final filter = state.lastFilter;
    if (filter == null) return;
    await _runSearch(emit, filter: filter, page: state.page);
  }

  Future<void> _onPageRequested(
    AmendmentSearchPageRequested event,
    Emitter<ManageAmendmentState> emit,
  ) async {
    final filter = state.lastFilter;
    if (filter == null) return;
    await _runSearch(emit, filter: filter, page: event.page);
  }

  void _onTabChanged(
    AmendmentResultTabChanged event,
    Emitter<ManageAmendmentState> emit,
  ) {
    emit(state.copyWith(selectedTab: event.tab));
  }

  void _onCleared(
    AmendmentSearchCleared event,
    Emitter<ManageAmendmentState> emit,
  ) {
    emit(const ManageAmendmentState());
  }

  Future<void> _runSearch(
    Emitter<ManageAmendmentState> emit, {
    required AmendmentSearchFilter filter,
    required int page,
  }) async {
    emit(
      state.copyWith(
        status: ManageAmendmentStatus.loading,
        lastFilter: filter,
        clearError: true,
      ),
    );

    try {
      final response = await _repository.searchAmendments(
        amendmentType: filter.type?.apiValue,
        status: filter.status?.apiValue,
        processedFrom:
            filter.processedFrom != null ? _startOfDayIso(filter.processedFrom!) : null,
        processedTo:
            filter.processedTo != null ? _endOfDayIso(filter.processedTo!) : null,
        page: page,
      );

      final data = response.data;
      emit(
        state.copyWith(
          status: ManageAmendmentStatus.success,
          rows: amendmentRowsFromDtos(data.items),
          page: data.page,
          totalPages: data.totalPages < 1 ? 1 : data.totalPages,
          totalItems: data.totalItems,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ManageAmendmentStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
