import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:travel_crm/core/constants/asset_constants.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/font_constant.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/theme/app_theme.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widget/custom_check_box.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widget/sub_category_details.dart';

class AmendmentInfoCard extends StatefulWidget {
  const AmendmentInfoCard({super.key});

  @override
  State<AmendmentInfoCard> createState() => _AmendmentInfoCardState();
}

class _AmendmentInfoCardState extends State<AmendmentInfoCard> {
  late final colors = AppTheme.colors(context);

  Color get titleColor => ColorConstant.whiteColor.withValues(alpha: .5);
  final ExpansibleController _controller = ExpansibleController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorConstant.card1BgColor,
      width: double.infinity,
      child: Padding(
        padding: _controller.isExpanded
            ? EdgeInsets.symmetric(
                horizontal: DimensionConstant.d25,
                vertical: DimensionConstant.d30,
              )
            : EdgeInsets.only(
                right: DimensionConstant.d25,
                left: DimensionConstant.d25,
                top: DimensionConstant.d30,
                // bottom: DimensionConstant.d30,
              ),
        child: Expansible(
          controller: _controller,
          headerBuilder: (BuildContext context, Animation<double> animation) {
            return InkWell(
              onTap: () {
                (_controller.isExpanded) ? _controller.collapse() : _controller.expand();
                setState(() {});
              },
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
                        subTitle: StringConstant.reIssue,
                        titleColor: titleColor,
                        subTitleColor: ColorConstant.whiteColor,
                      ),
                      SubCategoryDetails(
                        title: StringConstant.amendmentID,
                        subTitle: 'TAIR59789876',
                        titleColor: titleColor,
                        subTitleColor: ColorConstant.whiteColor,
                      ),
                      SubCategoryDetails(
                        title: StringConstant.status,
                        subTitle: 'Completed',
                        titleColor: titleColor,
                        subTitleColor: ColorConstant.subTitleGreenColor,
                      ),
                      SubCategoryDetails(
                        title: StringConstant.amountCharged,
                        subTitle: '₹19,999/-',
                        titleColor: titleColor,
                        subTitleColor: ColorConstant.subTitleGreenColor,
                      ),
                      SubCategoryDetails(
                        title: StringConstant.attachments,
                        subTitle: 'N/A',
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
          bodyBuilder: (BuildContext context, Animation<double> animation) {
            return Column(
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        SubCategoryDetails(
                          title: StringConstant.raisedBy,
                          subTitle: StringConstant.reIssue,
                          titleColor: titleColor,
                          subTitleColor: ColorConstant.whiteColor,
                        ),
                        SubCategoryDetails(
                          title: StringConstant.bookedBy,
                          subTitle: 'TAIR59789876',
                          titleColor: titleColor,
                          subTitleColor: ColorConstant.whiteColor,
                        ),
                        SubCategoryDetails(
                          title: StringConstant.assignedStaff,
                          subTitle: 'Completed',
                          titleColor: titleColor,
                          subTitleColor: ColorConstant.subTitleGreenColor,
                        ),
                        SubCategoryDetails(
                          title: StringConstant.amendmentInvoice,
                          subTitle: '₹19,999/-',
                          titleColor: titleColor,
                          subTitleColor: ColorConstant.subTitleGreenColor,
                        ),
                        SubCategoryDetails(
                          title: StringConstant.remarks,
                          subTitle: 'N/A',
                          titleColor: titleColor,
                          subTitleColor: ColorConstant.whiteColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: DimensionConstant.d25),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 113,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SubCategoryDetails(
                                  title: StringConstant.raisedBy,
                                  subTitle: StringConstant.reIssue,
                                  titleColor: titleColor,
                                  subTitleColor: ColorConstant.whiteColor,
                                ),
                                const SizedBox(height: DimensionConstant.d25),
                                SubCategoryDetails(
                                  title: StringConstant.bookedBy,
                                  subTitle: 'TAIR59789876',
                                  titleColor: titleColor,
                                  subTitleColor: ColorConstant.whiteColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                StringConstant.checklist,
                                style: FontConstant.interMedium(
                                  color: titleColor,
                                  fontSize: DimensionConstant.d12,
                                ),
                              ),
                              const SizedBox(height: DimensionConstant.d10),

                              /// Checklist items with custom checkboxes
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: DimensionConstant.d12,
                                children: [
                                  Row(
                                    spacing: DimensionConstant.d25,
                                    children: [
                                      Row(
                                        children: [
                                          CustomOutlineCheckbox(value: true, onChanged: (_) {}),
                                          const SizedBox(width: DimensionConstant.d12),
                                          Text(
                                            StringConstant.inLoop,
                                            style: FontConstant.interMedium(
                                              color: ColorConstant.whiteColor,
                                              fontSize: DimensionConstant.d12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          CustomOutlineCheckbox(value: true, onChanged: (_) {}),
                                          const SizedBox(width: DimensionConstant.d12),
                                          Text(
                                            StringConstant.inLoop,
                                            style: FontConstant.interMedium(
                                              color: ColorConstant.whiteColor,
                                              fontSize: DimensionConstant.d12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    spacing: DimensionConstant.d25,
                                    children: [
                                      Row(
                                        children: [
                                          CustomOutlineCheckbox(value: true, onChanged: (_) {}),
                                          const SizedBox(width: DimensionConstant.d12),
                                          Text(
                                            StringConstant.inLoop,
                                            style: FontConstant.interMedium(
                                              color: ColorConstant.whiteColor,
                                              fontSize: DimensionConstant.d12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          CustomOutlineCheckbox(value: true, onChanged: (_) {}),
                                          const SizedBox(width: DimensionConstant.d12),
                                          Text(
                                            StringConstant.inLoop,
                                            style: FontConstant.interMedium(
                                              color: ColorConstant.whiteColor,
                                              fontSize: DimensionConstant.d12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      CustomOutlineCheckbox(value: true, onChanged: (_) {}),
                                      const SizedBox(width: DimensionConstant.d12),
                                      Text(
                                        StringConstant.inLoop,
                                        style: FontConstant.interMedium(
                                          color: ColorConstant.whiteColor,
                                          fontSize: DimensionConstant.d12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SubCategoryDetails(
                          title: StringConstant.nextTravelDate,
                          subTitle: 'N/A',
                          titleColor: titleColor,
                          subTitleColor: ColorConstant.whiteColor,
                        ),
                        SubCategoryDetails(
                          title: StringConstant.emptyString,
                          subTitle: StringConstant.emptyString,
                          titleColor: titleColor,
                          subTitleColor: ColorConstant.whiteColor,
                        ),
                        SubCategoryDetails(
                          title: StringConstant.emptyString,
                          subTitle: StringConstant.emptyString,
                          titleColor: ColorConstant.whiteColor,
                          subTitleColor: ColorConstant.whiteColor,
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: DimensionConstant.d25),
                  child: Divider(color: ColorConstant.whiteColor.withValues(alpha: .3)),
                ),

                /// Bottom action bar
                Align(
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
                            InkWell(
                              onTap: () {},
                              child: Padding(
                                padding: const EdgeInsets.all(DimensionConstant.d15),
                                child: Center(
                                  child: Text(
                                    StringConstant.addNotes,
                                    textAlign: TextAlign.center,
                                    style: FontConstant.interMedium(
                                      color: ColorConstant.whiteColor,
                                      fontSize: DimensionConstant.d12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            VerticalDivider(color: ColorConstant.borderColorWhite30),

                            InkWell(
                              onTap: () {},
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(DimensionConstant.d15),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(AssetConstants.icCall),
                                      const SizedBox(width: DimensionConstant.d6),
                                      Text(
                                        StringConstant.text,
                                        textAlign: TextAlign.center,
                                        style: FontConstant.interMedium(
                                          color: ColorConstant.whiteColor,
                                          fontSize: DimensionConstant.d12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            VerticalDivider(color: ColorConstant.borderColorWhite30),
                            InkWell(
                              onTap: () {},
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: DimensionConstant.d15,
                                  ),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(AssetConstants.icMessageText),
                                      const SizedBox(width: DimensionConstant.d6),
                                      Text(
                                        StringConstant.callAgent,
                                        textAlign: TextAlign.center,
                                        style: FontConstant.interMedium(
                                          color: ColorConstant.whiteColor,
                                          fontSize: DimensionConstant.d12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
