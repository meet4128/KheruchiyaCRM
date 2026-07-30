import 'package:json_annotation/json_annotation.dart';
import 'package:travel_crm/data/models/inquiry/payment_plan_installment_dto.dart';

import 'payment_party_dtos.dart';

part 'unverified_payment_item.g.dart';

/// A single row of `GET /api/v1/payments/unverified` → `data.items[]`.
///
/// Carries the payment-plan fields plus the joined `inquiry`, `contact`, and
/// `assignedTo` snapshots the table columns need. Reuses the shared
/// [PaymentPlanInstallmentDto] for `installments[]`.
@JsonSerializable(explicitToJson: true)
class UnverifiedPaymentItem {
  const UnverifiedPaymentItem({
    this.paymentPlanId,
    this.inquiryId,
    this.travelDate,
    this.bookingType,
    this.totalAmount,
    this.numberOfInstallments,
    this.paymentReceivedTillNow,
    this.installments = const [],
    this.verified,
    this.submittedAt,
    this.createdAt,
    this.inquiry,
    this.contact,
    this.assignedTo,
  });

  factory UnverifiedPaymentItem.fromJson(Map<String, dynamic> json) =>
      _$UnverifiedPaymentItemFromJson(json);

  Map<String, dynamic> toJson() => _$UnverifiedPaymentItemToJson(this);

  final String? paymentPlanId;
  final String? inquiryId;
  final DateTime? travelDate;
  final String? bookingType;
  final num? totalAmount;
  final int? numberOfInstallments;
  final num? paymentReceivedTillNow;

  @JsonKey(defaultValue: [])
  final List<PaymentPlanInstallmentDto> installments;

  final bool? verified;
  final DateTime? submittedAt;
  final DateTime? createdAt;

  final PaymentInquiryRefDto? inquiry;
  final PaymentContactDto? contact;
  final PaymentAssigneeDto? assignedTo;
}
