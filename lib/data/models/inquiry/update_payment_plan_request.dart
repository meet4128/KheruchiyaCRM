import 'package:json_annotation/json_annotation.dart';
import 'package:travel_crm/data/models/inquiry/payment_plan_installment_dto.dart';

part 'update_payment_plan_request.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class UpdatePaymentPlanRequest {
  const UpdatePaymentPlanRequest({
    this.inquiryNumber,
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

  /// Human-readable inquiry number (e.g. `FT/2627/003`) so the accounts role can
  /// display it against the payment. Scoping still happens via the `inquiryId`
  /// path param — this is a display value the backend persists on the plan.
  final String? inquiryNumber;
  final DateTime? travelDate;
  final String? bookingType;
  final num? totalAmount;
  final int? numberOfInstallments;
  final num? paymentReceivedTillNow;
  final List<PaymentPlanInstallmentDto> installments;
}
