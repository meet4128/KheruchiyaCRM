import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/widgets/app_text_field.dart';
import 'package:travel_crm/data/repositories/members_repository.dart';

import '../data/add_member_request_mapper.dart';
import 'add_member_event.dart';
import 'add_member_state.dart';

class AddMemberBloc extends Bloc<AddMemberEvent, AddMemberState> {
  AddMemberBloc(this._membersRepository) : super(const AddMemberState()) {
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
    on<AddMemberBackPressed>(_onBackPressed);
    on<AddMemberFirstNameChanged>(_onFirstNameChanged);
    on<AddMemberLastNameChanged>(_onLastNameChanged);
    on<AddMemberEmployeeIdChanged>(_onEmployeeIdChanged);
    on<AddMemberDesignationChanged>(_onDesignationChanged);
    on<AddMemberEmploymentStatusChanged>(_onEmploymentStatusChanged);
    on<AddMemberDateOfJoiningChanged>(_onDateOfJoiningChanged);
    on<AddMemberRoleRowDepartmentChanged>(_onRoleRowDepartmentChanged);
    on<AddMemberRoleRowRoleChanged>(_onRoleRowRoleChanged);
    on<AddMemberRoleRowAdded>(_onRoleRowAdded);
    on<AddMemberRoleRowRemoved>(_onRoleRowRemoved);
    on<AddMemberOfficePhoneChanged>(_onOfficePhoneChanged);
    on<AddMemberAttachmentPicked>(_onAttachmentPicked);
    on<AddMemberAttachmentCleared>(_onAttachmentCleared);
    on<AddMemberSubmitPressed>(_onSubmitPressed);
  }

  final MembersRepository _membersRepository;

  void _onDialogOpened(AddMemberDialogOpened event, Emitter<AddMemberState> emit) {
    if (event.editingMemberId != null) {
      final name = (event.prefillFullName ?? '').trim();
      final parts = name.isEmpty ? <String>[] : name.split(RegExp(r'\s+'));
      final first = parts.isNotEmpty ? parts.first : '';
      final last = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      emit(
        AddMemberState(
          editingMemberId: event.editingMemberId,
          currentStep: AddMemberStep.operation,
          fullName: name,
          personalEmail: (event.prefillPersonalEmail ?? '').trim(),
          firstName: first,
          lastName: last,
        ),
      );
    } else {
      emit(const AddMemberState());
    }
  }

  void _onDialogClosed(AddMemberDialogClosed event, Emitter<AddMemberState> emit) {
    emit(const AddMemberState());
  }

  void _onBackPressed(AddMemberBackPressed event, Emitter<AddMemberState> emit) {
    emit(
      state.copyWith(
        currentStep: AddMemberStep.personal,
        status: AddMemberSubmitStatus.initial,
        clearFieldErrors: true,
      ),
    );
  }

  void _onFirstNameChanged(AddMemberFirstNameChanged event, Emitter<AddMemberState> emit) {
    emit(
      state.copyWith(
        firstName: event.value,
        firstNameError: null,
        status: AddMemberSubmitStatus.initial,
      ),
    );
  }

  void _onLastNameChanged(AddMemberLastNameChanged event, Emitter<AddMemberState> emit) {
    emit(
      state.copyWith(
        lastName: event.value,
        lastNameError: null,
        status: AddMemberSubmitStatus.initial,
      ),
    );
  }

  void _onEmployeeIdChanged(AddMemberEmployeeIdChanged event, Emitter<AddMemberState> emit) {
    emit(
      state.copyWith(
        employeeId: event.value,
        employeeIdError: null,
        status: AddMemberSubmitStatus.initial,
      ),
    );
  }

  void _onDesignationChanged(AddMemberDesignationChanged event, Emitter<AddMemberState> emit) {
    emit(
      state.copyWith(
        designation: event.value,
        designationError: null,
        status: AddMemberSubmitStatus.initial,
      ),
    );
  }

  void _onEmploymentStatusChanged(
    AddMemberEmploymentStatusChanged event,
    Emitter<AddMemberState> emit,
  ) {
    emit(
      state.copyWith(
        employmentStatus: event.value,
        employmentStatusError: null,
        status: AddMemberSubmitStatus.initial,
      ),
    );
  }

  void _onDateOfJoiningChanged(AddMemberDateOfJoiningChanged event, Emitter<AddMemberState> emit) {
    emit(
      state.copyWith(
        dateOfJoining: event.value,
        dateOfJoiningError: null,
        status: AddMemberSubmitStatus.initial,
      ),
    );
  }

  void _onRoleRowDepartmentChanged(
    AddMemberRoleRowDepartmentChanged event,
    Emitter<AddMemberState> emit,
  ) {
    final i = event.index;
    if (i < 0 || i >= state.roleRows.length) return;
    final rows = List<AddMemberRoleRow>.from(state.roleRows);
    rows[i] = rows[i].copyWith(department: event.value);
    emit(
      state.copyWith(
        roleRows: rows,
        roleRowsError: null,
        status: AddMemberSubmitStatus.initial,
      ),
    );
  }

