import 'package:intl/intl.dart';

import 'package:travel_crm/features/presentation/admin_panel/team_members/add_member/bloc/add_member_state.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/bloc/team_members_state.dart';

final DateFormat _dojFormat = DateFormat('dd/MM/yyyy');

/// Matches [AddMemberOperationInfoForm] department dropdown: `Admin`, `Sales`, `Purchase`, `Accounts`.
TeamSection? teamSectionFromDepartmentSelection(String department) {
  switch (department.trim().toLowerCase()) {
    case 'admin':
      return TeamSection.admin;
    case 'sales':
      return TeamSection.sales;
    case 'purchase':
      return TeamSection.purchase;
    case 'accounts':
      return TeamSection.accounts;
    default:
      return null;
  }
}

/// Team blocks where this member appears — **only** from each row’s **Department** dropdown (not role).
Set<TeamSection> teamSectionsFromRoleRows(List<AddMemberRoleRow> rows) {
  final out = <TeamSection>{};
  for (final row in rows) {
    final d = row.department.trim();
    if (d.isEmpty) continue;
    final section = teamSectionFromDepartmentSelection(d);
    if (section != null) out.add(section);
  }
  if (out.isEmpty) {
    out.add(TeamSection.sales);
  }
  return out;
}

/// Shown in the members table “department” column (selected departments, deduped).
String displayDepartmentFromRoleRows(List<AddMemberRoleRow> rows) {
  final parts = <String>[];
  final seen = <String>{};
  for (final row in rows) {
    final d = row.department.trim();
    if (d.isEmpty || seen.contains(d)) continue;
    seen.add(d);
    parts.add(d);
  }
  return parts.join(', ');
}

String _displayName(AddMemberState state) {
  final full = state.fullName.trim();
  if (full.isNotEmpty) return full;
  final first = state.firstName.trim();
  final last = state.lastName.trim();
  return '$first $last'.trim();
}

String _dojString(AddMemberState state) {
  if (state.dateOfJoining != null) {
    return _dojFormat.format(state.dateOfJoining!);
  }
  return _dojFormat.format(DateTime.now());
}

/// Builds a list row model after a successful **create** (new id).
///
/// Default invite stamping mirrors the backend behaviour:
///   - If the backend actually sent the invite ([InviteResultDto.sent] is
///     true) we mark the row `pending` so the row pill / Resend affordance
///     appears immediately.
///   - If the admin opted out of sending right now (`sendInvite: false`) we
///     still mark `pending` — the member doesn't have a password yet, the
///     admin will resend later. Same UX.
TeamMemberUiModel teamMemberUiModelForNewMember(AddMemberState state) {
  final id = 'm_${DateTime.now().microsecondsSinceEpoch}';
  final invite = state.lastInviteResult;
  final inviteSentAt = invite?.expiresAt != null
      // Backend's `expiresAt` is +72h from issuance, so the issuance time is
      // a close-enough stand-in for "last sent at" until we wire the real
      // value from the response.
      ? DateTime.tryParse(invite!.expiresAt!)?.subtract(const Duration(hours: 72))
      : null;
  return TeamMemberUiModel(
    id: id,
    name: _displayName(state),
    doj: _dojString(state),
    email: state.personalEmail.trim(),
    status: TeamMemberStatus.online,
    department: displayDepartmentFromRoleRows(state.roleRows),
    invitationStatus: TeamMemberInvitationStatus.pending,
    lastInviteSentAt: inviteSentAt,
  );
}

/// Builds a list row model after a successful **update** (keeps [memberId]).
///
/// Edit flow doesn't touch invite status — caller passes the previous value
/// through so we don't stamp a stale `unknown` over a real `active` flag.
TeamMemberUiModel teamMemberUiModelForUpdatedMember(
  AddMemberState state,
  String memberId, {
  TeamMemberInvitationStatus invitationStatus = TeamMemberInvitationStatus.unknown,
  DateTime? lastInviteSentAt,
}) {
  return TeamMemberUiModel(
    id: memberId,
    name: _displayName(state),
    doj: _dojString(state),
    email: state.personalEmail.trim(),
    status: TeamMemberStatus.online,
    department: displayDepartmentFromRoleRows(state.roleRows),
    invitationStatus: invitationStatus,
    lastInviteSentAt: lastInviteSentAt,
  );
}
