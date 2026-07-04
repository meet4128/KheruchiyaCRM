import 'package:equatable/equatable.dart';

import '../models/bank_name.dart';
import '../models/service_pricing.dart';
import '../models/service_rating.dart';
import '../models/vendor_attachment.dart';

/// Vendor company details field enum for validation.
enum VendorCompanyField {
  companyName,
  companyAddress,
  gstNo,
  panCard,
  bankName,
  accountNo,
  ifscCode,
  attachQr,
  attachVisitingCard,
  serviceRating,
  servicePricing,
  note,
}

/// Base class for all vendor company details events.
abstract class VendorCompanyDetailsEvent extends Equatable {
  const VendorCompanyDetailsEvent();

  @override
  List<Object?> get props => [];
}

class VendorCompanyNameChanged extends VendorCompanyDetailsEvent {
  const VendorCompanyNameChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

class VendorCompanyAddressChanged extends VendorCompanyDetailsEvent {
  const VendorCompanyAddressChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

class VendorGstNoChanged extends VendorCompanyDetailsEvent {
  const VendorGstNoChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

class VendorPanCardChanged extends VendorCompanyDetailsEvent {
  const VendorPanCardChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

class VendorBankNameChanged extends VendorCompanyDetailsEvent {
  const VendorBankNameChanged(this.value);
  final BankName value;
  @override
  List<Object?> get props => [value];
}

class VendorAccountNoChanged extends VendorCompanyDetailsEvent {
  const VendorAccountNoChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

class VendorIfscCodeChanged extends VendorCompanyDetailsEvent {
  const VendorIfscCodeChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

/// Set the QR attachment (non-null when picked) or clear it (null on remove).
class VendorAttachQrChanged extends VendorCompanyDetailsEvent {
  const VendorAttachQrChanged(this.attachment);
  final VendorAttachment? attachment;
  @override
  List<Object?> get props => [attachment];
}

/// Set the visiting card attachment (non-null when picked) or clear it.
class VendorAttachVisitingCardChanged extends VendorCompanyDetailsEvent {
  const VendorAttachVisitingCardChanged(this.attachment);
  final VendorAttachment? attachment;
  @override
  List<Object?> get props => [attachment];
}

class VendorServiceRatingChanged extends VendorCompanyDetailsEvent {
  const VendorServiceRatingChanged(this.value);
  final ServiceRating value;
  @override
  List<Object?> get props => [value];
}

class VendorServicePricingChanged extends VendorCompanyDetailsEvent {
  const VendorServicePricingChanged(this.value);
  final ServicePricing value;
  @override
  List<Object?> get props => [value];
}

class VendorNoteChanged extends VendorCompanyDetailsEvent {
  const VendorNoteChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

/// Fired when the user taps SUBMIT. Validates all fields and, when valid,
/// simulates submission.
class SubmitVendorCompanyDetails extends VendorCompanyDetailsEvent {
  const SubmitVendorCompanyDetails();
}

/// Clears the form (e.g. after a successful submission).
class ResetVendorCompanyDetailsForm extends VendorCompanyDetailsEvent {
  const ResetVendorCompanyDetailsForm();
}
