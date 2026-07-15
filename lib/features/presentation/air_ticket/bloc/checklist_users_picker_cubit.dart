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

/// A user selected in the checklist "Add users" dialog. [id] is the member's
/// `_id` when picked from the name-search API; it is null for legacy names
/// seeded from the comma-joined field (which stores names only).
class SelectedChecklistUser extends Equatable {
  const SelectedChecklistUser({required this.name, this.id});

  final String name;
  final String? id;

  @override
  List<Object?> get props => [name, id];
}

/// State for the add-users dialog (selected members).
class ChecklistUsersPickerState extends Equatable {
  const ChecklistUsersPickerState({required this.users});

  final List<SelectedChecklistUser> users;

  /// Display names (kept for the current field contract / payload).
  List<String> get names => users.map((u) => u.name).toList();

  @override
  List<Object?> get props => [users];
}

/// Manages the list of selected members in the checklist "Add users" dialog.
class ChecklistUsersPickerCubit extends Cubit<ChecklistUsersPickerState> {
  ChecklistUsersPickerCubit(List<String> initialNames)
      : super(ChecklistUsersPickerState(
          users: initialNames
              .map((n) => SelectedChecklistUser(name: n))
              .toList(),
        ));

  /// Adds a member picked from search results. De-duplicates by [id] when
  /// present, otherwise by case-insensitive name.
  void addMember({required String name, String? id}) {
    final t = name.trim();
    if (t.isEmpty) return;
    final exists = state.users.any((u) => id != null && u.id != null
        ? u.id == id
        : u.name.toLowerCase() == t.toLowerCase());
    if (exists) return;
    emit(ChecklistUsersPickerState(
      users: [...state.users, SelectedChecklistUser(name: t, id: id)],
    ));
  }

  void removeAt(int index) {
    if (index < 0 || index >= state.users.length) return;
    final next = List<SelectedChecklistUser>.from(state.users)..removeAt(index);
    emit(ChecklistUsersPickerState(users: next));
  }

  String joinedForField() => state.names.join(', ');
}
