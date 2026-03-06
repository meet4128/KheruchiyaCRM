import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:travel_crm/core/constants/asset_constants.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/font_constant.dart';
import 'package:travel_crm/core/widgets/inquiry_management_items.dart';
import 'package:travel_crm/di/injector.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/inquiry_management_bloc.dart';
import 'package:travel_crm/features/presentation/inquiry_management/view/vendor_list_view.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widget/amendment_info_card.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widget/inquiry_information.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widget/qna_notes.dart';

class InquiryManagementScreen extends StatefulWidget {
  const InquiryManagementScreen({super.key});

  @override
  State<InquiryManagementScreen> createState() => _InquiryManagementScreenState();
}

class _InquiryManagementScreenState extends State<InquiryManagementScreen> {
  final InquiryManagementBloc _inquiryManagementBloc = sl<InquiryManagementBloc>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _inquiryManagementBloc,
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          backgroundColor: ColorConstant.inquiryManagementBgColor,
          body: Padding(
            padding: const EdgeInsets.all(DimensionConstant.d25),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  /// Card Header 1
                  Container(
                    color: ColorConstant.cardBgColor,
                    width: double.infinity,
                    height: DimensionConstant.d133,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _hierarchyHeader(
                              title: 'Inquiry Management',
                              icon: AssetConstants.icRightArrow,
                            ),
                            _hierarchyHeader(title: 'Pending ', icon: AssetConstants.icRightArrow),
                            _hierarchyHeader(
                              title: '#85913 - Hardik Kheruchiya',
                              color: ColorConstant.whiteColor,
                            ),
                            const Spacer(),
                            Text(
                              'Refresh',
                              style: FontConstant.interMedium(
                                fontSize: DimensionConstant.d16,
                                color: ColorConstant.whiteColor,
                              ),
                            ),
                            const SizedBox(width: DimensionConstant.d15),
                            InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const VendorListView()));
                              },
                              child: Container(
                                height: DimensionConstant.d30,
                                width: DimensionConstant.d30,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [ColorConstant.purple, ColorConstant.indigo],
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(DimensionConstant.d7),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      AssetConstants.icRepeat,
                                      height: DimensionConstant.d24,
                                      width: DimensionConstant.d24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: DimensionConstant.d25),
                        StatusBar(),
                      ],
                    ),
                  ),
                  const SizedBox(height: DimensionConstant.d25),

                  /// Card Body 1
                  InquiryInformation(),
                  const SizedBox(height: DimensionConstant.d10),
                  AmendmentInfoCard(),
                  const SizedBox(height: DimensionConstant.d10),
                  AmendmentInfoCard(),
                  const SizedBox(height: DimensionConstant.d10),
                  AmendmentInfoCard(),
                  const SizedBox(height: DimensionConstant.d10),
                  AmendmentInfoCard(),
                  const SizedBox(height: DimensionConstant.d10),
                  QnaNotes(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _hierarchyHeader({required String title, String? icon, Color? color}) {
    return Row(
      children: [
        Text(
          title,
          style: FontConstant.interMedium(
            fontSize: DimensionConstant.d16,
            color: color ?? ColorConstant.whiteColor.withValues(alpha: DimensionConstant.d0_5),
          ),
        ),
        if (icon != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DimensionConstant.d13),
            child: SvgPicture.asset(
              icon,
              height: DimensionConstant.d24,
              width: DimensionConstant.d24,
            ),
          ),
      ],
    );
  }
}
