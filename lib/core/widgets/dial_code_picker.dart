import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';

/// Reusable dial code picker widget
/// Can be used across different screens for phone number inputs
class DialCodePicker extends StatelessWidget {
  const DialCodePicker({
    super.key,
    required this.dialCode,
    required this.onChanged,
    this.favoriteCodes,
    this.showFlag,
    this.textStyle,
    this.dialogTextStyle,
    this.searchStyle,
    this.barrierColor,
  });

  final String dialCode;
  final ValueChanged<String> onChanged;
  final List<String>? favoriteCodes;
  final bool? showFlag;
  final TextStyle? textStyle;
  final TextStyle? dialogTextStyle;
  final TextStyle? searchStyle;
  final Color? barrierColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161424),
        borderRadius: BorderRadius.circular(DimensionConstant.d12),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: DimensionConstant.d6),
      child: CountryCodePicker(
        initialSelection: dialCode,
        favorite: favoriteCodes ?? const ['+91', '+1', '+44'],
        showFlag: showFlag ?? false,
        textStyle: textStyle ?? const TextStyle(color: Colors.white),
        dialogTextStyle:
            dialogTextStyle ?? const TextStyle(color: Colors.white),
        searchStyle: searchStyle ?? const TextStyle(color: Colors.white),
        barrierColor: barrierColor ?? Colors.black.withOpacity(0.7),
        onChanged: (code) => onChanged(code.dialCode ?? dialCode),
        padding: EdgeInsets.zero,
      ),
    );
  }
}














