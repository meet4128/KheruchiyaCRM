import 'package:equatable/equatable.dart';

import 'vendor_inquiry_event.dart';

/// State for the Vendor Inquiry (Step 1) form.
/// All validation lives in the BLoC — the UI stays dumb and reads errors here.
class VendorInquiryState extends Equatable {
  const VendorInquiryState({
    this.fullName = '',
    this.phoneDialCode = '+91',
    this.phoneNumber = '',
    this.email = '',
    this.designation = '',
    this.specializeIn = '',
    this.subSpecializeIn = '',
    this.address = '',
    this.fullNameError,
    this.phoneError,
    this.emailError,
    this.designationError,
    this.specializeInError,
    this.subSpecializeInError,
    this.addressError,
    this.showValidationMessages = false,
    this.pendingNavigateToStep2 = false,
  });

  // Form fields
  final String fullName;
  final String phoneDialCode;
  final String phoneNumber;
  final String email;
  final String designation;
  final String specializeIn;
  final String subSpecializeIn;
  final String address;

  // Validation errors
  final String? fullNameError;
  final String? phoneError;
  final String? emailError;
  final String? designationError;
  final String? specializeInError;
  final String? subSpecializeInError;
  final String? addressError;

  // UI state
  final bool showValidationMessages;

  /// Set to true when NEXT is pressed and Step 1 is valid; the view navigates
  /// to Step 2 then dispatches [ClearPendingNavigateToStep2].
  final bool pendingNavigateToStep2;

  bool get hasErrors =>
      fullNameError != null ||
      phoneError != null ||
      emailError != null ||
      designationError != null ||
      specializeInError != null ||
      subSpecializeInError != null ||
      addressError != null;

  /// Field errors as a map (parallels [VendorInquiryField]).
  Map<VendorInquiryField, String?> get fieldErrors => {
        VendorInquiryField.fullName: fullNameError,
        VendorInquiryField.phoneNumber: phoneError,
        VendorInquiryField.email: emailError,
        VendorInquiryField.designation: designationError,
        VendorInquiryField.specializeIn: specializeInError,
        VendorInquiryField.subSpecializeIn: subSpecializeInError,
        VendorInquiryField.address: addressError,
      };

  VendorInquiryState copyWith({
    String? fullName,
    String? phoneDialCode,
    String? phoneNumber,
    String? email,
    String? designation,
    String? specializeIn,
    String? subSpecializeIn,
    String? address,
    String? fullNameError,
    String? phoneError,
    String? emailError,
    String? designationError,
    String? specializeInError,
    String? subSpecializeInError,
    String? addressError,
    bool? showValidationMessages,
    bool? pendingNavigateToStep2,
    bool clearFullNameError = false,
    bool clearPhoneError = false,
    bool clearEmailError = false,
    bool clearDesignationError = false,
    bool clearSpecializeInError = false,
    bool clearSubSpecializeInError = false,
    bool clearAddressError = false,
  }) {
    return VendorInquiryState(
      fullName: fullName ?? this.fullName,
      phoneDialCode: phoneDialCode ?? this.phoneDialCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      designation: designation ?? this.designation,
      specializeIn: specializeIn ?? this.specializeIn,
      subSpecializeIn: subSpecializeIn ?? this.subSpecializeIn,
      address: address ?? this.address,
      fullNameError: clearFullNameError
          ? null
          : (fullNameError ?? (fullName != null ? null : this.fullNameError)),
      phoneError: clearPhoneError
          ? null
          : (phoneError ?? (phoneNumber != null ? null : this.phoneError)),
      emailError: clearEmailError
          ? null
          : (emailError ?? (email != null ? null : this.emailError)),
      designationError: clearDesignationError
          ? null
          : (designationError ??
              (designation != null ? null : this.designationError)),
      specializeInError: clearSpecializeInError
          ? null
          : (specializeInError ??
              (specializeIn != null ? null : this.specializeInError)),
      subSpecializeInError: clearSubSpecializeInError
          ? null
          : (subSpecializeInError ??
              (subSpecializeIn != null ? null : this.subSpecializeInError)),
      addressError: clearAddressError
          ? null
          : (addressError ?? (address != null ? null : this.addressError)),
      showValidationMessages:
          showValidationMessages ?? this.showValidationMessages,
      pendingNavigateToStep2:
          pendingNavigateToStep2 ?? this.pendingNavigateToStep2,
    );
  }

  @override
  List<Object?> get props => [
        fullName,
        phoneDialCode,
        phoneNumber,
        email,
        designation,
        specializeIn,
        subSpecializeIn,
        address,
        fullNameError,
        phoneError,
        emailError,
        designationError,
        specializeInError,
        subSpecializeInError,
        addressError,
        showValidationMessages,
        pendingNavigateToStep2,
      ];
}
