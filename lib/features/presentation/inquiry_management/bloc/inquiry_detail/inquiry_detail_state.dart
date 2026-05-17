import 'package:equatable/equatable.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/amendment_card_ui.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/vendor_inquiry_row.dart';

enum InquiryDetailStatus { idle, loading, success, failure }

enum InquiryDetailFinalizeStatus { idle, submitting, success, failure }

class InquiryDetailState extends Equatable {
  const InquiryDetailState({
    this.inquiryId = '',
    this.status = InquiryDetailStatus.idle,
    this.errorMessage,
    this.vendorRow,
    this.peerPhoneE164 = '',
    this.amendments = const [],
    this.activeSessionId,
    this.finalizeStatus = InquiryDetailFinalizeStatus.idle,
    this.finalizeErrorMessage,
  });

  final String inquiryId;
  final InquiryDetailStatus status;
  final String? errorMessage;
  final VendorInquiryRow? vendorRow;
  final String peerPhoneE164;
  final List<AmendmentCardUi> amendments;
  final String? activeSessionId;
  final InquiryDetailFinalizeStatus finalizeStatus;
  final String? finalizeErrorMessage;

  bool get hasValidPeerPhone => peerPhoneE164.length >= 10;

  InquiryDetailState copyWith({
    String? inquiryId,
    InquiryDetailStatus? status,
    String? errorMessage,
    bool clearErrorMessage = false,
    VendorInquiryRow? vendorRow,
    String? peerPhoneE164,
    List<AmendmentCardUi>? amendments,
    String? activeSessionId,
    bool clearActiveSessionId = false,
    InquiryDetailFinalizeStatus? finalizeStatus,
    String? finalizeErrorMessage,
    bool clearFinalizeErrorMessage = false,
  }) {
    return InquiryDetailState(
      inquiryId: inquiryId ?? this.inquiryId,
      status: status ?? this.status,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      vendorRow: vendorRow ?? this.vendorRow,
      peerPhoneE164: peerPhoneE164 ?? this.peerPhoneE164,
      amendments: amendments ?? this.amendments,
      activeSessionId:
          clearActiveSessionId ? null : (activeSessionId ?? this.activeSessionId),
      finalizeStatus: finalizeStatus ?? this.finalizeStatus,
      finalizeErrorMessage: clearFinalizeErrorMessage
          ? null
          : (finalizeErrorMessage ?? this.finalizeErrorMessage),
    );
  }

  @override
  List<Object?> get props => [
        inquiryId,
        status,
        errorMessage,
        vendorRow,
        peerPhoneE164,
        amendments,
        activeSessionId,
        finalizeStatus,
        finalizeErrorMessage,
      ];
}
