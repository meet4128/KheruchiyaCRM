import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/widgets/app_text_field.dart';
import 'package:travel_crm/data/repositories/auth_repository.dart';

import 'forgot_password_event.dart';
import 'forgot_password_state.dart';

/// Drives the forgot-password screen.
///
/// Contract: the backend always responds 200 to `/auth/forgot-password`
/// regardless of whether the email matches an active member (anti-enumeration).
/// Therefore this bloc emits [ForgotPasswordStatus.success] on any 2xx and
/// only emits [ForgotPasswordStatus.failure] for transport-level errors.
class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const ForgotPasswordState()) {
    on<ForgotPasswordEmailChanged>(_onEmailChanged);
    on<ForgotPasswordSubmitted>(_onSubmitted);
  }

  final AuthRepository _authRepository;

  void _onEmailChanged(
    ForgotPasswordEmailChanged event,
    Emitter<ForgotPasswordState> emit,
  ) {
    emit(state.copyWith(
      email: event.email,
      clearEmailError: true,
      clearErrorMessage: true,
    ));
  }

  Future<void> _onSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    final trimmed = state.email.trim();
    final emailError = AppTextFieldValidators.email(trimmed);
    if (emailError != null) {
      emit(state.copyWith(emailError: emailError));
      return;
    }

    emit(state.copyWith(
      status: ForgotPasswordStatus.submitting,
      clearErrorMessage: true,
      clearEmailError: true,
    ));

    try {
      await _authRepository.forgotPassword(email: trimmed);
      emit(state.copyWith(status: ForgotPasswordStatus.success));
    } on AuthException catch (e) {
      emit(state.copyWith(
        status: ForgotPasswordStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ForgotPasswordStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
