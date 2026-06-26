import 'package:json_annotation/json_annotation.dart';
import 'package:travel_crm/data/models/inquiry/payment_plan_dto.dart';

part 'payment_plan_response.g.dart';

@JsonSerializable(explicitToJson: true)
class PaymentPlanData {
  const PaymentPlanData({this.paymentPlan});

  factory PaymentPlanData.fromJson(Map<String, dynamic> json) =>
      _$PaymentPlanDataFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentPlanDataToJson(this);

  final PaymentPlanDto? paymentPlan;
}

@JsonSerializable(explicitToJson: true)
class PaymentPlanResponse {
  const PaymentPlanResponse({
    required this.status,
    required this.data,
  });

  factory PaymentPlanResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentPlanResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentPlanResponseToJson(this);

  final String status;
  final PaymentPlanData data;
}
