import 'dart:convert';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// State for the dial code picker: countries list, English names, search, and filtered results.
class DialCodePickerState {
  const DialCodePickerState({
    this.isLoading = true,
    this.allCountries = const [],
    this.englishNames,
    this.searchQuery = '',
    this.filteredCountries = const [],
  });

  final bool isLoading;
  final List<CountryCode> allCountries;
  final Map<String, String>? englishNames;
  final String searchQuery;
  final List<CountryCode> filteredCountries;

  String englishName(CountryCode c) {
    final code = c.code;
    if (code == null) return c.name ?? '';
    return englishNames?[code] ?? c.name ?? '';
  }

  DialCodePickerState copyWith({
    bool? isLoading,
    List<CountryCode>? allCountries,
    Map<String, String>? englishNames,
    String? searchQuery,
    List<CountryCode>? filteredCountries,
  }) {
    return DialCodePickerState(
      isLoading: isLoading ?? this.isLoading,
      allCountries: allCountries ?? this.allCountries,
      englishNames: englishNames ?? this.englishNames,
      searchQuery: searchQuery ?? this.searchQuery,
      filteredCountries: filteredCountries ?? this.filteredCountries,
    );
  }
}

/// Cubit that manages loading countries, English names, and filtering by search.
class DialCodePickerCubit extends Cubit<DialCodePickerState> {
  DialCodePickerCubit() : super(const DialCodePickerState()) {
    load();
  }

  /// Loads English names from package asset and builds the full country list.
  Future<void> load() async {
    try {
      final jsonString = await rootBundle.loadString(
        'packages/country_code_picker/src/i18n/en.json',
      );
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      final Map<String, String> names = {};
      for (final e in decoded.entries) {
        if (e.key == 'no_country') continue;
        final v = e.value;
        names[e.key] =
            v is List ? (v.isNotEmpty ? v.first.toString() : '') : v.toString();
      }
      final all = codes
          .map((e) => CountryCode.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      emit(state.copyWith(
        isLoading: false,
        allCountries: all,
        englishNames: names,
        filteredCountries: all,
        searchQuery: '',
      ));
    } catch (_) {
      final all = codes
          .map((e) => CountryCode.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      emit(state.copyWith(
        isLoading: false,
        allCountries: all,
        filteredCountries: all,
        searchQuery: '',
      ));
    }
  }

  /// Updates search query and filters the country list (English name, code, dial code).
  void searchChanged(String query) {
    final q = query.trim().toUpperCase();
    if (q.isEmpty) {
      emit(state.copyWith(
        searchQuery: query,
        filteredCountries: List.from(state.allCountries),
      ));
      return;
    }
    final filtered = state.allCountries.where((c) {
      final name = state.englishName(c).toUpperCase();
      final code = (c.code ?? '').toUpperCase();
      final dial = c.dialCode ?? '';
      return name.contains(q) || code.contains(q) || dial.contains(q);
    }).toList();
    emit(state.copyWith(
      searchQuery: query,
      filteredCountries: filtered,
    ));
  }
}
