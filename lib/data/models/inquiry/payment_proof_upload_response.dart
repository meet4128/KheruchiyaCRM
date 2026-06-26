import 'package:json_annotation/json_annotation.dart';

part 'payment_proof_upload_response.g.dart';

@JsonSerializable()
class PaymentProofUploadData {
  const PaymentProofUploadData({
    required this.paymentProofUrl,
    this.fileName,
    this.mimeType,
  });

  factory PaymentProofUploadData.fromJson(Map<String, dynamic> json) =>
      _$PaymentProofUploadDataFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentProofUploadDataToJson(this);

  final String paymentProofUrl;
  final String? fileName;
  final String? mimeType;
}

@JsonSerializable(explicitToJson: true)
class PaymentProofUploadResponse {
  const PaymentProofUploadResponse({
    required this.status,
    required this.data,
  });

  factory PaymentProofUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentProofUploadResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentProofUploadResponseToJson(this);

  final String status;
  final PaymentProofUploadData data;
}
