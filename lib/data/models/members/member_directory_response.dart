import 'package:json_annotation/json_annotation.dart';
import 'package:travel_crm/data/models/members/member_directory_data.dart';

part 'member_directory_response.g.dart';

@JsonSerializable(explicitToJson: true)
class MemberDirectoryResponse {
  const MemberDirectoryResponse({
    required this.status,
    required this.data,
  });

  factory MemberDirectoryResponse.fromJson(Map<String, dynamic> json) =>
      _$MemberDirectoryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MemberDirectoryResponseToJson(this);

  final String status;
  final MemberDirectoryData data;
}
