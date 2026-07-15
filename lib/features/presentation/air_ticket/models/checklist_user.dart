import 'package:equatable/equatable.dart';
import 'package:travel_crm/data/models/members/list_members_item.dart';

/// A member assigned to a checklist row. Carries the database identity so the
/// create-inquiry payload can send the full `user` object
/// (`{ _id, fullName, firstName, lastName, employeeId }`) instead of a bare
/// name string. [id] is null for legacy / free-text names that were not picked
/// from the members name-search.
class ChecklistUser extends Equatable {
  const ChecklistUser({
    this.id,
    this.fullName,
    this.firstName,
    this.lastName,
    this.employeeId,
  });

  final String? id;
  final String? fullName;
  final String? firstName;
  final String? lastName;
  final String? employeeId;

  /// Builds from a member returned by the `/members/name-search` picker.
  factory ChecklistUser.fromMember(ListMembersItem member) => ChecklistUser(
        id: member.id,
        fullName: member.fullName,
        firstName: member.firstName,
        lastName: member.lastName,
        employeeId: member.employeeId,
      );

  /// Builds a name-only user (no backing member record) — used to seed the
  /// picker from legacy comma-joined name strings.
  factory ChecklistUser.fromName(String name) =>
      ChecklistUser(fullName: name.trim());

  /// Label shown in chips / fields: fullName → firstName+lastName → employeeId.
  String get displayName {
    final full = fullName?.trim();
    if (full != null && full.isNotEmpty) return full;
    final parts = [firstName, lastName]
        .where((s) => s != null && s.trim().isNotEmpty)
        .map((s) => s!.trim())
        .toList();
    if (parts.isNotEmpty) return parts.join(' ');
    return employeeId?.trim() ?? '';
  }

  /// The `checklist[].user` object for `POST /inquiries`. Null/empty fields are
  /// omitted (mirrors `includeIfNull: false`); returns null when nothing to send.
  Map<String, dynamic>? toJson() {
    final map = <String, dynamic>{};
    void put(String key, String? value) {
      final v = value?.trim();
      if (v != null && v.isNotEmpty) map[key] = v;
    }

    put('_id', id);
    put('fullName', fullName);
    put('firstName', firstName);
    put('lastName', lastName);
    put('employeeId', employeeId);
    return map.isEmpty ? null : map;
  }

  @override
  List<Object?> get props => [id, fullName, firstName, lastName, employeeId];
}
