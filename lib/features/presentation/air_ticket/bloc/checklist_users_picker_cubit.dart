import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/features/presentation/air_ticket/models/checklist_user.dart';

/// Parses a comma-separated names string into name-only [ChecklistUser]s.
/// Used to seed the picker from legacy fields that stored only display names.
List<ChecklistUser> parseChecklistUserList(String raw) {
  return raw
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .map(ChecklistUser.fromName)
      .toList();
}

/// State for the add-users dialog (selected members).
class ChecklistUsersPickerState extends Equatable {
  const ChecklistUsersPickerState({required this.users});

  final List<ChecklistUser> users;

  /// Display names (kept for legacy string-based callers).
  List<String> get names => users.map((u) => u.displayName).toList();

  @override
  List<Object?> get props => [users];
}

/// Manages the list of selected members in the checklist "Add users" dialog.
class ChecklistUsersPickerCubit extends Cubit<ChecklistUsersPickerState> {
  ChecklistUsersPickerCubit(List<ChecklistUser> initialUsers)
      : super(ChecklistUsersPickerState(users: List.of(initialUsers)));

  /// Adds a member picked from search results. De-duplicates by [ChecklistUser.id]
  /// when both users have one, otherwise by case-insensitive display name.
  void addUser(ChecklistUser user) {
    final name = user.displayName.trim();
    if (name.isEmpty) return;
    final exists = state.users.any((u) => u.id != null && user.id != null
        ? u.id == user.id
        : u.displayName.toLowerCase() == name.toLowerCase());
    if (exists) return;
    emit(ChecklistUsersPickerState(users: [...state.users, user]));
  }

  void removeAt(int index) {
    if (index < 0 || index >= state.users.length) return;
    final next = List<ChecklistUser>.from(state.users)..removeAt(index);
    emit(ChecklistUsersPickerState(users: next));
  }
}
