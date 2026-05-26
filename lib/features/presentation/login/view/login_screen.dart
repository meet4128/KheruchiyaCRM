import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/font_constant.dart';
import 'package:travel_crm/core/constants/path_constants.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/widgets/auth/auth_error_banner.dart';
import 'package:travel_crm/core/widgets/auth/auth_field_decoration.dart';
import 'package:travel_crm/core/widgets/auth/auth_gradient_submit_button.dart';
import 'package:travel_crm/core/widgets/auth/auth_page_scaffold.dart';
import 'package:travel_crm/features/presentation/login/bloc/login_bloc.dart';
import 'package:travel_crm/features/presentation/login/bloc/login_event.dart';
import 'package:travel_crm/features/presentation/login/bloc/login_state.dart';

/// Operations Portal layout — form state from [LoginBloc].
///
/// Visual chrome (brand pane / dark image pane / footer) is provided by
/// [AuthPageScaffold] so the new public-auth screens (forgot / set / reset)
/// stay pixel-identical to login.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthPageScaffold(card: _LoginCard());
  }
}

class _LoginCard extends StatefulWidget {
  const _LoginCard();

  static const double _maxCardWidth = 440;

  @override
  State<_LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<_LoginCard> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = Colors.white.withValues(alpha: 0.22);

    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        final loading = state.status == LoginStatus.loading;

        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _LoginCard._maxCardWidth),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DimensionConstant.d40,
              vertical: DimensionConstant.d40,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.52),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            child: Form(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    StringConstant.operationsPortalTitle,
                    textAlign: TextAlign.center,
                    style: FontConstant.interBold(
                      color: ColorConstant.whiteColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ).copyWith(letterSpacing: 1.2),
                  ),
                  const SizedBox(height: DimensionConstant.d8),
                  Text(
                    StringConstant.loginWithKheruchiyaTravels,
                    textAlign: TextAlign.center,
                    style: FontConstant.interNormal(
                      color: ColorConstant.whiteColor.withValues(alpha: 0.95),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: DimensionConstant.d12),
                  Text(
                    StringConstant.loginAuthorizedAccessDisclaimer,
                    textAlign: TextAlign.center,
                    style: FontConstant.interNormal(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: DimensionConstant.d28),
                  Text(
                    StringConstant.email,
                    style: FontConstant.interNormal(
                      color: ColorConstant.whiteColor.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: DimensionConstant.d6),
                  TextFormField(
                    controller: _emailController,
                    enabled: !loading,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    onChanged: (v) =>
                        context.read<LoginBloc>().add(LoginEmailChanged(v)),
                    style: FontConstant.interNormal(
                      color: ColorConstant.whiteColor,
                      fontSize: 14,
                    ),
                    cursorColor: ColorConstant.whiteColor,
                    decoration:
                        authFieldDecoration(errorText: state.emailError),
                  ),
                  const SizedBox(height: DimensionConstant.d18),
                  Text(
                    StringConstant.password,
                    style: FontConstant.interNormal(
                      color: ColorConstant.whiteColor.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: DimensionConstant.d6),
                  TextFormField(
                    controller: _passwordController,
                    enabled: !loading,
                    obscureText: state.obscurePassword,
                    autofillHints: const [AutofillHints.password],
                    onChanged: (v) =>
                        context.read<LoginBloc>().add(LoginPasswordChanged(v)),
                    style: FontConstant.interNormal(
                      color: ColorConstant.whiteColor,
                      fontSize: 14,
                    ),
                    cursorColor: ColorConstant.whiteColor,
                    decoration: authFieldDecoration(
                      errorText: state.passwordError,
                      suffixIcon: IconButton(
                        tooltip: state.obscurePassword
                            ? StringConstant.loginTooltipShowPassword
                            : StringConstant.loginTooltipHidePassword,
                        onPressed: loading
                            ? null
                            : () => context
                                .read<LoginBloc>()
                                .add(const LoginPasswordVisibilityToggled()),
                        icon: Icon(
                          state.obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color:
                              ColorConstant.whiteColor.withValues(alpha: 0.75),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  if (state.errorMessage != null &&
                      state.errorMessage!.isNotEmpty) ...[
                    const SizedBox(height: DimensionConstant.d12),
                    AuthErrorBanner(message: state.errorMessage!),
                  ],
                  const SizedBox(height: DimensionConstant.d16),
                  Row(
                    children: [
                      Checkbox(
                        value: state.rememberMe,
                        onChanged: loading
                            ? null
                            : (v) => context
                                .read<LoginBloc>()
                                .add(LoginRememberMeToggled(v ?? false)),
                        side: BorderSide(color: border),
                        fillColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return ColorConstant.whiteColor
                                .withValues(alpha: 0.35);
                          }
                          return Colors.white.withValues(alpha: 0.12);
                        }),
                      ),
                      Expanded(
                        child: Text(
                          StringConstant.keepMeSignedIn,
                          style: FontConstant.interNormal(
                            color:
                                ColorConstant.whiteColor.withValues(alpha: 0.92),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: loading
                            ? null
                            : () =>
                                context.go(PathConstant.forgotPassword),
                        child: Text(
                          StringConstant.forgotPasswordQuestion,
                          style: FontConstant.interNormal(
                            color: ColorConstant.whiteColor
                                .withValues(alpha: 0.95),
                            fontSize: 13,
                            textDecoration: TextDecoration.underline,
                            decorationColor: ColorConstant.whiteColor
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DimensionConstant.d20),
                  AuthGradientSubmitButton(
                    isLoading: loading,
                    onPressed: loading
                        ? null
                        : () {
                            final bloc = context.read<LoginBloc>();
                            bloc
                              ..add(LoginEmailChanged(_emailController.text))
                              ..add(LoginPasswordChanged(_passwordController.text))
                              ..add(const LoginSubmitted());
                          },
                    label: StringConstant.submit,
                  ),
                  const SizedBox(height: DimensionConstant.d20),
                  Text(
                    StringConstant.loginContactAdministratorNote,
                    textAlign: TextAlign.center,
                    style: FontConstant.interNormal(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
