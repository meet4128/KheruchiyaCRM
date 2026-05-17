import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widgets/qna_chat/qna_chat_composer.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widgets/qna_chat/qna_chat_message_list.dart';

/// Chat viewport (fixed height) + composer — screenshot 2 body.
class QnaChatSectionBody extends StatelessWidget {
  const QnaChatSectionBody({
    super.key,
    required this.onAttachTap,
    this.viewportHeight = 440,
  });

  final VoidCallback onAttachTap;
  final double viewportHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: viewportHeight,
          decoration: BoxDecoration(
            color: ColorConstant.cardBgColor,
            borderRadius: BorderRadius.circular(DimensionConstant.d4),
          ),
          clipBehavior: Clip.antiAlias,
          child: const QnaChatMessageList(),
        ),
        QnaChatComposer(onAttachTap: onAttachTap),
      ],
    );
  }
}
