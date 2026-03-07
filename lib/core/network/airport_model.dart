import 'package:json_annotation/json_annotation.dart';

part 'airport_model.g.dart';

/// Model for an airport from the search-airports API.
/// API returns: iata, name, city, country (code), id (number), etc.
@JsonSerializable()
class AirportModel {
  const AirportModel({
    this.id,
    this.iataCode,
    this.name,
    this.city,
    this.country,
  });

  factory AirportModel.fromJson(Map<String, dynamic> json) =>
      _$AirportModelFromJson(json);

  Map<String, dynamic> toJson() => _$AirportModelToJson(this);

  @JsonKey(fromJson: _idFromJson)
  final String? id;
  @JsonKey(name: 'iata')
  final String? iataCode;
  final String? name;
  final String? city;
  final String? country;

  static String? _idFromJson(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.toString();
    if (value is String) return value;
    return null;
  }
}
