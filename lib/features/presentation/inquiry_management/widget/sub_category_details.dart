import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/font_constant.dart';

class SubCategoryDetails extends StatelessWidget {
  final String title, subTitle;
  final Color titleColor, subTitleColor;

  const SubCategoryDetails({
    super.key,
    required this.title,
    required this.subTitle,
    required this.titleColor,
    required this.subTitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: FontConstant.interMedium(color: titleColor, fontSize: DimensionConstant.d12),
          ),
          const SizedBox(height: DimensionConstant.d10),
          Text(
            subTitle,
            style: FontConstant.interMedium(color: subTitleColor, fontSize: DimensionConstant.d12),
          ),
        ],
      ),
    );
  }
}
