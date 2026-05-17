import 'package:json_annotation/json_annotation.dart';

part 'amendment_notes_response.g.dart';

@JsonSerializable()
class AmendmentNoteItem {
  const AmendmentNoteItem({
    this.id,
    this.text,
    this.createdAt,
    this.createdBy,
  });

  factory AmendmentNoteItem.fromJson(Map<String, dynamic> json) =>
      _$AmendmentNoteItemFromJson(json);

  Map<String, dynamic> toJson() => _$AmendmentNoteItemToJson(this);

  @JsonKey(name: '_id')
  final String? id;
  final String? text;
  final String? createdAt;
  final String? createdBy;
}

@JsonSerializable()
class AmendmentNotesData {
  const AmendmentNotesData({this.items = const []});

  factory AmendmentNotesData.fromJson(Map<String, dynamic> json) =>
      _$AmendmentNotesDataFromJson(json);

  Map<String, dynamic> toJson() => _$AmendmentNotesDataToJson(this);

  @JsonKey(defaultValue: [])
  final List<AmendmentNoteItem> items;
}

@JsonSerializable(explicitToJson: true)
class AmendmentNotesResponse {
  const AmendmentNotesResponse({
    required this.status,
    required this.data,
  });

  factory AmendmentNotesResponse.fromJson(Map<String, dynamic> json) =>
      _$AmendmentNotesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AmendmentNotesResponseToJson(this);

  final String status;
  final AmendmentNotesData data;
}
