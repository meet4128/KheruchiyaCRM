import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/constants/asset_constants.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/font_constant.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/features/presentation/login/bloc/login_bloc.dart';
import 'package:travel_crm/features/presentation/login/bloc/login_event.dart';
import 'package:travel_crm/features/presentation/login/bloc/login_state.dart';

/// Matches brand pane / primary button gradient (mockup).
const List<Color> _kLoginGradientColors = [
  Color(0xFFC44EB9),
  Color(0xFF6B3FA8),
  Color(0xFF1E1C4A),
];

/// Operations Portal layout — form state from [LoginBloc] (Phase 4+).
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const double _wideBreakpoint = 880;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.primaryColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= _wideBreakpoint;
                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 2, child: _BrandPane(height: constraints.maxHeight)),
                      Expanded(flex: 3, child: _LoginImagePane(height: constraints.maxHeight)),
                    ],
                  );
                }
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      children: [
                        SizedBox(height: 260, child: _BrandPane(height: 260)),
                        _LoginImagePane(height: 520),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const _GlobalFooter(),
        ],
      ),
    );
  }
}

// --- Brand (left) -----------------------------------------------------------------

class _BrandPane extends StatelessWidget {
  const _BrandPane({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          height: height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _kLoginGradientColors,
            ),
          ),
        ),
        const CustomPaint(painter: _BrandArcPainter(), size: Size.infinite),
        Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxW = constraints.maxWidth;
              const horizontal = DimensionConstant.d24 * 2;
              final assetWidth = (maxW - horizontal).clamp(120.0, 440.0);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: DimensionConstant.d24),
                child: Image.asset(
                  AssetConstants.icKheruchiyaBgLogo,
                  width: assetWidth,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BrandArcPainter extends CustomPainter {
  const _BrandArcPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final w = size.width;
    final h = size.height;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.15, h * 0.35), width: w * 1.6, height: w * 1.6),
      0.2,
      1.1,
      false,
      stroke,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.55, h * 0.55), width: w * 1.2, height: w * 1.2),
      2.0,
      1.0,
      false,
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- Right pane (image + card) -----------------------------------------------------

class _LoginImagePane extends StatelessWidget {
  const _LoginImagePane({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AssetConstants.icLoginBackgroundView),
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      ),
      child: Container(
        color: Colors.black.withValues(alpha: 0.25),
        padding: const EdgeInsets.symmetric(
          horizontal: DimensionConstant.d24,
          vertical: DimensionConstant.d24,
        ),
        child: Center(
          child: SingleChildScrollView(
            child: const _LoginCard(),
          ),
        ),
      ),
    );
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
    final fieldFill = Colors.black.withValues(alpha: 0.45);

    InputDecoration fieldDecoration({String? errorText}) {
      return InputDecoration(
        isDense: true,
        filled: true,
        fillColor: fieldFill,
        errorText: errorText,
        errorMaxLines: 2,
        errorStyle: FontConstant.interNormal(color: ColorConstant.redColor, fontSize: 11),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DimensionConstant.d14,
          vertical: DimensionConstant.d14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: ColorConstant.whiteColor.withValues(alpha: 0.5)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ColorConstant.redColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ColorConstant.redColor),
        ),
      );
    }

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
                    style: FontConstant.interNormal(color: ColorConstant.whiteColor, fontSize: 14),
                    cursorColor: ColorConstant.whiteColor,
                    decoration: fieldDecoration(errorText: state.emailError),
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
                    style: FontConstant.interNormal(color: ColorConstant.whiteColor, fontSize: 14),
                    cursorColor: ColorConstant.whiteColor,
                    decoration: fieldDecoration(errorText: state.passwordError).copyWith(
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
                          color: ColorConstant.whiteColor.withValues(alpha: 0.75),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  if (state.errorMessage != null && state.errorMessage!.isNotEmpty) ...[
                    const SizedBox(height: DimensionConstant.d12),
                    _LoginApiErrorBanner(message: state.errorMessage!),
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
                            return ColorConstant.whiteColor.withValues(alpha: 0.35);
                          }
                          return Colors.white.withValues(alpha: 0.12);
                        }),
                      ),
                      Expanded(
                        child: Text(
                          StringConstant.keepMeSignedIn,
                          style: FontConstant.interNormal(
                            color: ColorConstant.whiteColor.withValues(alpha: 0.92),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: null,
                        child: Text(
                          StringConstant.forgotPasswordQuestion,
                          style: FontConstant.interNormal(
                            color: ColorConstant.whiteColor.withValues(alpha: 0.95),
                            fontSize: 13,
                            textDecoration: TextDecoration.underline,
                            decorationColor: ColorConstant.whiteColor.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DimensionConstant.d20),
                  _GradientSubmitButton(
                    gradientColors: _kLoginGradientColors,
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

/// Inline API / network error (Phase 9) — avoids duplicating the same text in a [SnackBar].
class _LoginApiErrorBanner extends StatelessWidget {
  const _LoginApiErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(DimensionConstant.d12),
        decoration: BoxDecoration(
          color: ColorConstant.redColor.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: ColorConstant.redColor.withValues(alpha: 0.45),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.error_outline,
              color: ColorConstant.redColor,
              size: 20,
            ),
            const SizedBox(width: DimensionConstant.d8),
            Expanded(
              child: Text(
                message,
                style: FontConstant.interNormal(
                  color: ColorConstant.whiteColor.withValues(alpha: 0.95),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientSubmitButton extends StatelessWidget {
  const _GradientSubmitButton({
    required this.gradientColors,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
  });

  final List<Color> gradientColors;
  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: DimensionConstant.d14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: gradientColors,
        ),
      ),
      alignment: Alignment.center,
      child: isLoading
          ? SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: ColorConstant.whiteColor,
              ),
            )
          : Text(
              label,
              style: FontConstant.interNormal(
                color: ColorConstant.whiteColor,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
    );

    if (onPressed == null && !isLoading) {
      return Opacity(opacity: 0.95, child: child);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: child,
      ),
    );
  }
}

// --- Footer ------------------------------------------------------------------------

class _GlobalFooter extends StatelessWidget {
  const _GlobalFooter();

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;
    final small = FontConstant.interNormal(
      color: ColorConstant.whiteColor.withValues(alpha: 0.82),
      fontSize: 12,
    );
    final dim = FontConstant.interNormal(
      color: ColorConstant.whiteColor.withValues(alpha: 0.45),
      fontSize: 12,
    );

    return Material(
      color: const Color(0xFF0A0818),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DimensionConstant.d24,
          vertical: DimensionConstant.d14,
        ),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${StringConstant.copyrightSymbol}$year${StringConstant.loginFooterKthplCrmSuffix}',
                      style: small,
                    ),
                    Text(
                      StringConstant.poweredByZeemoDigitalLine,
                      style: FontConstant.interNormal(
                        color: ColorConstant.whiteColor.withValues(alpha: 0.55),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: null,
                    child: Text(StringConstant.cookies, style: dim),
                  ),
                  Text(StringConstant.loginFooterLinksSeparator, style: dim),
                  TextButton(
                    onPressed: null,
                    child: Text(StringConstant.legalPolicies, style: dim),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(StringConstant.loginAppVersionDisplay, style: small),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
