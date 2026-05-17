import 'package:json_annotation/json_annotation.dart';

part 'phone_number_dto.g.dart';

@JsonSerializable()
class PhoneNumberDto {
  const PhoneNumberDto({
    this.countryCode,
    this.number,
  });

  factory PhoneNumberDto.fromJson(Map<String, dynamic> json) =>
      _$PhoneNumberDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PhoneNumberDtoToJson(this);

  final String? countryCode;
  final String? number;
}
