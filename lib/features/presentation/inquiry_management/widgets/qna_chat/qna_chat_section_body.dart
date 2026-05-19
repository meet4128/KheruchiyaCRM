import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/qna_chat/qna_chat_bloc.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/qna_chat/qna_chat_event.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/qna_chat/qna_chat_state.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widgets/qna_chat/qna_chat_bottom_action_bar.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widgets/qna_chat/qna_chat_composer.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widgets/qna_chat/qna_chat_finalize_bar.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widgets/qna_chat/qna_chat_message_list.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widgets/qna_chat/qna_chat_quick_actions.dart';

/// Figma §2.2 — chat viewport, composer, finalize (live only), quick + bottom bars.
class QnaChatSectionBody extends StatelessWidget {
  const QnaChatSectionBody({
    super.key,
    required this.onAttachTap,
    required this.onFinalizeAction,
    this.onTalkToPurchaseTeam,
    this.isFinalizeSubmitting = false,
    this.viewportHeight = 440,
  });

  final VoidCallback onAttachTap;
  final void Function(String action) onFinalizeAction;
  final VoidCallback? onTalkToPurchaseTeam;
  final bool isFinalizeSubmitting;
  final double viewportHeight;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QnaChatBloc, QnaChatState>(
      buildWhen: (p, c) =>
          p.isInnerExpanded != c.isInnerExpanded ||
          p.showFinalizeBar != c.showFinalizeBar ||
          p.hasSession != c.hasSession,
      builder: (context, state) {
        if (!state.isInnerExpanded) return const SizedBox.shrink();

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: viewportHeight,
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<QnaChatBloc>().add(const QnaChatRefreshRequested());
                  await Future<void>.delayed(const Duration(milliseconds: 400));
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: ColorConstant.cardBgColor,
                    borderRadius: BorderRadius.circular(DimensionConstant.d4),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: const QnaChatMessageList(),
                ),
              ),
            ),
            QnaChatComposer(onAttachTap: onAttachTap),
            if (state.showFinalizeBar) ...[
              const SizedBox(height: DimensionConstant.d20),
              QnaChatFinalizeBar(
                onAction: onFinalizeAction,
                onTalkToPurchaseTeam: onTalkToPurchaseTeam,
                isSubmitting: isFinalizeSubmitting,
              ),
              const SizedBox(height: DimensionConstant.d20),
              QnaChatQuickActions(
                onAddNotes: state.hasSession ? () => _promptAddNote(context) : null,
              ),
              const SizedBox(height: DimensionConstant.d20),
              const QnaChatBottomActionBar(),
            ],
          ],
        );
      },
    );
  }

  Future<void> _promptAddNote(BuildContext context) async {
    final chatState = context.read<QnaChatBloc>().state;
    if (!chatState.hasSession) return;

    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ColorConstant.cardBgColor,
        title: const Text('Add note'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (text != null && text.trim().isNotEmpty && context.mounted) {
      context.read<QnaChatBloc>().add(QnaChatAddNoteRequested(text.trim()));
    }
  }
}
