import 'package:json_annotation/json_annotation.dart';

part 'payment_plan_installment_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class PaymentPlanInstallmentDto {
  const PaymentPlanInstallmentDto({
    this.amount,
    this.dueDate,
    this.receivedDate,
    this.mode,
    this.status,
    this.paymentProofUrl,
  });

  factory PaymentPlanInstallmentDto.fromJson(Map<String, dynamic> json) =>
      _$PaymentPlanInstallmentDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentPlanInstallmentDtoToJson(this);

  final num? amount;
  final DateTime? dueDate;
  final DateTime? receivedDate;
  final String? mode;
  final String? status;
  final String? paymentProofUrl;
}
