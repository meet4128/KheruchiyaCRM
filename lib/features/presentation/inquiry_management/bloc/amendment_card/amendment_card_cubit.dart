import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/data/models/inquiry/inquiry_checklist_item.dart';
import 'package:travel_crm/data/repositories/inquiry_repository.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/amendment_card/amendment_card_state.dart';
import 'package:travel_crm/features/presentation/inquiry_management/mappers/amendment_detail_mapper.dart';
import 'package:travel_crm/features/presentation/inquiry_management/mappers/session_message_mapper.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/amendment_card_ui.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/qna_chat_message.dart';

class AmendmentCardCubit extends Cubit<AmendmentCardState> {
  AmendmentCardCubit({
    required InquiryRepository repository,
    required this.inquiryId,
    required this.summary,
    this.inquiryChecklist = const [],
  })  : _repository = repository,
        super(const AmendmentCardState());

  final InquiryRepository _repository;
  final String inquiryId;
  final AmendmentCardUi summary;
  final List<InquiryChecklistItem> inquiryChecklist;

  Future<void> loadExpandedContent() async {
    if (!summary.hasAmendmentId || inquiryId.isEmpty) return;
    if (state.hasLoadedOnce && state.loadStatus == AmendmentCardLoadStatus.success) {
      return;
    }

    final fallbackBody = amendmentBodyFromSummary(
      summary,
      fallbackChecklist: inquiryChecklist,
    );

    emit(
      state.copyWith(
        loadStatus: AmendmentCardLoadStatus.loading,
        clearErrorMessage: true,
        body: state.body ?? fallbackBody,
      ),
    );

    var body = fallbackBody;
  var messages = <QnaChatMessage>[];
    var noteTexts = <String>[];
    final errors = <String>[];

    try {
      final detailResponse = await _repository.getAmendmentDetail(
        inquiryId: inquiryId,
        amendmentId: summary.amendmentId,
      );
      body = amendmentBodyFromDetail(
        detailResponse.data.amendment,
        summary: summary,
        fallbackChecklist: inquiryChecklist,
      );
    } catch (e) {
      errors.add('Detail: $e');
    }

    try {
      final messagesResponse = await _repository.listAmendmentMessages(
        inquiryId: inquiryId,
        amendmentId: summary.amendmentId,
      );
      messages = qnaMessagesFromSessionItems(messagesResponse.data.items);
    } catch (e) {
      errors.add('Messages: $e');
    }

    try {
      final notesResponse = await _repository.listAmendmentNotes(
        inquiryId: inquiryId,
        amendmentId: summary.amendmentId,
      );
      noteTexts = notesResponse.data.items
          .map((n) => n.text?.trim() ?? '')
          .where((t) => t.isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      // Notes endpoint is optional — ignore failures.
    }

    final hasPartialData = messages.isNotEmpty || body != fallbackBody;
    final failed = errors.isNotEmpty && !hasPartialData;

    emit(
      state.copyWith(
        loadStatus:
            failed ? AmendmentCardLoadStatus.failure : AmendmentCardLoadStatus.success,
        body: body,
        messages: messages,
        noteTexts: noteTexts,
        errorMessage: failed ? errors.join('\n') : null,
        hasLoadedOnce: true,
        clearErrorMessage: !failed,
      ),
    );
  }
}
