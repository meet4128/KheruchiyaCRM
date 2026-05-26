import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/font_constant.dart';
import 'package:travel_crm/core/constants/string_constants.dart';

/// Persistent dark footer used by every public-auth screen.
///
/// Shows copyright + "powered by" on the left, legal links in the centre, and
/// the app version on the right. Decoupled from any specific screen so we can
/// drop it into the new public flows without re-implementing the layout.
class AuthGlobalFooter extends StatelessWidget {
  const AuthGlobalFooter({super.key});

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
