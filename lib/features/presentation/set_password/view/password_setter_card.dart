import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/font_constant.dart';
import 'package:travel_crm/core/constants/path_constants.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/widgets/auth/app_password_field.dart';
import 'package:travel_crm/core/widgets/auth/auth_error_banner.dart';
import 'package:travel_crm/core/widgets/auth/auth_gradient_submit_button.dart';
import 'package:travel_crm/features/presentation/set_password/bloc/set_password_bloc.dart';
import 'package:travel_crm/features/presentation/set_password/bloc/set_password_event.dart';
import 'package:travel_crm/features/presentation/set_password/bloc/set_password_state.dart';

/// Discriminates the copy + submit-button label between the invite
/// (Set Password) and forgot (Reset Password) flows. The actual API call is
/// determined by the underlying [SetPasswordBloc] / `ResetPasswordBloc`
/// instance — this enum only drives presentation.
enum PasswordSetterMode { setPassword, resetPassword }

/// Shared card body for `/set-password` and `/reset-password`. Renders the
/// active sub-view based on [SetPasswordState.phase]:
///
///   - `idle` / `validating` → centered spinner
///   - `validationFailed`    → retry CTA
///   - `ready` / `submitting`→ two password fields + submit
///   - token-error phases    → "link invalid / expired / used" empty state
///   - `success`             → "password set" panel with go-to-login CTA
class PasswordSetterCard extends StatefulWidget {
  const PasswordSetterCard({super.key, required this.mode});

  final PasswordSetterMode mode;

  static const double _maxCardWidth = 460;

  @override
  State<PasswordSetterCard> createState() => _PasswordSetterCardState();
}

class _PasswordSetterCardState extends State<PasswordSetterCard> {
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmController;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _confirmController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = Colors.white.withValues(alpha: 0.22);

