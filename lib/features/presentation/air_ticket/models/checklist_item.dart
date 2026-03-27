import 'package:equatable/equatable.dart';
import 'checklist_priority.dart';

/// Checklist item data model
class ChecklistItem extends Equatable {
  const ChecklistItem({
    this.user = '',
    this.dueDate,
    this.priority,
    this.category = '',
    this.inLoop = false,
    this.repeat = false,
  });

  final String user;
  final DateTime? dueDate;
  final ChecklistPriority? priority;
  final String category;
  final bool inLoop;
  final bool repeat;

  /// Backend value for [priority] (e.g. `HIGH`), not the UI label.
  String? get priorityApiValue => priority?.apiValue;

  ChecklistItem copyWith({
    String? user,
    DateTime? dueDate,
    ChecklistPriority? priority,
    String? category,
    bool? inLoop,
    bool? repeat,
  }) {
    return ChecklistItem(
      user: user ?? this.user,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      inLoop: inLoop ?? this.inLoop,
      repeat: repeat ?? this.repeat,
    );
  }

  @override
  List<Object?> get props => [user, dueDate, priority, category, inLoop, repeat];
}






