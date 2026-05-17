import 'package:equatable/equatable.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/amendment_card_body_ui.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/qna_chat_message.dart';

enum AmendmentCardLoadStatus { idle, loading, success, failure }

class AmendmentCardState extends Equatable {
  const AmendmentCardState({
    this.loadStatus = AmendmentCardLoadStatus.idle,
    this.body,
    this.messages = const [],
    this.noteTexts = const [],
    this.errorMessage,
    this.hasLoadedOnce = false,
  });

  final AmendmentCardLoadStatus loadStatus;
  final AmendmentCardBodyUi? body;
  final List<QnaChatMessage> messages;
  final List<String> noteTexts;
  final String? errorMessage;
  final bool hasLoadedOnce;

  @override
  List<Object?> get props => [
        loadStatus,
        body,
        messages,
        noteTexts,
        errorMessage,
        hasLoadedOnce,
      ];

  AmendmentCardState copyWith({
    AmendmentCardLoadStatus? loadStatus,
    AmendmentCardBodyUi? body,
    List<QnaChatMessage>? messages,
    List<String>? noteTexts,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? hasLoadedOnce,
  }) {
    return AmendmentCardState(
      loadStatus: loadStatus ?? this.loadStatus,
      body: body ?? this.body,
      messages: messages ?? this.messages,
      noteTexts: noteTexts ?? this.noteTexts,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
    );
  }
}
