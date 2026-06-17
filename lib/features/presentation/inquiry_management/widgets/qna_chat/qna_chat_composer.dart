import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/font_constant.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/qna_chat/qna_chat_bloc.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/qna_chat/qna_chat_event.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/qna_chat/qna_chat_state.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widgets/qna_chat/qna_chat_attachment_preview.dart';

class QnaChatComposer extends StatefulWidget {
  const QnaChatComposer({
    super.key,
    required this.onAttachTap,
  });

  final VoidCallback onAttachTap;

  @override
  State<QnaChatComposer> createState() => _QnaChatComposerState();
}

class _QnaChatComposerState extends State<QnaChatComposer> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QnaChatBloc, QnaChatState>(
      listenWhen: (previous, current) => previous.messageDraft != current.messageDraft,
      listener: (context, state) {
        if (_controller.text != state.messageDraft) {
          _controller.value = TextEditingValue(
            text: state.messageDraft,
            selection: TextSelection.collapsed(offset: state.messageDraft.length),
          );
        }
      },
      buildWhen: (previous, current) =>
          previous.messageDraft != current.messageDraft ||
          previous.sendStatus != current.sendStatus ||
          previous.sendErrorMessage != current.sendErrorMessage ||
          previous.amendmentType != current.amendmentType ||
          previous.pendingAttachment != current.pendingAttachment ||
          previous.showTemplateComposer != current.showTemplateComposer ||
          previous.templatePreviewText != current.templatePreviewText,
      builder: (context, state) {
        final sending = state.sendStatus == QnaChatSendStatus.sending;
        final hasDraft = state.messageDraft.trim().isNotEmpty;
        final hasAttachment = state.hasPendingAttachment;
        final templateMode = state.showTemplateComposer;
        final canSend = state.hasValidPeerPhone &&
            !sending &&
            (templateMode || hasDraft || hasAttachment);
        final canCompose = state.hasValidPeerPhone && !sending && !templateMode;

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DimensionConstant.d12,
            vertical: DimensionConstant.d10,
          ),
          decoration: const BoxDecoration(
            color: ColorConstant.card1BgColor,
            border: Border(
              top: BorderSide(color: ColorConstant.borderColorWhite30),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!state.hasValidPeerPhone)
                Padding(
                  padding: const EdgeInsets.only(bottom: DimensionConstant.d8),
                  child: Text(
                    StringConstant.qnaChatPhoneUnavailable,
                    style: FontConstant.interNormal(
                      color: ColorConstant.redColor.withValues(alpha: 0.9),
                      fontSize: DimensionConstant.d12,
                    ),
                  ),
                ),
              if (state.amendmentType != null && state.amendmentType!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: DimensionConstant.d8),
                  child: Text(
                    '${StringConstant.amendmentType}: ${state.amendmentType}',
                    style: FontConstant.interNormal(
                      color: ColorConstant.whiteColor.withValues(alpha: 0.65),
                      fontSize: DimensionConstant.d12,
                    ),
                  ),
                ),
              if (!templateMode && state.pendingAttachment != null)
                QnaChatAttachmentPreview(
                  fileName: state.pendingAttachment!.fileName,
                  onClear: () => context
                      .read<QnaChatBloc>()
                      .add(const QnaChatAttachmentCleared()),
                ),
              if (state.sendErrorMessage != null && state.sendErrorMessage!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: DimensionConstant.d8),
                  child: Text(
                    state.sendErrorMessage!,
                    style: FontConstant.interNormal(
                      color: ColorConstant.redColor.withValues(alpha: 0.95),
                      fontSize: DimensionConstant.d12,
                    ),
                  ),
                ),
              if (templateMode)
                _TemplateComposerRow(
                  previewText: state.templatePreviewText,
                  sending: sending,
                  canSend: canSend,
                )
              else
                _NormalComposerRow(
                  controller: _controller,
                  canCompose: canCompose,
                  canSend: canSend,
                  sending: sending,
                  onAttachTap: widget.onAttachTap,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TemplateComposerRow extends StatelessWidget {
  const _TemplateComposerRow({
    required this.previewText,
    required this.sending,
    required this.canSend,
  });

  final String previewText;
  final bool sending;
  final bool canSend;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DimensionConstant.d14,
              vertical: DimensionConstant.d12,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(DimensionConstant.d8),
              border: Border.all(
                color: ColorConstant.whiteColor.withValues(alpha: 0.12),
              ),
            ),
            child: Text(
              previewText,
              style: FontConstant.interNormal(
                color: ColorConstant.whiteColor.withValues(alpha: 0.85),
                fontSize: DimensionConstant.d13,
              ),
            ),
          ),
        ),
        const SizedBox(width: DimensionConstant.d4),
        IconButton(
          onPressed: canSend
              ? () => context.read<QnaChatBloc>().add(const QnaChatSendPressed())
              : null,
          icon: sending
              ? SizedBox(
                  width: DimensionConstant.d20,
                  height: DimensionConstant.d20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: ColorConstant.whiteColor.withValues(alpha: 0.8),
                  ),
                )
              : Icon(
                  Icons.send_rounded,
                  color: canSend
                      ? ColorConstant.whiteColor
                      : ColorConstant.whiteColor.withValues(alpha: 0.35),
                ),
          tooltip: StringConstant.submit,
        ),
      ],
    );
  }
}

