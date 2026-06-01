import 'package:equatable/equatable.dart';
import 'package:travel_crm/data/models/members/invite_result_dto.dart';
import 'package:travel_crm/data/models/members/list_members_item.dart';

enum AddMemberGender { male, female }

enum AddMemberSubmitStatus { initial, invalid, valid, submitting, success, failure }

/// Loading state for `GET /members/:id` when opening edit.
enum AddMemberDetailLoadStatus { idle, loading, success, failure }

/// Which email gets the invitation link when a new member is created.
///
/// - [personal] → backend uses `personalEmail` from the member record. We omit
///   `inviteEmail` from the request body so the backend default kicks in.
/// - [work]    → reserved for a future "work email" field on the member
///   record. The selector option is rendered but disabled until that field
///   exists; today this case maps to the same behaviour as [personal].
/// - [custom]  → admin typed a different address; we send it as `inviteEmail`.
enum AddMemberInviteEmailChoice { personal, work, custom }

/// Wizard step for Add Member dialog ([add_member_submit.md] Phase 1+).
enum AddMemberStep {
  personal,
  operation,
}

/// Document slot for Step 2 ([add_member_submit.md] Phase 4).
enum AddMemberAttachmentKind {
  aadhar,
  pan,
  cancelCheque,
}

class AddMemberAttachment extends Equatable {
  const AddMemberAttachment({required this.fileName, this.path});

  final String fileName;
  final String? path;

  @override
  List<Object?> get props => [fileName, path];
}

/// One department + role pair ([add_member_submit.md] Phase 3).
class AddMemberRoleRow extends Equatable {
  const AddMemberRoleRow({this.department = '', this.role = ''});

  final String department;
  final String role;

