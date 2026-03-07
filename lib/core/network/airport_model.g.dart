// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'airport_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AirportModel _$AirportModelFromJson(Map<String, dynamic> json) => AirportModel(
  id: AirportModel._idFromJson(json['id']),
  iataCode: json['iata'] as String?,
  name: json['name'] as String?,
  city: json['city'] as String?,
  country: json['country'] as String?,
);

Map<String, dynamic> _$AirportModelToJson(AirportModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'iata': instance.iataCode,
      'name': instance.name,
      'city': instance.city,
      'country': instance.country,
    };
