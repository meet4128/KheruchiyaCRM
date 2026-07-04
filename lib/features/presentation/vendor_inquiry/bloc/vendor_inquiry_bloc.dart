import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/constants/string_constants.dart';

import 'vendor_inquiry_event.dart';
import 'vendor_inquiry_state.dart';

/// BLoC for the Vendor Inquiry (Step 1) form.
/// Handles field changes, validation, and the NEXT → Step 2 gate. Mirrors the
/// [InquiryBloc] structure (all validation lives here; UI stays dumb).
class VendorInquiryBloc extends Bloc<VendorInquiryEvent, VendorInquiryState> {
  VendorInquiryBloc() : super(const VendorInquiryState()) {
    on<VendorInquiryInitialized>(_onInitialized);
    on<ResetVendorInquiryForm>(_onReset);
    on<VendorFullNameChanged>(_onFullNameChanged);
    on<VendorPhoneChanged>(_onPhoneChanged);
    on<VendorPhoneDialCodeChanged>(_onPhoneDialCodeChanged);
    on<VendorEmailChanged>(_onEmailChanged);
    on<VendorDesignationChanged>(_onDesignationChanged);
    on<VendorSpecializeInChanged>(_onSpecializeInChanged);
    on<VendorSubSpecializeInChanged>(_onSubSpecializeInChanged);
    on<VendorAddressChanged>(_onAddressChanged);
    on<VendorNextPressed>(_onNextPressed);
    on<ClearPendingNavigateToStep2>(_onClearPendingNavigateToStep2);
  }

  void _onInitialized(
    VendorInquiryInitialized event,
    Emitter<VendorInquiryState> emit,
  ) {
    emit(const VendorInquiryState());
  }

  void _onReset(
    ResetVendorInquiryForm event,
    Emitter<VendorInquiryState> emit,
  ) {
    emit(const VendorInquiryState());
  }

  void _onFullNameChanged(
    VendorFullNameChanged event,
    Emitter<VendorInquiryState> emit,
  ) {
    final error = _validateFullName(event.fullName);
    emit(state.copyWith(
      fullName: event.fullName,
      fullNameError: error,
      clearFullNameError: error == null,
    ));
  }

  void _onPhoneChanged(
    VendorPhoneChanged event,
    Emitter<VendorInquiryState> emit,
  ) {
    final error = _validatePhone(event.phone);
    emit(state.copyWith(
      phoneNumber: event.phone,
      phoneError: error,
      clearPhoneError: error == null,
    ));
  }

  void _onPhoneDialCodeChanged(
    VendorPhoneDialCodeChanged event,
    Emitter<VendorInquiryState> emit,
  ) {
    emit(state.copyWith(phoneDialCode: event.dialCode));
  }

  void _onEmailChanged(
    VendorEmailChanged event,
    Emitter<VendorInquiryState> emit,
  ) {
    final error = _validateEmail(event.email);
    emit(state.copyWith(
      email: event.email,
      emailError: error,
      clearEmailError: error == null,
    ));
  }

  void _onDesignationChanged(
    VendorDesignationChanged event,
    Emitter<VendorInquiryState> emit,
  ) {
    final error = _validateDesignation(event.designation);
    emit(state.copyWith(
      designation: event.designation,
      designationError: error,
      clearDesignationError: error == null,
    ));
  }

  void _onSpecializeInChanged(
    VendorSpecializeInChanged event,
    Emitter<VendorInquiryState> emit,
  ) {
    final error = _validateSpecializeIn(event.specializeIn);
    emit(state.copyWith(
      specializeIn: event.specializeIn,
      specializeInError: error,
      clearSpecializeInError: error == null,
    ));
  }

  void _onSubSpecializeInChanged(
    VendorSubSpecializeInChanged event,
    Emitter<VendorInquiryState> emit,
  ) {
    final error = _validateSubSpecializeIn(event.subSpecializeIn);
    emit(state.copyWith(
      subSpecializeIn: event.subSpecializeIn,
      subSpecializeInError: error,
      clearSubSpecializeInError: error == null,
    ));
  }

  void _onAddressChanged(
    VendorAddressChanged event,
    Emitter<VendorInquiryState> emit,
  ) {
    final error = _validateAddress(event.address);
    emit(state.copyWith(
      address: event.address,
      addressError: error,
      clearAddressError: error == null,
    ));
  }

  /// Validates Step 1. When valid, flags [VendorInquiryState.pendingNavigateToStep2]
  /// so the view routes to Step 2; otherwise surfaces all field errors.
  void _onNextPressed(
    VendorNextPressed event,
    Emitter<VendorInquiryState> emit,
  ) {
    final errors = _validateAll();
    final hasErrors = errors.values.any((e) => e != null);

    if (hasErrors) {
      emit(state.copyWith(
        fullNameError: errors[VendorInquiryField.fullName],
        phoneError: errors[VendorInquiryField.phoneNumber],
        emailError: errors[VendorInquiryField.email],
        designationError: errors[VendorInquiryField.designation],
        specializeInError: errors[VendorInquiryField.specializeIn],
        subSpecializeInError: errors[VendorInquiryField.subSpecializeIn],
        addressError: errors[VendorInquiryField.address],
        showValidationMessages: true,
        pendingNavigateToStep2: false,
      ));
      return;
    }

    emit(state.copyWith(pendingNavigateToStep2: true));
  }

  void _onClearPendingNavigateToStep2(
    ClearPendingNavigateToStep2 event,
    Emitter<VendorInquiryState> emit,
  ) {
    emit(state.copyWith(pendingNavigateToStep2: false));
  }

  // ========== Validation ==========

  Map<VendorInquiryField, String?> _validateAll() {
    return {
      VendorInquiryField.fullName: _validateFullName(state.fullName),
      VendorInquiryField.phoneNumber: _validatePhone(state.phoneNumber),
      VendorInquiryField.email: _validateEmail(state.email),
      VendorInquiryField.designation: _validateDesignation(state.designation),
      VendorInquiryField.specializeIn:
          _validateSpecializeIn(state.specializeIn),
      VendorInquiryField.subSpecializeIn:
          _validateSubSpecializeIn(state.subSpecializeIn),
      VendorInquiryField.address: _validateAddress(state.address),
    };
  }

  String? _validateFullName(String value) {
    if (value.trim().isEmpty) return StringConstant.fullNameRequired;
    if (value.trim().length < 2) return StringConstant.firstNameMinLength;
    return null;
  }

  String? _validatePhone(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return StringConstant.phoneNumberRequired;
    if (!RegExp(r'^[0-9]+$').hasMatch(trimmed)) {
      return StringConstant.phoneNumberDigitsOnly;
    }
    if (trimmed.length < 6 || trimmed.length > 15) {
      return StringConstant.phoneNumberLength;
    }
    return null;
  }

  String? _validateEmail(String value) {
    if (value.trim().isEmpty) return StringConstant.emailRequired;
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return StringConstant.emailInvalid;
    }
    return null;
  }

  String? _validateDesignation(String value) {
    if (value.trim().isEmpty) return StringConstant.designationRequired;
    return null;
  }

  String? _validateSpecializeIn(String value) {
    if (value.trim().isEmpty) return StringConstant.specializeInRequired;
    return null;
  }

  String? _validateSubSpecializeIn(String value) {
    if (value.trim().isEmpty) return StringConstant.subSpecializeInRequired;
    return null;
  }

  String? _validateAddress(String value) {
    if (value.trim().isEmpty) return StringConstant.addressRequired;
    if (value.trim().length < 5) return StringConstant.addressMinLength;
    return null;
  }
}
