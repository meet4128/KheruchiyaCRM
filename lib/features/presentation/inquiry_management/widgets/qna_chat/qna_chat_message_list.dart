import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/font_constant.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/qna_chat/qna_chat_bloc.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/qna_chat/qna_chat_event.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/qna_chat/qna_chat_state.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/qna_chat_message.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widgets/qna_chat/qna_chat_bubble.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widgets/qna_chat/qna_chat_date_separator.dart';

class QnaChatMessageList extends StatefulWidget {
  const QnaChatMessageList({super.key});

  @override
  State<QnaChatMessageList> createState() => _QnaChatMessageListState();
}

class _QnaChatMessageListState extends State<QnaChatMessageList> {
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
    return BlocConsumer<QnaChatBloc, QnaChatState>(
      listenWhen: (previous, current) =>
          previous.scrollToBottom != current.scrollToBottom ||
          previous.messages.length != current.messages.length,
      listener: (context, state) {
        if (state.scrollToBottom || state.messages.isNotEmpty) {
          _scrollToBottom();
        }
        if (state.scrollToBottom) {
          context.read<QnaChatBloc>().add(const QnaChatScrollToBottomHandled());
        }
      },
      buildWhen: (previous, current) =>
          previous.messages != current.messages ||
          previous.loadStatus != current.loadStatus ||
          previous.errorMessage != current.errorMessage,
      builder: (context, state) {
        if (state.loadStatus == QnaChatStatus.loading && state.messages.isEmpty) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        if (state.loadStatus == QnaChatStatus.failure && state.messages.isEmpty) {
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
                  onPressed: () =>
                      context.read<QnaChatBloc>().add(const QnaChatRefreshRequested()),
                  child: Text(StringConstant.qnaChatRetry),
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
                color: ColorConstant.whiteColor.withValues(alpha: 0.5),
                fontSize: DimensionConstant.d12,
              ),
            ),
          );
        }

        final groups = state.groupedMessages;
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(
            horizontal: DimensionConstant.d16,
            vertical: DimensionConstant.d12,
          ),
          itemCount: _itemCount(groups),
          itemBuilder: (context, index) => _buildItem(groups, index),
        );
      },
    );
  }

  int _itemCount(List<QnaChatDateGroup> groups) {
    var count = 0;
    for (final group in groups) {
      count += 1 + group.messages.length;
    }
    return count;
  }

  Widget _buildItem(List<QnaChatDateGroup> groups, int index) {
    var cursor = 0;
    for (final group in groups) {
      if (index == cursor) {
        return QnaChatDateSeparator(label: group.label);
      }
      cursor++;
      for (final message in group.messages) {
        if (index == cursor) {
          return QnaChatBubble(message: message);
        }
        cursor++;
      }
    }
    return const SizedBox.shrink();
  }
}
