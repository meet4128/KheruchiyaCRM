import 'package:equatable/equatable.dart';
import 'package:travel_crm/data/models/members/list_members_item.dart';

import 'add_member_state.dart';

abstract class AddMemberEvent extends Equatable {
  const AddMemberEvent();

  @override
  List<Object?> get props => [];
}

class AddMemberDialogOpened extends AddMemberEvent {
  const AddMemberDialogOpened({
    this.editingMemberId,
    this.listMemberPrefill,
    this.prefillFullName,
    this.prefillPersonalEmail,
  });

  /// When set, submit uses PATCH `/api/v1/members/{id}` instead of POST create.
  final String? editingMemberId;

  /// Optional list-row cache shown while `GET /members/:id` loads.
  final ListMembersItem? listMemberPrefill;

  /// Legacy fallbacks when [listMemberPrefill] is unavailable.
  final String? prefillFullName;
  final String? prefillPersonalEmail;

  @override
  List<Object?> get props => [
        editingMemberId,
        listMemberPrefill,
        prefillFullName,
        prefillPersonalEmail,
      ];
}

/// Re-fetches `GET /members/:id` after a failed edit prefill load.
class AddMemberMemberDetailRetryRequested extends AddMemberEvent {
  const AddMemberMemberDetailRetryRequested();
}

class AddMemberDialogClosed extends AddMemberEvent {
  const AddMemberDialogClosed();
}

class AddMemberFullNameChanged extends AddMemberEvent {
  const AddMemberFullNameChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class AddMemberPersonalEmailChanged extends AddMemberEvent {
  const AddMemberPersonalEmailChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class AddMemberPhoneChanged extends AddMemberEvent {
  const AddMemberPhoneChanged({
    required this.dialCode,
    required this.number,
  });

  final String dialCode;
  final String number;

  @override
  List<Object?> get props => [dialCode, number];
}

class AddMemberHomePhoneChanged extends AddMemberEvent {
  const AddMemberHomePhoneChanged({
    required this.dialCode,
    required this.number,
  });

  final String dialCode;
  final String number;

  @override
  List<Object?> get props => [dialCode, number];
}

class AddMemberDobChanged extends AddMemberEvent {
  const AddMemberDobChanged(this.value);

  final DateTime value;

  @override
  List<Object?> get props => [value];
}

class AddMemberGenderChanged extends AddMemberEvent {
  const AddMemberGenderChanged(this.value);

  final AddMemberGender value;

  @override
  List<Object?> get props => [value];
}

class AddMemberMaritalStatusChanged extends AddMemberEvent {
  const AddMemberMaritalStatusChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class AddMemberAnniversaryChanged extends AddMemberEvent {
  const AddMemberAnniversaryChanged(this.value);

  final DateTime value;

  @override
  List<Object?> get props => [value];
}

class AddMemberAddressChanged extends AddMemberEvent {
  const AddMemberAddressChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class AddMemberAddressLine2Changed extends AddMemberEvent {
  const AddMemberAddressLine2Changed(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class AddMemberZipCodeChanged extends AddMemberEvent {
  const AddMemberZipCodeChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class AddMemberCityChanged extends AddMemberEvent {
  const AddMemberCityChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class AddMemberNextPressed extends AddMemberEvent {
  const AddMemberNextPressed();
}

class AddMemberBackPressed extends AddMemberEvent {
  const AddMemberBackPressed();
}

class AddMemberFirstNameChanged extends AddMemberEvent {
  const AddMemberFirstNameChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class AddMemberLastNameChanged extends AddMemberEvent {
  const AddMemberLastNameChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class AddMemberEmployeeIdChanged extends AddMemberEvent {
  const AddMemberEmployeeIdChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class AddMemberDesignationChanged extends AddMemberEvent {
  const AddMemberDesignationChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class AddMemberEmploymentStatusChanged extends AddMemberEvent {
  const AddMemberEmploymentStatusChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class AddMemberDateOfJoiningChanged extends AddMemberEvent {
  const AddMemberDateOfJoiningChanged(this.value);

  final DateTime value;

  @override
  List<Object?> get props => [value];
}

class AddMemberRoleRowDepartmentChanged extends AddMemberEvent {
  const AddMemberRoleRowDepartmentChanged({required this.index, required this.value});

  final int index;
  final String value;

  @override
  List<Object?> get props => [index, value];
}

class AddMemberRoleRowRoleChanged extends AddMemberEvent {
  const AddMemberRoleRowRoleChanged({required this.index, required this.value});

  final int index;
  final String value;

  @override
  List<Object?> get props => [index, value];
}

class AddMemberRoleRowAdded extends AddMemberEvent {
  const AddMemberRoleRowAdded();
}

class AddMemberRoleRowRemoved extends AddMemberEvent {
  const AddMemberRoleRowRemoved(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

class AddMemberOfficePhoneChanged extends AddMemberEvent {
  const AddMemberOfficePhoneChanged({
    required this.dialCode,
    required this.number,
  });

  final String dialCode;
  final String number;

  @override
  List<Object?> get props => [dialCode, number];
}

class AddMemberAttachmentPicked extends AddMemberEvent {
  const AddMemberAttachmentPicked({
    required this.kind,
    required this.fileName,
    this.path,
  });

  final AddMemberAttachmentKind kind;
  final String fileName;
  final String? path;

  @override
  List<Object?> get props => [kind, fileName, path];
}

class AddMemberAttachmentCleared extends AddMemberEvent {
  const AddMemberAttachmentCleared(this.kind);

  final AddMemberAttachmentKind kind;

  @override
  List<Object?> get props => [kind];
}

class AddMemberInviteEmailChoiceChanged extends AddMemberEvent {
  const AddMemberInviteEmailChoiceChanged(this.value);

  final AddMemberInviteEmailChoice value;

  @override
  List<Object?> get props => [value];
}

class AddMemberCustomInviteEmailChanged extends AddMemberEvent {
  const AddMemberCustomInviteEmailChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class AddMemberSendInviteToggled extends AddMemberEvent {
  const AddMemberSendInviteToggled(this.value);

  final bool value;

  @override
  List<Object?> get props => [value];
}

class AddMemberSubmitPressed extends AddMemberEvent {
  const AddMemberSubmitPressed();
}
