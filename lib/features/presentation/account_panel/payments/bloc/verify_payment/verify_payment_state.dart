import 'package:equatable/equatable.dart';

/// - [idle]        → waiting on the accountant's confirmation.
/// - [submitting]  → verify request in flight.
/// - [success]     → payment verified; the dialog closes.
/// - [failure]     → verify failed; [errorMessage] holds the copy.
enum VerifyPaymentStatus { idle, submitting, success, failure }

class VerifyPaymentState extends Equatable {
  const VerifyPaymentState({
    this.confirmed = false,
    this.status = VerifyPaymentStatus.idle,
    this.errorMessage,
  });

  /// The "i have Verified with accounts…" checkbox.
  final bool confirmed;
  final VerifyPaymentStatus status;
  final String? errorMessage;

  bool get isSubmitting => status == VerifyPaymentStatus.submitting;

  /// The primary button is only actionable once confirmed and not mid-submit.
  bool get canSubmit => confirmed && !isSubmitting;

  VerifyPaymentState copyWith({
    bool? confirmed,
    VerifyPaymentStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return VerifyPaymentState(
      confirmed: confirmed ?? this.confirmed,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [confirmed, status, errorMessage];
}
