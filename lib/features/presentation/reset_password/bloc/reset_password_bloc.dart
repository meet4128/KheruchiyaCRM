import 'package:travel_crm/core/utils/shared_pref_utils.dart';
import 'package:travel_crm/data/models/auth/token_purpose.dart';
import 'package:travel_crm/features/presentation/set_password/bloc/set_password_bloc.dart';

/// Drives the `/reset-password?token=…` screen.
///
/// Inherits 95% of the behaviour from [SetPasswordBloc] — same state, same
/// events, same form. Only three things differ:
///
/// 1. [purpose] returns `TokenPurpose.reset` so `validateToken` hits the
///    reset-token store.
/// 2. [performSubmit] calls `resetPassword` instead of `setPassword`.
/// 3. On a successful submit we wipe any locally-cached session (the backend
///    bumped `tokenVersion`, so any extant refresh-token is dead anyway —
///    clearing locally just makes the next navigation correctly land on
///    `/login` via `globalRedirect`).
class ResetPasswordBloc extends SetPasswordBloc {
  ResetPasswordBloc({required super.authRepository});

  @override
  TokenPurpose get purpose => TokenPurpose.reset;

  @override
  Future<void> performSubmit() async {
    await authRepository.resetPassword(
      token: state.token,
      password: state.password,
    );
    // Backend invalidated this user's tokens on every device; wipe local
    // session too so the user has to log in fresh after redirect.
    await SharedPrefUtils.clearSharedPref();
  }
}
