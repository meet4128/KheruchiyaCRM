import 'package:flutter/material.dart';
import 'color_constants.dart';
import 'dimension_constant.dart';

class FontConstant {
  static const String poppinsFont = 'Poppins';
  static const String interFont = 'Inter';

  /// Poppins Font Styles
  static TextStyle poppinsLight({
    Color color = ColorConstant.singInTextColor,
    FontWeight fontWeight = FontWeight.w300,
    FontStyle fontStyle = FontStyle.normal,
    double? fontSize,
    double? height,
    TextDecoration? textDecoration,
  }) {
    return TextStyle(
      color: color,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      fontSize: fontSize ?? (DimensionConstant.d14),
      height: height,
      decoration: textDecoration,
      fontFamily: poppinsFont,
    );
  }

  static TextStyle poppinsNormal({
    Color color = ColorConstant.singInTextColor,
    FontWeight fontWeight = FontWeight.normal,
    FontStyle fontStyle = FontStyle.normal,
    double? fontSize,
    double? height,
    TextDecoration? textDecoration,
    Color? decorationColor,
  }) {
    return TextStyle(
      color: color,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      fontSize: fontSize ?? (DimensionConstant.d14),
      height: height,
      fontFamily: poppinsFont,
      decoration: textDecoration,
      decorationColor: decorationColor,
    );
  }

  static TextStyle poppinsSemiBold({
    Color color = ColorConstant.singInTextColor,
    FontWeight fontWeight = FontWeight.w500,
    FontStyle fontStyle = FontStyle.normal,
    double? fontSize,
    double? height,
    TextDecoration? textDecoration,
  }) {
    return TextStyle(
      color: color,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      fontSize: fontSize ?? (DimensionConstant.d14),
      height: height,
      fontFamily: poppinsFont,
      decoration: textDecoration,
    );
  }

  static TextStyle poppinsBold({
    Color color = ColorConstant.singInTextColor,
    FontWeight fontWeight = FontWeight.w600,
    FontStyle fontStyle = FontStyle.normal,
    double? fontSize,
    double? height,
    TextDecoration? textDecoration,
  }) {
    return TextStyle(
      color: color,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      fontSize: fontSize ?? (DimensionConstant.d14),
      height: height,
      fontFamily: poppinsFont,
      decoration: textDecoration,
    );
  }

  static TextStyle poppinsExtraBold({
    Color color = ColorConstant.singInTextColor,
    FontWeight fontWeight = FontWeight.w700,
    FontStyle fontStyle = FontStyle.normal,
    double? fontSize,
    double? height,
    TextDecoration? textDecoration,
  }) {
    return TextStyle(
      color: color,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      fontSize: fontSize ?? (DimensionConstant.d14),
      height: height,
      fontFamily: poppinsFont,
      decoration: textDecoration,
    );
  }

  /// Inter Font Styles
  static TextStyle interNormal({
    Color color = ColorConstant.singInTextColor,
    FontWeight fontWeight = FontWeight.normal, // 400
    FontStyle fontStyle = FontStyle.normal,
    double? fontSize,
    double? height,
    TextDecoration? textDecoration,
    Color? decorationColor,
  }) {
    return TextStyle(
      color: color,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      fontSize: fontSize ?? (DimensionConstant.d14),
      height: height,
      fontFamily: interFont,
      decoration: textDecoration,
      decorationColor: decorationColor,
    );
  }

  static TextStyle interMedium({
    Color color = ColorConstant.singInTextColor,
    FontWeight fontWeight = FontWeight.w500, // 500
    FontStyle fontStyle = FontStyle.normal,
    double? fontSize,
    double? height,
    TextDecoration? textDecoration,
  }) {
    return TextStyle(
      color: color,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      fontSize: fontSize ?? (DimensionConstant.d14),
      height: height,
      fontFamily: interFont,
      decoration: textDecoration,
    );
  }

  static TextStyle interSemiBold({
    Color color = ColorConstant.singInTextColor,
    FontWeight fontWeight = FontWeight.w600, // 600
    FontStyle fontStyle = FontStyle.normal,
    double? fontSize,
    double? height,
    TextDecoration? textDecoration,
  }) {
    return TextStyle(
      color: color,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      fontSize: fontSize ?? (DimensionConstant.d14),
      height: height,
      fontFamily: interFont,
      decoration: textDecoration,
    );
  }

  static TextStyle interBold({
    Color color = ColorConstant.singInTextColor,
    FontWeight fontWeight = FontWeight.w700, // 700
    FontStyle fontStyle = FontStyle.normal,
    double? fontSize,
    double? height,
    TextDecoration? textDecoration,
  }) {
    return TextStyle(
      color: color,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      fontSize: fontSize ?? (DimensionConstant.d14),
      height: height,
      fontFamily: interFont,
      decoration: textDecoration,
    );
  }
}
