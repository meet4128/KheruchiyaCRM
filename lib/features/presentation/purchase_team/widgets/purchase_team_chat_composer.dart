import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/font_constant.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widgets/qna_chat/qna_chat_attachment_preview.dart';
import 'package:travel_crm/features/presentation/purchase_team/bloc/purchase_team_chat/purchase_team_chat_bloc.dart';
import 'package:travel_crm/features/presentation/purchase_team/bloc/purchase_team_chat/purchase_team_chat_event.dart';
import 'package:travel_crm/features/presentation/purchase_team/bloc/purchase_team_chat/purchase_team_chat_state.dart';

class PurchaseTeamChatComposer extends StatefulWidget {
  const PurchaseTeamChatComposer({
    super.key,
    required this.onAttachTap,
    this.enabled = true,
  });

  final VoidCallback onAttachTap;
  final bool enabled;

  @override
  State<PurchaseTeamChatComposer> createState() => _PurchaseTeamChatComposerState();
}

class _PurchaseTeamChatComposerState extends State<PurchaseTeamChatComposer> {
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
    return BlocConsumer<PurchaseTeamChatBloc, PurchaseTeamChatState>(
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
          previous.pendingAttachment != current.pendingAttachment,
      builder: (context, state) {
        final sending = state.sendStatus == PurchaseTeamChatSendStatus.sending;
        final hasDraft = state.messageDraft.trim().isNotEmpty;
        final hasAttachment = state.hasPendingAttachment;
        final canSend = widget.enabled && !sending && (hasDraft || hasAttachment);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasAttachment && state.pendingAttachment != null)
              QnaChatAttachmentPreview(
                fileName: state.pendingAttachment!.fileName,
                onClear: () => context
                    .read<PurchaseTeamChatBloc>()
                    .add(const PurchaseTeamChatAttachmentCleared()),
              ),
            if (state.sendErrorMessage != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: DimensionConstant.d16),
                child: Text(
                  state.sendErrorMessage!,
                  style: FontConstant.interNormal(
                    color: Colors.redAccent,
                    fontSize: DimensionConstant.d12,
                  ),
                ),
              ),
              const SizedBox(height: DimensionConstant.d4),
            ],
            Container(
              color: ColorConstant.cardBgColor,
              padding: const EdgeInsets.symmetric(
                horizontal: DimensionConstant.d12,
                vertical: DimensionConstant.d8,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: widget.enabled && !sending ? widget.onAttachTap : null,
                    icon: Icon(
                      Icons.attach_file,
                      color: widget.enabled
                          ? ColorConstant.whiteColor
                          : ColorConstant.whiteColor.withValues(alpha: 0.3),
                    ),
                    tooltip: StringConstant.qnaChatAttach,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: widget.enabled && !sending,
                      onChanged: (value) => context
                          .read<PurchaseTeamChatBloc>()
                          .add(PurchaseTeamChatMessageDraftChanged(value)),
                      style: FontConstant.interNormal(color: ColorConstant.whiteColor),
                      decoration: InputDecoration(
                        hintText: StringConstant.typeYourMessageHere,
                        hintStyle: FontConstant.interNormal(
                          color: ColorConstant.whiteColor.withValues(alpha: 0.45),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      minLines: 1,
                      maxLines: 4,
                      onSubmitted: canSend
                          ? (_) => context
                              .read<PurchaseTeamChatBloc>()
                              .add(const PurchaseTeamChatSendPressed())
                          : null,
                    ),
                  ),
                  IconButton(
                    onPressed: canSend
                        ? () => context
                            .read<PurchaseTeamChatBloc>()
                            .add(const PurchaseTeamChatSendPressed())
                        : null,
                    icon: sending
                        ? const SizedBox(
                            width: DimensionConstant.d20,
                            height: DimensionConstant.d20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            Icons.send,
                            color: canSend
                                ? ColorConstant.subTitleGreenColor
                                : ColorConstant.whiteColor.withValues(alpha: 0.3),
                          ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
