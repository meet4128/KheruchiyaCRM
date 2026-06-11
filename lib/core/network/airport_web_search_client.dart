import 'package:dio/dio.dart';
import 'package:travel_crm/core/network/airport_model.dart' as network;

/// CORS-enabled airport autocomplete for Flutter Web.
///
/// [airportroutes.com] blocks cross-origin browser requests; this client uses
/// Travelpayouts autocomplete until the inquiry API proxy is available.
class AirportWebSearchClient {
  AirportWebSearchClient({Dio? dio}) : _dio = dio ?? Dio();

  static const String _baseUrl =
      'https://autocomplete.travelpayouts.com/places2';

  final Dio _dio;

  Future<List<network.AirportModel>> searchAirports(
    String query, {
    int limit = 10,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      _baseUrl,
      queryParameters: <String, dynamic>{
        'term': query,
        'locale': 'en',
        'types[]': <String>['airport', 'city'],
      },
    );

    final raw = response.data ?? const <dynamic>[];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(_mapHit)
        .where((airport) => airport.iataCode?.trim().isNotEmpty ?? false)
        .take(limit)
        .toList();
  }

  network.AirportModel _mapHit(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? '';
    final code = json['code'] as String?;
    final name = json['name'] as String?;
    final cityName = json['city_name'] as String?;
    final countryName = json['country_name'] as String?;
    final countryCode = json['country_code'] as String?;
    final mainAirportName = json['main_airport_name'] as String?;

    final displayName = type == 'city'
        ? (mainAirportName?.trim().isNotEmpty == true
            ? mainAirportName!
            : name ?? '')
        : name ?? '';

    return network.AirportModel(
      iataCode: code,
      name: displayName,
      city: cityName ?? name ?? '',
      country: countryName ?? countryCode ?? '',
    );
  }
}
