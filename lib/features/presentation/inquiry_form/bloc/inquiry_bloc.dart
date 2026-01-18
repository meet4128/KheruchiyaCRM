import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'inquiry_event.dart';
import 'inquiry_state.dart';

/// BLoC for managing Inquiry form state
/// Handles all form field changes, validation, and submission
class InquiryBloc extends Bloc<InquiryEvent, InquiryState> {
  InquiryBloc() : super(const InquiryState()) {
    // Register event handlers
    on<InquiryInitialized>(_onInitialized);
    on<TitleChanged>(_onTitleChanged);
    on<FirstNameChanged>(_onFirstNameChanged);
    on<LastNameChanged>(_onLastNameChanged);
    on<PhoneChanged>(_onPhoneChanged);
    on<EmailChanged>(_onEmailChanged);
    on<AddressChanged>(_onAddressChanged);
    on<BookingTypeChanged>(_onBookingTypeChanged);
    on<ReferenceNameChanged>(_onReferenceNameChanged);
    on<ReferenceNumberChanged>(_onReferenceNumberChanged);
    on<PhoneDialCodeChanged>(_onPhoneDialCodeChanged);
    on<ReferenceDialCodeChanged>(_onReferenceDialCodeChanged);
    on<SubmitInquiry>(_onSubmitInquiry);
    
    // Support for legacy event (for backward compatibility)
    on<InquiryFieldChanged>(_onFieldChanged);
    on<InquiryBookingTypeChanged>(_onBookingTypeChangedLegacy);
    on<InquiryPhoneDialCodeChanged>(_onDialCodeChangedLegacy);
    on<InquirySubmitRequested>(_onSubmitRequestedLegacy);
  }

  /// Handle initialization event
  void _onInitialized(
    InquiryInitialized event,
    Emitter<InquiryState> emit,
  ) {
    emit(const InquiryState());
  }

  /// Handle title changed event
  void _onTitleChanged(
    TitleChanged event,
    Emitter<InquiryState> emit,
  ) {
    final error = _validateTitle(event.title);
    emit(state.copyWith(
      title: event.title,
      titleError: error,
      clearTitleError: error == null,
    ));
  }

  /// Handle first name changed event
  void _onFirstNameChanged(
    FirstNameChanged event,
    Emitter<InquiryState> emit,
  ) {
    final error = _validateFirstName(event.firstName);
    emit(state.copyWith(
      firstName: event.firstName,
      firstNameError: error,
      clearFirstNameError: error == null,
    ));
  }

  /// Handle last name changed event
  void _onLastNameChanged(
    LastNameChanged event,
    Emitter<InquiryState> emit,
  ) {
    final error = _validateLastName(event.lastName);
    emit(state.copyWith(
      lastName: event.lastName,
      lastNameError: error,
      clearLastNameError: error == null,
    ));
  }

  /// Handle phone changed event
  void _onPhoneChanged(
    PhoneChanged event,
    Emitter<InquiryState> emit,
  ) {
    final error = _validatePhone(event.phone);
    emit(state.copyWith(
      phoneNumber: event.phone,
      phoneError: error,
      clearPhoneError: error == null,
    ));
  }

  /// Handle email changed event
  void _onEmailChanged(
    EmailChanged event,
    Emitter<InquiryState> emit,
  ) {
    final error = _validateEmail(event.email);
    emit(state.copyWith(
      email: event.email,
      emailError: error,
      clearEmailError: error == null,
    ));
  }

  /// Handle address changed event
  void _onAddressChanged(
    AddressChanged event,
    Emitter<InquiryState> emit,
  ) {
    final error = _validateAddress(event.address);
    emit(state.copyWith(
      address: event.address,
      addressError: error,
      clearAddressError: error == null,
    ));
  }

  /// Handle booking type changed event
  void _onBookingTypeChanged(
    BookingTypeChanged event,
    Emitter<InquiryState> emit,
  ) {
    emit(state.copyWith(
      bookingType: event.bookingType,
      bookingTypeError: null,
      clearBookingTypeError: true,
    ));
  }

