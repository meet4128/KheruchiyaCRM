import 'package:equatable/equatable.dart';
import 'inquiry_event.dart';

/// Submission status enum
enum InquirySubmissionStatus {
  idle,
  submitting,
  success,
  failure,
}

/// State class for Inquiry form
class InquiryState extends Equatable {
  const InquiryState({
    this.title = '',
    this.firstName = '',
    this.lastName = '',
    this.phoneDialCode = '+91',
    this.phoneNumber = '',
    this.email = '',
    this.address = '',
    this.bookingType,
    this.referenceName = '',
    this.referenceDialCode = '+91',
    this.referenceNumber = '',
    this.titleError,
    this.firstNameError,
    this.lastNameError,
    this.phoneError,
    this.emailError,
    this.addressError,
    this.bookingTypeError,
    this.referenceNameError,
    this.referenceNumberError,
    this.showValidationMessages = false,
    this.status = InquirySubmissionStatus.idle,
    this.successMessage,
    this.errorMessage,
  });

  // Form fields
  final String title;
  final String firstName;
  final String lastName;
  final String phoneDialCode;
  final String phoneNumber;
  final String email;
  final String address;
  final BookingType? bookingType;
  final String referenceName;
  final String referenceDialCode;
  final String referenceNumber;

  // Validation errors
  final String? titleError;
  final String? firstNameError;
  final String? lastNameError;
  final String? phoneError;
  final String? emailError;
  final String? addressError;
  final String? bookingTypeError;
  final String? referenceNameError;
  final String? referenceNumberError;

  // UI state
  final bool showValidationMessages;
  final InquirySubmissionStatus status;
  final String? successMessage;
  final String? errorMessage;

  /// Check if form has any errors
  bool get hasErrors =>
      titleError != null ||
      firstNameError != null ||
      lastNameError != null ||
      phoneError != null ||
      emailError != null ||
      addressError != null ||
      bookingTypeError != null ||
      referenceNameError != null ||
      referenceNumberError != null;

  /// Check if form is submitting
  bool get isSubmitting => status == InquirySubmissionStatus.submitting;

  /// Check if form submission was successful
  bool get isSuccess => status == InquirySubmissionStatus.success;

  /// Check if form submission was successful (alias for isSuccess)
  bool get isSubmitted => status == InquirySubmissionStatus.success;

  /// Check if form is valid (no errors and all required fields filled)
  /// This is computed from state - UI remains dumb
  bool get isValid {
    // First check: No validation errors present
    if (hasErrors) return false;
    
    // Second check: All required fields are filled
    if (title.trim().isEmpty) return false;
    if (firstName.trim().isEmpty) return false;
    if (lastName.trim().isEmpty) return false;
    if (phoneNumber.trim().isEmpty) return false;
    if (email.trim().isEmpty) return false;
    if (address.trim().isEmpty) return false;
    if (bookingType == null) return false;
    if (referenceName.trim().isEmpty) return false;
    if (referenceNumber.trim().isEmpty) return false;
    
    // All checks passed - form is valid
    return true;
  }

  /// Get field errors as a map (for backward compatibility with existing view)
  Map<InquiryField, String?> get fieldErrors => {
        InquiryField.title: titleError,
        InquiryField.firstName: firstNameError,
        InquiryField.lastName: lastNameError,
        InquiryField.phoneNumber: phoneError,
        InquiryField.email: emailError,
        InquiryField.address: addressError,
        InquiryField.bookingType: bookingTypeError,
        InquiryField.referenceName: referenceNameError,
        InquiryField.referenceNumber: referenceNumberError,
      };

  /// Create a copy of the state with updated values
  InquiryState copyWith({
    String? title,
    String? firstName,
    String? lastName,
    String? phoneDialCode,
    String? phoneNumber,
    String? email,
    String? address,
    BookingType? bookingType,
    String? referenceName,
    String? referenceDialCode,
    String? referenceNumber,
    String? titleError,
    String? firstNameError,
    String? lastNameError,
    String? phoneError,
    String? emailError,
    String? addressError,
    String? bookingTypeError,
    String? referenceNameError,
    String? referenceNumberError,
    bool? showValidationMessages,
    InquirySubmissionStatus? status,
    String? successMessage,
    String? errorMessage,
    bool clearTitleError = false,
    bool clearFirstNameError = false,
    bool clearLastNameError = false,
    bool clearPhoneError = false,
    bool clearEmailError = false,
    bool clearAddressError = false,
    bool clearBookingTypeError = false,
    bool clearReferenceNameError = false,
    bool clearReferenceNumberError = false,
  }) {
    return InquiryState(
      title: title ?? this.title,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneDialCode: phoneDialCode ?? this.phoneDialCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      bookingType: bookingType ?? this.bookingType,
      referenceName: referenceName ?? this.referenceName,
      referenceDialCode: referenceDialCode ?? this.referenceDialCode,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      titleError: clearTitleError
          ? null
          : (titleError ?? (title != null ? null : this.titleError)),
      firstNameError: clearFirstNameError
          ? null
          : (firstNameError ??
              (firstName != null ? null : this.firstNameError)),
      lastNameError: clearLastNameError
          ? null
          : (lastNameError ?? (lastName != null ? null : this.lastNameError)),
      phoneError: clearPhoneError
          ? null
          : (phoneError ?? (phoneNumber != null ? null : this.phoneError)),
      emailError: clearEmailError
          ? null
          : (emailError ?? (email != null ? null : this.emailError)),
      addressError: clearAddressError
          ? null
          : (addressError ?? (address != null ? null : this.addressError)),
      bookingTypeError: clearBookingTypeError
          ? null
          : (bookingTypeError ??
              (bookingType != null ? null : this.bookingTypeError)),
      referenceNameError: clearReferenceNameError
          ? null
          : (referenceNameError ??
              (referenceName != null ? null : this.referenceNameError)),
      referenceNumberError: clearReferenceNumberError
          ? null
          : (referenceNumberError ??
              (referenceNumber != null ? null : this.referenceNumberError)),
      showValidationMessages:
          showValidationMessages ?? this.showValidationMessages,
      status: status ?? this.status,
      successMessage: successMessage ?? this.successMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        title,
        firstName,
        lastName,
        phoneDialCode,
        phoneNumber,
        email,
        address,
        bookingType,
        referenceName,
        referenceDialCode,
        referenceNumber,
        titleError,
        firstNameError,
        lastNameError,
        phoneError,
        emailError,
        addressError,
        bookingTypeError,
        referenceNameError,
        referenceNumberError,
        showValidationMessages,
        status,
        successMessage,
        errorMessage,
      ];
}
