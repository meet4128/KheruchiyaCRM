import 'package:equatable/equatable.dart';

import 'add_member_state.dart';

abstract class AddMemberEvent extends Equatable {
  const AddMemberEvent();

  @override
  List<Object?> get props => [];
}

class AddMemberDialogOpened extends AddMemberEvent {
  const AddMemberDialogOpened();
}

class AddMemberDialogClosed extends AddMemberEvent {
  const AddMemberDialogClosed();
}

class AddMemberFullNameChanged extends AddMemberEvent {
  const AddMemberFullNameChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class AddMemberPersonalEmailChanged extends AddMemberEvent {
  const AddMemberPersonalEmailChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class AddMemberPhoneChanged extends AddMemberEvent {
  const AddMemberPhoneChanged({
    required this.dialCode,
    required this.number,
  });

  final String dialCode;
  final String number;

  @override
  List<Object?> get props => [dialCode, number];
}

class AddMemberHomePhoneChanged extends AddMemberEvent {
  const AddMemberHomePhoneChanged({
    required this.dialCode,
    required this.number,
  });

  final String dialCode;
  final String number;

  @override
  List<Object?> get props => [dialCode, number];
}

class AddMemberDobChanged extends AddMemberEvent {
  const AddMemberDobChanged(this.value);

  final DateTime value;

  @override
  List<Object?> get props => [value];
}

class AddMemberGenderChanged extends AddMemberEvent {
  const AddMemberGenderChanged(this.value);

  final AddMemberGender value;

  @override
  List<Object?> get props => [value];
}

class AddMemberMaritalStatusChanged extends AddMemberEvent {
  const AddMemberMaritalStatusChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class AddMemberAnniversaryChanged extends AddMemberEvent {
  const AddMemberAnniversaryChanged(this.value);

  final DateTime value;

  @override
  List<Object?> get props => [value];
}

class AddMemberAddressChanged extends AddMemberEvent {
  const AddMemberAddressChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class AddMemberAddressLine2Changed extends AddMemberEvent {
  const AddMemberAddressLine2Changed(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class AddMemberZipCodeChanged extends AddMemberEvent {
  const AddMemberZipCodeChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class AddMemberCityChanged extends AddMemberEvent {
  const AddMemberCityChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class AddMemberNextPressed extends AddMemberEvent {
  const AddMemberNextPressed();
}
