import 'package:equatable/equatable.dart';

enum AddMemberGender { male, female }

enum AddMemberSubmitStatus { initial, invalid, valid, submitting, success, failure }

class AddMemberState extends Equatable {
  const AddMemberState({
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
    this.status = AddMemberSubmitStatus.initial,
  });

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
  final AddMemberSubmitStatus status;

  AddMemberState copyWith({
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
    bool clearFieldErrors = false,
    AddMemberSubmitStatus? status,
  }) {
    return AddMemberState(
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
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
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
        status,
      ];
}
