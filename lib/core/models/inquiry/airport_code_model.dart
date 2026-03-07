import 'package:json_annotation/json_annotation.dart';

part 'airport_code_model.g.dart';

@JsonSerializable()
class AirportCodeModel {
  const AirportCodeModel({
    required this.code,
    required this.city,
  });

  factory AirportCodeModel.fromJson(Map<String, dynamic> json) =>
      _$AirportCodeModelFromJson(json);

  Map<String, dynamic> toJson() => _$AirportCodeModelToJson(this);

  final String code;
  final String city;
}
