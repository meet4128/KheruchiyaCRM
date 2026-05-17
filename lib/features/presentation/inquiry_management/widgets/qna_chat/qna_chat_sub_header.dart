import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:travel_crm/core/constants/asset_constants.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/font_constant.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/qna_chat/qna_chat_bloc.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/qna_chat/qna_chat_event.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/qna_chat/qna_chat_state.dart';

class QnaChatSubHeader extends StatelessWidget {
  const QnaChatSubHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QnaChatBloc, QnaChatState>(
      buildWhen: (p, c) =>
          p.isInnerExpanded != c.isInnerExpanded || p.amendmentType != c.amendmentType,
      builder: (context, state) {
        return Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [ColorConstant.purple, ColorConstant.indigo],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DimensionConstant.d25,
                  vertical: DimensionConstant.d15,
                ),
                child: Row(
                  children: [
                    Text(
                      StringConstant.questionAndAnswer,
                      style: FontConstant.interMedium(
                        color: ColorConstant.whiteColor,
                        fontSize: DimensionConstant.d16,
                      ),
                    ),
                    const Spacer(),
                    _AmendmentTypeDropdown(selected: state.amendmentType),
                    const SizedBox(width: DimensionConstant.d25),
                    InkWell(
                      onTap: () => context
                          .read<QnaChatBloc>()
                          .add(const QnaChatInnerExpansionToggled()),
                      child: state.isInnerExpanded
                          ? SvgPicture.asset(AssetConstants.icUpRoundArrow)
                          : RotatedBox(
                              quarterTurns: DimensionConstant.i2,
                              child: SvgPicture.asset(AssetConstants.icUpRoundArrow),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            if (!state.isInnerExpanded)
              Padding(
                padding: const EdgeInsets.only(bottom: DimensionConstant.d15),
                child: Divider(color: ColorConstant.whiteColor.withValues(alpha: 0.3)),
              ),
          ],
        );
      },
    );
  }
}

class _AmendmentTypeDropdown extends StatelessWidget {
  const _AmendmentTypeDropdown({this.selected});

  final String? selected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: StringConstant.amendmentType,
      color: ColorConstant.cardBgColor,
      onSelected: (value) {
        context.read<QnaChatBloc>().add(QnaChatAmendmentTypeChanged(value));
      },
      itemBuilder: (context) => [
        ...StringConstant.qnaChatAmendmentTypeOptions.map(
          (o) => PopupMenuItem<String>(
            value: o,
            child: Text(
              o,
              style: FontConstant.interNormal(
                color: ColorConstant.whiteColor,
                fontSize: DimensionConstant.d13,
              ),
            ),
          ),
        ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: StringConstant.amendmentType,
                  style: FontConstant.interNormal(
                    color: ColorConstant.whiteColor,
                    fontSize: DimensionConstant.d14,
                  ),
                ),
                TextSpan(
                  text: StringConstant.asterisk,
                  style: FontConstant.interNormal(
                    color: ColorConstant.asteriskRedColor,
                    fontSize: DimensionConstant.d14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: DimensionConstant.d8),
          Text(
            selected ?? 'Select',
            style: FontConstant.interNormal(
              color: ColorConstant.whiteColor.withValues(alpha: 0.85),
              fontSize: DimensionConstant.d12,
            ),
          ),
          const SizedBox(width: DimensionConstant.d6),
          SvgPicture.asset(
            AssetConstants.icArrowRight,
            height: DimensionConstant.d8,
            width: DimensionConstant.d8,
          ),
        ],
      ),
    );
  }
}
