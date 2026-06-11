import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:travel_crm/core/network/apis.dart';
import 'package:travel_crm/core/network/dio_client.dart';

import 'airport_model.dart';

part 'airport_api_client.g.dart';

/// Keys used by the API to wrap the airport list when response is an object.
/// This API uses "hits".
const List<String> _kListKeys = ['hits', 'data', 'results', 'airports', 'items'];

/// Creates a [Dio] instance for the airport API with an interceptor that
/// normalizes responses: if the body is a [Map], extracts the list from
/// common keys (e.g. "data", "results") so the client always receives a list.
Dio createAirportApiDio() {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onResponse: (response, handler) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          for (final key in _kListKeys) {
            final value = data[key];
            if (value is List) {
              response.data = value;
              return handler.next(response);
            }
          }
          response.data = <dynamic>[];
        }
        return handler.next(response);
      },
    ),
  );
  return dio;
}

/// Platform-aware airport search client.
///
/// - **Web:** inquiry API proxy (same-origin, CORS-safe).
/// - **Mobile / desktop:** direct [Apis.airportRoutesSearchUrl].
AirportApiClient createAirportApiClient() {
  if (kIsWeb) {
    return AirportApiClient(
      DioClient.getInstance(),
      baseUrl: '${Apis.inquiryBaseUrl}${Apis.inquirySearchAirportsPath}',
    );
  }
  return AirportApiClient(
    createAirportApiDio(),
    baseUrl: Apis.airportRoutesSearchUrl,
  );
}

@RestApi()
abstract class AirportApiClient {
  factory AirportApiClient(Dio dio, {String baseUrl}) = _AirportApiClient;

  @GET('')
  Future<List<AirportModel>> searchAirports(
    @Query('q') String query,
    @Query('limit') int limit,
    @Query('scheduled_service') bool scheduledService,
  );
}
