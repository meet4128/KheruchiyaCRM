import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/data/repositories/payments_repository.dart';

import '../mappers/unverified_payment_row_mapper.dart';
import 'unverified_payments_event.dart';
import 'unverified_payments_state.dart';

/// Drives the Accounting → Unverified Payments screen: fetches
/// `/payments/unverified`, holds the result rows, and handles pagination.
/// Search is applied client-side over the loaded rows (see
/// [UnverifiedPaymentsState.visibleRows]) and never hits the API. Starts
/// [loading]; the screen dispatches [UnverifiedPaymentsStarted] on mount.
class UnverifiedPaymentsBloc
    extends Bloc<UnverifiedPaymentsEvent, UnverifiedPaymentsState> {
  UnverifiedPaymentsBloc(this._repository)
      : super(const UnverifiedPaymentsState()) {
    on<UnverifiedPaymentsStarted>(_onStarted);
    on<UnverifiedPaymentsRefreshed>(_onRefreshed);
    on<UnverifiedPaymentsPageRequested>(_onPageRequested);
    on<UnverifiedPaymentsSearchChanged>(_onSearchChanged);
    on<UnverifiedPaymentExpansionToggled>(_onExpansionToggled);
  }

  final PaymentsRepository _repository;

  Future<void> _onStarted(
    UnverifiedPaymentsStarted event,
    Emitter<UnverifiedPaymentsState> emit,
  ) =>
      _fetch(emit, page: 1);

  Future<void> _onRefreshed(
    UnverifiedPaymentsRefreshed event,
    Emitter<UnverifiedPaymentsState> emit,
  ) =>
      _fetch(emit, page: state.page);

  Future<void> _onPageRequested(
    UnverifiedPaymentsPageRequested event,
    Emitter<UnverifiedPaymentsState> emit,
  ) =>
      _fetch(emit, page: event.page);

  /// Pure client-side filter — just stores the query so [visibleRows] recomputes.
  void _onSearchChanged(
    UnverifiedPaymentsSearchChanged event,
    Emitter<UnverifiedPaymentsState> emit,
  ) {
    emit(state.copyWith(search: event.search));
  }

  /// Toggles a row's installment breakdown open/closed (pure view state).
  void _onExpansionToggled(
    UnverifiedPaymentExpansionToggled event,
    Emitter<UnverifiedPaymentsState> emit,
  ) {
    final id = event.paymentPlanId;
    if (id.isEmpty) return;
    final expanded = Set<String>.from(state.expandedIds);
    if (!expanded.remove(id)) expanded.add(id);
    emit(state.copyWith(expandedIds: expanded));
  }

  Future<void> _fetch(
    Emitter<UnverifiedPaymentsState> emit, {
    required int page,
  }) async {
    emit(state.copyWith(
      status: UnverifiedPaymentsStatus.loading,
      clearError: true,
    ));

    try {
      final response = await _repository.listUnverifiedPayments(page: page);
      final data = response.data;
      emit(
        state.copyWith(
          status: UnverifiedPaymentsStatus.success,
          rows: unverifiedPaymentRowsFromDtos(data.items),
          page: data.page,
          totalPages: data.totalPages < 1 ? 1 : data.totalPages,
          totalItems: data.totalItems,
          clearError: true,
          // Fresh page of rows — drop any stale expansion state.
          expandedIds: const {},
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: UnverifiedPaymentsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
