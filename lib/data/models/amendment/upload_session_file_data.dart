import 'package:json_annotation/json_annotation.dart';

part 'upload_session_file_data.g.dart';

@JsonSerializable()
class UploadSessionFileData {
  const UploadSessionFileData({
    required this.mediaUrl,
    required this.fileName,
    this.mimeType,
  });

  factory UploadSessionFileData.fromJson(Map<String, dynamic> json) =>
      _$UploadSessionFileDataFromJson(json);

  Map<String, dynamic> toJson() => _$UploadSessionFileDataToJson(this);

  final String mediaUrl;
  final String fileName;
  final String? mimeType;
}

@JsonSerializable(explicitToJson: true)
class UploadSessionFileResponse {
  const UploadSessionFileResponse({
    required this.status,
    required this.data,
  });

  factory UploadSessionFileResponse.fromJson(Map<String, dynamic> json) =>
      _$UploadSessionFileResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UploadSessionFileResponseToJson(this);

  final String status;
  final UploadSessionFileData data;
}
