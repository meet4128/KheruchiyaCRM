import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/font_constant.dart';
import 'package:travel_crm/features/presentation/purchase_team/models/purchase_team_member_ui.dart';

class PurchaseTeamMemberTile extends StatelessWidget {
  const PurchaseTeamMemberTile({
    super.key,
    required this.member,
    required this.isSelected,
    required this.onTap,
  });

  final PurchaseTeamMemberUi member;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? ColorConstant.navyBlue.withValues(alpha: 0.35)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DimensionConstant.d16,
            vertical: DimensionConstant.d12,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: DimensionConstant.d20,
                backgroundColor: ColorConstant.navyBlue,
                child: Text(
                  member.initials,
                  style: FontConstant.interBold(
                    color: ColorConstant.whiteColor,
                    fontSize: DimensionConstant.d12,
                  ),
                ),
              ),
              const SizedBox(width: DimensionConstant.d12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FontConstant.interBold(
                        color: ColorConstant.whiteColor,
                        fontSize: DimensionConstant.d14,
                      ),
                    ),
                    if (member.designation.isNotEmpty) ...[
                      const SizedBox(height: DimensionConstant.d2),
                      Text(
                        member.designation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FontConstant.interNormal(
                          color: ColorConstant.whiteColor.withValues(alpha: 0.65),
                          fontSize: DimensionConstant.d12,
                        ),
                      ),
                    ],
                    if (member.hasThreadPreview) ...[
                      const SizedBox(height: DimensionConstant.d4),
                      Text(
                        member.lastMessagePreview!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FontConstant.interNormal(
                          color: ColorConstant.whiteColor.withValues(alpha: 0.5),
                          fontSize: DimensionConstant.d12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
