import 'package:equatable/equatable.dart';

/// Vendor inquiry field enum for validation.
enum VendorInquiryField {
  fullName,
  phoneNumber,
  email,
  designation,
  specializeIn,
  subSpecializeIn,
  address,
}

/// Base class for all vendor inquiry events.
abstract class VendorInquiryEvent extends Equatable {
  const VendorInquiryEvent();

  @override
  List<Object?> get props => [];
}

/// Fired when the vendor form is initialized / reset.
class VendorInquiryInitialized extends VendorInquiryEvent {
  const VendorInquiryInitialized();
}

/// Clears the Step 1 draft (e.g. after moving on / starting fresh).
class ResetVendorInquiryForm extends VendorInquiryEvent {
  const ResetVendorInquiryForm();
}

class VendorFullNameChanged extends VendorInquiryEvent {
  const VendorFullNameChanged(this.fullName);

  final String fullName;

  @override
  List<Object?> get props => [fullName];
}

class VendorPhoneChanged extends VendorInquiryEvent {
  const VendorPhoneChanged(this.phone);

  final String phone;

  @override
  List<Object?> get props => [phone];
}

class VendorPhoneDialCodeChanged extends VendorInquiryEvent {
  const VendorPhoneDialCodeChanged(this.dialCode);

  final String dialCode;

  @override
  List<Object?> get props => [dialCode];
}

class VendorEmailChanged extends VendorInquiryEvent {
  const VendorEmailChanged(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

class VendorDesignationChanged extends VendorInquiryEvent {
  const VendorDesignationChanged(this.designation);

  final String designation;

  @override
  List<Object?> get props => [designation];
}

class VendorSpecializeInChanged extends VendorInquiryEvent {
  const VendorSpecializeInChanged(this.specializeIn);

  final String specializeIn;

  @override
  List<Object?> get props => [specializeIn];
}

class VendorSubSpecializeInChanged extends VendorInquiryEvent {
  const VendorSubSpecializeInChanged(this.subSpecializeIn);

  final String subSpecializeIn;

  @override
  List<Object?> get props => [subSpecializeIn];
}

class VendorAddressChanged extends VendorInquiryEvent {
  const VendorAddressChanged(this.address);

  final String address;

  @override
  List<Object?> get props => [address];
}

/// Fired when the user taps NEXT. Validates Step 1 and, when valid, flags the
/// state so the view navigates to Step 2 (Company Details).
class VendorNextPressed extends VendorInquiryEvent {
  const VendorNextPressed();
}

/// Clears the pending-navigate flag after the listener has navigated to Step 2.
class ClearPendingNavigateToStep2 extends VendorInquiryEvent {
  const ClearPendingNavigateToStep2();
}