class _NormalComposerRow extends StatelessWidget {
  const _NormalComposerRow({
    required this.controller,
    required this.canCompose,
    required this.canSend,
    required this.sending,
    required this.onAttachTap,
  });

  final TextEditingController controller;
  final bool canCompose;
  final bool canSend;
  final bool sending;
  final VoidCallback onAttachTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        IconButton(
          onPressed: canCompose ? onAttachTap : null,
          icon: Icon(
            Icons.add,
            color: sending
                ? ColorConstant.whiteColor.withValues(alpha: 0.35)
                : ColorConstant.whiteColor,
          ),
          tooltip: sending
              ? StringConstant.qnaChatUploadingDocument
              : StringConstant.qnaChatAttach,
        ),
        Expanded(
          child: TextField(
            controller: controller,
            enabled: canCompose,
            minLines: 1,
            maxLines: 4,
            style: FontConstant.interNormal(
              color: ColorConstant.whiteColor,
              fontSize: DimensionConstant.d13,
            ),
            cursorColor: ColorConstant.whiteColor,
            decoration: InputDecoration(
              hintText: StringConstant.typeYourMessageHere,
              hintStyle: FontConstant.interNormal(
                color: ColorConstant.whiteColor.withValues(alpha: 0.4),
                fontSize: DimensionConstant.d13,
              ),
              filled: true,
              fillColor: Colors.black.withValues(alpha: 0.35),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: DimensionConstant.d14,
                vertical: DimensionConstant.d12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DimensionConstant.d8),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (text) => context
                .read<QnaChatBloc>()
                .add(QnaChatMessageDraftChanged(text)),
            onSubmitted: (_) {
              if (canSend) {
                context.read<QnaChatBloc>().add(const QnaChatSendPressed());
              }
            },
          ),
        ),
        const SizedBox(width: DimensionConstant.d4),
        IconButton(
          onPressed: canSend
              ? () => context.read<QnaChatBloc>().add(const QnaChatSendPressed())
              : null,
          icon: sending
              ? SizedBox(
                  width: DimensionConstant.d20,
                  height: DimensionConstant.d20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: ColorConstant.whiteColor.withValues(alpha: 0.8),
                  ),
                )
              : Icon(
                  Icons.send_rounded,
                  color: canSend
                      ? ColorConstant.whiteColor
                      : ColorConstant.whiteColor.withValues(alpha: 0.35),
                ),
          tooltip: StringConstant.submit,
        ),
      ],
    );
  }
}