  /// Handle reference name changed event
  void _onReferenceNameChanged(
    ReferenceNameChanged event,
    Emitter<InquiryState> emit,
  ) {
    final error = _validateReferenceName(event.referenceName);
    emit(state.copyWith(
      referenceName: event.referenceName,
      referenceNameError: error,
      clearReferenceNameError: error == null,
    ));
  }

  /// Handle reference number changed event
  void _onReferenceNumberChanged(
    ReferenceNumberChanged event,
    Emitter<InquiryState> emit,
  ) {
    final error = _validateReferenceNumber(event.referenceNumber);
    emit(state.copyWith(
      referenceNumber: event.referenceNumber,
      referenceNumberError: error,
      clearReferenceNumberError: error == null,
    ));
  }

  /// Handle phone dial code changed event
  void _onPhoneDialCodeChanged(
    PhoneDialCodeChanged event,
    Emitter<InquiryState> emit,
  ) {
    emit(state.copyWith(phoneDialCode: event.dialCode));
  }

  /// Handle reference dial code changed event
  void _onReferenceDialCodeChanged(
    ReferenceDialCodeChanged event,
    Emitter<InquiryState> emit,
  ) {
    emit(state.copyWith(referenceDialCode: event.dialCode));
  }

  /// Handle submit inquiry event
  /// Validates all fields and simulates API submission
  void _onSubmitInquiry(
    SubmitInquiry event,
    Emitter<InquiryState> emit,
  ) async {
    // Don't allow submission if already submitting
    if (state.isSubmitting) {
      return;
    }

    // Validate all fields - validation happens ONLY in BLoC
    final errors = _validateAll();

    // If there are validation errors, show them and prevent submission
    final hasValidationErrors = errors.values.any((error) => error != null);
    if (hasValidationErrors) {
      emit(state.copyWith(
        titleError: errors[InquiryField.title],
        firstNameError: errors[InquiryField.firstName],
        lastNameError: errors[InquiryField.lastName],
        phoneError: errors[InquiryField.phoneNumber],
        emailError: errors[InquiryField.email],
        addressError: errors[InquiryField.address],
        bookingTypeError: errors[InquiryField.bookingType],
        referenceNameError: errors[InquiryField.referenceName],
        referenceNumberError: errors[InquiryField.referenceNumber],
        showValidationMessages: true,
        status: InquirySubmissionStatus.idle,
        errorMessage: null,
        successMessage: null,
      ));
      return;
    }

    // All validations passed - start submission
    emit(state.copyWith(
      status: InquirySubmissionStatus.submitting,
      errorMessage: null,
      successMessage: null,
    ));

    try {
      // Simulate API call using Future.delayed
      // TODO: Replace with actual API call when ready
      await Future.delayed(const Duration(seconds: 2));

      // Simulate successful API response
      emit(state.copyWith(
        status: InquirySubmissionStatus.success,
        successMessage: StringConstant.inquirySubmittedSuccessfully,
        errorMessage: null,
      ));
    } catch (e) {
      // Handle API error
      emit(state.copyWith(
        status: InquirySubmissionStatus.failure,
        errorMessage: StringConstant.inquirySubmissionFailed,
        successMessage: null,
      ));
    }
  }

  // ========== Legacy Event Handlers (for backward compatibility) ==========

  /// Legacy handler for field changed event
  void _onFieldChanged(
    InquiryFieldChanged event,
    Emitter<InquiryState> emit,
  ) {
    switch (event.field) {
      case InquiryField.title:
        add(TitleChanged(event.value));
        break;
      case InquiryField.firstName:
        add(FirstNameChanged(event.value));
        break;
      case InquiryField.lastName:
        add(LastNameChanged(event.value));
        break;
      case InquiryField.phoneNumber:
        add(PhoneChanged(event.value));
        break;
      case InquiryField.email:
        add(EmailChanged(event.value));
        break;
      case InquiryField.address:
        add(AddressChanged(event.value));
        break;
      case InquiryField.referenceName:
        add(ReferenceNameChanged(event.value));
        break;
      case InquiryField.referenceNumber:
        add(ReferenceNumberChanged(event.value));
        break;
      case InquiryField.bookingType:
        // Handled separately
        break;
    }
  }

