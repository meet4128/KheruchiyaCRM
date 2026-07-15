import 'package:equatable/equatable.dart';

/// Base class for member search events.
abstract class MemberSearchEvent extends Equatable {
  const MemberSearchEvent();

  @override
  List<Object?> get props => [];
}

/// Fired when the user changes the search query. Debounce (400ms) is applied
/// before a search is requested.
class MemberSearchQueryChanged extends MemberSearchEvent {
  const MemberSearchQueryChanged(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}

/// Fired to perform a search (e.g. after debounce). Uses current [query];
/// throttle (1000ms) is applied.
class MemberSearchRequested extends MemberSearchEvent {
  const MemberSearchRequested(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}
