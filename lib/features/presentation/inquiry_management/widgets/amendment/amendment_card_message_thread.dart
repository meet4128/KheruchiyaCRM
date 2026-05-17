import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/font_constant.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/qna_chat_message.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widgets/qna_chat/qna_chat_bubble.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widgets/qna_chat/qna_chat_date_separator.dart';

/// Read-only message thread for [AmendmentInfoCard] expanded body.
class AmendmentCardMessageThread extends StatelessWidget {
  const AmendmentCardMessageThread({
    super.key,
    required this.messages,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<QnaChatMessage> messages;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (isLoading && messages.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (errorMessage != null && messages.isEmpty) {
      return Text(
        errorMessage!,
        style: FontConstant.interNormal(
          color: ColorConstant.redColor,
          fontSize: DimensionConstant.d12,
        ),
      );
    }

    if (messages.isEmpty) {
      return Text(
        StringConstant.qnaChatEmpty,
        style: FontConstant.interNormal(
          color: ColorConstant.whiteColor.withValues(alpha: 0.5),
          fontSize: DimensionConstant.d12,
        ),
      );
    }

    final groups = groupQnaChatMessagesByDate(messages);
    return Container(
      height: 280,
      decoration: BoxDecoration(color: ColorConstant.cardBgColor),
      child: ListView(
        padding: const EdgeInsets.all(DimensionConstant.d12),
        children: [
          for (final group in groups) ...[
            QnaChatDateSeparator(label: group.label),
            for (final m in group.messages) QnaChatBubble(message: m),
          ],
        ],
      ),
    );
  }
}
