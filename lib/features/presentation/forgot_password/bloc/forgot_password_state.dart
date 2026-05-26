import 'package:equatable/equatable.dart';

enum ForgotPasswordStatus {
  initial,
  submitting,
  /// Backend returned 2xx — the form is replaced by the "Check your email"
  /// panel. Per the anti-enumeration contract, we never know whether the
  /// email matched; we show the same copy regardless.
  success,
  /// Network / transport failure. The form is still visible; an error banner
  /// appears so the user can retry.
  failure,
}

class ForgotPasswordState extends Equatable {
  const ForgotPasswordState({
    this.email = '',
    this.emailError,
    this.status = ForgotPasswordStatus.initial,
    this.errorMessage,
  });

  final String email;
  final String? emailError;
  final ForgotPasswordStatus status;

  /// Only ever populated on transport-level failures (timeout / no network).
  /// Never populated on 200 / "email not found".
  final String? errorMessage;

  bool get isSubmitting => status == ForgotPasswordStatus.submitting;

  ForgotPasswordState copyWith({
    String? email,
    String? emailError,
    ForgotPasswordStatus? status,
    String? errorMessage,
    bool clearEmailError = false,
    bool clearErrorMessage = false,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      status: status ?? this.status,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [email, emailError, status, errorMessage];
}
