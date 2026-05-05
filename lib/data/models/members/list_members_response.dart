import 'package:json_annotation/json_annotation.dart';

import 'list_members_data.dart';

part 'list_members_response.g.dart';

@JsonSerializable(explicitToJson: true)
class ListMembersResponse {
  const ListMembersResponse({
    required this.status,
    required this.data,
  });

  factory ListMembersResponse.fromJson(Map<String, dynamic> json) =>
      _$ListMembersResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ListMembersResponseToJson(this);

  final String status;
  final ListMembersData data;
}
