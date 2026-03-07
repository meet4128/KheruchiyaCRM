import 'package:flutter_bloc/flutter_bloc.dart';

/// Static list of airports (code - city). Replace with API later.
const List<String> kAirports = [
  'AMD - Ahmedabad',
  'GOI - Goa',
  'BOM - Mumbai',
  'DEL - Delhi',
  'BLR - Bengaluru',
  'CCU - Kolkata',
  'MAA - Chennai',
  'HYD - Hyderabad',
  'COK - Kochi',
  'PNQ - Pune',
  'IXC - Chandigarh',
  'JAI - Jaipur',
  'LKO - Lucknow',
  'GAU - Guwahati',
  'TRV - Thiruvananthapuram',
  'DXB - Dubai',
  'LHR - London',
  'SIN - Singapore',
  'BKK - Bangkok',
  'KUL - Kuala Lumpur',
  'HKG - Hong Kong',
  'NRT - Tokyo',
  'SYD - Sydney',
  'JFK - New York',
  'LAX - Los Angeles',
];

/// State for the airport picker: full list, search query, and filtered results.
class AirportPickerState {
  const AirportPickerState({
    this.allAirports = kAirports,
    this.searchQuery = '',
    this.filteredAirports = kAirports,
  });

  final List<String> allAirports;
  final String searchQuery;
  final List<String> filteredAirports;

  AirportPickerState copyWith({
    List<String>? allAirports,
    String? searchQuery,
    List<String>? filteredAirports,
  }) {
    return AirportPickerState(
      allAirports: allAirports ?? this.allAirports,
      searchQuery: searchQuery ?? this.searchQuery,
      filteredAirports: filteredAirports ?? this.filteredAirports,
    );
  }
}

/// Cubit that holds the airport list and filters by search.
/// Replace [allAirports] with API data later.
class AirportPickerCubit extends Cubit<AirportPickerState> {
  AirportPickerCubit() : super(const AirportPickerState());

  void searchChanged(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      emit(state.copyWith(
        searchQuery: query,
        filteredAirports: List.from(state.allAirports),
      ));
      return;
    }
    final filtered = state.allAirports
        .where((a) => a.toLowerCase().contains(q))
        .toList();
    emit(state.copyWith(
      searchQuery: query,
      filteredAirports: filtered,
    ));
  }
}
