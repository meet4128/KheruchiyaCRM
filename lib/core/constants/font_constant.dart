import 'package:flutter/material.dart';
import 'color_constants.dart';
import 'dimension_constant.dart';

class FontConstant {
  static const String poppinsFont = 'Poppins';

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
      decorationColor: decorationColor
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
}