    return BlocBuilder<SetPasswordBloc, SetPasswordState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        return ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: PasswordSetterCard._maxCardWidth,
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
            child: _buildBody(context, state),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SetPasswordState state) {
    if (state.phase == SetPasswordPhase.idle ||
        state.isValidating) {
      return const _ValidatingPanel();
    }
    if (state.phase == SetPasswordPhase.validationFailed) {
      return _ValidationFailedPanel(message: state.errorMessage);
    }
    if (state.isTokenErrorPhase) {
      return _TokenErrorPanel(phase: state.phase);
    }
    if (state.isSuccess) {
      return _SuccessPanel(mode: widget.mode);
    }
    return _PasswordForm(
      mode: widget.mode,
      state: state,
      passwordController: _passwordController,
      confirmController: _confirmController,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Validating spinner
// ─────────────────────────────────────────────────────────────────────────────

class _ValidatingPanel extends StatelessWidget {
  const _ValidatingPanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          height: 36,
          width: 36,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: ColorConstant.whiteColor,
          ),
        ),
        const SizedBox(height: DimensionConstant.d16),
        Text(
          StringConstant.setPasswordVerifyingLink,
          textAlign: TextAlign.center,
          style: FontConstant.interNormal(
            color: ColorConstant.whiteColor.withValues(alpha: 0.85),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Validation-failed retry panel (network / 5xx during validate)
// ─────────────────────────────────────────────────────────────────────────────

class _ValidationFailedPanel extends StatelessWidget {
  const _ValidationFailedPanel({required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.cloud_off_outlined,
          color: ColorConstant.whiteColor.withValues(alpha: 0.85),
          size: 48,
        ),
        const SizedBox(height: DimensionConstant.d16),
        Text(
          StringConstant.setPasswordValidationFailedTitle,
          textAlign: TextAlign.center,
          style: FontConstant.interBold(
            color: ColorConstant.whiteColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: DimensionConstant.d8),
        Text(
          message?.isNotEmpty == true
              ? message!
              : StringConstant.setPasswordValidationFailedBody,
          textAlign: TextAlign.center,
          style: FontConstant.interNormal(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 13,
            height: 1.45,
          ),
        ),
        const SizedBox(height: DimensionConstant.d20),
        AuthGradientSubmitButton(
          onPressed: () => context
              .read<SetPasswordBloc>()
              .add(const SetPasswordRetryValidation()),
          label: StringConstant.setPasswordRetry,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Token error states (400 / 410 expired / 410 used)
// ─────────────────────────────────────────────────────────────────────────────

class _TokenErrorPanel extends StatelessWidget {
  const _TokenErrorPanel({required this.phase});

  final SetPasswordPhase phase;

  @override
  Widget build(BuildContext context) {
    final (title, body, icon) = switch (phase) {
      SetPasswordPhase.invalidToken => (
          StringConstant.setPasswordInvalidLinkTitle,
          StringConstant.setPasswordInvalidLinkBody,
          Icons.link_off_outlined,
        ),
      SetPasswordPhase.expiredToken => (
          StringConstant.setPasswordExpiredLinkTitle,
          StringConstant.setPasswordExpiredLinkBody,
          Icons.schedule_outlined,
        ),
      SetPasswordPhase.alreadyUsed => (
          StringConstant.setPasswordUsedLinkTitle,
          StringConstant.setPasswordUsedLinkBody,
          Icons.check_circle_outline,
        ),
      _ => (
          StringConstant.setPasswordInvalidLinkTitle,
          StringConstant.setPasswordInvalidLinkBody,
          Icons.link_off_outlined,
        ),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          icon,
          color: ColorConstant.whiteColor.withValues(alpha: 0.85),
          size: 56,
        ),
        const SizedBox(height: DimensionConstant.d16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: FontConstant.interBold(
            color: ColorConstant.whiteColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: DimensionConstant.d12),
        Text(
          body,
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
          label: StringConstant.setPasswordGoToLogin,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Success panel
// ─────────────────────────────────────────────────────────────────────────────

class _SuccessPanel extends StatefulWidget {
  const _SuccessPanel({required this.mode});

  final PasswordSetterMode mode;

  @override
  State<_SuccessPanel> createState() => _SuccessPanelState();
}

class _SuccessPanelState extends State<_SuccessPanel> {
  static const _autoRedirectDelay = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    Future.delayed(_autoRedirectDelay, () {
      if (!mounted) return;
      context.go(PathConstant.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.mode == PasswordSetterMode.setPassword
        ? StringConstant.setPasswordSuccessTitle
        : StringConstant.resetPasswordSuccessTitle;
    final subtitle = widget.mode == PasswordSetterMode.setPassword
        ? StringConstant.setPasswordSuccessSubtitle
        : StringConstant.resetPasswordSuccessSubtitle;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.check_circle_outline,
          color: ColorConstant.whiteColor.withValues(alpha: 0.9),
          size: 56,
        ),
        const SizedBox(height: DimensionConstant.d16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: FontConstant.interBold(
            color: ColorConstant.whiteColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: DimensionConstant.d12),
        Text(
          subtitle,
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
          label: StringConstant.setPasswordGoToLogin,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// The form (ready / submitting)
// ─────────────────────────────────────────────────────────────────────────────

class _PasswordForm extends StatelessWidget {
  const _PasswordForm({
    required this.mode,
    required this.state,
    required this.passwordController,
    required this.confirmController,
  });

  final PasswordSetterMode mode;
  final SetPasswordState state;
  final TextEditingController passwordController;
  final TextEditingController confirmController;

  @override
  Widget build(BuildContext context) {
    final loading = state.isSubmitting;

    final title = mode == PasswordSetterMode.setPassword
        ? StringConstant.setPasswordTitle
        : StringConstant.resetPasswordTitle;
    final submitLabel = mode == PasswordSetterMode.setPassword
        ? StringConstant.setPasswordSubmit
        : StringConstant.resetPasswordSubmit;

    return Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: FontConstant.interBold(
              color: ColorConstant.whiteColor,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ).copyWith(letterSpacing: 1.2),
          ),
          if (state.maskedEmail != null && state.maskedEmail!.isNotEmpty) ...[
            const SizedBox(height: DimensionConstant.d8),
            Text(
              StringConstant.setPasswordSubtitleTemplate
                  .replaceFirst('{email}', state.maskedEmail!),
              textAlign: TextAlign.center,
              style: FontConstant.interNormal(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 13,
              ),
            ),
          ],
          if (state.expiresAt != null) ...[
            const SizedBox(height: DimensionConstant.d6),
            Text(
              StringConstant.setPasswordLinkExpiresTemplate
                  .replaceFirst('{dateTime}', _formatExpiry(state.expiresAt!)),
              textAlign: TextAlign.center,
              style: FontConstant.interNormal(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: DimensionConstant.d28),
          AppPasswordField(
            controller: passwordController,
            label: StringConstant.setPasswordNewLabel,
            enabled: !loading,
            errorText: state.passwordError,
            autofillHints: const [AutofillHints.newPassword],
            onChanged: (v) => context
                .read<SetPasswordBloc>()
                .add(SetPasswordPasswordChanged(v)),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: DimensionConstant.d18),
          AppPasswordField(
            controller: confirmController,
            label: StringConstant.setPasswordConfirmLabel,
            enabled: !loading,
            errorText: state.confirmError,
            autofillHints: const [AutofillHints.newPassword],
            onChanged: (v) => context
                .read<SetPasswordBloc>()
                .add(SetPasswordConfirmChanged(v)),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(context),
          ),
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) ...[
            const SizedBox(height: DimensionConstant.d12),
            AuthErrorBanner(message: state.errorMessage!),
          ],
          const SizedBox(height: DimensionConstant.d24),
          AuthGradientSubmitButton(
            isLoading: loading,
            onPressed: loading ? null : () => _submit(context),
            label: submitLabel,
          ),
        ],
      ),
    );
  }

  void _submit(BuildContext context) {
    final bloc = context.read<SetPasswordBloc>();
    bloc
      ..add(SetPasswordPasswordChanged(passwordController.text))
      ..add(SetPasswordConfirmChanged(confirmController.text))
      ..add(const SetPasswordSubmitted());
  }

  String _formatExpiry(DateTime dt) {
    final local = dt.isUtc ? dt.toLocal() : dt;
    return DateFormat('d MMM yyyy, h:mm a').format(local);
  }
}
