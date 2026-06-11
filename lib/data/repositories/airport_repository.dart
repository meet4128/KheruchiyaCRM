import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:travel_crm/core/models/airport/airport_model.dart';
import 'package:travel_crm/core/network/airport_api_client.dart';
import 'package:travel_crm/core/network/airport_model.dart' as network;
import 'package:travel_crm/core/network/airport_web_search_client.dart';

/// Repository for airport search. No UI logic.
class AirportRepository {
  AirportRepository({
    required AirportApiClient apiClient,
    AirportWebSearchClient? webSearchClient,
  })  : _apiClient = apiClient,
        _webSearchClient = webSearchClient ?? AirportWebSearchClient();

  final AirportApiClient _apiClient;
  final AirportWebSearchClient _webSearchClient;

  static const int _defaultLimit = 10;
  static const bool _defaultScheduledService = true;

  /// Searches airports by [query]. Uses [limit]=10 and [scheduled_service]=true.
  /// Throws on network/API errors.
  Future<List<AirportModel>> searchAirports(String query) async {
    try {
      if (kIsWeb) {
        return await _searchOnWeb(query);
      }
      final results = await _apiClient.searchAirports(
        query,
        _defaultLimit,
        _defaultScheduledService,
      );
      return _mapToDomainModels(results);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<AirportModel>> _searchOnWeb(String query) async {
    try {
      final results = await _apiClient.searchAirports(
        query,
        _defaultLimit,
        _defaultScheduledService,
      );
      return _mapToDomainModels(results);
    } on DioException catch (e) {
      if (_shouldUseWebFallback(e)) {
        final results = await _webSearchClient.searchAirports(
          query,
          limit: _defaultLimit,
        );
        return _mapToDomainModels(results);
      }
      rethrow;
    }
  }

  bool _shouldUseWebFallback(DioException error) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.response?.statusCode == 404;
  }

  List<AirportModel> _mapToDomainModels(List<network.AirportModel> results) {
    return results
        .map(
          (e) => AirportModel(
            code: e.iataCode ?? e.id ?? '',
            name: e.name ?? '',
            city: e.city ?? '',
            country: e.country ?? '',
          ),
        )
        .toList();
  }
}
