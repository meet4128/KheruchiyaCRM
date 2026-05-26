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
import 'package:travel_crm/features/presentation/forgot_password/bloc/forgot_password_bloc.dart';
import 'package:travel_crm/features/presentation/forgot_password/bloc/forgot_password_event.dart';
import 'package:travel_crm/features/presentation/forgot_password/bloc/forgot_password_state.dart';

/// Public-auth route that lets a user request a password-reset email.
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthPageScaffold(card: _ForgotPasswordCard());
  }
}

class _ForgotPasswordCard extends StatefulWidget {
  const _ForgotPasswordCard();

  static const double _maxCardWidth = 440;

  @override
  State<_ForgotPasswordCard> createState() => _ForgotPasswordCardState();
}

class _ForgotPasswordCardState extends State<_ForgotPasswordCard> {
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = Colors.white.withValues(alpha: 0.22);

    return BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        return ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: _ForgotPasswordCard._maxCardWidth,
          ),
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
            child: state.status == ForgotPasswordStatus.success
                ? const _ForgotPasswordSuccessPanel()
                : _ForgotPasswordFormPanel(
                    emailController: _emailController,
                    state: state,
                  ),
          ),
        );
      },
    );
  }
}

class _ForgotPasswordFormPanel extends StatelessWidget {
  const _ForgotPasswordFormPanel({
    required this.emailController,
    required this.state,
  });

  final TextEditingController emailController;
  final ForgotPasswordState state;

  @override
  Widget build(BuildContext context) {
    final loading = state.isSubmitting;

    return Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            StringConstant.forgotPasswordTitle,
            textAlign: TextAlign.center,
            style: FontConstant.interBold(
              color: ColorConstant.whiteColor,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ).copyWith(letterSpacing: 1.2),
          ),
          const SizedBox(height: DimensionConstant.d12),
          Text(
            StringConstant.forgotPasswordSubtitle,
            textAlign: TextAlign.center,
            style: FontConstant.interNormal(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: DimensionConstant.d28),
          Text(
            StringConstant.forgotPasswordEmailLabel,
            style: FontConstant.interNormal(
              color: ColorConstant.whiteColor.withValues(alpha: 0.9),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: DimensionConstant.d6),
          TextFormField(
            controller: emailController,
            enabled: !loading,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            onChanged: (v) => context
                .read<ForgotPasswordBloc>()
                .add(ForgotPasswordEmailChanged(v)),
            onFieldSubmitted: (_) => _submit(context, emailController),
            style: FontConstant.interNormal(
              color: ColorConstant.whiteColor,
              fontSize: 14,
            ),
            cursorColor: ColorConstant.whiteColor,
            decoration: authFieldDecoration(errorText: state.emailError),
          ),
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) ...[
            const SizedBox(height: DimensionConstant.d12),
            AuthErrorBanner(message: state.errorMessage!),
          ],
          const SizedBox(height: DimensionConstant.d24),
          AuthGradientSubmitButton(
            isLoading: loading,
            onPressed: loading ? null : () => _submit(context, emailController),
            label: StringConstant.forgotPasswordSubmit,
          ),
          const SizedBox(height: DimensionConstant.d16),
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: loading
                  ? null
                  : () => context.go(PathConstant.login),
              child: Text(
                StringConstant.forgotPasswordBackToLogin,
                style: FontConstant.interNormal(
                  color: ColorConstant.whiteColor.withValues(alpha: 0.85),
                  fontSize: 13,
                  textDecoration: TextDecoration.underline,
                  decorationColor:
                      ColorConstant.whiteColor.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submit(BuildContext context, TextEditingController controller) {
    final bloc = context.read<ForgotPasswordBloc>();
    bloc
      ..add(ForgotPasswordEmailChanged(controller.text))
      ..add(const ForgotPasswordSubmitted());
  }
}

class _ForgotPasswordSuccessPanel extends StatelessWidget {
  const _ForgotPasswordSuccessPanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.mark_email_read_outlined,
          color: ColorConstant.whiteColor.withValues(alpha: 0.9),
          size: 56,
        ),
        const SizedBox(height: DimensionConstant.d16),
        Text(
          StringConstant.forgotPasswordSentTitle,
          textAlign: TextAlign.center,
          style: FontConstant.interBold(
            color: ColorConstant.whiteColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: DimensionConstant.d12),
        Text(
          StringConstant.forgotPasswordSentSubtitle,
          textAlign: TextAlign.center,
          style: FontConstant.interNormal(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 13,
            height: 1.45,
          ),
        ),
        const SizedBox(height: DimensionConstant.d24),
        AuthGradientSubmitButton(
          onPressed: () => context.go(PathConstant.login),
          label: StringConstant.forgotPasswordBackToLogin,
        ),
      ],
    );
  }
}
