import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/font_constant.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/qna_chat_message.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widgets/qna_chat/qna_chat_document_bubble_content.dart';

/// Incoming (question) = left gray; outgoing (answer) = right purple.
class QnaChatBubble extends StatelessWidget {
  const QnaChatBubble({super.key, required this.message});

  final QnaChatMessage message;

  static const Color _incomingBubbleColor = Color(0xFF35353D);

  @override
  Widget build(BuildContext context) {
    final isQuestion = message.isQuestion;
    final bubbleColor = isQuestion ? _incomingBubbleColor : ColorConstant.purpleBrown;
    final align = isQuestion ? Alignment.centerLeft : Alignment.centerRight;
    final maxWidth = MediaQuery.sizeOf(context).width * 0.72;

    return Align(
      alignment: align,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          margin: const EdgeInsets.only(bottom: DimensionConstant.d10),
          padding: const EdgeInsets.fromLTRB(
            DimensionConstant.d12,
            DimensionConstant.d10,
            DimensionConstant.d12,
            DimensionConstant.d8,
          ),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(DimensionConstant.d8),
              topRight: const Radius.circular(DimensionConstant.d8),
              bottomLeft: Radius.circular(isQuestion ? DimensionConstant.d2 : DimensionConstant.d8),
              bottomRight: Radius.circular(isQuestion ? DimensionConstant.d8 : DimensionConstant.d2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _MessageBody(message: message),
              const SizedBox(height: DimensionConstant.d4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  formatQnaChatTime(message.createdAt),
                  style: FontConstant.interNormal(
                    color: ColorConstant.whiteColor.withValues(alpha: 0.45),
                    fontSize: DimensionConstant.d10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBody extends StatelessWidget {
  const _MessageBody({required this.message});

  final QnaChatMessage message;

  @override
  Widget build(BuildContext context) {
    if (message.isDocument) {
      return QnaChatDocumentBubbleContent(message: message);
    }

    return SelectableText(
      message.body,
      style: FontConstant.interNormal(
        color: ColorConstant.whiteColor,
        fontSize: DimensionConstant.d12,
        height: message.contentType == QnaChatMessageContentType.structured ? 1.45 : 1.35,
      ),
    );
  }
}
