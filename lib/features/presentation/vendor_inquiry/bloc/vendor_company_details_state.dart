import 'package:equatable/equatable.dart';

import '../models/bank_name.dart';
import '../models/service_pricing.dart';
import '../models/service_rating.dart';
import '../models/vendor_attachment.dart';
import 'vendor_company_details_event.dart';

/// Submission status for the vendor company details form.
enum VendorCompanySubmissionStatus { idle, submitting, success, failure }

/// State for the Vendor Company Details (Step 2) form.
/// All validation lives in the BLoC; the UI reads errors from here.
class VendorCompanyDetailsState extends Equatable {
  const VendorCompanyDetailsState({
    this.companyName = '',
    this.companyAddress = '',
    this.gstNo = '',
    this.panCard = '',
    this.bankName,
    this.accountNo = '',
    this.ifscCode = '',
    this.attachQr,
    this.attachVisitingCard,
    this.serviceRating,
    this.servicePricing,
    this.note = '',
    this.companyNameError,
    this.companyAddressError,
    this.gstNoError,
    this.panCardError,
    this.bankNameError,
    this.accountNoError,
    this.ifscCodeError,
    this.attachQrError,
    this.attachVisitingCardError,
    this.serviceRatingError,
    this.servicePricingError,
    this.noteError,
    this.showValidationMessages = false,
    this.status = VendorCompanySubmissionStatus.idle,
    this.successMessage,
    this.errorMessage,
  });

  // Form fields
  final String companyName;
  final String companyAddress;
  final String gstNo;
  final String panCard;
  final BankName? bankName;
  final String accountNo;
  final String ifscCode;
  final VendorAttachment? attachQr;
  final VendorAttachment? attachVisitingCard;
  final ServiceRating? serviceRating;
  final ServicePricing? servicePricing;
  final String note;

  // Validation errors
  final String? companyNameError;
  final String? companyAddressError;
  final String? gstNoError;
  final String? panCardError;
  final String? bankNameError;
  final String? accountNoError;
  final String? ifscCodeError;
  final String? attachQrError;
  final String? attachVisitingCardError;
  final String? serviceRatingError;
  final String? servicePricingError;
  final String? noteError;

  // UI state
  final bool showValidationMessages;
  final VendorCompanySubmissionStatus status;
  final String? successMessage;
  final String? errorMessage;

  bool get isSubmitting => status == VendorCompanySubmissionStatus.submitting;

  Map<VendorCompanyField, String?> get fieldErrors => {
        VendorCompanyField.companyName: companyNameError,
        VendorCompanyField.companyAddress: companyAddressError,
        VendorCompanyField.gstNo: gstNoError,
        VendorCompanyField.panCard: panCardError,
        VendorCompanyField.bankName: bankNameError,
        VendorCompanyField.accountNo: accountNoError,
        VendorCompanyField.ifscCode: ifscCodeError,
        VendorCompanyField.attachQr: attachQrError,
        VendorCompanyField.attachVisitingCard: attachVisitingCardError,
        VendorCompanyField.serviceRating: serviceRatingError,
        VendorCompanyField.servicePricing: servicePricingError,
        VendorCompanyField.note: noteError,
      };

  VendorCompanyDetailsState copyWith({
    String? companyName,
    String? companyAddress,
    String? gstNo,
    String? panCard,
    BankName? bankName,
    String? accountNo,
    String? ifscCode,
    VendorAttachment? attachQr,
    VendorAttachment? attachVisitingCard,
    ServiceRating? serviceRating,
    ServicePricing? servicePricing,
    String? note,
    String? companyNameError,
    String? companyAddressError,
    String? gstNoError,
    String? panCardError,
    String? bankNameError,
    String? accountNoError,
    String? ifscCodeError,
    String? attachQrError,
    String? attachVisitingCardError,
    String? serviceRatingError,
    String? servicePricingError,
    String? noteError,
    bool? showValidationMessages,
    VendorCompanySubmissionStatus? status,
    String? successMessage,
    String? errorMessage,
    bool clearCompanyNameError = false,
    bool clearCompanyAddressError = false,
    bool clearGstNoError = false,
    bool clearPanCardError = false,
    bool clearBankNameError = false,
    bool clearAccountNoError = false,
    bool clearIfscCodeError = false,
    bool clearAttachQrError = false,
    bool clearAttachVisitingCardError = false,
    bool clearServiceRatingError = false,
    bool clearServicePricingError = false,
    bool clearNoteError = false,
    // Attachments are nullable fields, so clearing needs explicit flags.
    bool clearAttachQr = false,
    bool clearAttachVisitingCard = false,
  }) {
    return VendorCompanyDetailsState(
      companyName: companyName ?? this.companyName,
      companyAddress: companyAddress ?? this.companyAddress,
      gstNo: gstNo ?? this.gstNo,
      panCard: panCard ?? this.panCard,
      bankName: bankName ?? this.bankName,
      accountNo: accountNo ?? this.accountNo,
      ifscCode: ifscCode ?? this.ifscCode,
      attachQr: clearAttachQr ? null : (attachQr ?? this.attachQr),
      attachVisitingCard: clearAttachVisitingCard
          ? null
          : (attachVisitingCard ?? this.attachVisitingCard),
      serviceRating: serviceRating ?? this.serviceRating,
      servicePricing: servicePricing ?? this.servicePricing,
      note: note ?? this.note,
      companyNameError: clearCompanyNameError
          ? null
          : (companyNameError ??
              (companyName != null ? null : this.companyNameError)),
      companyAddressError: clearCompanyAddressError
          ? null
          : (companyAddressError ??
              (companyAddress != null ? null : this.companyAddressError)),
      gstNoError: clearGstNoError
          ? null
          : (gstNoError ?? (gstNo != null ? null : this.gstNoError)),
      panCardError: clearPanCardError
          ? null
          : (panCardError ?? (panCard != null ? null : this.panCardError)),
      bankNameError: clearBankNameError
          ? null
          : (bankNameError ?? (bankName != null ? null : this.bankNameError)),
      accountNoError: clearAccountNoError
          ? null
          : (accountNoError ??
              (accountNo != null ? null : this.accountNoError)),
      ifscCodeError: clearIfscCodeError
          ? null
          : (ifscCodeError ?? (ifscCode != null ? null : this.ifscCodeError)),
      attachQrError: clearAttachQrError
          ? null
          : (attachQrError ?? this.attachQrError),
      attachVisitingCardError: clearAttachVisitingCardError
          ? null
          : (attachVisitingCardError ?? this.attachVisitingCardError),
      serviceRatingError: clearServiceRatingError
          ? null
          : (serviceRatingError ??
              (serviceRating != null ? null : this.serviceRatingError)),
      servicePricingError: clearServicePricingError
          ? null
          : (servicePricingError ??
              (servicePricing != null ? null : this.servicePricingError)),
      noteError: clearNoteError
          ? null
          : (noteError ?? (note != null ? null : this.noteError)),
      showValidationMessages:
          showValidationMessages ?? this.showValidationMessages,
      status: status ?? this.status,
      successMessage: successMessage ?? this.successMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
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
        companyNameError,
        companyAddressError,
        gstNoError,
        panCardError,
        bankNameError,
        accountNoError,
        ifscCodeError,
        attachQrError,
        attachVisitingCardError,
        serviceRatingError,
        servicePricingError,
        noteError,
        showValidationMessages,
        status,
        successMessage,
        errorMessage,
      ];
}
