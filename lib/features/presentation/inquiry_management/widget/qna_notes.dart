import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:travel_crm/core/constants/asset_constants.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/font_constant.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/di/injector.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/qna_chat/qna_chat_bloc.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/qna_chat/qna_chat_event.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/qna_chat/qna_chat_state.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widgets/qna_chat/qna_chat_section_body.dart';

class QnaNotes extends StatefulWidget {
  const QnaNotes({super.key, this.inquiryId = ''});

  final String inquiryId;

  @override
  State<QnaNotes> createState() => _QnaNotesState();
}

class _QnaNotesState extends State<QnaNotes> {
  final ExpansibleController _expansionController = ExpansibleController();

  @override
  void initState() {
    super.initState();
    _expansionController.expand();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<QnaChatBloc>()..add(QnaChatStarted(inquiryId: widget.inquiryId)),
      child: BlocListener<QnaChatBloc, QnaChatState>(
        listenWhen: (previous, current) =>
            previous.isSectionExpanded != current.isSectionExpanded,
        listener: (context, state) {
          if (state.isSectionExpanded) {
            _expansionController.expand();
          } else {
            _expansionController.collapse();
          }
        },
        child: BlocBuilder<QnaChatBloc, QnaChatState>(
          buildWhen: (previous, current) =>
              previous.isSectionExpanded != current.isSectionExpanded,
          builder: (context, state) {
            return Container(
              color: ColorConstant.card1BgColor,
              width: double.infinity,
              child: Padding(
                padding: state.isSectionExpanded
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
                  controller: _expansionController,
                  headerBuilder: (context, animation) => _ChatSectionHeader(
                    isExpanded: state.isSectionExpanded,
                    onToggle: () => context
                        .read<QnaChatBloc>()
                        .add(const QnaChatSectionExpansionToggled()),
                  ),
                  bodyBuilder: (context, animation) => QnaChatSectionBody(
                    onAttachTap: () => _showAmendmentSheet(context),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showAmendmentSheet(BuildContext context) {
    final bloc = context.read<QnaChatBloc>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ColorConstant.cardBgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DimensionConstant.d12)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: DimensionConstant.d16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: DimensionConstant.d20),
                  child: Text(
                    StringConstant.amendmentType,
                    style: FontConstant.interMedium(
                      color: ColorConstant.whiteColor,
                      fontSize: DimensionConstant.d14,
                    ),
                  ),
                ),
                const SizedBox(height: DimensionConstant.d8),
                ...StringConstant.qnaChatAmendmentTypeOptions.map(
                  (option) => ListTile(
                    title: Text(
                      option,
                      style: FontConstant.interNormal(
                        color: ColorConstant.whiteColor,
                        fontSize: DimensionConstant.d13,
                      ),
                    ),
                    onTap: () {
                      bloc.add(QnaChatAmendmentTypeChanged(option));
                      Navigator.of(sheetContext).pop();
                    },
                  ),
                ),
                ListTile(
                  title: Text(
                    StringConstant.qnaChatClearAmendmentType,
                    style: FontConstant.interNormal(
                      color: ColorConstant.whiteColor.withValues(alpha: 0.6),
                      fontSize: DimensionConstant.d12,
                    ),
                  ),
                  onTap: () {
                    bloc.add(const QnaChatAmendmentTypeChanged(null));
                    Navigator.of(sheetContext).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ChatSectionHeader extends StatelessWidget {
  const _ChatSectionHeader({
    required this.isExpanded,
    required this.onToggle,
  });

  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Column(
        children: [
          Row(
            children: [
              Text(
                StringConstant.questionAndAnswer,
                style: FontConstant.interNormal(
                  color: ColorConstant.whiteColor,
                  fontSize: DimensionConstant.d16,
                ),
              ),
              const Spacer(),
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
