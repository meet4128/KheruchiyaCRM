import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/font_constant.dart';

/// Inline error banner used by every auth form to surface API / network
/// failures without duplicating the message inside a [SnackBar].
///
/// Wrapped in a [Semantics] live region so screen readers announce the
/// failure when it appears.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message});

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
