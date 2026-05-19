import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/font_constant.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/features/presentation/purchase_team/bloc/purchase_team_chat/purchase_team_chat_bloc.dart';
import 'package:travel_crm/features/presentation/purchase_team/bloc/purchase_team_chat/purchase_team_chat_event.dart';
import 'package:travel_crm/features/presentation/purchase_team/bloc/purchase_team_chat/purchase_team_chat_state.dart';
import 'package:travel_crm/features/presentation/purchase_team/widgets/purchase_team_chat_composer.dart';
import 'package:travel_crm/features/presentation/purchase_team/widgets/purchase_team_message_list.dart';

class PurchaseTeamChatPane extends StatelessWidget {
  const PurchaseTeamChatPane({
    super.key,
    required this.hasInquiry,
    required this.onAttachTap,
    this.inquiryDisplayNo,
  });

  final bool hasInquiry;
  final VoidCallback onAttachTap;
  final String? inquiryDisplayNo;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PurchaseTeamChatBloc, PurchaseTeamChatState>(
      builder: (context, state) {
        if (!hasInquiry) {
          return _placeholder(
            StringConstant.messagesSelectInquiryHint,
            icon: Icons.info_outline,
          );
        }

        if (!state.hasMember) {
          return _placeholder(
            StringConstant.messagesSelectMemberHint,
            icon: Icons.chat_bubble_outline,
          );
        }

        final member = state.member!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DimensionConstant.d16,
                vertical: DimensionConstant.d14,
              ),
              color: ColorConstant.cardBgColor,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.displayName,
                          style: FontConstant.interBold(
                            color: ColorConstant.whiteColor,
                            fontSize: DimensionConstant.d16,
                          ),
                        ),
                        if (member.designation.isNotEmpty)
                          Text(
                            member.designation,
                            style: FontConstant.interNormal(
                              color: ColorConstant.whiteColor.withValues(alpha: 0.65),
                              fontSize: DimensionConstant.d12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (inquiryDisplayNo != null && inquiryDisplayNo!.isNotEmpty)
                    Text(
                      inquiryDisplayNo!,
                      style: FontConstant.interNormal(
                        color: ColorConstant.whiteColor.withValues(alpha: 0.55),
                        fontSize: DimensionConstant.d12,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  context
                      .read<PurchaseTeamChatBloc>()
                      .add(const PurchaseTeamChatRefreshRequested());
                  await Future<void>.delayed(const Duration(milliseconds: 400));
                },
                child: Container(
                  color: ColorConstant.inquiryManagementBgColor,
                  child: const PurchaseTeamMessageList(),
                ),
              ),
            ),
            PurchaseTeamChatComposer(
              onAttachTap: onAttachTap,
              enabled: hasInquiry && state.hasMember,
            ),
          ],
        );
      },
    );
  }

  Widget _placeholder(String message, {required IconData icon}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DimensionConstant.d32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: DimensionConstant.d48,
              color: ColorConstant.whiteColor.withValues(alpha: 0.35),
            ),
            const SizedBox(height: DimensionConstant.d16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: FontConstant.interNormal(
                color: ColorConstant.whiteColor.withValues(alpha: 0.6),
                fontSize: DimensionConstant.d14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
