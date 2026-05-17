import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:travel_crm/core/constants/asset_constants.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/font_constant.dart';
import 'package:travel_crm/core/constants/string_constants.dart';

class QnaChatQuickActions extends StatelessWidget {
  const QnaChatQuickActions({
    super.key,
    this.onAddNotes,
    this.onText,
    this.onCallAgent,
  });

  final VoidCallback? onAddNotes;
  final VoidCallback? onText;
  final VoidCallback? onCallAgent;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: IntrinsicHeight(
        child: IntrinsicWidth(
          child: Container(
            decoration: BoxDecoration(
              color: ColorConstant.blackColor,
              borderRadius: BorderRadius.circular(DimensionConstant.d4),
              border: Border.all(color: ColorConstant.borderColorWhite30),
            ),
            child: Row(
              children: [
                _item(StringConstant.addNotes, onAddNotes),
                const VerticalDivider(color: ColorConstant.borderColorWhite30),
                _item(StringConstant.text, onText, icon: AssetConstants.icCall),
                const VerticalDivider(color: ColorConstant.borderColorWhite30),
                _item(
                  StringConstant.callAgent,
                  onCallAgent,
                  icon: AssetConstants.icMessageText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(String label, VoidCallback? onTap, {String? icon}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(DimensionConstant.d15),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              SvgPicture.asset(icon, width: DimensionConstant.d16, height: DimensionConstant.d16),
              const SizedBox(width: DimensionConstant.d6),
            ],
            Text(
              label,
              style: FontConstant.interMedium(
                color: ColorConstant.whiteColor,
                fontSize: DimensionConstant.d12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
