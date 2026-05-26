import 'package:equatable/equatable.dart';

sealed class SetPasswordEvent extends Equatable {
  const SetPasswordEvent();

  @override
  List<Object?> get props => const [];
}

/// Fires from the page wrapper on mount with the `?token=…` query parameter.
/// Triggers a `GET /auth/token/validate?purpose=invite` round-trip.
final class SetPasswordTokenReceived extends SetPasswordEvent {
  const SetPasswordTokenReceived(this.token);

  final String token;

  @override
  List<Object?> get props => [token];
}

final class SetPasswordPasswordChanged extends SetPasswordEvent {
  const SetPasswordPasswordChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

final class SetPasswordConfirmChanged extends SetPasswordEvent {
  const SetPasswordConfirmChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

final class SetPasswordSubmitted extends SetPasswordEvent {
  const SetPasswordSubmitted();
}

/// User tapped "Try again" on the validating-failed empty state.
final class SetPasswordRetryValidation extends SetPasswordEvent {
  const SetPasswordRetryValidation();
}
