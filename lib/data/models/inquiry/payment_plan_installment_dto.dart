import 'package:json_annotation/json_annotation.dart';

part 'payment_plan_installment_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class PaymentPlanInstallmentDto {
  const PaymentPlanInstallmentDto({
    this.id,
    this.amount,
    this.dueDate,
    this.receivedDate,
    this.mode,
    this.status,
    this.paymentProofUrl,
    this.verificationStatus,
    this.verifiedAt,
    this.verifiedBy,
  });

  factory PaymentPlanInstallmentDto.fromJson(Map<String, dynamic> json) =>
      _$PaymentPlanInstallmentDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentPlanInstallmentDtoToJson(this);

  /// Backend installment id (`_id`), a.k.a. the paymentId. Sent back on save so
  /// the server merges by row; omitted for brand-new rows. Also the id used to
  /// verify a single installment.
  @JsonKey(name: '_id')
  final String? id;

  final num? amount;
  final DateTime? dueDate;
  final DateTime? receivedDate;
  final String? mode;
  final String? status;
  final String? paymentProofUrl;

  /// Per-installment verification state: `PENDING` or `VERIFIED`. Response-only;
  /// never sent on save (the server owns it).
  final String? verificationStatus;
  final DateTime? verifiedAt;
  final String? verifiedBy;

  bool get isVerified => verificationStatus == 'VERIFIED';
  bool get isPending => verificationStatus == 'PENDING';
}
