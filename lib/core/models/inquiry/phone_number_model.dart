import 'package:json_annotation/json_annotation.dart';

part 'phone_number_model.g.dart';

@JsonSerializable()
class PhoneNumberModel {
  const PhoneNumberModel({
    required this.countryCode,
    required this.number,
  });

  factory PhoneNumberModel.fromJson(Map<String, dynamic> json) =>
      _$PhoneNumberModelFromJson(json);

  Map<String, dynamic> toJson() => _$PhoneNumberModelToJson(this);

  final String countryCode;
  final String number;
}
