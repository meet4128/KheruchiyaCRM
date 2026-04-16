import 'package:equatable/equatable.dart';

/// Minimum password length for login validation ([loginflow.md] §4.3).
const int kLoginPasswordMinLength = 8;

enum LoginStatus {
  initial,
  loading,
  success,
  failure,
}

class LoginState extends Equatable {
  const LoginState({
    this.email = '',
    this.password = '',
    this.obscurePassword = true,
    this.rememberMe = false,
    this.userRole = '',
    this.emailError,
    this.passwordError,
    this.status = LoginStatus.initial,
    this.errorMessage,
  });

  final String email;
  final String password;
  final bool obscurePassword;
  final bool rememberMe;
  final String userRole;
  final String? emailError;
  final String? passwordError;
  final LoginStatus status;
  final String? errorMessage;

  LoginState copyWith({
    String? email,
    String? password,
    bool? obscurePassword,
    bool? rememberMe,
    String? userRole,
    String? emailError,
    String? passwordError,
    LoginStatus? status,
    String? errorMessage,
    bool clearEmailError = false,
    bool clearPasswordError = false,
    bool clearErrorMessage = false,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      rememberMe: rememberMe ?? this.rememberMe,
      userRole: userRole ?? this.userRole,
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      passwordError: clearPasswordError ? null : (passwordError ?? this.passwordError),
      status: status ?? this.status,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        email,
        password,
        obscurePassword,
        rememberMe,
        userRole,
        emailError,
        passwordError,
        status,
        errorMessage,
      ];
}
