import 'package:equatable/equatable.dart';

enum AddMemberGender { male, female }

enum AddMemberSubmitStatus { initial, invalid, valid, submitting, success, failure }

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
        status,
        editingMemberId,
        submitErrorMessage,
      ];
}
