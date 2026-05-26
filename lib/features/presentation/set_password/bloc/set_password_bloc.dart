import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/widgets/app_text_field.dart';
import 'package:travel_crm/data/models/auth/token_purpose.dart';
import 'package:travel_crm/data/models/auth/token_validate_response.dart';
import 'package:travel_crm/data/repositories/auth_repository.dart';

import 'set_password_event.dart';
import 'set_password_state.dart';

/// Drives the `/set-password?token=…` screen (invite token).
///
/// On mount the page wrapper fires [SetPasswordTokenReceived] which kicks off
/// `validateToken(purpose: invite)`. The bloc then transitions the [phase]
/// based on the server response so the screen can render either the form,
/// an error empty state, or the success panel.
class SetPasswordBloc extends Bloc<SetPasswordEvent, SetPasswordState> {
  SetPasswordBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const SetPasswordState()) {
    on<SetPasswordTokenReceived>(_onTokenReceived);
    on<SetPasswordPasswordChanged>(_onPasswordChanged);
    on<SetPasswordConfirmChanged>(_onConfirmChanged);
    on<SetPasswordSubmitted>(_onSubmitted);
    on<SetPasswordRetryValidation>(_onRetry);
  }

  final AuthRepository _authRepository;

  /// Exposed to subclasses (e.g. `ResetPasswordBloc`) so they can implement
  /// [performSubmit] without re-storing the repository instance.
  @protected
  AuthRepository get authRepository => _authRepository;

  /// Purpose passed to validate / used to discriminate sub-classed blocs.
  /// Overridden by [ResetPasswordBloc] which validates with `purpose: reset`.
  TokenPurpose get purpose => TokenPurpose.invite;

  Future<void> _onTokenReceived(
    SetPasswordTokenReceived event,
    Emitter<SetPasswordState> emit,
  ) async {
    final token = event.token.trim();
    if (token.isEmpty) {
      emit(state.copyWith(
        phase: SetPasswordPhase.invalidToken,
        token: '',
      ));
      return;
    }
    emit(state.copyWith(
      phase: SetPasswordPhase.validating,
      token: token,
      clearMaskedEmail: true,
      clearExpiresAt: true,
      clearErrorMessage: true,
    ));

    await _runValidate(token, emit);
  }

  Future<void> _onRetry(
    SetPasswordRetryValidation event,
    Emitter<SetPasswordState> emit,
  ) async {
    if (state.token.isEmpty) return;
    emit(state.copyWith(
      phase: SetPasswordPhase.validating,
      clearErrorMessage: true,
    ));
    await _runValidate(state.token, emit);
  }

  Future<void> _runValidate(
    String token,
    Emitter<SetPasswordState> emit,
  ) async {
    try {
      final response = await _authRepository.validateToken(
        token: token,
        purpose: purpose,
      );
      emit(_readyFromValidate(response));
    } on TokenInvalidException {
      emit(state.copyWith(phase: SetPasswordPhase.invalidToken));
    } on TokenExpiredException {
      emit(state.copyWith(phase: SetPasswordPhase.expiredToken));
    } on TokenAlreadyUsedException {
      emit(state.copyWith(phase: SetPasswordPhase.alreadyUsed));
    } on AuthException catch (e) {
      // Network / transport — show retry UI so the user can recover.
      emit(state.copyWith(
        phase: SetPasswordPhase.validationFailed,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        phase: SetPasswordPhase.validationFailed,
        errorMessage: e.toString(),
      ));
    }
  }

  SetPasswordState _readyFromValidate(TokenValidateResponse response) {
    return state.copyWith(
      phase: SetPasswordPhase.ready,
      maskedEmail: response.data.email,
      expiresAt: DateTime.tryParse(response.data.expiresAt),
      clearErrorMessage: true,
    );
  }

  void _onPasswordChanged(
    SetPasswordPasswordChanged event,
    Emitter<SetPasswordState> emit,
  ) {
    emit(state.copyWith(
      password: event.value,
      clearPasswordError: true,
      clearConfirmError: true,
      clearErrorMessage: true,
    ));
  }

  void _onConfirmChanged(
    SetPasswordConfirmChanged event,
    Emitter<SetPasswordState> emit,
  ) {
    emit(state.copyWith(
      confirmPassword: event.value,
      clearConfirmError: true,
      clearErrorMessage: true,
    ));
  }

  Future<void> _onSubmitted(
    SetPasswordSubmitted event,
    Emitter<SetPasswordState> emit,
  ) async {
    if (state.phase != SetPasswordPhase.ready) return;

    final passwordError =
        AppTextFieldValidators.invitePasswordPolicy(state.password);
    final confirmError = state.confirmPassword.isEmpty
        ? StringConstant.setPasswordRequired
        : (state.password != state.confirmPassword
            ? StringConstant.setPasswordMismatch
            : null);
    if (passwordError != null || confirmError != null) {
      emit(state.copyWith(
        passwordError: passwordError,
        confirmError: confirmError,
        clearErrorMessage: true,
      ));
      return;
    }

    emit(state.copyWith(
      phase: SetPasswordPhase.submitting,
      clearErrorMessage: true,
      clearPasswordError: true,
      clearConfirmError: true,
    ));

    try {
      await performSubmit();
      emit(state.copyWith(phase: SetPasswordPhase.success));
    } on WeakPasswordException catch (e) {
      emit(state.copyWith(
        phase: SetPasswordPhase.ready,
        passwordError: e.message,
      ));
    } on SamePasswordException catch (e) {
      // Theoretically set-password shouldn't see this (the user has no
      // prior password). Handled defensively anyway for ResetPasswordBloc.
      emit(state.copyWith(
        phase: SetPasswordPhase.ready,
        passwordError: e.message,
      ));
    } on TokenInvalidException {
      emit(state.copyWith(phase: SetPasswordPhase.invalidToken));
    } on TokenExpiredException {
      emit(state.copyWith(phase: SetPasswordPhase.expiredToken));
    } on TokenAlreadyUsedException {
      emit(state.copyWith(phase: SetPasswordPhase.alreadyUsed));
    } on RateLimitedException catch (e) {
      emit(state.copyWith(
        phase: SetPasswordPhase.ready,
        errorMessage: e.message,
      ));
    } on AuthException catch (e) {
      emit(state.copyWith(
        phase: SetPasswordPhase.ready,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        phase: SetPasswordPhase.ready,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Subclassed by [ResetPasswordBloc] to swap the underlying repository
  /// call. Kept protected via the @visibleForOverriding pattern.
  Future<void> performSubmit() {
    return _authRepository.setPassword(
      token: state.token,
      password: state.password,
    );
  }
}
