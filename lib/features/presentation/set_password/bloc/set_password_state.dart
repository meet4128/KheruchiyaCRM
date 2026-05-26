import 'package:equatable/equatable.dart';

/// Drives which sub-view the [SetPasswordScreen] renders.
enum SetPasswordPhase {
  /// Initial state — wrapper hasn't fired `SetPasswordTokenReceived` yet.
  /// Treated visually the same as [validating] (loading spinner).
  idle,

  /// Token validate in flight.
  validating,

  /// Validate failed with a network / transport error — show a "Try again"
  /// affordance so the user can retry without losing context.
  validationFailed,

  /// 200 from validate — show the form.
  ready,

  /// 400 from validate / submit.
  invalidToken,

  /// 410 expired from validate / submit.
  expiredToken,

  /// 410 already-used from validate / submit.
  alreadyUsed,

  /// Submit in flight.
  submitting,

  /// Submit returned 200 — show the success panel.
  success,
}

class SetPasswordState extends Equatable {
  const SetPasswordState({
    this.phase = SetPasswordPhase.idle,
    this.token = '',
    this.maskedEmail,
    this.expiresAt,
    this.password = '',
    this.confirmPassword = '',
    this.passwordError,
    this.confirmError,
    this.errorMessage,
  });

  final SetPasswordPhase phase;
  final String token;

  /// Server-masked email from `GET /auth/token/validate` — e.g. `a****@x.com`.
  /// Safe to render in the UI.
  final String? maskedEmail;

  /// Expiry timestamp returned by validate. Rendered in the form header.
  final DateTime? expiresAt;

  final String password;
  final String confirmPassword;

  final String? passwordError;
  final String? confirmError;

  /// Submit-time error banner (e.g. rate-limit message).
  final String? errorMessage;

  bool get isValidating => phase == SetPasswordPhase.validating;
  bool get isSubmitting => phase == SetPasswordPhase.submitting;
  bool get isReady => phase == SetPasswordPhase.ready;
  bool get isSuccess => phase == SetPasswordPhase.success;
  bool get isTokenErrorPhase =>
      phase == SetPasswordPhase.invalidToken ||
      phase == SetPasswordPhase.expiredToken ||
      phase == SetPasswordPhase.alreadyUsed;

  SetPasswordState copyWith({
    SetPasswordPhase? phase,
    String? token,
    String? maskedEmail,
    DateTime? expiresAt,
    String? password,
    String? confirmPassword,
    String? passwordError,
    String? confirmError,
    String? errorMessage,
    bool clearMaskedEmail = false,
    bool clearExpiresAt = false,
    bool clearPasswordError = false,
    bool clearConfirmError = false,
    bool clearErrorMessage = false,
  }) {
    return SetPasswordState(
      phase: phase ?? this.phase,
      token: token ?? this.token,
      maskedEmail: clearMaskedEmail ? null : (maskedEmail ?? this.maskedEmail),
      expiresAt: clearExpiresAt ? null : (expiresAt ?? this.expiresAt),
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      passwordError:
          clearPasswordError ? null : (passwordError ?? this.passwordError),
      confirmError:
          clearConfirmError ? null : (confirmError ?? this.confirmError),
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        phase,
        token,
        maskedEmail,
        expiresAt,
        password,
        confirmPassword,
        passwordError,
        confirmError,
        errorMessage,
      ];
}
