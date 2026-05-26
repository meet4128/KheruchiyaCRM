import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/asset_constants.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/widgets/auth/auth_brand_pane.dart';
import 'package:travel_crm/core/widgets/auth/auth_constants.dart';
import 'package:travel_crm/core/widgets/auth/auth_global_footer.dart';

/// Common layout for every public-auth screen: gradient brand pane on the
/// left, full-bleed background image with a translucent overlay on the right
/// (where the caller's form card lives), and the shared footer pinned to
/// the bottom.
///
/// Below [kAuthWideBreakpoint] we collapse to a stacked, scrollable layout so
/// narrow viewports still render usable.
class AuthPageScaffold extends StatelessWidget {
  const AuthPageScaffold({
    super.key,
    required this.card,
    this.cardMaxWidth = 440,
  });

  /// The form / content card that should sit centred on the right pane.
  final Widget card;

  /// Optional override for the form-card's max width. Default mirrors the
  /// original login card.
  final double cardMaxWidth;

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
                final wide = constraints.maxWidth >= kAuthWideBreakpoint;
                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 2,
                        child: AuthBrandPane(height: constraints.maxHeight),
                      ),
                      Expanded(
                        flex: 3,
                        child: _AuthImagePane(
                          height: constraints.maxHeight,
                          card: card,
                        ),
                      ),
                    ],
                  );
                }
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 260,
                          child: AuthBrandPane(height: 260),
                        ),
                        _AuthImagePane(height: 520, card: card),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const AuthGlobalFooter(),
        ],
      ),
    );
  }
}

class _AuthImagePane extends StatelessWidget {
  const _AuthImagePane({required this.height, required this.card});

  final double height;
  final Widget card;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
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
            child: card,
          ),
        ),
      ),
    );
  }
}
