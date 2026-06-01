import 'package:travel_crm/data/models/inquiry/phone_number_dto.dart';
import 'package:travel_crm/data/models/members/list_members_item.dart';
import 'package:travel_crm/features/presentation/admin_panel/team_members/add_member/bloc/add_member_state.dart';

/// Seeds [AddMemberState] from a [ListMembersItem] (list row or `GET /members/:id`).
AddMemberState addMemberStateFromListMember(
  ListMembersItem item, {
  required String editingMemberId,
}) {
  final fullName = _fullName(item);
  final parts = fullName.isEmpty ? <String>[] : fullName.split(RegExp(r'\s+'));
  final first = (item.firstName ?? '').trim().isNotEmpty
      ? item.firstName!.trim()
      : (parts.isNotEmpty ? parts.first : '');
  final last = (item.lastName ?? '').trim().isNotEmpty
      ? item.lastName!.trim()
      : (parts.length > 1 ? parts.sublist(1).join(' ') : '');

  final roleRows = item.departmentRoles
      .where((r) => r.department.trim().isNotEmpty || r.role.trim().isNotEmpty)
      .map((r) => AddMemberRoleRow(department: r.department.trim(), role: r.role.trim()))
      .toList();

  final mobile = _phoneFields(item.phoneNumber);
  final home = _phoneFields(item.homePhoneNumber);
  final office = _phoneFields(item.officePhoneNumber);

  return AddMemberState(
    editingMemberId: editingMemberId,
    currentStep: AddMemberStep.personal,
    fullName: fullName,
    personalEmail: (item.personalEmail ?? '').trim(),
    phoneDialCode: mobile.dialCode,
    phoneNumber: mobile.number,
    homePhoneDialCode: home.dialCode,
    homePhoneNumber: home.number,
    dob: _parseDate(item.dateOfBirth),
    gender: _genderFromApi(item.gender),
    maritalStatus: _maritalFromApi(item.maritalStatus),
    anniversaryDate: _parseDate(item.dateOfAnniversary),
    address: (item.addressLine1 ?? '').trim(),
    addressLine2: (item.addressLine2 ?? '').trim(),
    zipCode: (item.zipCode ?? '').trim(),
    city: (item.city ?? '').trim(),
    firstName: first,
    lastName: last,
    employeeId: (item.employeeId ?? '').trim(),
    designation: (item.designation ?? '').trim(),
    employmentStatus: _employmentToUi(item.employmentStatus),
    dateOfJoining: _parseDate(item.dateOfJoining),
    roleRows: roleRows.isEmpty ? const [AddMemberRoleRow()] : roleRows,
    officePhoneDialCode: office.dialCode,
    officePhoneNumber: office.number,
    aadharAttachment: _attachmentFromUrl(item.aadharDocumentUrl),
    panAttachment: _attachmentFromUrl(item.panDocumentUrl),
    cancelChequeAttachment: _attachmentFromUrl(item.cancelChequeDocumentUrl),
    detailLoadStatus: AddMemberDetailLoadStatus.success,
    formRevision: DateTime.now().millisecondsSinceEpoch,
  );
}

class _PhoneFields {
  const _PhoneFields({required this.dialCode, required this.number});
  final String dialCode;
  final String number;
}

_PhoneFields _phoneFields(PhoneNumberDto? dto) {
  final code = (dto?.countryCode ?? '').trim();
  final number = (dto?.number ?? '').trim();
  return _PhoneFields(
    dialCode: code.isNotEmpty ? code : '+91',
    number: number,
  );
}

AddMemberAttachment? _attachmentFromUrl(String? url) {
  final trimmed = (url ?? '').trim();
  if (trimmed.isEmpty) return null;
  final segments = trimmed.split('/');
  final fileName = segments.isNotEmpty ? segments.last : trimmed;
  return AddMemberAttachment(fileName: fileName, path: trimmed);
}

String _fullName(ListMembersItem item) {
  final full = (item.fullName ?? '').trim();
  if (full.isNotEmpty) return full;
  return '${item.firstName ?? ''} ${item.lastName ?? ''}'.trim();
}

AddMemberGender? _genderFromApi(String? api) {
  switch ((api ?? '').trim().toLowerCase()) {
    case 'male':
      return AddMemberGender.male;
    case 'female':
      return AddMemberGender.female;
    default:
      return null;
  }
}

String _maritalFromApi(String? api) {
  switch ((api ?? '').trim().toLowerCase()) {
    case 'married':
      return 'Married';
    case 'unmarried':
      return 'Unmarried';
    case 'widow':
      return 'Widow';
    default:
      return '';
  }
}

String _employmentToUi(String? api) {
  switch ((api ?? '').trim().toLowerCase()) {
    case 'active':
      return 'Active';
    case 'probation':
      return 'Probation';
    case 'on_leave':
      return 'On Leave';
    case 'contract':
      return 'Contract';
    case 'inactive':
    case 'terminated':
      return 'Active';
    default:
      return '';
  }
}

DateTime? _parseDate(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final trimmed = value.trim();
  final parsed = DateTime.tryParse(trimmed);
  if (parsed != null) return parsed;
  final dateOnly = trimmed.split(RegExp(r'[T\s]')).first;
  return DateTime.tryParse(dateOnly);
}
