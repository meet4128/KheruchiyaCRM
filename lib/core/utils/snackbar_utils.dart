import 'package:flutter/material.dart';

import '../constants/color_constants.dart';
import '../constants/dimension_constant.dart';
import '../constants/font_constant.dart';

class SnackBarUtils {
  /// Show success SnackBar with green background
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ColorConstant.addBtnGreenColor,
        content: Text(message, style: FontConstant.poppinsBold(fontSize: DimensionConstant.d20, color: ColorConstant.whiteColor)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show error SnackBar with red background
  static void showError(BuildContext context, String message) {
    // Don't show snackbar for empty messages (404 errors)
    if (message.isEmpty) {
      return;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ColorConstant.redColor,
        content: Text(message, style: FontConstant.poppinsBold(fontSize: DimensionConstant.d20, color: ColorConstant.whiteColor)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Show warning SnackBar with orange/yellow background
  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ColorConstant.orangeColor,
        content: Text(message, style: FontConstant.poppinsBold(fontSize: DimensionConstant.d20, color: ColorConstant.whiteColor)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show info SnackBar with blue background
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ColorConstant.logInBtnColor,
        content: Text(message, style: FontConstant.poppinsBold(fontSize: DimensionConstant.d20, color: ColorConstant.whiteColor)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show custom SnackBar with custom background color
  static void showCustom(BuildContext context, String message, {Color? backgroundColor, Color? textColor, Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor ?? ColorConstant.logInBtnColor,
        content: Text(
          message,
          style: FontConstant.poppinsBold(fontSize: DimensionConstant.d20, color: textColor ?? ColorConstant.whiteColor),
        ),
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }
}
