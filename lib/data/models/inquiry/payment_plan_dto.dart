import 'package:json_annotation/json_annotation.dart';
import 'package:travel_crm/data/models/inquiry/payment_plan_installment_dto.dart';

part 'payment_plan_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class PaymentPlanDto {
  const PaymentPlanDto({
    this.id,
    this.inquiryId,
    this.inquiryNumber,
    this.travelDate,
    this.bookingType,
    this.totalAmount,
    this.numberOfInstallments,
    this.paymentReceivedTillNow,
    this.installments = const [],
    this.verified,
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

  /// Human-readable inquiry number (e.g. `FT/2627/001`) persisted on the plan.
  final String? inquiryNumber;
  final DateTime? travelDate;
  final String? bookingType;
  final num? totalAmount;
  final int? numberOfInstallments;
  final num? paymentReceivedTillNow;
  final List<PaymentPlanInstallmentDto> installments;

  /// Set true once accounts verify the plan; the client then locks editing.
  final bool? verified;
  final String? createdBy;
  final String? updatedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