  AddMemberRoleRow copyWith({String? department, String? role}) {
    return AddMemberRoleRow(
      department: department ?? this.department,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [department, role];
}

class AddMemberState extends Equatable {
  const AddMemberState({
    this.currentStep = AddMemberStep.personal,
    this.fullName = '',
    this.personalEmail = '',
    this.phoneDialCode = '+91',
    this.phoneNumber = '',
    this.homePhoneDialCode = '+91',
    this.homePhoneNumber = '',
    this.dob,
    this.gender,
    this.maritalStatus = '',
    this.anniversaryDate,
    this.address = '',
    this.addressLine2 = '',
    this.zipCode = '',
    this.city = '',
    this.firstName = '',
    this.lastName = '',
    this.employeeId = '',
    this.designation = '',
    this.employmentStatus = '',
    this.dateOfJoining,
    this.roleRows = const [AddMemberRoleRow()],
    this.officePhoneDialCode = '+91',
    this.officePhoneNumber = '',
    this.aadharAttachment,
    this.panAttachment,
    this.cancelChequeAttachment,
    this.fullNameError,
    this.personalEmailError,
    this.phoneNumberError,
    this.homePhoneNumberError,
    this.dobError,
    this.genderError,
    this.maritalStatusError,
    this.addressError,
    this.zipCodeError,
    this.cityError,
    this.firstNameError,
    this.lastNameError,
    this.employeeIdError,
    this.designationError,
    this.employmentStatusError,
    this.dateOfJoiningError,
    this.roleRowsError,
    this.officePhoneNumberError,
    this.inviteEmailChoice = AddMemberInviteEmailChoice.personal,
    this.customInviteEmail = '',
    this.customInviteEmailError,
    this.sendInvite = true,
    this.lastInviteResult,
    this.lastCreatedMemberId,
    this.lastUpdatedMember,
    this.detailLoadStatus = AddMemberDetailLoadStatus.idle,
    this.detailLoadErrorMessage,
    this.status = AddMemberSubmitStatus.initial,
    this.editingMemberId,
    this.submitErrorMessage,
  });

  final AddMemberStep currentStep;
  final String fullName;
  final String personalEmail;
  final String phoneDialCode;
  final String phoneNumber;
  final String homePhoneDialCode;
  final String homePhoneNumber;
  final DateTime? dob;
  final AddMemberGender? gender;
  final String maritalStatus;
  final DateTime? anniversaryDate;
  final String address;
  final String addressLine2;
  final String zipCode;
  final String city;

  /// Step 2 — Operation Information ([add_member_submit.md] Phase 2–4).
  final String firstName;
  final String lastName;
  final String employeeId;
  final String designation;
  final String employmentStatus;
  final DateTime? dateOfJoining;
  final List<AddMemberRoleRow> roleRows;
  final String officePhoneDialCode;
  final String officePhoneNumber;
  final AddMemberAttachment? aadharAttachment;
  final AddMemberAttachment? panAttachment;
  final AddMemberAttachment? cancelChequeAttachment;

  final String? fullNameError;
  final String? personalEmailError;
  final String? phoneNumberError;
  final String? homePhoneNumberError;
  final String? dobError;
  final String? genderError;
  final String? maritalStatusError;
  final String? addressError;
  final String? zipCodeError;
  final String? cityError;
  final String? firstNameError;
  final String? lastNameError;
  final String? employeeIdError;
  final String? designationError;
  final String? employmentStatusError;
  final String? dateOfJoiningError;
  final String? roleRowsError;
  final String? officePhoneNumberError;

  /// Invite section (only shown on the create flow). Defaults: send the invite
  /// to the personal email. See [AddMemberInviteEmailChoice] for the semantics
  /// of each value.
  final AddMemberInviteEmailChoice inviteEmailChoice;
  final String customInviteEmail;
  final String? customInviteEmailError;

  /// When `false` the bloc sends `sendInvite: false` so the backend skips the
  /// email; admin can resend it later from the team list.
  final bool sendInvite;

  /// Populated **only on a successful create** so the dialog footer can render
  /// the invite-specific SnackBar (`Invite sent to alice@…` vs. `Member
  /// created, click Resend …`). Null otherwise (e.g. PATCH on edit).
  final InviteResultDto? lastInviteResult;

  /// Real server id from `POST /members` — used when stamping the team row.
  final String? lastCreatedMemberId;

  /// Populated after a successful PATCH — drives list refresh from server.
  final ListMembersItem? lastUpdatedMember;

  final AddMemberDetailLoadStatus detailLoadStatus;
  final String? detailLoadErrorMessage;

  final AddMemberSubmitStatus status;

  /// Server member id when opened from team table **Edit** (PATCH on submit).
  final String? editingMemberId;

  /// Last submit failure message (shown in SnackBar; cleared on next submit).
  final String? submitErrorMessage;

  AddMemberState copyWith({
    AddMemberStep? currentStep,
    String? fullName,
    String? personalEmail,
    String? phoneDialCode,
    String? phoneNumber,
    String? homePhoneDialCode,
    String? homePhoneNumber,
    DateTime? dob,
    bool clearDob = false,
    AddMemberGender? gender,
    bool clearGender = false,
    String? maritalStatus,
    DateTime? anniversaryDate,
    bool clearAnniversaryDate = false,
    String? address,
    String? addressLine2,
    String? zipCode,
    String? city,
    String? firstName,
    String? lastName,
    String? employeeId,
    String? designation,
    String? employmentStatus,
    DateTime? dateOfJoining,
    bool clearDateOfJoining = false,
    List<AddMemberRoleRow>? roleRows,
    String? officePhoneDialCode,
    String? officePhoneNumber,
    AddMemberAttachment? aadharAttachment,
    bool clearAadharAttachment = false,
    AddMemberAttachment? panAttachment,
    bool clearPanAttachment = false,
    AddMemberAttachment? cancelChequeAttachment,
    bool clearCancelChequeAttachment = false,
    String? fullNameError,
    String? personalEmailError,
    String? phoneNumberError,
    String? homePhoneNumberError,
    String? dobError,
    String? genderError,
    String? maritalStatusError,
    String? addressError,
    String? zipCodeError,
    String? cityError,
    String? firstNameError,
    String? lastNameError,
    String? employeeIdError,
    String? designationError,
    String? employmentStatusError,
    String? dateOfJoiningError,
    String? roleRowsError,
    String? officePhoneNumberError,
    bool clearFieldErrors = false,
    AddMemberInviteEmailChoice? inviteEmailChoice,
    String? customInviteEmail,
    String? customInviteEmailError,
    bool clearCustomInviteEmailError = false,
    bool? sendInvite,
    InviteResultDto? lastInviteResult,
    bool clearLastInviteResult = false,
    String? lastCreatedMemberId,
    bool clearLastCreatedMemberId = false,
    ListMembersItem? lastUpdatedMember,
    bool clearLastUpdatedMember = false,
    AddMemberDetailLoadStatus? detailLoadStatus,
    String? detailLoadErrorMessage,
    bool clearDetailLoadErrorMessage = false,
    AddMemberSubmitStatus? status,
    String? editingMemberId,
    bool clearEditingMemberId = false,
    String? submitErrorMessage,
    bool clearSubmitErrorMessage = false,
  }) {
    return AddMemberState(
      currentStep: currentStep ?? this.currentStep,
      fullName: fullName ?? this.fullName,
      personalEmail: personalEmail ?? this.personalEmail,
      phoneDialCode: phoneDialCode ?? this.phoneDialCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      homePhoneDialCode: homePhoneDialCode ?? this.homePhoneDialCode,
      homePhoneNumber: homePhoneNumber ?? this.homePhoneNumber,
      dob: clearDob ? null : (dob ?? this.dob),
      gender: clearGender ? null : (gender ?? this.gender),
      maritalStatus: maritalStatus ?? this.maritalStatus,
      anniversaryDate: clearAnniversaryDate ? null : (anniversaryDate ?? this.anniversaryDate),
      address: address ?? this.address,
      addressLine2: addressLine2 ?? this.addressLine2,
      zipCode: zipCode ?? this.zipCode,
      city: city ?? this.city,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      employeeId: employeeId ?? this.employeeId,
      designation: designation ?? this.designation,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      dateOfJoining: clearDateOfJoining ? null : (dateOfJoining ?? this.dateOfJoining),
      roleRows: roleRows ?? this.roleRows,
      officePhoneDialCode: officePhoneDialCode ?? this.officePhoneDialCode,
      officePhoneNumber: officePhoneNumber ?? this.officePhoneNumber,
      aadharAttachment: clearAadharAttachment ? null : (aadharAttachment ?? this.aadharAttachment),
      panAttachment: clearPanAttachment ? null : (panAttachment ?? this.panAttachment),
      cancelChequeAttachment: clearCancelChequeAttachment
          ? null
          : (cancelChequeAttachment ?? this.cancelChequeAttachment),
      fullNameError: clearFieldErrors ? null : fullNameError,
      personalEmailError: clearFieldErrors ? null : personalEmailError,
      phoneNumberError: clearFieldErrors ? null : phoneNumberError,
      homePhoneNumberError: clearFieldErrors ? null : homePhoneNumberError,
      dobError: clearFieldErrors ? null : dobError,
      genderError: clearFieldErrors ? null : genderError,
      maritalStatusError: clearFieldErrors ? null : maritalStatusError,
      addressError: clearFieldErrors ? null : addressError,
      zipCodeError: clearFieldErrors ? null : zipCodeError,
      cityError: clearFieldErrors ? null : cityError,
      firstNameError: clearFieldErrors ? null : firstNameError,
      lastNameError: clearFieldErrors ? null : lastNameError,
      employeeIdError: clearFieldErrors ? null : employeeIdError,
      designationError: clearFieldErrors ? null : designationError,
      employmentStatusError: clearFieldErrors ? null : employmentStatusError,
      dateOfJoiningError: clearFieldErrors ? null : dateOfJoiningError,
      roleRowsError: clearFieldErrors ? null : roleRowsError,
      officePhoneNumberError: clearFieldErrors ? null : officePhoneNumberError,
      inviteEmailChoice: inviteEmailChoice ?? this.inviteEmailChoice,
      customInviteEmail: customInviteEmail ?? this.customInviteEmail,
      customInviteEmailError: clearCustomInviteEmailError
          ? null
          : (customInviteEmailError ?? this.customInviteEmailError),
      sendInvite: sendInvite ?? this.sendInvite,
      lastInviteResult:
          clearLastInviteResult ? null : (lastInviteResult ?? this.lastInviteResult),
      lastCreatedMemberId: clearLastCreatedMemberId
          ? null
          : (lastCreatedMemberId ?? this.lastCreatedMemberId),
      lastUpdatedMember: clearLastUpdatedMember
          ? null
          : (lastUpdatedMember ?? this.lastUpdatedMember),
      detailLoadStatus: detailLoadStatus ?? this.detailLoadStatus,
      detailLoadErrorMessage: clearDetailLoadErrorMessage
          ? null
          : (detailLoadErrorMessage ?? this.detailLoadErrorMessage),
      status: status ?? this.status,
      editingMemberId: clearEditingMemberId ? null : (editingMemberId ?? this.editingMemberId),
      submitErrorMessage: clearSubmitErrorMessage ? null : (submitErrorMessage ?? this.submitErrorMessage),
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        fullName,
        personalEmail,
        phoneDialCode,
        phoneNumber,
        homePhoneDialCode,
        homePhoneNumber,
        dob,
        gender,
        maritalStatus,
        anniversaryDate,
        address,
        addressLine2,
        zipCode,
        city,
        firstName,
        lastName,
        employeeId,
        designation,
        employmentStatus,
        dateOfJoining,
        roleRows,
        officePhoneDialCode,
        officePhoneNumber,
        aadharAttachment,
        panAttachment,
        cancelChequeAttachment,
        fullNameError,
        personalEmailError,
        phoneNumberError,
        homePhoneNumberError,
        dobError,
        genderError,
        maritalStatusError,
        addressError,
        zipCodeError,
        cityError,
        firstNameError,
        lastNameError,
        employeeIdError,
        designationError,
        employmentStatusError,
        dateOfJoiningError,
        roleRowsError,
        officePhoneNumberError,
        inviteEmailChoice,
        customInviteEmail,
        customInviteEmailError,
        sendInvite,
        lastInviteResult,
        lastCreatedMemberId,
        lastUpdatedMember,
        detailLoadStatus,
        detailLoadErrorMessage,
        status,
        editingMemberId,
        submitErrorMessage,
      ];
}
