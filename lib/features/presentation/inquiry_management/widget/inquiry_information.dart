import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:travel_crm/core/constants/asset_constants.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/font_constant.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widget/overlapping_avatar.dart';

class InquiryInformation extends StatefulWidget {
  const InquiryInformation({super.key});

  @override
  State<InquiryInformation> createState() => _InquiryInformationState();
}

class _InquiryInformationState extends State<InquiryInformation> {
  final ExpansibleController _controller = ExpansibleController();

  final List<String> peopleImages = [
    "https://images.unsplash.com/photo-1494790108377-be9c29b29330",
    "https://images.unsplash.com/photo-1500648767791-00dcc994a43e",
    "https://images.unsplash.com/photo-1531123897727-8f129e1688ce",
  ];

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
                        StringConstant.inquiryInformation,
                        style: FontConstant.interNormal(
                          color: ColorConstant.whiteColor,
                          fontSize: DimensionConstant.d16,
                        ),
                      ),
                      Text(
                        ' #85913',
                        style: FontConstant.interNormal(
                          color: ColorConstant.inquiryInfoTxtColor,
                          fontSize: DimensionConstant.d16,
                        ),
                      ),
                      const Spacer(),

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
                                          StringConstant.allTicketBookings,
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
                                        child: Text(
                                          StringConstant.allInvoices,
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
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: DimensionConstant.d15,
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              StringConstant.moreOptions,
                                              textAlign: TextAlign.center,
                                              style: FontConstant.interMedium(
                                                color: ColorConstant.whiteColor,
                                                fontSize: DimensionConstant.d12,
                                              ),
                                            ),
                                            const SizedBox(width: DimensionConstant.d6),
                                            SvgPicture.asset(
                                              AssetConstants.icArrowRight,
                                              height: DimensionConstant.d16,
                                              width: DimensionConstant.d16,
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
                      const SizedBox(width: DimensionConstant.d25),
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
                      Text(
                        StringConstant.inquiryNumber,
                        style: FontConstant.interNormal(
                          color: ColorConstant.whiteColor.withValues(alpha: .5),
                          fontSize: DimensionConstant.d12,
                        ),
                      ),
                      Text(
                        ' #85913',
                        style: FontConstant.interNormal(
                          color: ColorConstant.whiteColor,
                          fontSize: DimensionConstant.d12,
                        ),
                      ),
                      const SizedBox(width: DimensionConstant.d10),
                      Text(
                        StringConstant.inquiryGenerated,
                        style: FontConstant.interNormal(
                          color: ColorConstant.whiteColor.withValues(alpha: .5),
                          fontSize: DimensionConstant.d12,
                        ),
                      ),
                      Text(
                        ' #17/12/2025 @ 8:50PM',
                        style: FontConstant.interNormal(
                          color: ColorConstant.whiteColor,
                          fontSize: DimensionConstant.d12,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        StringConstant.assignedTo,
                        style: FontConstant.interNormal(
                          color: ColorConstant.whiteColor.withValues(alpha: .5),
                          fontSize: DimensionConstant.d12,
                        ),
                      ),
                      OverlappingAvatars(images: peopleImages),
                      const SizedBox(width: DimensionConstant.d5),
                      Text(
                        'Amit, Jenny & Helly',
                        style: FontConstant.interNormal(
                          color: ColorConstant.whiteColor,
                          fontSize: DimensionConstant.d12,
                        ),
                      ),
                      const SizedBox(width: DimensionConstant.d15),
                      Text(
                        StringConstant.priority,
                        style: FontConstant.interNormal(
                          color: ColorConstant.whiteColor.withValues(alpha: .5),
                          fontSize: DimensionConstant.d12,
                        ),
                      ),
                      const SizedBox(width: DimensionConstant.d5),
                      SvgPicture.asset(
                        AssetConstants.icRedUpArrow,
                        height: DimensionConstant.d16,
                        width: DimensionConstant.d16,
                      ),
                      const SizedBox(width: DimensionConstant.d5),
                      Text(
                        '00:15 min Left',
                        style: FontConstant.interNormal(
                          color: ColorConstant.whiteColor.withValues(alpha: .5),
                          fontSize: DimensionConstant.d12,
                        ),
                      ),
                      const SizedBox(width: DimensionConstant.d15),
                      Text(
                        StringConstant.statusColon,
                        style: FontConstant.interNormal(
                          color: ColorConstant.whiteColor.withValues(alpha: .5),
                          fontSize: DimensionConstant.d12,
                        ),
                      ),
                      const SizedBox(width: DimensionConstant.d5),
                      SvgPicture.asset(
                        AssetConstants.icTimer,
                        height: DimensionConstant.d16,
                        width: DimensionConstant.d16,
                      ),
                      const SizedBox(width: DimensionConstant.d5),
                      Text(
                        StringConstant.inProgress,
                        style: FontConstant.interNormal(
                          color: ColorConstant.whiteColor.withValues(alpha: .5),
                          fontSize: DimensionConstant.d12,
                        ),
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
            return Offstage();
          },
        ),
      ),
    );
  }
}
