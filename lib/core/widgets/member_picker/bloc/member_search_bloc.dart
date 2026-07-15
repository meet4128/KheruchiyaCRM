import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/data/repositories/members_repository.dart';

import 'member_search_event.dart';
import 'member_search_state.dart';

/// Bloc for member name search with debounce (400ms) and throttle (1000ms).
/// Mirrors [AirportSearchBloc]; all state via Bloc (no setState).
class MemberSearchBloc extends Bloc<MemberSearchEvent, MemberSearchState> {
  MemberSearchBloc({required MembersRepository repository})
      : _repository = repository,
        super(const MemberSearchState()) {
    on<MemberSearchQueryChanged>(_onQueryChanged);
    on<MemberSearchRequested>(_onSearchRequested);
  }

  final MembersRepository _repository;
  Timer? _debounce;
  DateTime? _lastSearchTime;

  static const Duration _debounceDuration = Duration(milliseconds: 400);
  static const Duration _throttleDuration = Duration(milliseconds: 1000);

  /// On query change: cancel existing debounce, start a new 400ms timer.
  /// When it fires, dispatch [MemberSearchRequested].
  Future<void> _onQueryChanged(
    MemberSearchQueryChanged event,
    Emitter<MemberSearchState> emit,
  ) async {
    _debounce?.cancel();
    emit(state.copyWith(query: event.query, clearErrorMessage: true));

    final query = event.query.trim();
    if (query.isEmpty) {
      emit(state.copyWith(members: []));
      return;
    }

    _debounce = Timer(_debounceDuration, () {
      _debounce = null;
      add(MemberSearchRequested(query));
    });
  }

  /// Invoked when the debounce timer fires. Throttle: skip if last request was
  /// < 1000ms ago. Then call the repository and emit loading/success/error.
  Future<void> _onSearchRequested(
    MemberSearchRequested event,
    Emitter<MemberSearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(state.copyWith(members: [], isLoading: false));
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
      final members = await _repository.searchMembers(query);
      if (!isClosed) {
        emit(state.copyWith(
          members: members,
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
        return 'Unable to reach the member search service. Check your connection and try again.';
      }
      final statusCode = error.response?.statusCode;
      if (statusCode != null) {
        return 'Member search failed (HTTP $statusCode). Please try again.';
      }
      return 'Member search failed. Please try again.';
    }
    return 'Member search failed. Please try again.';
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
