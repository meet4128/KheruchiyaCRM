import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/font_constant.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widgets/qna_chat/qna_chat_bubble.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widgets/qna_chat/qna_chat_date_separator.dart';
import 'package:travel_crm/features/presentation/purchase_team/bloc/purchase_team_chat/purchase_team_chat_bloc.dart';
import 'package:travel_crm/features/presentation/purchase_team/bloc/purchase_team_chat/purchase_team_chat_event.dart';
import 'package:travel_crm/features/presentation/purchase_team/bloc/purchase_team_chat/purchase_team_chat_state.dart';

class PurchaseTeamMessageList extends StatefulWidget {
  const PurchaseTeamMessageList({super.key});

  @override
  State<PurchaseTeamMessageList> createState() => _PurchaseTeamMessageListState();
}

class _PurchaseTeamMessageListState extends State<PurchaseTeamMessageList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PurchaseTeamChatBloc, PurchaseTeamChatState>(
      listenWhen: (previous, current) =>
          previous.scrollToBottom != current.scrollToBottom ||
          previous.messages.length != current.messages.length,
      listener: (context, state) {
        if (state.scrollToBottom || state.messages.isNotEmpty) {
          _scrollToBottom();
        }
        if (state.scrollToBottom) {
          context
              .read<PurchaseTeamChatBloc>()
              .add(const PurchaseTeamChatScrollToBottomHandled());
        }
      },
      buildWhen: (previous, current) =>
          previous.messages != current.messages ||
          previous.loadStatus != current.loadStatus ||
          previous.errorMessage != current.errorMessage ||
          previous.isRefreshing != current.isRefreshing,
      builder: (context, state) {
        if (state.loadStatus == PurchaseTeamChatStatus.loading && state.messages.isEmpty) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        if (state.loadStatus == PurchaseTeamChatStatus.failure && state.messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.errorMessage ?? StringConstant.qnaChatLoadFailed,
                  textAlign: TextAlign.center,
                  style: FontConstant.interNormal(
                    color: ColorConstant.whiteColor.withValues(alpha: 0.7),
                    fontSize: DimensionConstant.d12,
                  ),
                ),
                const SizedBox(height: DimensionConstant.d12),
                TextButton(
                  onPressed: () => context
                      .read<PurchaseTeamChatBloc>()
                      .add(const PurchaseTeamChatRefreshRequested()),
                  child: const Text(StringConstant.qnaChatRetry),
                ),
              ],
            ),
          );
        }

        if (state.messages.isEmpty) {
          return Center(
            child: Text(
              StringConstant.qnaChatEmpty,
              style: FontConstant.interNormal(
                color: ColorConstant.whiteColor.withValues(alpha: 0.6),
                fontSize: DimensionConstant.d12,
              ),
            ),
          );
        }

        final groups = state.groupedMessages;

        return Stack(
          children: [
            ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: DimensionConstant.d16,
                vertical: DimensionConstant.d12,
              ),
              itemCount: groups.length,
              itemBuilder: (context, groupIndex) {
                final group = groups[groupIndex];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    QnaChatDateSeparator(label: group.label),
                    ...group.messages.map(
                      (message) => Padding(
                        padding: const EdgeInsets.only(bottom: DimensionConstant.d8),
                        child: QnaChatBubble(message: message),
                      ),
                    ),
                  ],
                );
              },
            ),
            if (state.isRefreshing)
              const Positioned(
                top: DimensionConstant.d8,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: DimensionConstant.d20,
                    height: DimensionConstant.d20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
