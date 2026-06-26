import 'package:json_annotation/json_annotation.dart';
import 'package:travel_crm/data/models/inquiry/payment_plan_installment_dto.dart';

part 'payment_plan_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class PaymentPlanDto {
  const PaymentPlanDto({
    this.id,
    this.inquiryId,
    this.travelDate,
    this.bookingType,
    this.totalAmount,
    this.numberOfInstallments,
    this.paymentReceivedTillNow,
    this.installments = const [],
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentPlanDto.fromJson(Map<String, dynamic> json) =>
      _$PaymentPlanDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentPlanDtoToJson(this);

  @JsonKey(name: '_id')
  final String? id;
  final String? inquiryId;
  final DateTime? travelDate;
  final String? bookingType;
  final num? totalAmount;
  final int? numberOfInstallments;
  final num? paymentReceivedTillNow;
  final List<PaymentPlanInstallmentDto> installments;
  final String? createdBy;
  final String? updatedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
