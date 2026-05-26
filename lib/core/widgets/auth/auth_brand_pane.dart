import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/asset_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/widgets/auth/auth_constants.dart';

/// Gradient brand pane used by every public-auth screen.
///
/// Replicates the exact look originally hand-coded inside `login_screen.dart`
/// — gradient fill, two faint concentric arcs, the Kheruchiya word-mark
/// centered horizontally — so the chrome looks pixel-identical across login,
/// forgot-password, set-password, and reset-password.
class AuthBrandPane extends StatelessWidget {
  const AuthBrandPane({super.key, required this.height});

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
              colors: kAuthGradientColors,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: DimensionConstant.d24,
                ),
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
      Rect.fromCenter(
        center: Offset(w * 0.15, h * 0.35),
        width: w * 1.6,
        height: w * 1.6,
      ),
      0.2,
      1.1,
      false,
      stroke,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(w * 0.55, h * 0.55),
        width: w * 1.2,
        height: w * 1.2,
      ),
      2.0,
      1.0,
      false,
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
