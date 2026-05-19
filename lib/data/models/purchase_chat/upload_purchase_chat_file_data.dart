import 'package:json_annotation/json_annotation.dart';

part 'upload_purchase_chat_file_data.g.dart';

@JsonSerializable()
class UploadPurchaseChatFileData {
  const UploadPurchaseChatFileData({
    required this.mediaUrl,
    required this.fileName,
    this.mimeType,
  });

  factory UploadPurchaseChatFileData.fromJson(Map<String, dynamic> json) =>
      _$UploadPurchaseChatFileDataFromJson(json);

  Map<String, dynamic> toJson() => _$UploadPurchaseChatFileDataToJson(this);

  final String mediaUrl;
  final String fileName;
  final String? mimeType;
}

@JsonSerializable(explicitToJson: true)
class UploadPurchaseChatFileResponse {
  const UploadPurchaseChatFileResponse({
    required this.status,
    required this.data,
  });

  factory UploadPurchaseChatFileResponse.fromJson(Map<String, dynamic> json) =>
      _$UploadPurchaseChatFileResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UploadPurchaseChatFileResponseToJson(this);

  final String status;
  final UploadPurchaseChatFileData data;
}
