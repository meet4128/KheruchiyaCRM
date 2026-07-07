import 'package:equatable/equatable.dart';

import '../models/amendment_filter_options.dart';
import '../models/amendment_search_filter.dart';

abstract class ManageAmendmentEvent extends Equatable {
  const ManageAmendmentEvent();

  @override
  List<Object?> get props => [];
}

/// User pressed "Search" in the filter form. Runs the query from page 1.
class AmendmentSearchSubmitted extends ManageAmendmentEvent {
  const AmendmentSearchSubmitted(this.filter);

  final AmendmentSearchFilter filter;

  @override
  List<Object?> get props => [filter];
}

/// Re-runs the last submitted search (Refresh button / retry after error).
class AmendmentSearchRefreshed extends ManageAmendmentEvent {
  const AmendmentSearchRefreshed();
}

/// Pagination — fetches [page] with the last submitted filter.
class AmendmentSearchPageRequested extends ManageAmendmentEvent {
  const AmendmentSearchPageRequested(this.page);

  final int page;

  @override
  List<Object?> get props => [page];
}

/// Client-side tab over already-fetched rows (All / Pending With Supplier / …).
class AmendmentResultTabChanged extends ManageAmendmentEvent {
  const AmendmentResultTabChanged(this.tab);

  final AmendmentResultTab tab;

  @override
  List<Object?> get props => [tab];
}

/// Resets the screen back to the blank (pre-search) state.
class AmendmentSearchCleared extends ManageAmendmentEvent {
  const AmendmentSearchCleared();
}
