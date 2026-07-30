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

/// Re-runs the current query (refresh button / retry after error). When
/// [preserveExpansion] is true the currently expanded rows stay open — used
/// after verifying a single installment so its row doesn't collapse.
class UnverifiedPaymentsRefreshed extends UnverifiedPaymentsEvent {
  const UnverifiedPaymentsRefreshed({this.preserveExpansion = false});

  final bool preserveExpansion;

  @override
  List<Object?> get props => [preserveExpansion];
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
