import 'package:equatable/equatable.dart';
import 'checklist_priority.dart';
import 'checklist_user.dart';

/// Checklist item data model
class ChecklistItem extends Equatable {
  const ChecklistItem({
    this.users = const [],
    this.dueDate,
    this.priority,
    this.category = '',
    this.inLoop = false,
    this.repeat = false,
  });

  /// Members assigned to this checklist row. Each carries its database identity
  /// so the create-inquiry payload can send the full `user` object.
  final List<ChecklistUser> users;
  final DateTime? dueDate;
  final ChecklistPriority? priority;
  final String category;
  final bool inLoop;
  final bool repeat;

  /// Backend value for [priority] (e.g. `HIGH`), not the UI label.
  String? get priorityApiValue => priority?.apiValue;

  ChecklistItem copyWith({
    List<ChecklistUser>? users,
    DateTime? dueDate,
    ChecklistPriority? priority,
    String? category,
    bool? inLoop,
    bool? repeat,
  }) {
    return ChecklistItem(
      users: users ?? this.users,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      inLoop: inLoop ?? this.inLoop,
      repeat: repeat ?? this.repeat,
    );
  }

  @override
  List<Object?> get props => [users, dueDate, priority, category, inLoop, repeat];
}
