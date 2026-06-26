import 'package:json_annotation/json_annotation.dart';
import 'package:travel_crm/data/models/inquiry/payment_plan_installment_dto.dart';

part 'update_payment_plan_request.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class UpdatePaymentPlanRequest {
  const UpdatePaymentPlanRequest({
    this.travelDate,
    this.bookingType,
    this.totalAmount,
    this.numberOfInstallments,
    this.paymentReceivedTillNow,
    this.installments = const [],
  });

  factory UpdatePaymentPlanRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdatePaymentPlanRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdatePaymentPlanRequestToJson(this);

  final DateTime? travelDate;
  final String? bookingType;
  final num? totalAmount;
  final int? numberOfInstallments;
  final num? paymentReceivedTillNow;
  final List<PaymentPlanInstallmentDto> installments;
}