  /// Legacy handler for booking type changed
  void _onBookingTypeChangedLegacy(
    InquiryBookingTypeChanged event,
    Emitter<InquiryState> emit,
  ) {
    add(BookingTypeChanged(event.bookingType));
  }

  /// Legacy handler for dial code changed
  void _onDialCodeChangedLegacy(
    InquiryPhoneDialCodeChanged event,
    Emitter<InquiryState> emit,
  ) {
    if (event.isReference) {
      add(ReferenceDialCodeChanged(event.dialCode));
    } else {
      add(PhoneDialCodeChanged(event.dialCode));
    }
  }

  /// Legacy handler for submit requested
  void _onSubmitRequestedLegacy(
    InquirySubmitRequested event,
    Emitter<InquiryState> emit,
  ) {
    add(const SubmitInquiry());
  }

  // ========== Validation Methods ==========

  /// Validate all fields
  Map<InquiryField, String?> _validateAll() {
    return {
      InquiryField.title: _validateTitle(state.title),
      InquiryField.firstName: _validateFirstName(state.firstName),
      InquiryField.lastName: _validateLastName(state.lastName),
      InquiryField.phoneNumber: _validatePhone(state.phoneNumber),
      InquiryField.email: _validateEmail(state.email),
      InquiryField.address: _validateAddress(state.address),
      InquiryField.bookingType: state.bookingType == null
          ? StringConstant.typeOfBookingRequired
          : null,
      InquiryField.referenceName: _validateReferenceName(state.referenceName),
      InquiryField.referenceNumber:
          _validateReferenceNumber(state.referenceNumber),
    };
  }

  /// Validate title
  String? _validateTitle(String value) {
    if (value.trim().isEmpty) {
      return StringConstant.titleRequired;
    }
    return null;
  }

  /// Validate first name
  String? _validateFirstName(String value) {
    if (value.trim().isEmpty) {
      return StringConstant.firstNameRequired;
    }
    if (value.trim().length < 2) {
      return StringConstant.firstNameMinLength;
    }
    return null;
  }

  /// Validate last name
  String? _validateLastName(String value) {
    if (value.trim().isEmpty) {
      return StringConstant.lastNameRequired;
    }
    if (value.trim().length < 2) {
      return StringConstant.lastNameMinLength;
    }
    return null;
  }

  /// Validate phone number
  String? _validatePhone(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return StringConstant.phoneNumberRequired;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(trimmed)) {
      return StringConstant.phoneNumberDigitsOnly;
    }
    if (trimmed.length < 6 || trimmed.length > 15) {
      return StringConstant.phoneNumberLength;
    }
    return null;
  }

  /// Validate email
  String? _validateEmail(String value) {
    if (value.trim().isEmpty) {
      return StringConstant.emailRequired;
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return StringConstant.emailInvalid;
    }
    return null;
  }

  /// Validate address
  String? _validateAddress(String value) {
    if (value.trim().isEmpty) {
      return StringConstant.addressRequired;
    }
    if (value.trim().length < 5) {
      return StringConstant.addressMinLength;
    }
    return null;
  }

  /// Validate reference name
  String? _validateReferenceName(String value) {
    if (value.trim().isEmpty) {
      return StringConstant.referenceNameRequired;
    }
    if (value.trim().length < 2) {
      return StringConstant.referenceNameMinLength;
    }
    return null;
  }

  /// Validate reference number
  String? _validateReferenceNumber(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return StringConstant.referenceNumberRequired;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(trimmed)) {
      return StringConstant.referenceNumberDigitsOnly;
    }
    if (trimmed.length < 6 || trimmed.length > 15) {
      return StringConstant.referenceNumberLength;
    }
    return null;
  }
}
