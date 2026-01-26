import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:travel_crm/core/constants/asset_constants.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/font_constant.dart';
import 'package:travel_crm/core/constants/string_constants.dart';

class QnaNotes extends StatefulWidget {
  const QnaNotes({super.key});

  @override
  State<QnaNotes> createState() => _QnaNotesState();
}

class _QnaNotesState extends State<QnaNotes> {
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
                        StringConstant.qnaNotes,
                        style: FontConstant.interNormal(
                          color: ColorConstant.whiteColor,
                          fontSize: DimensionConstant.d16,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () {},
                        child: Container(
                          decoration: BoxDecoration(
                            color: ColorConstant.blackColor,
                            border: Border.all(color: ColorConstant.borderColorWhite30),
                            borderRadius: BorderRadius.circular(DimensionConstant.d6),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(DimensionConstant.d15),
                            child: Center(
                              child: Text(
                                StringConstant.addNewNotes,
                                style: FontConstant.interNormal(
                                  color: ColorConstant.whiteColor,
                                  fontSize: DimensionConstant.d12,
                                ),
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
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [ColorConstant.purple, ColorConstant.indigo],
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: DimensionConstant.d15,
                            horizontal: DimensionConstant.d25,
                          ),
                          child: Row(
                            children: [
                              Text(
                                StringConstant.questions,
                                style: FontConstant.interMedium(
                                  color: ColorConstant.whiteColor,
                                  fontSize: DimensionConstant.d16,
                                ),
                              ),
                              const Spacer(),
                              InkWell(
                                onTap: () {},
                                child: Row(
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
                                    SvgPicture.asset(
                                      AssetConstants.icArrowRight,
                                      height: DimensionConstant.d8,
                                      width: DimensionConstant.d8,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: DimensionConstant.d25),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [ColorConstant.purple, ColorConstant.indigo],
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: DimensionConstant.d15,
                            horizontal: DimensionConstant.d25,
                          ),
                          child: Text(
                            StringConstant.answers,
                            style: FontConstant.interMedium(
                              color: ColorConstant.whiteColor,
                              fontSize: DimensionConstant.d16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DimensionConstant.d15),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: ColorConstant.cardBgColor),
                  child: Padding(
                    padding: EdgeInsets.all(DimensionConstant.d20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(color: ColorConstant.qnaCard1BgColor),
                            child: Padding(
                              padding: const EdgeInsets.all(DimensionConstant.d10),
                              child: Text(
                                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec auctor, metus ac ultrices dignissim, justo libero dictum  sapien, non pharetra felis purus sit amet libero. Vestibulum magna dui, semper nec fringilla eu, egestas non lectus.  Suspendisse potenti. Cras laoreet vestibulum volutpat.',
                                style: FontConstant.interNormal(
                                  color: ColorConstant.whiteColor,
                                  fontSize: DimensionConstant.d12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: DimensionConstant.d25),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(color: ColorConstant.qnaCard1BgColor),
                            child: Padding(
                              padding: const EdgeInsets.all(DimensionConstant.d10),
                              child: Text(
                                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec auctor, metus ac ultrices dignissim, justo libero dictum  sapien, non pharetra felis purus sit amet libero. Vestibulum magna dui, semper nec fringilla eu, egestas non lectus.  Suspendisse potenti. Cras laoreet vestibulum volutpat.',
                                style: FontConstant.interNormal(
                                  color: ColorConstant.whiteColor,
                                  fontSize: DimensionConstant.d12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: DimensionConstant.d25),
                  child: Divider(color: ColorConstant.whiteColor.withValues(alpha: .3)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
