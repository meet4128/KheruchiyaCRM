import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/widgets/app_text_field.dart';

import 'add_member_event.dart';
import 'add_member_state.dart';

class AddMemberBloc extends Bloc<AddMemberEvent, AddMemberState> {
  AddMemberBloc() : super(const AddMemberState()) {
    on<AddMemberDialogOpened>(_onDialogOpened);
    on<AddMemberDialogClosed>(_onDialogClosed);
    on<AddMemberFullNameChanged>(_onFullNameChanged);
    on<AddMemberPersonalEmailChanged>(_onPersonalEmailChanged);
    on<AddMemberPhoneChanged>(_onPhoneChanged);
    on<AddMemberHomePhoneChanged>(_onHomePhoneChanged);
    on<AddMemberDobChanged>(_onDobChanged);
    on<AddMemberGenderChanged>(_onGenderChanged);
    on<AddMemberMaritalStatusChanged>(_onMaritalStatusChanged);
    on<AddMemberAnniversaryChanged>(_onAnniversaryChanged);
    on<AddMemberAddressChanged>(_onAddressChanged);
    on<AddMemberAddressLine2Changed>(_onAddressLine2Changed);
    on<AddMemberZipCodeChanged>(_onZipCodeChanged);
    on<AddMemberCityChanged>(_onCityChanged);
    on<AddMemberNextPressed>(_onNextPressed);
  }

  void _onDialogOpened(AddMemberDialogOpened event, Emitter<AddMemberState> emit) {
    emit(const AddMemberState());
  }

  void _onDialogClosed(AddMemberDialogClosed event, Emitter<AddMemberState> emit) {
    emit(state.copyWith(status: AddMemberSubmitStatus.initial, clearFieldErrors: true));
  }

  void _onFullNameChanged(AddMemberFullNameChanged event, Emitter<AddMemberState> emit) {
    emit(
      state.copyWith(
        fullName: event.value,
        fullNameError: null,
        status: AddMemberSubmitStatus.initial,
      ),
    );
  }

  void _onPersonalEmailChanged(
    AddMemberPersonalEmailChanged event,
    Emitter<AddMemberState> emit,
  ) {
    emit(
      state.copyWith(
        personalEmail: event.value,
        personalEmailError: null,
        status: AddMemberSubmitStatus.initial,
      ),
    );
  }

  void _onPhoneChanged(AddMemberPhoneChanged event, Emitter<AddMemberState> emit) {
    emit(
      state.copyWith(
        phoneDialCode: event.dialCode,
        phoneNumber: event.number,
        phoneNumberError: null,
        status: AddMemberSubmitStatus.initial,
      ),
    );
  }

  void _onHomePhoneChanged(AddMemberHomePhoneChanged event, Emitter<AddMemberState> emit) {
    emit(
      state.copyWith(
        homePhoneDialCode: event.dialCode,
        homePhoneNumber: event.number,
        homePhoneNumberError: null,
        status: AddMemberSubmitStatus.initial,
      ),
    );
  }

  void _onDobChanged(AddMemberDobChanged event, Emitter<AddMemberState> emit) {
    emit(
      state.copyWith(
        dob: event.value,
        dobError: null,
        status: AddMemberSubmitStatus.initial,
      ),
    );
  }

  void _onGenderChanged(AddMemberGenderChanged event, Emitter<AddMemberState> emit) {
    emit(
      state.copyWith(
        gender: event.value,
        genderError: null,
        status: AddMemberSubmitStatus.initial,
      ),
    );
  }

  void _onMaritalStatusChanged(
    AddMemberMaritalStatusChanged event,
    Emitter<AddMemberState> emit,
  ) {
    emit(
      state.copyWith(
        maritalStatus: event.value,
        maritalStatusError: null,
        status: AddMemberSubmitStatus.initial,
      ),
    );
  }

  void _onAnniversaryChanged(AddMemberAnniversaryChanged event, Emitter<AddMemberState> emit) {
    emit(
      state.copyWith(
        anniversaryDate: event.value,
        status: AddMemberSubmitStatus.initial,
      ),
    );
  }

  void _onAddressChanged(AddMemberAddressChanged event, Emitter<AddMemberState> emit) {
    emit(
      state.copyWith(
        address: event.value,
        addressError: null,
        status: AddMemberSubmitStatus.initial,
      ),
    );
  }

  void _onAddressLine2Changed(
    AddMemberAddressLine2Changed event,
    Emitter<AddMemberState> emit,
  ) {
    emit(state.copyWith(addressLine2: event.value, status: AddMemberSubmitStatus.initial));
  }

  void _onZipCodeChanged(AddMemberZipCodeChanged event, Emitter<AddMemberState> emit) {
    emit(
      state.copyWith(
        zipCode: event.value,
        zipCodeError: null,
        status: AddMemberSubmitStatus.initial,
      ),
    );
  }

  void _onCityChanged(AddMemberCityChanged event, Emitter<AddMemberState> emit) {
    emit(
      state.copyWith(
        city: event.value,
        cityError: null,
        status: AddMemberSubmitStatus.initial,
      ),
    );
  }

  void _onNextPressed(AddMemberNextPressed event, Emitter<AddMemberState> emit) {
    final fullNameError = AppTextFieldValidators.required(state.fullName, message: 'Full name is required');
    final personalEmailError = AppTextFieldValidators.email(state.personalEmail);
    final phoneError = AppTextFieldValidators.phone(state.phoneNumber);
    final homePhoneError = AppTextFieldValidators.phone(state.homePhoneNumber);
    final dobError = state.dob == null ? 'Date of birth is required' : null;
    final genderError = state.gender == null ? 'Gender is required' : null;
    final maritalStatusError = AppTextFieldValidators.required(
      state.maritalStatus,
      message: 'Marital status is required',
    );
    final addressError = AppTextFieldValidators.required(state.address, message: 'Address is required');
    final zipError = AppTextFieldValidators.required(state.zipCode, message: 'Zip code is required');
    final cityError = AppTextFieldValidators.required(state.city, message: 'City is required');

    final hasError = [
      fullNameError,
      personalEmailError,
      phoneError,
      homePhoneError,
      dobError,
      genderError,
      maritalStatusError,
      addressError,
      zipError,
      cityError,
    ].any((e) => e != null);

    emit(
      state.copyWith(
        fullNameError: fullNameError,
        personalEmailError: personalEmailError,
        phoneNumberError: phoneError,
        homePhoneNumberError: homePhoneError,
        dobError: dobError,
        genderError: genderError,
        maritalStatusError: maritalStatusError,
        addressError: addressError,
        zipCodeError: zipError,
        cityError: cityError,
        status: hasError ? AddMemberSubmitStatus.invalid : AddMemberSubmitStatus.success,
      ),
    );
  }
}
