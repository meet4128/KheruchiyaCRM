import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/utils/shared_pref_utils.dart';
import 'package:travel_crm/core/widgets/app_text_field.dart';
import 'package:travel_crm/data/models/auth/auth_tokens_response.dart';
import 'package:travel_crm/data/repositories/auth_repository.dart';
import 'package:travel_crm/features/presentation/login/bloc/login_event.dart';
import 'package:travel_crm/features/presentation/login/bloc/login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const LoginState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginPasswordVisibilityToggled>(_onPasswordVisibilityToggled);
    on<LoginRememberMeToggled>(_onRememberMeToggled);
    on<LoginSubmitted>(_onSubmitted);
  }

  final AuthRepository _authRepository;

  void _onEmailChanged(LoginEmailChanged event, Emitter<LoginState> emit) {
    emit(
      state.copyWith(
        email: event.email,
        clearEmailError: true,
        clearErrorMessage: true,
        status: state.status == LoginStatus.failure ? LoginStatus.initial : null,
      ),
    );
  }

  void _onPasswordChanged(LoginPasswordChanged event, Emitter<LoginState> emit) {
    emit(
      state.copyWith(
        password: event.password,
        clearPasswordError: true,
        clearErrorMessage: true,
        status: state.status == LoginStatus.failure ? LoginStatus.initial : null,
      ),
    );
  }

  void _onPasswordVisibilityToggled(
    LoginPasswordVisibilityToggled event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  void _onRememberMeToggled(LoginRememberMeToggled event, Emitter<LoginState> emit) {
    emit(state.copyWith(rememberMe: event.value));
  }

  Future<void> _onSubmitted(LoginSubmitted event, Emitter<LoginState> emit) async {
    final emailErr = AppTextFieldValidators.email(state.email.trim());
    final passwordErr = AppTextFieldValidators.minLength(
      state.password,
      kLoginPasswordMinLength,
    );

    if (emailErr != null || passwordErr != null) {
      emit(
        LoginState(
          email: state.email,
          password: state.password,
          obscurePassword: state.obscurePassword,
          rememberMe: state.rememberMe,
          userRole: state.userRole,
          emailError: emailErr,
          passwordError: passwordErr,
          status: LoginStatus.initial,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: LoginStatus.loading,
        clearEmailError: true,
        clearPasswordError: true,
        clearErrorMessage: true,
      ),
    );

    try {
      final response = await _authRepository.login(
        email: state.email.trim(),
        password: state.password,
        isAdmin: false
      );
      _persistLoginSession(
        response: response,
        rememberMe: state.rememberMe,
      );
      emit(
        state.copyWith(
          status: LoginStatus.success,
          userRole: response.data.user.role.trim().toLowerCase(),
          emailError: null,
          passwordError: null,
          errorMessage: null,
        ),
      );
    } on AuthException catch (e) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: e.message,
        ),
      );
    }
  }
}

void _persistLoginSession({
  required AuthTokensResponse response,
  required bool rememberMe,
}) {
  final data = response.data;
  SharedPrefUtils.setValue(SharedPrefUtilsKeys.userToken, data.accessToken.trim());
  final refresh = data.refreshToken.trim();
  if (refresh.isNotEmpty) {
    SharedPrefUtils.setValue(SharedPrefUtilsKeys.refreshToken, refresh);
  } else {
    SharedPrefUtils.removeValue(SharedPrefUtilsKeys.refreshToken);
  }
  SharedPrefUtils.setValue(SharedPrefUtilsKeys.isLoggedIn, true);
  SharedPrefUtils.setValue(SharedPrefUtilsKeys.isRememberMe, rememberMe);
  final email = data.user.email.trim();
  if (email.isNotEmpty) {
    SharedPrefUtils.setValue(SharedPrefUtilsKeys.userName, email);
  }
  SharedPrefUtils.setValue(
    SharedPrefUtilsKeys.userRole,
    data.user.role.trim().toLowerCase(),
  );
}
