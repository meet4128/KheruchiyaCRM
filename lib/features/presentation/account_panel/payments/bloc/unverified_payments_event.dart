import 'package:equatable/equatable.dart';

abstract class UnverifiedPaymentsEvent extends Equatable {
  const UnverifiedPaymentsEvent();

  @override
  List<Object?> get props => [];
}

/// First load / screen mount — fetches page 1 with the current search.
class UnverifiedPaymentsStarted extends UnverifiedPaymentsEvent {
  const UnverifiedPaymentsStarted();
}

/// Re-runs the current query (refresh button / retry after error).
class UnverifiedPaymentsRefreshed extends UnverifiedPaymentsEvent {
  const UnverifiedPaymentsRefreshed();
}

/// User typed in the search box — client-side filter over the loaded rows
/// (no API call).
class UnverifiedPaymentsSearchChanged extends UnverifiedPaymentsEvent {
  const UnverifiedPaymentsSearchChanged(this.search);

  final String search;

  @override
  List<Object?> get props => [search];
}

/// Pagination — fetches [page] with the current search.
class UnverifiedPaymentsPageRequested extends UnverifiedPaymentsEvent {
  const UnverifiedPaymentsPageRequested(this.page);

  final int page;

  @override
  List<Object?> get props => [page];
}

/// Expands / collapses a row's installment breakdown (keyed by payment plan id).
class UnverifiedPaymentExpansionToggled extends UnverifiedPaymentsEvent {
  const UnverifiedPaymentExpansionToggled(this.paymentPlanId);

  final String paymentPlanId;

  @override
  List<Object?> get props => [paymentPlanId];
}

/// Verifies a single installment (`PATCH .../installments/{id}/verify`). On
/// success the list refreshes; a plan leaves the queue once all its
/// installments are verified.
class UnverifiedInstallmentVerifyRequested extends UnverifiedPaymentsEvent {
  const UnverifiedInstallmentVerifyRequested({
    required this.inquiryId,
    required this.installmentId,
  });

  final String inquiryId;
  final String installmentId;

  @override
  List<Object?> get props => [inquiryId, installmentId];
}
