import 'package:intl/intl.dart';
import 'package:travel_crm/core/models/inquiry/phone_number_model.dart';
import 'package:travel_crm/data/models/members/create_member_request.dart';
import 'package:travel_crm/data/models/members/department_role_dto.dart';
import 'package:travel_crm/data/models/members/update_member_request.dart';

import '../bloc/add_member_state.dart';

final DateFormat _isoDate = DateFormat('yyyy-MM-dd');

String _maritalToApi(String ui) {
  switch (ui.trim()) {
    case 'Married':
      return 'married';
    case 'Unmarried':
      return 'unmarried';
    case 'Widow':
      return 'widow';
    default:
      return ui.trim().isEmpty ? 'unmarried' : ui.trim().toLowerCase();
  }
}

String _employmentToApi(String ui) {
  switch (ui.trim()) {
    case 'Active':
      return 'active';
    case 'Probation':
      return 'probation';
    case 'On Leave':
      return 'on_leave';
    case 'Contract':
      return 'contract';
    default:
      return ui.trim().isEmpty ? 'active' : ui.trim().toLowerCase().replaceAll(' ', '_');
  }
}

String? _genderToApi(AddMemberGender? g) {
  if (g == null) return null;
  return g == AddMemberGender.male ? 'male' : 'female';
}

List<DepartmentRoleDto> _departmentRoles(AddMemberState state) {
  return state.roleRows
      .where((r) => r.department.trim().isNotEmpty && r.role.trim().isNotEmpty)
      .map((r) => DepartmentRoleDto(department: r.department.trim(), role: r.role.trim()))
      .toList();
}

CreateMemberRequest mapStateToCreateRequest(AddMemberState state) {
  // Invite flags — backend defaults are `sendInvite: true` and
  // `inviteEmail: <personalEmail>`. We only send these fields when the admin
  // overrode the defaults, so the wire payload stays minimal in the common
  // case and the backend's `includeIfNull: false` semantics work cleanly.
  final bool? sendInviteOverride = state.sendInvite ? null : false;
  String? inviteEmailOverride;
  if (state.sendInvite &&
      state.inviteEmailChoice == AddMemberInviteEmailChoice.custom) {
    final trimmed = state.customInviteEmail.trim();
    if (trimmed.isNotEmpty) inviteEmailOverride = trimmed;
  }

  return CreateMemberRequest(
    fullName: state.fullName.trim(),
    personalEmail: state.personalEmail.trim(),
    phoneNumber: PhoneNumberModel(countryCode: state.phoneDialCode, number: state.phoneNumber),
    homePhoneNumber: PhoneNumberModel(
      countryCode: state.homePhoneDialCode,
      number: state.homePhoneNumber,
    ),
    dateOfBirth: state.dob != null ? _isoDate.format(state.dob!) : null,
    gender: _genderToApi(state.gender),
    maritalStatus: _maritalToApi(state.maritalStatus),
    dateOfAnniversary: state.anniversaryDate != null ? _isoDate.format(state.anniversaryDate!) : null,
    addressLine1: state.address.trim(),
    addressLine2: state.addressLine2.trim(),
    zipCode: state.zipCode.trim(),
    city: state.city.trim(),
    firstName: state.firstName.trim(),
    lastName: state.lastName.trim(),
    employeeId: state.employeeId.trim(),
    designation: state.designation.trim(),
    employmentStatus: _employmentToApi(state.employmentStatus),
    dateOfJoining: state.dateOfJoining != null ? _isoDate.format(state.dateOfJoining!) : null,
    departmentRoles: _departmentRoles(state),
    officePhoneNumber: PhoneNumberModel(
      countryCode: state.officePhoneDialCode,
      number: state.officePhoneNumber,
    ),
    aadharDocumentUrl: null,
    panDocumentUrl: null,
    cancelChequeDocumentUrl: null,
    sendInvite: sendInviteOverride,
    inviteEmail: inviteEmailOverride,
  );
}

/// Full PATCH payload from current wizard state (MVP: same shape as create).
UpdateMemberRequest mapStateToUpdateRequest(AddMemberState state) {
  final create = mapStateToCreateRequest(state);
  return UpdateMemberRequest(
    fullName: create.fullName,
    personalEmail: create.personalEmail,
    phoneNumber: create.phoneNumber,
    homePhoneNumber: create.homePhoneNumber,
    dateOfBirth: create.dateOfBirth,
    gender: create.gender,
    maritalStatus: create.maritalStatus,
    dateOfAnniversary: create.dateOfAnniversary,
    addressLine1: create.addressLine1,
    addressLine2: create.addressLine2,
    zipCode: create.zipCode,
    city: create.city,
    firstName: create.firstName,
    lastName: create.lastName,
    employeeId: create.employeeId,
    designation: create.designation,
    employmentStatus: create.employmentStatus,
    dateOfJoining: create.dateOfJoining,
    departmentRoles: create.departmentRoles,
    officePhoneNumber: create.officePhoneNumber,
    aadharDocumentUrl: create.aadharDocumentUrl,
    panDocumentUrl: create.panDocumentUrl,
    cancelChequeDocumentUrl: create.cancelChequeDocumentUrl,
  );
}
