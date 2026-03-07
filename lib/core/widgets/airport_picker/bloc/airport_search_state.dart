import 'package:equatable/equatable.dart';
import 'package:travel_crm/core/models/airport/airport_model.dart';

/// State for airport search (query, results, loading, error).
class AirportSearchState extends Equatable {
  const AirportSearchState({
    this.query = '',
    this.airports = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final String query;
  final List<AirportModel> airports;
  final bool isLoading;
  final String? errorMessage;

  AirportSearchState copyWith({
    String? query,
    List<AirportModel>? airports,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AirportSearchState(
      query: query ?? this.query,
      airports: airports ?? this.airports,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [query, airports, isLoading, errorMessage];
}
