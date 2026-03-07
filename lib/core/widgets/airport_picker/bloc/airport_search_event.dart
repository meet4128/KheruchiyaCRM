import 'package:equatable/equatable.dart';

/// Base class for airport search events.
abstract class AirportSearchEvent extends Equatable {
  const AirportSearchEvent();

  @override
  List<Object?> get props => [];
}

/// Fired when the user changes the search query. Debounce (400ms) is applied
/// before a search is requested.
class AirportSearchQueryChanged extends AirportSearchEvent {
  const AirportSearchQueryChanged(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}

/// Fired to perform a search (e.g. after debounce or on explicit action).
/// Uses current [query] from state; throttle (1000ms) is applied.
class AirportSearchRequested extends AirportSearchEvent {
  const AirportSearchRequested(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}
