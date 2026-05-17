// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_member_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateMemberRequest _$UpdateMemberRequestFromJson(Map<String, dynamic> json) =>
    UpdateMemberRequest(
      fullName: json['fullName'] as String?,
      personalEmail: json['personalEmail'] as String?,
      phoneNumber: json['phoneNumber'] == null
          ? null
          : PhoneNumberModel.fromJson(
              json['phoneNumber'] as Map<String, dynamic>,
            ),
      homePhoneNumber: json['homePhoneNumber'] == null
          ? null
          : PhoneNumberModel.fromJson(
              json['homePhoneNumber'] as Map<String, dynamic>,
            ),
      dateOfBirth: json['dateOfBirth'] as String?,
      gender: json['gender'] as String?,
      maritalStatus: json['maritalStatus'] as String?,
      dateOfAnniversary: json['dateOfAnniversary'] as String?,
      addressLine1: json['addressLine1'] as String?,
      addressLine2: json['addressLine2'] as String?,
      zipCode: json['zipCode'] as String?,
      city: json['city'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      employeeId: json['employeeId'] as String?,
      designation: json['designation'] as String?,
      employmentStatus: json['employmentStatus'] as String?,
      dateOfJoining: json['dateOfJoining'] as String?,
      departmentRoles: (json['departmentRoles'] as List<dynamic>?)
          ?.map((e) => DepartmentRoleDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      officePhoneNumber: json['officePhoneNumber'] == null
          ? null
          : PhoneNumberModel.fromJson(
              json['officePhoneNumber'] as Map<String, dynamic>,
            ),
      aadharDocumentUrl: json['aadharDocumentUrl'] as String?,
      panDocumentUrl: json['panDocumentUrl'] as String?,
      cancelChequeDocumentUrl: json['cancelChequeDocumentUrl'] as String?,
    );

Map<String, dynamic> _$UpdateMemberRequestToJson(
  UpdateMemberRequest instance,
) => <String, dynamic>{
  'fullName': ?instance.fullName,
  'personalEmail': ?instance.personalEmail,
  'phoneNumber': ?instance.phoneNumber?.toJson(),
  'homePhoneNumber': ?instance.homePhoneNumber?.toJson(),
  'dateOfBirth': ?instance.dateOfBirth,
  'gender': ?instance.gender,
  'maritalStatus': ?instance.maritalStatus,
  'dateOfAnniversary': ?instance.dateOfAnniversary,
  'addressLine1': ?instance.addressLine1,
  'addressLine2': ?instance.addressLine2,
  'zipCode': ?instance.zipCode,
  'city': ?instance.city,
  'firstName': ?instance.firstName,
  'lastName': ?instance.lastName,
  'employeeId': ?instance.employeeId,
  'designation': ?instance.designation,
  'employmentStatus': ?instance.employmentStatus,
  'dateOfJoining': ?instance.dateOfJoining,
  'departmentRoles': ?instance.departmentRoles?.map((e) => e.toJson()).toList(),
  'officePhoneNumber': ?instance.officePhoneNumber?.toJson(),
  'aadharDocumentUrl': ?instance.aadharDocumentUrl,
  'panDocumentUrl': ?instance.panDocumentUrl,
  'cancelChequeDocumentUrl': ?instance.cancelChequeDocumentUrl,
};
