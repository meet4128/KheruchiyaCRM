import 'package:equatable/equatable.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/vendor_inquiry_row.dart';

class MessagesRouteArgs extends Equatable {
  const MessagesRouteArgs({
    this.inquiryId,
    this.inquiryDisplayNo,
    this.returnToPath,
    this.returnToLabel,
    this.returnVendorRow,
  });

  final String? inquiryId;
  final String? inquiryDisplayNo;
  final String? returnToPath;
  final String? returnToLabel;
  final VendorInquiryRow? returnVendorRow;

  bool get hasInquiry => inquiryId != null && inquiryId!.isNotEmpty;
  bool get canReturnToInquiry =>
      returnToPath != null && returnToPath!.isNotEmpty;

  @override
  List<Object?> get props => [
        inquiryId,
        inquiryDisplayNo,
        returnToPath,
        returnToLabel,
        returnVendorRow,
      ];
}
