import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/font_constant.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/amendment_card/amendment_card_cubit.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/amendment_card/amendment_card_state.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/amendment_card_body_ui.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widget/custom_check_box.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widget/sub_category_details.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widgets/amendment/amendment_card_message_thread.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AmendmentCardExpandedBody extends StatelessWidget {
  const AmendmentCardExpandedBody({
    super.key,
    required this.titleColor,
  });

  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AmendmentCardCubit, AmendmentCardState>(
      builder: (context, state) {
        final body = state.body;
        if (body == null) {
          return const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _MetadataRows(body: body, titleColor: titleColor),
            if (body.invoiceDownloadUrl != null) ...[
              const SizedBox(height: DimensionConstant.d16),
              Text(
                '${StringConstant.downloadAmendmentInvoice}: ${body.invoiceDownloadUrl}',
                style: FontConstant.interMedium(
                  color: ColorConstant.subTitleGreenColor,
                  fontSize: DimensionConstant.d12,
                ),
              ),
            ],
            if (state.noteTexts.isNotEmpty) ...[
              const SizedBox(height: DimensionConstant.d20),
              Text(
                StringConstant.amendmentCardNotesTitle,
                style: FontConstant.interMedium(
                  color: titleColor,
                  fontSize: DimensionConstant.d12,
                ),
              ),
              const SizedBox(height: DimensionConstant.d8),
              ...state.noteTexts.map(
                (note) => Padding(
                  padding: const EdgeInsets.only(bottom: DimensionConstant.d6),
                  child: Text(
                    '• $note',
                    style: FontConstant.interNormal(
                      color: ColorConstant.whiteColor,
                      fontSize: DimensionConstant.d12,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: DimensionConstant.d25),
            AmendmentCardMessageThread(
              messages: state.messages,
              isLoading: state.loadStatus == AmendmentCardLoadStatus.loading,
              errorMessage: state.errorMessage,
            ),
          ],
        );
      },
    );
  }

}

class _MetadataRows extends StatelessWidget {
  const _MetadataRows({
    required this.body,
    required this.titleColor,
  });

  final AmendmentCardBodyUi body;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SubCategoryDetails(
              title: StringConstant.raisedBy,
              subTitle: body.raisedBy,
              titleColor: titleColor,
              subTitleColor: ColorConstant.whiteColor,
            ),
            SubCategoryDetails(
              title: StringConstant.bookedBy,
              subTitle: body.bookedBy,
              titleColor: titleColor,
              subTitleColor: ColorConstant.whiteColor,
            ),
            SubCategoryDetails(
              title: StringConstant.assignedStaff,
              subTitle: body.assignedStaff,
              titleColor: titleColor,
              subTitleColor: ColorConstant.subTitleGreenColor,
            ),
            SubCategoryDetails(
              title: StringConstant.amendmentInvoice,
              subTitle: body.amendmentInvoice,
              titleColor: titleColor,
              subTitleColor: ColorConstant.subTitleGreenColor,
            ),
            SubCategoryDetails(
              title: StringConstant.remarks,
              subTitle: body.remarks,
              titleColor: titleColor,
              subTitleColor: ColorConstant.whiteColor,
            ),
          ],
        ),
        const SizedBox(height: DimensionConstant.d25),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
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
                  if (body.checklistItems.isEmpty)
                    Text(
                      'N/A',
                      style: FontConstant.interNormal(
                        color: ColorConstant.whiteColor,
                        fontSize: DimensionConstant.d12,
                      ),
                    )
                  else
                    Wrap(
                      spacing: DimensionConstant.d25,
                      runSpacing: DimensionConstant.d12,
                      children: body.checklistItems
                          .map(
                            (item) => Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomOutlineCheckbox(
                                  value: item.isChecked,
                                  onChanged: (_) {},
                                ),
                                const SizedBox(width: DimensionConstant.d12),
                                Text(
                                  item.label,
                                  style: FontConstant.interMedium(
                                    color: ColorConstant.whiteColor,
                                    fontSize: DimensionConstant.d12,
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
            SubCategoryDetails(
              title: StringConstant.nextTravelDate,
              subTitle: body.nextTravelDate,
              titleColor: titleColor,
              subTitleColor: ColorConstant.whiteColor,
            ),
            SubCategoryDetails(
              title: 'Processed Time',
              subTitle: body.processedTime,
              titleColor: titleColor,
              subTitleColor: ColorConstant.whiteColor,
            ),
            SubCategoryDetails(
              title: 'Generation Time',
              subTitle: body.generationTime,
              titleColor: titleColor,
              subTitleColor: ColorConstant.whiteColor,
            ),
          ],
        ),
      ],
    );
  }
}
