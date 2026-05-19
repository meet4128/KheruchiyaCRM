import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/font_constant.dart';
import 'package:travel_crm/core/constants/path_constants.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/di/injector.dart';
import 'package:travel_crm/features/presentation/inquiry_management/utils/qna_attachment_pick_util.dart';
import 'package:travel_crm/features/presentation/purchase_team/bloc/purchase_team_chat/purchase_team_chat_bloc.dart';
import 'package:travel_crm/features/presentation/purchase_team/bloc/purchase_team_chat/purchase_team_chat_event.dart';
import 'package:travel_crm/features/presentation/purchase_team/bloc/purchase_team_directory/purchase_team_directory_bloc.dart';
import 'package:travel_crm/features/presentation/purchase_team/bloc/purchase_team_directory/purchase_team_directory_event.dart';
import 'package:travel_crm/features/presentation/purchase_team/bloc/purchase_team_directory/purchase_team_directory_state.dart';
import 'package:travel_crm/features/presentation/purchase_team/models/messages_route_args.dart';
import 'package:travel_crm/features/presentation/purchase_team/models/purchase_team_member_ui.dart';
import 'package:travel_crm/features/presentation/purchase_team/widgets/purchase_team_chat_pane.dart';
import 'package:travel_crm/features/presentation/purchase_team/widgets/purchase_team_member_list.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key, this.routeArgs});

  final MessagesRouteArgs? routeArgs;

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late final PurchaseTeamDirectoryBloc _directoryBloc;
  late final PurchaseTeamChatBloc _chatBloc;

  @override
  void initState() {
    super.initState();
    final inquiryId = widget.routeArgs?.inquiryId;
    _directoryBloc = sl<PurchaseTeamDirectoryBloc>()
      ..add(PurchaseTeamDirectoryStarted(inquiryId: inquiryId));
    _chatBloc = sl<PurchaseTeamChatBloc>();
  }

  @override
  void dispose() {
    _directoryBloc.close();
    _chatBloc.close();
    super.dispose();
  }

  void _onMemberTap(BuildContext context, String memberId) {
    final directoryState = _directoryBloc.state;
    _directoryBloc.add(PurchaseTeamDirectoryMemberSelected(memberId));

    final inquiryId = directoryState.inquiryId;
    if (inquiryId == null || inquiryId.isEmpty) return;

    PurchaseTeamMemberUi? member;
    for (final m in directoryState.members) {
      if (m.purchaseTeamMemberId == memberId) {
        member = m;
        break;
      }
    }
    if (member == null) return;

    _chatBloc.add(
      PurchaseTeamChatMemberSelected(
        inquiryId: inquiryId,
        member: member,
      ),
    );
  }

  Future<void> _onAttach(BuildContext context) async {
    final attachment = await pickQnaChatAttachment();
    if (attachment == null) return;

    _chatBloc.add(
      PurchaseTeamChatAttachmentPicked(
        fileName: attachment.fileName,
        filePath: attachment.filePath,
        bytes: attachment.bytes,
      ),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${attachment.fileName} — tap send to upload')),
      );
    }
  }

  void _onBack(BuildContext context) {
    final args = widget.routeArgs;
    if (args != null && args.canReturnToInquiry) {
      final path = args.returnToPath!;
      final row = args.returnVendorRow;
      if (row != null) {
        context.go(path, extra: row);
      } else {
        context.go(path);
      }
      return;
    }
    context.go(PathConstant.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.routeArgs;
    final hasInquiry = args?.hasInquiry ?? false;
    final inquiryLabel = args?.inquiryDisplayNo;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _directoryBloc),
        BlocProvider.value(value: _chatBloc),
      ],
      child: Scaffold(
        backgroundColor: ColorConstant.inquiryManagementBgColor,
        body: Padding(
          padding: const EdgeInsets.all(DimensionConstant.d25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _MessagesHeader(
                inquiryLabel: inquiryLabel,
                returnLabel: args?.returnToLabel,
                onBack: () => _onBack(context),
              ),
              const SizedBox(height: DimensionConstant.d16),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 900;
                    final pane = Container(
                      decoration: BoxDecoration(
                        color: ColorConstant.cardBgColor,
                        borderRadius: BorderRadius.circular(DimensionConstant.d4),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: PurchaseTeamChatPane(
                        hasInquiry: hasInquiry,
                        inquiryDisplayNo: inquiryLabel,
                        onAttachTap: () => _onAttach(context),
                      ),
                    );

                    final listPane = Container(
                      decoration: BoxDecoration(
                        color: ColorConstant.cardBgColor,
                        borderRadius: BorderRadius.circular(DimensionConstant.d4),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: PurchaseTeamMemberList(
                        onMemberTap: (id) => _onMemberTap(context, id),
                      ),
                    );

                    if (wide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(width: 320, child: listPane),
                          const SizedBox(width: DimensionConstant.d16),
                          Expanded(child: pane),
                        ],
                      );
                    }

                    return BlocBuilder<PurchaseTeamDirectoryBloc, PurchaseTeamDirectoryState>(
                      buildWhen: (p, c) => p.selectedMemberId != c.selectedMemberId,
                      builder: (context, dirState) {
                        if (dirState.selectedMemberId != null && hasInquiry) {
                          return Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: () {
                                    _directoryBloc.add(
                                      const PurchaseTeamDirectoryMemberSelected(''),
                                    );
                                    _chatBloc.add(const PurchaseTeamChatCleared());
                                  },
                                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                                  label: Text(
                                    StringConstant.messagesBackToMembers,
                                    style: FontConstant.interNormal(
                                      color: ColorConstant.whiteColor,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(child: pane),
                            ],
                          );
                        }
                        return listPane;
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessagesHeader extends StatelessWidget {
  const _MessagesHeader({
    required this.onBack,
    this.inquiryLabel,
    this.returnLabel,
  });

  final VoidCallback onBack;
  final String? inquiryLabel;
  final String? returnLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          tooltip: returnLabel ?? StringConstant.messagesBack,
        ),
        Text(
          StringConstant.messagesTitle,
          style: FontConstant.interBold(
            color: ColorConstant.whiteColor,
            fontSize: DimensionConstant.d20,
          ),
        ),
        if (inquiryLabel != null && inquiryLabel!.isNotEmpty) ...[
          const SizedBox(width: DimensionConstant.d12),
          Text(
            '• $inquiryLabel',
            style: FontConstant.interNormal(
              color: ColorConstant.whiteColor.withValues(alpha: 0.65),
              fontSize: DimensionConstant.d14,
            ),
          ),
        ],
      ],
    );
  }
}
