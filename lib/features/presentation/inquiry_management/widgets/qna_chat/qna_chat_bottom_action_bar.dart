import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:travel_crm/core/constants/asset_constants.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/font_constant.dart';
import 'package:travel_crm/core/constants/string_constants.dart';

/// Figma bottom bar — stub actions in v1.
class QnaChatBottomActionBar extends StatelessWidget {
  const QnaChatBottomActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      ('User', AssetConstants.icUser),
      ('Due Date', AssetConstants.icCalendar),
      ('Set Priority', AssetConstants.icRefresh),
      ('Attachment', AssetConstants.icSetting),
      ('In Loop', AssetConstants.icUser),
      ('Set Follow Up', AssetConstants.icRefresh),
    ];

    return Container(
      height: DimensionConstant.d50,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(DimensionConstant.d8),
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: _node(
                label: items[i].$1,
                icon: items[i].$2,
                isLast: false,
              ),
            ),
          Expanded(
            child: _submitNode(),
          ),
        ],
      ),
    );
  }

  Widget _node({
    required String label,
    required String icon,
    required bool isLast,
  }) {
    return Container(
      height: DimensionConstant.d50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(icon, width: DimensionConstant.d16, height: DimensionConstant.d16),
          const SizedBox(width: DimensionConstant.d6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FontConstant.interNormal(
                color: ColorConstant.whiteColor,
                fontSize: DimensionConstant.d12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitNode() {
    return Container(
      height: DimensionConstant.d50,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [ColorConstant.purple, ColorConstant.indigo],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        StringConstant.submit,
        style: FontConstant.interNormal(
          color: ColorConstant.whiteColor,
          fontSize: DimensionConstant.d12,
        ),
      ),
    );
  }
}
