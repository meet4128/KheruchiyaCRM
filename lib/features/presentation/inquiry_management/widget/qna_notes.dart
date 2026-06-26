import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/svg.dart';
import 'package:travel_crm/core/constants/asset_constants.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/font_constant.dart';
import 'package:travel_crm/core/constants/path_constants.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/di/injector.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/inquiry_detail/inquiry_detail_bloc.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/inquiry_detail/inquiry_detail_event.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/inquiry_detail/inquiry_detail_state.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/qna_chat/qna_chat_bloc.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/qna_chat/qna_chat_event.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/qna_chat/qna_chat_state.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widgets/qna_chat/qna_chat_section_body.dart';
import 'package:travel_crm/features/presentation/inquiry_management/utils/qna_attachment_pick_util.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widgets/qna_chat/qna_chat_sub_header.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widgets/follow_up/show_put_follow_up_dialog.dart';
import 'package:travel_crm/features/presentation/purchase_team/models/messages_route_args.dart';

/// Live Q&A — Figma §2.2 (bottom of inquiry detail). Finalize buttons live here only.
class QnaNotes extends StatefulWidget {
  const QnaNotes({
    super.key,
    required this.inquiryId,
    required this.peerPhone,
    this.sessionId,
    this.customerName = '',
    this.bookingType,
  });

  final String inquiryId;
  final String peerPhone;
  final String? sessionId;
  final String customerName;
  final String? bookingType;

  @override
  State<QnaNotes> createState() => _QnaNotesState();
}

class _QnaNotesState extends State<QnaNotes> {
  final ExpansibleController _outerController = ExpansibleController();
  late final QnaChatBloc _chatBloc;
  bool _navigateToMessagesOnFinalize = false;

  @override
  void initState() {
    super.initState();
    _outerController.expand();
    _chatBloc = sl<QnaChatBloc>()
      ..add(
        QnaChatStarted(
          inquiryId: widget.inquiryId,
          peerPhone: widget.peerPhone,
          sessionId: widget.sessionId,
          customerName: widget.customerName,
          bookingType: widget.bookingType,
        ),
      );
  }

