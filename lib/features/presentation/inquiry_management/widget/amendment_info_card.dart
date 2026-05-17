import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:travel_crm/core/constants/asset_constants.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/font_constant.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/data/models/inquiry/inquiry_checklist_item.dart';
import 'package:travel_crm/di/injector.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/amendment_card/amendment_card_cubit.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/amendment_card/amendment_card_state.dart';
import 'package:travel_crm/features/presentation/inquiry_management/mappers/amendment_mapper.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/amendment_card_ui.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widget/sub_category_details.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widgets/amendment/amendment_card_expanded_body.dart';

class AmendmentInfoCard extends StatefulWidget {
  const AmendmentInfoCard({
    super.key,
    required this.amendment,
    required this.inquiryId,
    this.inquiryChecklist = const [],
  });

  final AmendmentCardUi amendment;
  final String inquiryId;
  final List<InquiryChecklistItem> inquiryChecklist;

  @override
  State<AmendmentInfoCard> createState() => _AmendmentInfoCardState();
}

class _AmendmentInfoCardState extends State<AmendmentInfoCard> {
  final ExpansibleController _controller = ExpansibleController();
  late final AmendmentCardCubit _cubit;

  Color get titleColor => ColorConstant.whiteColor.withValues(alpha: .5);

  @override
  void initState() {
    super.initState();
    _cubit = AmendmentCardCubit(
      repository: sl(),
      inquiryId: widget.inquiryId,
      summary: widget.amendment,
      inquiryChecklist: widget.inquiryChecklist,
    );
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _toggleExpanded() {
    final willExpand = !_controller.isExpanded;
    if (willExpand) {
      _controller.expand();
      _cubit.loadExpandedContent();
    } else {
      _controller.collapse();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Container(
        color: ColorConstant.card1BgColor,
        width: double.infinity,
        child: Padding(
          padding: _controller.isExpanded
              ? const EdgeInsets.symmetric(
                  horizontal: DimensionConstant.d25,
                  vertical: DimensionConstant.d30,
                )
              : const EdgeInsets.only(
                  left: DimensionConstant.d25,
                  right: DimensionConstant.d25,
                  top: DimensionConstant.d30,
                ),
          child: Expansible(
            controller: _controller,
            headerBuilder: (context, animation) {
              return BlocBuilder<AmendmentCardCubit, AmendmentCardState>(
                buildWhen: (p, c) => p.body?.attachmentsDisplay != c.body?.attachmentsDisplay,
                builder: (context, cardState) {
                  final attachments = cardState.body?.attachmentsDisplay ?? 'N/A';

                  return InkWell(
                    onTap: _toggleExpanded,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              StringConstant.amendmentInformation,
                              style: FontConstant.interNormal(
                                color: ColorConstant.whiteColor,
                                fontSize: DimensionConstant.d16,
                              ),
                            ),
                            const Spacer(),
                            _controller.isExpanded
                                ? SvgPicture.asset(AssetConstants.icUpRoundArrow)
                                : RotatedBox(
                                    quarterTurns: DimensionConstant.i2,
                                    child: SvgPicture.asset(AssetConstants.icUpRoundArrow),
                                  ),
                          ],
                        ),
                        const SizedBox(height: DimensionConstant.d25),
                        Row(
                          children: [
                            SubCategoryDetails(
                              title: StringConstant.amendmentType,
                              subTitle: widget.amendment.amendmentTypeLabel,
                              titleColor: titleColor,
                              subTitleColor: ColorConstant.whiteColor,
                            ),
                            SubCategoryDetails(
                              title: StringConstant.amendmentID,
                              subTitle: widget.amendment.amendmentId.isEmpty
                                  ? '—'
                                  : widget.amendment.amendmentId,
                              titleColor: titleColor,
                              subTitleColor: ColorConstant.whiteColor,
                            ),
                            SubCategoryDetails(
                              title: StringConstant.status,
                              subTitle: widget.amendment.statusLabel,
                              titleColor: titleColor,
                              subTitleColor: amendmentStatusIsSuccess(widget.amendment.status)
                                  ? ColorConstant.subTitleGreenColor
                                  : ColorConstant.whiteColor,
                            ),
                            SubCategoryDetails(
                              title: StringConstant.amountCharged,
                              subTitle: widget.amendment.amountChargedDisplay,
                              titleColor: titleColor,
                              subTitleColor: widget.amendment.amountCharged != null
                                  ? ColorConstant.subTitleGreenColor
                                  : ColorConstant.whiteColor,
                            ),
                            SubCategoryDetails(
                              title: StringConstant.attachments,
                              subTitle: attachments,
                              titleColor: titleColor,
                              subTitleColor: ColorConstant.whiteColor,
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: DimensionConstant.d25),
                          child: Divider(color: ColorConstant.whiteColor.withValues(alpha: .3)),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            bodyBuilder: (context, animation) {
              return Column(
                children: [
                  AmendmentCardExpandedBody(titleColor: titleColor),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: DimensionConstant.d25),
                    child: Divider(color: ColorConstant.whiteColor.withValues(alpha: .3)),
                  ),
                  _CardQuickActions(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CardQuickActions extends StatelessWidget {
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
                _stub(StringConstant.addNotes),
                VerticalDivider(color: ColorConstant.borderColorWhite30),
                _stub(StringConstant.text, icon: AssetConstants.icCall),
                VerticalDivider(color: ColorConstant.borderColorWhite30),
                _stub(StringConstant.callAgent, icon: AssetConstants.icMessageText),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stub(String label, {String? icon}) {
    return Padding(
      padding: const EdgeInsets.all(DimensionConstant.d15),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            SvgPicture.asset(icon),
            const SizedBox(width: DimensionConstant.d6),
          ],
          Text(
            label,
            style: FontConstant.interMedium(
              color: ColorConstant.whiteColor.withValues(alpha: 0.5),
              fontSize: DimensionConstant.d12,
            ),
          ),
        ],
      ),
    );
  }
}
