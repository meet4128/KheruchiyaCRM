import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/constants/string_constants.dart';

import 'vendor_company_details_event.dart';
import 'vendor_company_details_state.dart';

/// BLoC for the Vendor Company Details (Step 2) form.
/// Mirrors the established pattern: per-field change events, all validation in
/// the BLoC, and a simulated submission (no vendor endpoint yet).
class VendorCompanyDetailsBloc
    extends Bloc<VendorCompanyDetailsEvent, VendorCompanyDetailsState> {
  VendorCompanyDetailsBloc() : super(const VendorCompanyDetailsState()) {
    on<VendorCompanyNameChanged>(_onCompanyNameChanged);
    on<VendorCompanyAddressChanged>(_onCompanyAddressChanged);
    on<VendorGstNoChanged>(_onGstNoChanged);
    on<VendorPanCardChanged>(_onPanCardChanged);
    on<VendorBankNameChanged>(_onBankNameChanged);
    on<VendorAccountNoChanged>(_onAccountNoChanged);
    on<VendorIfscCodeChanged>(_onIfscCodeChanged);
    on<VendorAttachQrChanged>(_onAttachQrChanged);
    on<VendorAttachVisitingCardChanged>(_onAttachVisitingCardChanged);
    on<VendorServiceRatingChanged>(_onServiceRatingChanged);
    on<VendorServicePricingChanged>(_onServicePricingChanged);
    on<VendorNoteChanged>(_onNoteChanged);
    on<SubmitVendorCompanyDetails>(_onSubmit);
    on<ResetVendorCompanyDetailsForm>(_onReset);
  }

  void _onCompanyNameChanged(
    VendorCompanyNameChanged event,
    Emitter<VendorCompanyDetailsState> emit,
  ) {
    final error = _validateRequired(event.value, StringConstant.companyNameRequired);
    emit(state.copyWith(
      companyName: event.value,
      companyNameError: error,
      clearCompanyNameError: error == null,
    ));
  }

  void _onCompanyAddressChanged(
    VendorCompanyAddressChanged event,
    Emitter<VendorCompanyDetailsState> emit,
  ) {
    final error = _validateRequired(
        event.value, StringConstant.companyAddressRequired);
    emit(state.copyWith(
      companyAddress: event.value,
      companyAddressError: error,
      clearCompanyAddressError: error == null,
    ));
  }

  void _onGstNoChanged(
    VendorGstNoChanged event,
    Emitter<VendorCompanyDetailsState> emit,
  ) {
    final error = _validateRequired(event.value, StringConstant.gstNoRequired);
    emit(state.copyWith(
      gstNo: event.value,
      gstNoError: error,
      clearGstNoError: error == null,
    ));
  }

  void _onPanCardChanged(
    VendorPanCardChanged event,
    Emitter<VendorCompanyDetailsState> emit,
  ) {
    final error = _validateRequired(event.value, StringConstant.panCardRequired);
    emit(state.copyWith(
      panCard: event.value,
      panCardError: error,
      clearPanCardError: error == null,
    ));
  }

  void _onBankNameChanged(
    VendorBankNameChanged event,
    Emitter<VendorCompanyDetailsState> emit,
  ) {
    emit(state.copyWith(
      bankName: event.value,
      clearBankNameError: true,
    ));
  }

  void _onAccountNoChanged(
    VendorAccountNoChanged event,
    Emitter<VendorCompanyDetailsState> emit,
  ) {
    final error = _validateAccountNo(event.value);
    emit(state.copyWith(
      accountNo: event.value,
      accountNoError: error,
      clearAccountNoError: error == null,
    ));
  }

  void _onIfscCodeChanged(
    VendorIfscCodeChanged event,
    Emitter<VendorCompanyDetailsState> emit,
  ) {
    final error = _validateRequired(event.value, StringConstant.ifscCodeRequired);
    emit(state.copyWith(
      ifscCode: event.value,
      ifscCodeError: error,
      clearIfscCodeError: error == null,
    ));
  }

  void _onAttachQrChanged(
    VendorAttachQrChanged event,
    Emitter<VendorCompanyDetailsState> emit,
  ) {
    emit(state.copyWith(
      attachQr: event.attachment,
      clearAttachQr: event.attachment == null,
      clearAttachQrError: event.attachment != null,
    ));
  }

  void _onAttachVisitingCardChanged(
    VendorAttachVisitingCardChanged event,
    Emitter<VendorCompanyDetailsState> emit,
  ) {
    emit(state.copyWith(
      attachVisitingCard: event.attachment,
      clearAttachVisitingCard: event.attachment == null,
      clearAttachVisitingCardError: event.attachment != null,
    ));
  }

  void _onServiceRatingChanged(
    VendorServiceRatingChanged event,
    Emitter<VendorCompanyDetailsState> emit,
  ) {
    emit(state.copyWith(
      serviceRating: event.value,
      clearServiceRatingError: true,
    ));
  }

  void _onServicePricingChanged(
    VendorServicePricingChanged event,
    Emitter<VendorCompanyDetailsState> emit,
  ) {
    emit(state.copyWith(
      servicePricing: event.value,
      clearServicePricingError: true,
    ));
  }

  void _onNoteChanged(
    VendorNoteChanged event,
    Emitter<VendorCompanyDetailsState> emit,
  ) {
    final error = _validateRequired(event.value, StringConstant.noteRequired);
    emit(state.copyWith(
      note: event.value,
      noteError: error,
      clearNoteError: error == null,
    ));
  }

  Future<void> _onSubmit(
    SubmitVendorCompanyDetails event,
    Emitter<VendorCompanyDetailsState> emit,
  ) async {
    if (state.isSubmitting) return;

    final errors = _validateAll();
    final hasErrors = errors.values.any((e) => e != null);
    if (hasErrors) {
      emit(state.copyWith(
        companyNameError: errors[VendorCompanyField.companyName],
        companyAddressError: errors[VendorCompanyField.companyAddress],
        gstNoError: errors[VendorCompanyField.gstNo],
        panCardError: errors[VendorCompanyField.panCard],
        bankNameError: errors[VendorCompanyField.bankName],
        accountNoError: errors[VendorCompanyField.accountNo],
        ifscCodeError: errors[VendorCompanyField.ifscCode],
        attachQrError: errors[VendorCompanyField.attachQr],
        attachVisitingCardError: errors[VendorCompanyField.attachVisitingCard],
        serviceRatingError: errors[VendorCompanyField.serviceRating],
        servicePricingError: errors[VendorCompanyField.servicePricing],
        noteError: errors[VendorCompanyField.note],
        showValidationMessages: true,
        status: VendorCompanySubmissionStatus.idle,
        errorMessage: null,
        successMessage: null,
      ));
      return;
    }

    emit(state.copyWith(
      status: VendorCompanySubmissionStatus.submitting,
      errorMessage: null,
      successMessage: null,
    ));

    try {
      // TODO: Replace with the real vendor-create API when available.
      await Future.delayed(const Duration(seconds: 2));
      emit(state.copyWith(
        status: VendorCompanySubmissionStatus.success,
        successMessage: StringConstant.vendorSubmittedSuccessfully,
        errorMessage: null,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: VendorCompanySubmissionStatus.failure,
        errorMessage: StringConstant.vendorSubmissionFailed,
        successMessage: null,
      ));
    }
  }

  void _onReset(
    ResetVendorCompanyDetailsForm event,
    Emitter<VendorCompanyDetailsState> emit,
  ) {
    emit(const VendorCompanyDetailsState());
  }

  // ========== Validation ==========

  Map<VendorCompanyField, String?> _validateAll() {
    return {
      VendorCompanyField.companyName:
          _validateRequired(state.companyName, StringConstant.companyNameRequired),
      VendorCompanyField.companyAddress: _validateRequired(
          state.companyAddress, StringConstant.companyAddressRequired),
      VendorCompanyField.gstNo:
          _validateRequired(state.gstNo, StringConstant.gstNoRequired),
      VendorCompanyField.panCard:
          _validateRequired(state.panCard, StringConstant.panCardRequired),
      VendorCompanyField.bankName:
          state.bankName == null ? StringConstant.bankNameRequired : null,
      VendorCompanyField.accountNo: _validateAccountNo(state.accountNo),
      VendorCompanyField.ifscCode:
          _validateRequired(state.ifscCode, StringConstant.ifscCodeRequired),
      VendorCompanyField.attachQr:
          state.attachQr == null ? StringConstant.attachQrRequired : null,
      VendorCompanyField.attachVisitingCard: state.attachVisitingCard == null
          ? StringConstant.attachVisitingCardRequired
          : null,
      VendorCompanyField.serviceRating: state.serviceRating == null
          ? StringConstant.serviceRatingRequired
          : null,
      VendorCompanyField.servicePricing: state.servicePricing == null
          ? StringConstant.servicePricingRequired
          : null,
      VendorCompanyField.note:
          _validateRequired(state.note, StringConstant.noteRequired),
    };
  }

  String? _validateRequired(String value, String message) {
    if (value.trim().isEmpty) return message;
    return null;
  }

  String? _validateAccountNo(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return StringConstant.accountNoRequired;
    if (!RegExp(r'^[0-9]+$').hasMatch(trimmed)) {
      return StringConstant.accountNoDigitsOnly;
    }
    return null;
  }
}