  @override
  void didUpdateWidget(covariant QnaNotes oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sessionId != widget.sessionId) {
      _chatBloc.add(QnaChatSessionIdUpdated(widget.sessionId));
    }
    if (oldWidget.peerPhone != widget.peerPhone ||
        oldWidget.inquiryId != widget.inquiryId ||
        oldWidget.customerName != widget.customerName ||
        oldWidget.bookingType != widget.bookingType) {
      _chatBloc.add(
        QnaChatStarted(
          inquiryId: widget.inquiryId,
          peerPhone: widget.peerPhone,
          sessionId: widget.sessionId,
          customerName: widget.customerName,
          bookingType: widget.bookingType,
        ),
      );
    }
  }

  @override
  void dispose() {
    _chatBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _chatBloc,
      child: MultiBlocListener(
        listeners: [
          BlocListener<QnaChatBloc, QnaChatState>(
            listenWhen: (p, c) => p.isSectionExpanded != c.isSectionExpanded,
            listener: (context, state) {
              if (state.isSectionExpanded) {
                _outerController.expand();
              } else {
                _outerController.collapse();
              }
            },
          ),
          BlocListener<QnaChatBloc, QnaChatState>(
            listenWhen: (p, c) => p.sessionId != c.sessionId && c.sessionId != null,
            listener: (context, state) {
              if (state.sessionId != null) {
                context.read<InquiryDetailBloc>().add(
                      InquiryDetailSessionIdAssigned(state.sessionId!),
                    );
              }
            },
          ),
          BlocListener<InquiryDetailBloc, InquiryDetailState>(
            listenWhen: (p, c) => p.activeSessionId != c.activeSessionId,
            listener: (context, state) {
              _chatBloc.add(QnaChatSessionIdUpdated(state.activeSessionId));
            },
          ),
          BlocListener<QnaChatBloc, QnaChatState>(
            listenWhen: (p, c) => p.sendErrorMessage != c.sendErrorMessage && c.sendErrorMessage != null,
            listener: (context, state) {
              _showSnack(context, state.sendErrorMessage!);
            },
          ),
          BlocListener<InquiryDetailBloc, InquiryDetailState>(
            listenWhen: (p, c) =>
                p.finalizeErrorMessage != c.finalizeErrorMessage &&
                c.finalizeErrorMessage != null,
            listener: (context, state) {
              if (_navigateToMessagesOnFinalize) {
                _navigateToMessagesOnFinalize = false;
              }
              _showSnack(context, state.finalizeErrorMessage!);
            },
          ),
          BlocListener<InquiryDetailBloc, InquiryDetailState>(
            listenWhen: (p, c) =>
                _navigateToMessagesOnFinalize &&
                p.finalizeStatus != c.finalizeStatus &&
                c.finalizeStatus == InquiryDetailFinalizeStatus.success,
            listener: (context, state) {
              _navigateToMessagesOnFinalize = false;
              _goToMessages(context, state);
            },
          ),
        ],
        child: BlocBuilder<QnaChatBloc, QnaChatState>(
          buildWhen: (p, c) => p.isSectionExpanded != c.isSectionExpanded,
          builder: (context, chatState) {
            return Container(
              color: ColorConstant.card1BgColor,
              width: double.infinity,
              child: Padding(
                padding: chatState.isSectionExpanded
                    ? const EdgeInsets.symmetric(
                        horizontal: DimensionConstant.d25,
                        vertical: DimensionConstant.d30,
                      )
                    : const EdgeInsets.only(
                        left: DimensionConstant.d25,
                        right: DimensionConstant.d25,
                        top: DimensionConstant.d30,
                      ),
                child: Expansible(
                  controller: _outerController,
                  headerBuilder: (context, animation) => _OuterHeader(
                    isExpanded: chatState.isSectionExpanded,
                    onToggle: () => context
                        .read<QnaChatBloc>()
                        .add(const QnaChatSectionExpansionToggled()),
                    onAddNewNotes: () => _onAddNewNotes(context),
                    canAddNotes: chatState.hasSession,
                  ),
                  bodyBuilder: (context, animation) {
                    return BlocBuilder<InquiryDetailBloc, InquiryDetailState>(
                      buildWhen: (p, c) =>
                          p.finalizeStatus != c.finalizeStatus,
                      builder: (context, detailState) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const QnaChatSubHeader(),
                            QnaChatSectionBody(
                              onAttachTap: () => _onAttach(context),
                              isFinalizeSubmitting:
                                  detailState.finalizeStatus ==
                                      InquiryDetailFinalizeStatus.submitting,
                              onFinalizeAction: (action) =>
                                  _onFinalize(context, action),
                              onTalkToPurchaseTeam: () =>
                                  _onTalkToPurchaseTeam(context),
                              onSetFollowUp: () => _onPutFollowUp(context),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onAttach(BuildContext context) async {
    if (_chatBloc.state.sendStatus == QnaChatSendStatus.sending) return;
    if (_chatBloc.state.showTemplateComposer) return;

    final attachment = await pickQnaChatAttachment();
    if (attachment == null) return;

    _chatBloc.add(
      QnaChatAttachmentPicked(
        fileName: attachment.fileName,
        filePath: attachment.filePath,
        bytes: attachment.bytes,
      ),
    );

    if (context.mounted) {
      _showSnack(
        context,
        '${attachment.fileName} — tap send to upload',
      );
    }
  }

  Future<void> _onAddNewNotes(BuildContext context) async {
    if (!_chatBloc.state.hasSession) {
      _showSnack(context, StringConstant.qnaChatSendMessageFirstForNotes);
      return;
    }

    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ColorConstant.cardBgColor,
        title: const Text(StringConstant.addNewNotes),
        content: TextField(controller: controller, autofocus: true, maxLines: 4),
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
      _showSnack(context, 'Note saved');
    }
  }

  void _onTalkToPurchaseTeam(BuildContext context) {
    _navigateToMessagesOnFinalize = true;
    _onFinalize(context, 'mark_pending');
  }

  void _goToMessages(BuildContext context, InquiryDetailState detailState) {
    final inquiryId = detailState.inquiryId.isNotEmpty
        ? detailState.inquiryId
        : widget.inquiryId;
    final displayNo = detailState.vendorRow?.inquiryNo;
    final vendorRow = detailState.vendorRow;

    context.go(
      PathConstant.messages,
      extra: MessagesRouteArgs(
        inquiryId: inquiryId,
        inquiryDisplayNo: displayNo,
        returnToPath: PathConstant.inquiryManagementDetail,
        returnToLabel: displayNo ?? 'Inquiry detail',
        returnVendorRow: vendorRow,
      ),
    );
  }

  Future<void> _onFinalize(BuildContext context, String action) async {
    if (action == 'put_follow_up') {
      await _onPutFollowUp(context);
      return;
    }

    final chatBloc = context.read<QnaChatBloc>();
    final amendmentApi = chatBloc.amendmentTypeApi;
    if (amendmentApi == null) {
      if (_navigateToMessagesOnFinalize) {
        _navigateToMessagesOnFinalize = false;
      }
      _showSnack(context, 'Please select amendment type.');
      return;
    }

    double? amount;
    if (action == 'mark_won') {
      amount = await _promptAmount(context);
      if (amount == null || !context.mounted) return;
    }

    if (!context.mounted) return;
    context.read<InquiryDetailBloc>().add(
          InquiryDetailFinalizeRequested(
            action: action,
            amendmentTypeApi: amendmentApi,
            amountCharged: amount,
          ),
        );
  }

  Future<void> _onPutFollowUp(BuildContext context) async {
    final chatBloc = _chatBloc;
    final amendmentApi = chatBloc.amendmentTypeApi;
    if (amendmentApi == null) {
      _showSnack(context, 'Please select amendment type.');
      return;
    }

    final sessionId = chatBloc.state.sessionId;
    if (sessionId == null || sessionId.trim().isEmpty) {
      _showSnack(context, StringConstant.qnaChatSendMessageFirstForNotes);
      return;
    }

    await showPutFollowUpDialog(
      context,
      inquiryId: widget.inquiryId,
      sessionId: sessionId,
      amendmentTypeApi: amendmentApi,
      onSaved: () {
        if (!context.mounted) return;
        context.read<InquiryDetailBloc>()
          ..add(const InquiryDetailSessionCleared())
          ..add(const InquiryDetailRefreshRequested());
      },
    );
  }

  Future<double?> _promptAmount(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ColorConstant.cardBgColor,
        title: const Text(StringConstant.qnaAmountChargedTitle),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(hintText: StringConstant.qnaAmountChargedHint),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final v = double.tryParse(controller.text.trim());
              Navigator.pop(ctx, v);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return result;
  }
}

class _OuterHeader extends StatelessWidget {
  const _OuterHeader({
    required this.isExpanded,
    required this.onToggle,
    required this.onAddNewNotes,
    required this.canAddNotes,
  });

  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onAddNewNotes;
  final bool canAddNotes;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Column(
        children: [
          Row(
            children: [
              Text(
                StringConstant.qnaNotes,
                style: FontConstant.interNormal(
                  color: ColorConstant.whiteColor,
                  fontSize: DimensionConstant.d16,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: canAddNotes ? onAddNewNotes : null,
                child: Opacity(
                  opacity: canAddNotes ? 1 : 0.45,
                  child: Container(
                    decoration: BoxDecoration(
                      color: ColorConstant.blackColor,
                      border: Border.all(color: ColorConstant.borderColorWhite30),
                      borderRadius: BorderRadius.circular(DimensionConstant.d6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(DimensionConstant.d15),
                      child: Text(
                        StringConstant.addNewNotes,
                        style: FontConstant.interNormal(
                          color: ColorConstant.whiteColor,
                          fontSize: DimensionConstant.d12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: DimensionConstant.d25),
              isExpanded
                  ? SvgPicture.asset(AssetConstants.icUpRoundArrow)
                  : RotatedBox(
                      quarterTurns: DimensionConstant.i2,
                      child: SvgPicture.asset(AssetConstants.icUpRoundArrow),
                    ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: DimensionConstant.d25),
            child: Divider(color: ColorConstant.whiteColor.withValues(alpha: 0.3)),
          ),
        ],
      ),
    );
  }
}
