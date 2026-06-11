import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/data/repositories/airport_repository.dart';

import 'airport_search_event.dart';
import 'airport_search_state.dart';

/// Bloc for airport search with debounce (400ms) and throttle (1000ms).
/// No setState; all state via Bloc.
class AirportSearchBloc extends Bloc<AirportSearchEvent, AirportSearchState> {
  AirportSearchBloc({required AirportRepository repository})
      : _repository = repository,
        super(const AirportSearchState()) {
    on<AirportSearchQueryChanged>(_onQueryChanged);
    on<AirportSearchRequested>(_onSearchRequested);
  }

  final AirportRepository _repository;
  Timer? _debounce;
  DateTime? _lastSearchTime;

  static const Duration _debounceDuration = Duration(milliseconds: 400);
  static const Duration _throttleDuration = Duration(milliseconds: 1000);

  /// When [AirportSearchQueryChanged] arrives: cancel existing debounce, start new 400ms timer.
  /// When timer fires: check throttle; if last request < 1000ms ago skip, otherwise call repository and emit states.
  Future<void> _onQueryChanged(
    AirportSearchQueryChanged event,
    Emitter<AirportSearchState> emit,
  ) async {
    _debounce?.cancel();
    emit(state.copyWith(
      query: event.query,
      clearErrorMessage: true,
    ));

    final query = event.query.trim();
    if (query.isEmpty) {
      emit(state.copyWith(airports: []));
      return;
    }

    _debounce = Timer(_debounceDuration, () {
      _debounce = null;
      add(AirportSearchRequested(query));
    });
  }

  /// Invoked when debounce timer fires (or explicit request). Throttle: skip if last request < 1000ms ago. Then call repository and emit loading/success/error.
  Future<void> _onSearchRequested(
    AirportSearchRequested event,
    Emitter<AirportSearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(state.copyWith(airports: [], isLoading: false));
      return;
    }

    final now = DateTime.now();
    if (_lastSearchTime != null &&
        now.difference(_lastSearchTime!).inMilliseconds <
            _throttleDuration.inMilliseconds) {
      return;
    }
    _lastSearchTime = now;

    emit(state.copyWith(isLoading: true, clearErrorMessage: true));

    try {
      final airports = await _repository.searchAirports(query);
      if (!isClosed) {
        emit(state.copyWith(
          airports: airports,
          isLoading: false,
          clearErrorMessage: true,
        ));
      }
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: _formatError(e),
        ));
      }
    }
  }

  String _formatError(Object error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionError) {
        return 'Unable to reach the airport search service. Check your connection and try again.';
      }
      final statusCode = error.response?.statusCode;
      if (statusCode != null) {
        return 'Airport search failed (HTTP $statusCode). Please try again.';
      }
      return 'Airport search failed. Please try again.';
    }
    return 'Airport search failed. Please try again.';
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
