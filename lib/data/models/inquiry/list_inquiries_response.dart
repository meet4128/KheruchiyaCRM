import 'package:json_annotation/json_annotation.dart';

import 'list_inquiries_data.dart';

part 'list_inquiries_response.g.dart';

@JsonSerializable(explicitToJson: true)
class ListInquiriesResponse {
  const ListInquiriesResponse({
    required this.status,
    required this.data,
  });

  factory ListInquiriesResponse.fromJson(Map<String, dynamic> json) =>
      _$ListInquiriesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ListInquiriesResponseToJson(this);

  final String status;
  final ListInquiriesData data;
}