  void _onRoleRowRoleChanged(AddMemberRoleRowRoleChanged event, Emitter<AddMemberState> emit) {
    final i = event.index;
    if (i < 0 || i >= state.roleRows.length) return;
    final rows = List<AddMemberRoleRow>.from(state.roleRows);
    rows[i] = rows[i].copyWith(role: event.value);
    emit(
      state.copyWith(
        roleRows: rows,
        roleRowsError: null,
        status: AddMemberSubmitStatus.initial,
      ),
    );
  }

  void _onRoleRowAdded(AddMemberRoleRowAdded event, Emitter<AddMemberState> emit) {
    emit(
      state.copyWith(
        roleRows: [...state.roleRows, const AddMemberRoleRow()],
        roleRowsError: null,
        status: AddMemberSubmitStatus.initial,
      ),
    );
  }

  void _onRoleRowRemoved(AddMemberRoleRowRemoved event, Emitter<AddMemberState> emit) {
    final i = event.index;
    if (i <= 0 || i >= state.roleRows.length) return;
    final rows = List<AddMemberRoleRow>.from(state.roleRows)..removeAt(i);
    emit(
      state.copyWith(
        roleRows: rows,
        roleRowsError: null,
        status: AddMemberSubmitStatus.initial,
      ),
    );
  }

  void _onOfficePhoneChanged(AddMemberOfficePhoneChanged event, Emitter<AddMemberState> emit) {
    emit(
      state.copyWith(
        officePhoneDialCode: event.dialCode,
        officePhoneNumber: event.number,
        officePhoneNumberError: null,
        status: AddMemberSubmitStatus.initial,
      ),
    );
  }

  void _onAttachmentPicked(AddMemberAttachmentPicked event, Emitter<AddMemberState> emit) {
    final file = AddMemberAttachment(fileName: event.fileName, path: event.path);
    switch (event.kind) {
      case AddMemberAttachmentKind.aadhar:
        emit(state.copyWith(aadharAttachment: file, status: AddMemberSubmitStatus.initial));
      case AddMemberAttachmentKind.pan:
        emit(state.copyWith(panAttachment: file, status: AddMemberSubmitStatus.initial));
      case AddMemberAttachmentKind.cancelCheque:
        emit(state.copyWith(cancelChequeAttachment: file, status: AddMemberSubmitStatus.initial));
    }
  }

  void _onAttachmentCleared(AddMemberAttachmentCleared event, Emitter<AddMemberState> emit) {
    switch (event.kind) {
      case AddMemberAttachmentKind.aadhar:
        emit(state.copyWith(clearAadharAttachment: true, status: AddMemberSubmitStatus.initial));
      case AddMemberAttachmentKind.pan:
        emit(state.copyWith(clearPanAttachment: true, status: AddMemberSubmitStatus.initial));
      case AddMemberAttachmentKind.cancelCheque:
        emit(state.copyWith(clearCancelChequeAttachment: true, status: AddMemberSubmitStatus.initial));
    }
  }

  Future<void> _onSubmitPressed(AddMemberSubmitPressed event, Emitter<AddMemberState> emit) async {
    final officePhoneError = AppTextFieldValidators.phone(state.officePhoneNumber);

    if (officePhoneError != null) {
      emit(
        state.copyWith(
          firstNameError: null,
          lastNameError: null,
          employeeIdError: null,
          designationError: null,
          employmentStatusError: null,
          dateOfJoiningError: null,
          roleRowsError: null,
          officePhoneNumberError: officePhoneError,
          status: AddMemberSubmitStatus.invalid,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AddMemberSubmitStatus.submitting,
        clearSubmitErrorMessage: true,
        firstNameError: null,
        lastNameError: null,
        employeeIdError: null,
        designationError: null,
        employmentStatusError: null,
        dateOfJoiningError: null,
        roleRowsError: null,
        officePhoneNumberError: null,
      ),
    );

    try {
      final editingId = state.editingMemberId;
      if (editingId != null) {
        await _membersRepository.updateMember(editingId, mapStateToUpdateRequest(state));
      } else {
        await _membersRepository.createMember(mapStateToCreateRequest(state));
      }
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AddMemberSubmitStatus.success,
          clearSubmitErrorMessage: true,
        ),
      );
    } on MembersValidationException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AddMemberSubmitStatus.failure,
          submitErrorMessage: e.message,
        ),
      );
    } on MembersUnauthorizedException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AddMemberSubmitStatus.failure,
          submitErrorMessage: e.toString(),
        ),
      );
    } on MembersApiException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AddMemberSubmitStatus.failure,
          submitErrorMessage: e.message,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AddMemberSubmitStatus.failure,
          submitErrorMessage: e.toString(),
        ),
      );
    }
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
        firstNameError: hasError ? state.firstNameError : null,
        lastNameError: hasError ? state.lastNameError : null,
        employeeIdError: hasError ? state.employeeIdError : null,
        designationError: hasError ? state.designationError : null,
        employmentStatusError: hasError ? state.employmentStatusError : null,
        dateOfJoiningError: hasError ? state.dateOfJoiningError : null,
        roleRowsError: hasError ? state.roleRowsError : null,
        officePhoneNumberError: hasError ? state.officePhoneNumberError : null,
        status: hasError ? AddMemberSubmitStatus.invalid : AddMemberSubmitStatus.initial,
        currentStep: hasError ? null : AddMemberStep.operation,
      ),
    );
  }
}
