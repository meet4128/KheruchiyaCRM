import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Parses comma-separated user string from checklist field.
List<String> parseChecklistUserList(String raw) {
  return raw
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
}

/// State for the add-users dialog (chip list only; draft text uses [TextEditingController] in UI).
class ChecklistUsersPickerState extends Equatable {
  const ChecklistUsersPickerState({required this.names});

  final List<String> names;

  @override
  List<Object?> get props => [names];
}

/// Manages the list of user names in the checklist "Add users" dialog.
class ChecklistUsersPickerCubit extends Cubit<ChecklistUsersPickerState> {
  ChecklistUsersPickerCubit(List<String> initialNames)
      : super(ChecklistUsersPickerState(names: List<String>.from(initialNames)));

  void addName(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return;
    final exists = state.names.any((n) => n.toLowerCase() == t.toLowerCase());
    if (exists) return;
    emit(ChecklistUsersPickerState(names: [...state.names, t]));
  }

  void removeAt(int index) {
    if (index < 0 || index >= state.names.length) return;
    final next = List<String>.from(state.names)..removeAt(index);
    emit(ChecklistUsersPickerState(names: next));
  }

  String joinedForField() => state.names.join(', ');
}
