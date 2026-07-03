import 'package:equatable/equatable.dart';

/// Booking type enum
enum BookingType {
  flight('Flight Booking'),
  hotel('Hotel Booking'),
  cruise('Cruise Booking'),
  tourPackage('Tour Package'),
  visa('Visa Assistance');

  const BookingType(this.label);
  final String label;
}

/// Type of client (inquiry form — separate from [BookingType] / type of booking).
enum ClientType {
  customer('Customer'),
  agent('Agent'),
  corporate('Corporate');

  const ClientType(this.label);
  final String label;
}

/// Inquiry field enum for validation
enum InquiryField {
  title,
  firstName,
  lastName,
  phoneNumber,
  email,
  address,
  bookingType,
  referenceName,
  referenceNumber,
  clientBehaviour,
}

/// Base class for all Inquiry events
abstract class InquiryEvent extends Equatable {
  const InquiryEvent();

  @override
  List<Object?> get props => [];
}

/// Event fired when inquiry form is initialized
class InquiryInitialized extends InquiryEvent {
  const InquiryInitialized();

  @override
  List<Object> get props => [];
}

/// Event fired when title changes
class TitleChanged extends InquiryEvent {
  const TitleChanged(this.title);

  final String title;

  @override
  List<Object> get props => [title];
}

/// Event fired when first name changes
class FirstNameChanged extends InquiryEvent {
  const FirstNameChanged(this.firstName);

  final String firstName;

  @override
  List<Object> get props => [firstName];
}

/// Event fired when last name changes
class LastNameChanged extends InquiryEvent {
  const LastNameChanged(this.lastName);

  final String lastName;

  @override
  List<Object> get props => [lastName];
}

/// Event fired when phone number changes
class PhoneChanged extends InquiryEvent {
  const PhoneChanged(this.phone);

  final String phone;

  @override
  List<Object> get props => [phone];
}

/// Event fired when email changes
class EmailChanged extends InquiryEvent {
  const EmailChanged(this.email);

  final String email;

  @override
  List<Object> get props => [email];
}

/// Event fired when address changes
class AddressChanged extends InquiryEvent {
  const AddressChanged(this.address);

  final String address;

  @override
  List<Object> get props => [address];
}

/// Event fired when booking type changes (typeOfBooking field)
class BookingTypeChanged extends InquiryEvent {
  const BookingTypeChanged(this.bookingType);

  final BookingType bookingType;

  @override
  List<Object> get props => [bookingType];
}

/// Event fired when type of client changes (typeOfClient field — independent from typeOfBooking)
class TypeOfClientChanged extends InquiryEvent {
  const TypeOfClientChanged(this.typeOfClient);

  final ClientType typeOfClient;

  @override
  List<Object> get props => [typeOfClient];
}

/// Event fired when reference name changes
class ReferenceNameChanged extends InquiryEvent {
  const ReferenceNameChanged(this.referenceName);

  final String referenceName;

  @override
  List<Object> get props => [referenceName];
}

/// Event fired when reference number changes
class ReferenceNumberChanged extends InquiryEvent {
  const ReferenceNumberChanged(this.referenceNumber);

  final String referenceNumber;

  @override
  List<Object> get props => [referenceNumber];
}

/// Event fired when phone dial code changes
class PhoneDialCodeChanged extends InquiryEvent {
  const PhoneDialCodeChanged(this.dialCode);

  final String dialCode;

  @override
  List<Object> get props => [dialCode];
}

/// Event fired when reference dial code changes
class ReferenceDialCodeChanged extends InquiryEvent {
  const ReferenceDialCodeChanged(this.dialCode);

  final String dialCode;

  @override
  List<Object> get props => [dialCode];
}

/// Event fired when client behaviour changes
class ClientBehaviourChanged extends InquiryEvent {
  const ClientBehaviourChanged(this.clientBehaviour);

  final String clientBehaviour;

  @override
  List<Object> get props => [clientBehaviour];
}

/// Event fired when inquiry form is submitted
class SubmitInquiry extends InquiryEvent {
  const SubmitInquiry();

  @override
  List<Object> get props => [];
}

/// Clears the inquiry draft after successful submission or when starting fresh.
class ResetInquiryForm extends InquiryEvent {
  const ResetInquiryForm();

  @override
  List<Object> get props => [];
}

// ========== Legacy Events (for backward compatibility) ==========

/// Legacy event for field changes (use specific events like TitleChanged instead)
class InquiryFieldChanged extends InquiryEvent {
  const InquiryFieldChanged({
    required this.field,
    required this.value,
  });

  final InquiryField field;
  final String value;

  @override
  List<Object> get props => [field, value];
}

/// Clears the pending-navigate flag after the listener has navigated to air ticket.
class ClearPendingNavigateToAirTicket extends InquiryEvent {
  const ClearPendingNavigateToAirTicket();

  @override
  List<Object> get props => [];
}

/// Clears the pending-navigate flag after the listener has navigated to hotel booking.
class ClearPendingNavigateToHotelBooking extends InquiryEvent {
  const ClearPendingNavigateToHotelBooking();

  @override
  List<Object> get props => [];
}

/// Legacy event for booking type changes (use BookingTypeChanged instead)
class InquiryBookingTypeChanged extends InquiryEvent {
  const InquiryBookingTypeChanged(this.bookingType);

  final BookingType bookingType;

  @override
  List<Object> get props => [bookingType];
}

/// Legacy event for dial code changes (use PhoneDialCodeChanged or ReferenceDialCodeChanged instead)
class InquiryPhoneDialCodeChanged extends InquiryEvent {
  const InquiryPhoneDialCodeChanged({
    required this.isReference,
    required this.dialCode,
  });

  final bool isReference;
  final String dialCode;

  @override
  List<Object> get props => [isReference, dialCode];
}

/// Legacy event for submit request (use SubmitInquiry instead)
class InquirySubmitRequested extends InquiryEvent {
  const InquirySubmitRequested();

  @override
  List<Object> get props => [];
}
