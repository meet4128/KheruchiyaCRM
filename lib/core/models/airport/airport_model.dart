import 'package:json_annotation/json_annotation.dart';

part 'airport_model.g.dart';

@JsonSerializable()
class AirportModel {
  final String code;
  final String name;
  final String city;
  final String country;

  const AirportModel({
    required this.code,
    required this.name,
    required this.city,
    required this.country,
  });

  factory AirportModel.fromJson(Map<String, dynamic> json) =>
      _$AirportModelFromJson(json);

  Map<String, dynamic> toJson() => _$AirportModelToJson(this);
}
