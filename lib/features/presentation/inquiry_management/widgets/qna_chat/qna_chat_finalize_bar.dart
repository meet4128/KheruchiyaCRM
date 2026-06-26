import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/font_constant.dart';
import 'package:travel_crm/core/constants/string_constants.dart';

typedef FinalizeActionCallback = void Function(String action);

/// Figma §2.2.3 — live [QnaNotes] only.
class QnaChatFinalizeBar extends StatelessWidget {
  const QnaChatFinalizeBar({
    super.key,
    required this.onAction,
    this.onTalkToPurchaseTeam,
    this.isSubmitting = false,
    this.canMarkWon = false,
  });

  final FinalizeActionCallback onAction;
  final VoidCallback? onTalkToPurchaseTeam;
  final bool isSubmitting;

  /// Whether "Mark as Won" is allowed — only once the received amount matches
  /// the total amount to be received.
  final bool canMarkWon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: DimensionConstant.d50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DimensionConstant.d4),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          _cell(
            title: StringConstant.qnaGetPersonalDocumentDetails,
            color: Colors.black,
            onTap: () {},
          ),
          _cell(
            title: StringConstant.qnaTalkToPurchaseTeam,
            color: ColorConstant.navyBlue,
            onTap: isSubmitting ? null : onTalkToPurchaseTeam,
          ),
          _cell(
            title: StringConstant.qnaPutFollowUp,
            color: ColorConstant.navyBlue,
            onTap: isSubmitting ? null : () => onAction('put_follow_up'),
          ),
          _cell(
            title: StringConstant.qnaMarkAsPending,
            color: ColorConstant.purpleBrown,
            onTap: isSubmitting ? null : () => onAction('mark_pending'),
          ),
          _cell(
            title: StringConstant.qnaMarkAsLoss,
            color: ColorConstant.purpleViolet,
            onTap: isSubmitting ? null : () => onAction('mark_loss'),
          ),
          _cell(
            title: StringConstant.qnaMarkAsWon,
            color: ColorConstant.subTitleGreenColor,
            textColor: Colors.black,
            enabled: canMarkWon,
            onTap: (isSubmitting || !canMarkWon) ? null : () => onAction('mark_won'),
          ),
        ],
      ),
    );
  }

  Widget _cell({
    required String title,
    required Color color,
    required VoidCallback? onTap,
    Color textColor = ColorConstant.whiteColor,
    bool enabled = true,
  }) {
    return Expanded(
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Material(
          color: color,
          child: InkWell(
            onTap: onTap,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: DimensionConstant.d8),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                ),
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: FontConstant.interNormal(
                  color: textColor,
                  fontSize: DimensionConstant.d12,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
