import 'package:travel_crm/core/models/airport/airport_model.dart';
import 'package:travel_crm/core/network/airport_api_client.dart';
import 'package:travel_crm/core/network/airport_model.dart' as network;

/// Repository for airport search. No UI logic.
class AirportRepository {
  AirportRepository({required AirportApiClient apiClient}) : _apiClient = apiClient;

  final AirportApiClient _apiClient;

  static const int _defaultLimit = 10;
  static const bool _defaultScheduledService = true;

  /// Searches airports by [query]. Uses [limit]=10 and [scheduled_service]=true.
  /// Throws on network/API errors.
  Future<List<AirportModel>> searchAirports(String query) async {
    try {
      final results = await _apiClient.searchAirports(
        query,
        _defaultLimit,
        _defaultScheduledService,
      );
      return _mapToDomainModels(results);
    } catch (_) {
      rethrow;
    }
  }

  List<AirportModel> _mapToDomainModels(List<network.AirportModel> results) {
    return results.map((e) => AirportModel(
      code: e.iataCode ?? e.id ?? '',
      name: e.name ?? '',
      city: e.city ?? '',
      country: e.country ?? '',
    )).toList();
  }
}
