import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/qna_chat/qna_chat_event.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/qna_chat/qna_chat_state.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/qna_chat_message.dart';

class QnaChatBloc extends Bloc<QnaChatEvent, QnaChatState> {
  QnaChatBloc() : super(const QnaChatState()) {
    on<QnaChatStarted>(_onStarted);
    on<QnaChatSectionExpansionToggled>(_onSectionExpansionToggled);
    on<QnaChatMessageDraftChanged>(_onMessageDraftChanged);
    on<QnaChatSendPressed>(_onSendPressed);
    on<QnaChatRefreshRequested>(_onRefreshRequested);
    on<QnaChatAmendmentTypeChanged>(_onAmendmentTypeChanged);
    on<QnaChatScrollToBottomHandled>(_onScrollToBottomHandled);
  }

  Future<void> _onStarted(QnaChatStarted event, Emitter<QnaChatState> emit) async {
    emit(
      state.copyWith(
        inquiryId: event.inquiryId,
        loadStatus: QnaChatStatus.loading,
        clearErrorMessage: true,
      ),
    );

    // Phase 6: replace with repository fetch.
    await Future<void>.delayed(const Duration(milliseconds: 200));
    emit(
      state.copyWith(
        messages: _mockSeedMessages(),
        loadStatus: QnaChatStatus.success,
        clearErrorMessage: true,
      ),
    );
  }

  void _onSectionExpansionToggled(
    QnaChatSectionExpansionToggled event,
    Emitter<QnaChatState> emit,
  ) {
    emit(state.copyWith(isSectionExpanded: !state.isSectionExpanded));
  }

  void _onMessageDraftChanged(
    QnaChatMessageDraftChanged event,
    Emitter<QnaChatState> emit,
  ) {
    emit(
      state.copyWith(
        messageDraft: event.text,
        clearSendErrorMessage: true,
        sendStatus: QnaChatSendStatus.idle,
      ),
    );
  }

  Future<void> _onSendPressed(QnaChatSendPressed event, Emitter<QnaChatState> emit) async {
    final draft = state.messageDraft.trim();
    if (draft.isEmpty || state.sendStatus == QnaChatSendStatus.sending) return;

    emit(
      state.copyWith(
        sendStatus: QnaChatSendStatus.sending,
        clearSendErrorMessage: true,
      ),
    );

    // Phase 6: POST via repository; optimistic UI for now.
    await Future<void>.delayed(const Duration(milliseconds: 150));

    final newMessage = QnaChatMessage(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      kind: QnaChatMessageKind.answer,
      contentType: QnaChatMessageContentType.text,
      body: draft,
      createdAt: DateTime.now(),
    );

    emit(
      state.copyWith(
        messages: [...state.messages, newMessage],
        messageDraft: '',
        sendStatus: QnaChatSendStatus.idle,
        scrollToBottom: true,
        clearSendErrorMessage: true,
      ),
    );
  }

  Future<void> _onRefreshRequested(
    QnaChatRefreshRequested event,
    Emitter<QnaChatState> emit,
  ) async {
    add(QnaChatStarted(inquiryId: state.inquiryId));
  }

  void _onAmendmentTypeChanged(
    QnaChatAmendmentTypeChanged event,
    Emitter<QnaChatState> emit,
  ) {
    emit(
      state.copyWith(
        amendmentType: event.amendmentType,
        clearAmendmentType: event.amendmentType == null,
      ),
    );
  }

  void _onScrollToBottomHandled(
    QnaChatScrollToBottomHandled event,
    Emitter<QnaChatState> emit,
  ) {
    if (state.scrollToBottom) {
      emit(state.copyWith(scrollToBottom: false));
    }
  }

  static List<QnaChatMessage> _mockSeedMessages() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    const lorem =
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec auctor, metus ac ultrices dignissim, justo libero dictum sapien, non pharetra felis purus sit amet libero. Vestibulum magna dui, semper nec fringilla eu, egestas non lectus. Suspendisse potenti. Cras laoreet vestibulum volutpat.';

    const structured = '''1. Indigo (6E)
Fare: ₹13,700.00
Pax Count: 2 Adults
Refundable: Partially Refundable
Outbound: 12 May 2026 (2h 10m)
Route: LKO (18:30) -> AMD (20:40)
Baggage: 15 Kg Check-in + 7 Kg Cabin''';

    return [
      QnaChatMessage(
        id: 'mock-1',
        kind: QnaChatMessageKind.question,
        contentType: QnaChatMessageContentType.text,
        body: lorem,
        createdAt: DateTime(yesterday.year, yesterday.month, yesterday.day, 14, 26),
      ),
      QnaChatMessage(
        id: 'mock-2',
        kind: QnaChatMessageKind.answer,
        contentType: QnaChatMessageContentType.text,
        body: lorem,
        createdAt: DateTime(now.year, now.month, now.day, 10, 15),
      ),
      QnaChatMessage(
        id: 'mock-3',
        kind: QnaChatMessageKind.answer,
        contentType: QnaChatMessageContentType.structured,
        body: structured,
        createdAt: DateTime(now.year, now.month, now.day, 11, 42),
      ),
    ];
  }
}
